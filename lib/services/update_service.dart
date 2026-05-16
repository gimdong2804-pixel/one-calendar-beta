import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 현재 앱의 빌드 번호 (pubspec.yaml의 +N 부분과 일치시켜야 함)
const int currentBuildNumber = 6;
const String currentVersionName = 'One UI 1.0 (Beta 6)';

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
      final request = await client.getUrl(Uri.parse(_updateInfoUrl));
      final response = await request.close();

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
    // 로딩 표시
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
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

    if (!context.mounted) return;
    Navigator.of(context).pop(); // 로딩 닫기

    if (info == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
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
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text('최신 버전입니다'),
          content: Text('현재 버전: $currentVersionName'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    // 업데이트 있음!
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.system_update, color: Color(0xFF4F46E5), size: 48),
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
              const Text('변경 사항:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(info.changelog),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('나중에'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _downloadUpdate(context, info.downloadUrl);
            },
            icon: const Icon(Icons.download),
            label: const Text('업데이트'),
          ),
        ],
      ),
    );
  }

  /// 브라우저에서 APK 다운로드 열기
  static Future<void> _downloadUpdate(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('다운로드 링크를 열 수 없습니다.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
