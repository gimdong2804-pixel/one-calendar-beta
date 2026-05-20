import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui'; // DartPluginRegistrant 사용을 위해 필수

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'update_service.dart';

/// iOS 백그라운드 트리거 시 실행 (iOS는 1분 주기가 허용되지 않아 백그라운드 fetch 작동 시 실행)
@pragma('vm:entry-point')
Future<bool> onStartBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized(); // 백그라운드 Isolate 내 플러그인 바인딩 강제 활성화
  await _performUpdateCheckFlow(null);
  return true;
}

/// 백그라운드 Isolate 진입점 (실제 1분 주기 타이머 구동)
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized(); // 백그라운드 Isolate 내 플러그인 바인딩 강제 활성화

  // 백그라운드 Isolate 영역에서 알림 플러그인 초기화 처리
  try {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await BackgroundUpdateService.notificationsPlugin.initialize(initSettings);
  } catch (e) {
    debugPrint('[백그라운드 서비스] 알림 플러그인 독립 초기화 에러: $e');
  }

  // 포그라운드 서비스 알림 채널 연동
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // 1분 간격 주기적인 업데이트 확인 타이머 설정
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    await _performUpdateCheckFlow(service);
  });
}

/// 실제 업데이트 체크 프로세스 비즈니스 로직 (탑레벨 함수로 추출)
Future<void> _performUpdateCheckFlow(ServiceInstance? service) async {
  try {
    debugPrint('[백그라운드 서비스] 1분 업데이트 체크 타이머 시작');

    // 1. 인터넷 연결 유무 파악 (없으면 즉시 중단하여 불필요 리소스 제거)
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      debugPrint('[백그라운드 서비스] 인터넷 연결 없음. 조회를 스킵합니다.');
      return;
    }

    // 2. 서버 업데이트 JSON 파싱 조회
    final info = await UpdateService.checkForUpdate();
    if (info == null) {
      debugPrint('[백그라운드 서비스] 업데이트 정보 로드 실패 또는 데이터 없음.');
      return;
    }

    debugPrint('[백그라운드 서비스] 조회 완료: 최신 빌드(${info.latestBuildNumber}), 현재 빌드($currentBuildNumber)');

    // 포그라운드 고정 알림 텍스트 갱신 (사용자가 확인 중임을 명시적으로 인지할 수 있도록 서포트)
    if (service is AndroidServiceInstance) {
      final now = DateTime.now();
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      service.setForegroundNotificationInfo(
        title: 'One Calendar 업데이트 모니터링',
        content: '마지막 확인 시간: $timeStr (최신 버전 상태)',
      );
    }

    // 3. 신규 업데이트 감지
    if (info.hasUpdate) {
      final prefs = await SharedPreferences.getInstance();
      final lastNotifiedBuild = prefs.getInt('last_notified_build') ?? 0;

      // 동일 버전에 대해 중복 알림이 발생하지 않도록 제어
      if (info.latestBuildNumber > lastNotifiedBuild) {
        debugPrint('[백그라운드 서비스] 새로운 업데이트 발견! 알림을 발송합니다.');

        // 상주 알림 텍스트 갱신
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: '새로운 업데이트 발견!',
            content: '업데이트 가능한 최신 버전이 대기 중입니다.',
          );
        }

        // 네이티브 푸시 알림 발송
        await _showUpdatePushNotification(info);

        // 알림 발송된 빌드 번호를 저장하여 중복 발송 차단
        await prefs.setInt('last_notified_build', info.latestBuildNumber);
      } else {
        debugPrint('[백그라운드 서비스] 이미 감지되어 알림이 발송된 빌드 번호입니다. 알림을 생략합니다.');
      }
    }
  } catch (e) {
    debugPrint('[백그라운드 서비스] 프로세스 도중 예외 발생: $e');
  }
}

/// 네이티브 알림창에 클릭 가능한 푸시 알림 띄우기 (탑레벨 함수로 추출)
Future<void> _showUpdatePushNotification(UpdateInfo info) async {
  try {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await BackgroundUpdateService.notificationsPlugin.initialize(initSettings);
  } catch (e) {
    debugPrint('[백그라운드 서비스] 푸시 발송 전 알림 플러그인 강제 초기화 에러: $e');
  }

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    BackgroundUpdateService.notificationChannelId,
    '소프트웨어 업데이트 알림',
    channelDescription: '새로운 소프트웨어 업데이트 발견 시 알림을 전송합니다.',
    importance: Importance.max,
    priority: Priority.high,
    ticker: '새로운 소프트웨어 업데이트가 있습니다!',
    playSound: true,
    enableVibration: true,
    styleInformation: BigTextStyleInformation(''), // 긴 텍스트 체인지로그 대응
  );

  const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

  final String changelogSnippet = info.changelog.length > 80
      ? '${info.changelog.substring(0, 80)}...'
      : info.changelog;

  await BackgroundUpdateService.notificationsPlugin.show(
    999, // 업데이트 알림 고유 ID
    '새 업데이트: ${info.versionName}',
    '아래로 쓸어내려 상세 내역을 확인하고 업데이트를 다운로드하세요.\n\n[변경 사항]\n$changelogSnippet',
    platformDetails,
    payload: jsonEncode({
      'buildNumber': info.latestBuildNumber,
      'versionName': info.versionName,
      'downloadUrl': info.downloadUrl,
    }),
  );
}

/// 백그라운드에서 실시간 업데이트를 모니터링하고 알림을 전송하는 서비스 관리 클래스
class BackgroundUpdateService {
  static const String notificationChannelId = 'update_notification_channel';
  static const String foregroundChannelId = 'update_monitor_foreground_channel';
  
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 백그라운드 서비스 및 알림 플러그인 초기화 (메인 UI Isolate에서 실행)
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    // 1. Android 알림 채널 생성
    const AndroidNotificationChannel updateChannel = AndroidNotificationChannel(
      notificationChannelId,
      '소프트웨어 업데이트 알림',
      description: '새로운 소프트웨어 업데이트 발견 시 알림을 전송합니다.',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel foregroundChannel = AndroidNotificationChannel(
      foregroundChannelId,
      '실시간 업데이트 확인 서비스',
      description: '백그라운드에서 소프트웨어 업데이트를 감지하기 위해 실행 중인 상태를 표시합니다.',
      importance: Importance.low, // 무음 형태로 상주하도록 설정
    );

    // 알림 채널 등록
    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(updateChannel);

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(foregroundChannel);

    // 2. 알림 플러그인 초기화
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('알림 클릭됨: ${response.payload}');
      },
    );

    // 2.5 Android 13+ 알림 권한 요청
    if (Platform.isAndroid) {
      await notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    // 3. 백그라운드 서비스 설정
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: foregroundChannelId,
        initialNotificationTitle: 'One Calendar 업데이트 모니터링',
        initialNotificationContent: '실시간 업데이트 자동 확인이 작동 중입니다 (1분 주기).',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onStartBackground,
      ),
    );
  }
}
