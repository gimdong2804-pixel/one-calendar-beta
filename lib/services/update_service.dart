import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// 현재 앱의 빌드 번호 (pubspec.yaml의 +N 부분과 일치시켜야 함)
const int currentBuildNumber = 34;
const String currentVersionName = 'One UI 1.0 (Beta 34)';

/// GitHub raw URL에서 update_info.json 읽기
const String _updateInfoUrl =
    'https://raw.githubusercontent.com/gimdong2804-pixel/one-calendar-beta/main/update_info.json';

class UpdateInfo {
  final int latestBuildNumber;
  final String versionName;
  final String downloadUrl;
  final String changelog;

  const UpdateInfo({
    required this.latestBuildNumber,
    required this.versionName,
    required this.downloadUrl,
    required this.changelog,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      latestBuildNumber: json['latestBuildNumber'] as int,
      versionName: json['versionName'] as String,
      downloadUrl: json['downloadUrl'] as String,
      changelog: json['changelog'] as String? ?? '',
    );
  }

  bool get hasUpdate => latestBuildNumber > currentBuildNumber;
}

class UpdateService {
  /// 서버에서 최신 버전 정보 가져오기
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      
      // 캐시 방지를 위해 타임스탬프 쿼리 매개변수 추가 (GitHub CDN 및 로컬 디바이스 캐시 우회)
      final preventCacheUrl = '$_updateInfoUrl?t=${DateTime.now().millisecondsSinceEpoch}';
      final request = await client.getUrl(Uri.parse(preventCacheUrl));
      final response = await request.close().timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        return UpdateInfo.fromJson(json);
      }
      return null;
    } catch (e) {
      debugPrint('업데이트 확인 실패: $e');
      return null;
    }
  }

  /// 업데이트 확인 후 다이얼로그 표시
  static Future<void> checkAndShowDialog(BuildContext context) async {
    // SettingsModal이 닫히면서 context가 unmounted 되는 것을 방지하기 위해 최상단 Navigator의 context를 가져옵니다.
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    // 로딩 표시
    if (!rootContext.mounted) return;
    showDialog(
      context: rootContext,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('업데이트 확인 중...'),
          ],
        ),
      ),
    );

    final info = await checkForUpdate();

    if (!rootContext.mounted) return;
    Navigator.of(rootContext, rootNavigator: true).pop(); // 로딩 닫기

    if (info == null) {
      if (!rootContext.mounted) return;
      ScaffoldMessenger.of(rootContext)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('업데이트를 확인할 수 없습니다. 인터넷 연결을 확인해주세요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    if (!info.hasUpdate) {
      if (!rootContext.mounted) return;
      showDialog(
        context: rootContext,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text('최신 버전입니다'),
          content: Text('현재 버전: $currentVersionName'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(rootContext).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    // 업데이트 있음!
    if (!rootContext.mounted) return;
    showDialog(
      context: rootContext,
      builder: (_) => AlertDialog(
        icon: const Icon(
          Icons.system_update,
          color: Color(0xFF4F46E5),
          size: 48,
        ),
        title: const Text('새 업데이트가 있습니다!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _UpdateRow(label: '현재 버전', value: currentVersionName),
            const SizedBox(height: 8),
            _UpdateRow(label: '최신 버전', value: info.versionName),
            if (info.changelog.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                '변경 사항:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(info.changelog),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(rootContext).pop(),
            child: const Text('나중에'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(rootContext).pop();
              downloadAndInstall(
                rootContext,
                info.downloadUrl,
                info.versionName,
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('업데이트'),
          ),
        ],
      ),
    );
  }

  /// APK를 인앱으로 다운로드하고 자동으로 설치 화면을 띄움
  static Future<void> downloadAndInstall(
    BuildContext context,
    String url,
    String versionName,
  ) async {
    // 진행률 표시용 ValueNotifier
    final progress = ValueNotifier<double>(0.0);
    final statusText = ValueNotifier<String>('다운로드 준비 중...');

    final rootContext = Navigator.of(context, rootNavigator: true).context;
    if (!rootContext.mounted) return;

    // 다운로드 진행 다이얼로그
    showDialog(
      context: rootContext,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          icon: const Icon(
            Icons.downloading,
            color: Color(0xFF4F46E5),
            size: 40,
          ),
          title: const Text('업데이트 다운로드 중'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<double>(
                valueListenable: progress,
                builder: (_, value, _) => Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: value > 0 ? value : null,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${(value * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<String>(
                valueListenable: statusText,
                builder: (_, value, _) => Text(
                  value,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // 캐시 디렉토리에 APK 저장
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/OneCalendar-update.apk';

      // 기존 파일이 있으면 삭제
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      statusText.value = '서버에서 다운로드 중...';

      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            progress.value = received / total;
            final receivedMB = (received / 1024 / 1024).toStringAsFixed(1);
            final totalMB = (total / 1024 / 1024).toStringAsFixed(1);
            statusText.value = '$receivedMB MB / $totalMB MB';
          }
        },
      );

      // 다운로드 완료
      statusText.value = '설치 준비 중...';
      progress.value = 1.0;

      // 다이얼로그 닫기
      if (rootContext.mounted) {
        Navigator.of(rootContext, rootNavigator: true).pop();
      }

      // APK 설치 화면 열기
      final result = await OpenFilex.open(
        filePath,
        type: 'application/vnd.android.package-archive',
      );

      if (result.type != ResultType.done) {
        if (!rootContext.mounted) return;
        ScaffoldMessenger.of(rootContext)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text('설치를 열 수 없습니다: ${result.message}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } catch (e) {
      // 다이얼로그 닫기
      if (rootContext.mounted) {
        Navigator.of(rootContext, rootNavigator: true).pop();
      }

      if (!rootContext.mounted) return;
      ScaffoldMessenger.of(rootContext)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('다운로드 실패: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      progress.dispose();
      statusText.dispose();
    }
  }

  /// APK를 인앱으로 다운로드하고 진행률을 콜백으로 전달하며 완료 시 자동으로 설치 화면을 띄움
  static Future<void> downloadAndInstallWithCallback({
    required BuildContext context,
    required String url,
    required String versionName,
    required void Function(double progress, String statusText) onProgress,
    required void Function(String error) onError,
    required void Function() onComplete,
  }) async {
    try {
      // 캐시 디렉토리에 APK 저장
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/OneCalendar-update.apk';

      // 기존 파일이 있으면 삭제
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      onProgress(0.0, '다운로드 준비 중...');

      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final val = received / total;
            final receivedMB = (received / 1024 / 1024).toStringAsFixed(1);
            final totalMB = (total / 1024 / 1024).toStringAsFixed(1);
            onProgress(val, '$receivedMB MB / $totalMB MB');
          }
        },
      );

      // 다운로드 완료
      onProgress(1.0, '설치 준비 중...');
      onComplete();

      // APK 설치 화면 열기
      final result = await OpenFilex.open(
        filePath,
        type: 'application/vnd.android.package-archive',
      );

      if (result.type != ResultType.done) {
        onError('설치를 열 수 없습니다: ${result.message}');
      }
    } catch (e) {
      onError('다운로드 실패: $e');
    }
  }
}

class _UpdateRow extends StatelessWidget {
  const _UpdateRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Expanded(child: Text(value)),
      ],
    );
  }
}
