import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int fallbackCurrentBuildNumber = 65;
const String currentVersionName = 'One UI 1.0 (Beta 65)';
const String currentReleaseDateIso = '2026-05-30T11:52:00+09:00';
const String currentReleaseChangelog = '- 화면 이동 시 버벅이는 문제 수정';

const String _updateInfoUrl =
    'https://raw.githubusercontent.com/gimdong2804-pixel/one-calendar-beta/main/update_info.json';

const String _downloadedBuildKey = 'downloaded_update_build';
const String _downloadedUrlKey = 'downloaded_update_url';
const String _downloadedPathKey = 'downloaded_update_path';

class CurrentAppVersion {
  const CurrentAppVersion({
    required this.buildNumber,
    required this.versionName,
  });

  final int buildNumber;
  final String versionName;
}

class UpdateInfo {
  final int latestBuildNumber;
  final String versionName;
  final String downloadUrl;
  final String changelog;
  final DateTime? releasedAt;

  const UpdateInfo({
    required this.latestBuildNumber,
    required this.versionName,
    required this.downloadUrl,
    required this.changelog,
    this.releasedAt,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      latestBuildNumber: _readInt(json['latestBuildNumber']),
      versionName: json['versionName'] as String,
      downloadUrl: json['downloadUrl'] as String,
      changelog: json['changelog'] as String? ?? '',
      releasedAt: _readDateTime(json['releasedAt']),
    );
  }
}

class UpdateService {
  static UpdateInfo get currentReleaseInfo {
    return UpdateInfo(
      latestBuildNumber: fallbackCurrentBuildNumber,
      versionName: currentVersionName,
      downloadUrl: '',
      changelog: currentReleaseChangelog,
      releasedAt: DateTime.tryParse(currentReleaseDateIso),
    );
  }

  static Future<CurrentAppVersion> getCurrentAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final buildNumber =
          int.tryParse(packageInfo.buildNumber) ?? fallbackCurrentBuildNumber;
      return CurrentAppVersion(
        buildNumber: buildNumber,
        versionName: _versionNameForBuild(buildNumber),
      );
    } catch (e) {
      debugPrint('현재 앱 버전 확인 실패: $e');
      return const CurrentAppVersion(
        buildNumber: fallbackCurrentBuildNumber,
        versionName: currentVersionName,
      );
    }
  }

  static Future<bool> isUpdateAvailable(UpdateInfo info) async {
    final current = await getCurrentAppVersion();
    return info.latestBuildNumber > current.buildNumber;
  }

  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);

      final preventCacheUrl =
          '$_updateInfoUrl?t=${DateTime.now().millisecondsSinceEpoch}';
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

  static Future<void> checkAndShowDialog(BuildContext context) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;

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
    final current = await getCurrentAppVersion();

    if (!rootContext.mounted) return;
    Navigator.of(rootContext, rootNavigator: true).pop();

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

    if (info.latestBuildNumber <= current.buildNumber) {
      if (!rootContext.mounted) return;
      showDialog(
        context: rootContext,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text('최신 소프트웨어입니다.'),
          content: Text('현재 버전: ${current.versionName}'),
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

    if (!rootContext.mounted) return;
    showDialog(
      context: rootContext,
      builder: (_) => AlertDialog(
        icon: const Icon(
          Icons.system_update,
          color: Color(0xFF4F46E5),
          size: 48,
        ),
        title: const Text('새 업데이트가 있습니다.'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _UpdateRow(label: '현재 버전', value: current.versionName),
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
              downloadAndInstall(rootContext, info);
            },
            icon: const Icon(Icons.download),
            label: const Text('업데이트'),
          ),
        ],
      ),
    );
  }

  static Future<File?> getPreparedInstaller(UpdateInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    final savedBuild = prefs.getInt(_downloadedBuildKey);
    final savedUrl = prefs.getString(_downloadedUrlKey);
    final savedPath = prefs.getString(_downloadedPathKey);

    if (savedBuild != info.latestBuildNumber ||
        savedUrl != info.downloadUrl ||
        savedPath == null) {
      return null;
    }

    final file = File(savedPath);
    if (await file.exists() && await file.length() > 0) {
      return file;
    }

    await clearPreparedInstaller();
    return null;
  }

  static Future<void> clearPreparedInstaller() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_downloadedBuildKey);
    await prefs.remove(_downloadedUrlKey);
    await prefs.remove(_downloadedPathKey);
  }

  static Future<void> downloadUpdateInstaller({
    required UpdateInfo updateInfo,
    required void Function(double progress, String statusText) onProgress,
  }) async {
    final cachedInstaller = await getPreparedInstaller(updateInfo);
    if (cachedInstaller != null) {
      onProgress(1.0, '설치 준비 완료');
      return;
    }

    final file = await _installerFileFor(updateInfo);
    if (await file.exists()) {
      await file.delete();
    }
    await clearPreparedInstaller();

    onProgress(0.0, '다운로드 준비 중...');

    try {
      final dio = Dio();
      await dio.download(
        updateInfo.downloadUrl,
        file.path,
        deleteOnError: true,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final value = received / total;
            final receivedMB = (received / 1024 / 1024).toStringAsFixed(1);
            final totalMB = (total / 1024 / 1024).toStringAsFixed(1);
            onProgress(value, '$receivedMB MB / $totalMB MB');
          }
        },
      );

      if (!await file.exists() || await file.length() == 0) {
        throw const FileSystemException('다운로드된 APK 파일이 비어 있습니다.');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_downloadedBuildKey, updateInfo.latestBuildNumber);
      await prefs.setString(_downloadedUrlKey, updateInfo.downloadUrl);
      await prefs.setString(_downloadedPathKey, file.path);

      onProgress(1.0, '설치 준비 완료');
    } catch (_) {
      if (await file.exists()) {
        await file.delete();
      }
      await clearPreparedInstaller();
      rethrow;
    }
  }

  static Future<String?> openPreparedInstaller(UpdateInfo info) async {
    final file = await getPreparedInstaller(info);
    if (file == null) {
      return '설치 파일을 찾을 수 없습니다. 다시 다운로드해주세요.';
    }

    final result = await OpenFilex.open(
      file.path,
      type: 'application/vnd.android.package-archive',
    );

    if (result.type != ResultType.done) {
      return result.message.isEmpty ? '설치 화면을 열 수 없습니다.' : result.message;
    }

    return null;
  }

  static Future<void> downloadAndInstall(
    BuildContext context,
    UpdateInfo info,
  ) async {
    final progress = ValueNotifier<double>(0.0);
    final statusText = ValueNotifier<String>('다운로드 준비 중...');

    final rootContext = Navigator.of(context, rootNavigator: true).context;
    if (!rootContext.mounted) return;

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
      await downloadUpdateInstaller(
        updateInfo: info,
        onProgress: (value, status) {
          progress.value = value;
          statusText.value = status;
        },
      );

      if (rootContext.mounted) {
        Navigator.of(rootContext, rootNavigator: true).pop();
      }

      final error = await openPreparedInstaller(info);
      if (error != null && rootContext.mounted) {
        ScaffoldMessenger.of(rootContext)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text('설치를 시작할 수 없습니다: $error'),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } catch (e) {
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

  static Future<File> _installerFileFor(UpdateInfo info) async {
    final dir = await getApplicationSupportDirectory();
    final updatesDir = Directory('${dir.path}${Platform.pathSeparator}updates');
    if (!await updatesDir.exists()) {
      await updatesDir.create(recursive: true);
    }
    return File(
      '${updatesDir.path}${Platform.pathSeparator}one_calendar_update_${info.latestBuildNumber}.apk',
    );
  }

  static String _versionNameForBuild(int buildNumber) {
    return 'One UI 1.0 (Beta $buildNumber)';
  }
}

int _readInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _readDateTime(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
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
