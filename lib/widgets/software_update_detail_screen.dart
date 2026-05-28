import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../services/update_service.dart';
import '../system_ui.dart';
import '../theme.dart';

enum DownloadState { idle, downloading, completed, error }

class SoftwareUpdateDetailScreen extends StatefulWidget {
  final UpdateInfo updateInfo;

  const SoftwareUpdateDetailScreen({super.key, required this.updateInfo});

  @override
  State<SoftwareUpdateDetailScreen> createState() =>
      _SoftwareUpdateDetailScreenState();
}

class _SoftwareUpdateDetailScreenState
    extends State<SoftwareUpdateDetailScreen> {
  DownloadState _downloadState = DownloadState.idle;
  double _downloadProgress = 0.0;
  String _statusText = '';

  @override
  void initState() {
    super.initState();
    _restorePreparedInstaller();
  }

  Future<void> _restorePreparedInstaller() async {
    final installer = await UpdateService.getPreparedInstaller(
      widget.updateInfo,
    );
    if (!mounted || installer == null) return;

    setState(() {
      _downloadState = DownloadState.completed;
      _downloadProgress = 1.0;
      _statusText = '설치 준비 완료';
    });
  }

  Future<void> _startDownload() async {
    if (_downloadState == DownloadState.downloading) return;

    setState(() {
      _downloadState = DownloadState.downloading;
      _downloadProgress = 0.0;
      _statusText = '다운로드 준비 중...';
    });

    try {
      await UpdateService.downloadUpdateInstaller(
        updateInfo: widget.updateInfo,
        onProgress: (progress, status) {
          if (!mounted) return;
          setState(() {
            _downloadProgress = progress;
            _statusText = status;
          });
        },
      );

      if (!mounted) return;
      setState(() {
        _downloadState = DownloadState.completed;
        _downloadProgress = 1.0;
        _statusText = '설치 준비 완료';
      });
    } catch (e) {
      if (!mounted) return;
      final message = '다운로드 실패: $e';
      setState(() {
        _downloadState = DownloadState.error;
        _statusText = message;
      });
      _showError(message);
    }
  }

  Future<void> _installPreparedUpdate() async {
    final error = await UpdateService.openPreparedInstaller(widget.updateInfo);
    if (!mounted || error == null) return;

    setState(() {
      _downloadState = DownloadState.error;
      _statusText = error;
    });
    _showError(error);
  }

  void _handleButtonTap() {
    switch (_downloadState) {
      case DownloadState.idle:
      case DownloadState.error:
        _startDownload();
        break;
      case DownloadState.completed:
        _installPreparedUpdate();
        break;
      case DownloadState.downloading:
        break;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFE53935),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = context.updateDetailBg;
    final textColor = context.settingsOnSurface;
    final subTextColor = context.updateSubText;
    final bodyTextColor = context.updateBodyText;

    final systemOverlay = oneUiSystemOverlayStyle(
      context: context,
      navigationBarColor: bgColor,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    );

    final changes = _changelogItems();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlay,
      child: Scaffold(
        backgroundColor: bgColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  Expanded(
                    flex: 9,
                    child: Image.asset(
                      'assets/images/one_ui_8_5_wallpaper.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFF8C00),
                                Color(0xFF8A2387),
                                Color(0xFF00F2FE),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'One UI 1.0',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: Container(
                      width: double.infinity,
                      color: bgColor,
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
                              physics: const ClampingScrollPhysics(),
                              children: [
                                Text(
                                  '업데이트 있음',
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatReleaseTime(
                                    widget.updateInfo.releasedAt,
                                  ),
                                  style: TextStyle(
                                    color: subTextColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(height: 26),
                                Text(
                                  widget.updateInfo.versionName,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    height: 1.35,
                                    letterSpacing: 0,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                for (final item in changes)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _ChangeLine(
                                      text: item,
                                      color: bodyTextColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                              left: 24,
                              right: 24,
                              bottom: MediaQuery.of(context).padding.bottom + 16,
                              top: 12,
                            ),
                            decoration: BoxDecoration(
                              color: bgColor,
                              border: Border(
                                top: BorderSide(
                                  color: context.updateLogBg,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: _buildProgressButton(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: 44,
                    height: 44,
                    color: Colors.black.withValues(alpha: 0.28),
                    child: Center(
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressButton() {
    final isDownloading = _downloadState == DownloadState.downloading;
    const double buttonHeight = 56;
    const Color activeBlue = Color(0xFF2A7DFC);
    final Color progressTrackColor = context.updateProgressTrack;

    return Container(
      width: double.infinity,
      height: buttonHeight,
      decoration: BoxDecoration(
        color: isDownloading ? progressTrackColor : activeBlue,
        borderRadius: BorderRadius.circular(buttonHeight / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(buttonHeight / 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDownloading ? null : _handleButtonTap,
            highlightColor: Colors.white10,
            splashColor: Colors.white.withValues(alpha: 0.15),
            enableFeedback: context.watch<SettingsProvider>().isSoundEnabled,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isDownloading)
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOut,
                            width: constraints.maxWidth * _downloadProgress,
                            color: activeBlue,
                          ),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildButtonTextContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonTextContent() {
    switch (_downloadState) {
      case DownloadState.idle:
        return const _ButtonText(key: ValueKey('idle'), text: '다운로드 및 설치');
      case DownloadState.downloading:
        return _ButtonText(
          key: const ValueKey('downloading'),
          text:
              '다운로드 중... ${(_downloadProgress * 100).toStringAsFixed(0)}% ($_statusText)',
          fontSize: 14,
        );
      case DownloadState.completed:
        return const _ButtonText(key: ValueKey('completed'), text: '설치 준비 완료');
      case DownloadState.error:
        return const _ButtonText(key: ValueKey('error'), text: '다시 시도');
    }
  }

  List<String> _changelogItems() {
    final items = widget.updateInfo.changelog
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .map((line) => line.startsWith('-') ? line.substring(1).trim() : line)
        .where((line) => line.isNotEmpty)
        .toList();

    if (items.isNotEmpty) return items;
    return const ['업데이트 안정성을 개선했습니다.'];
  }
}

class _ChangeLine extends StatelessWidget {
  const _ChangeLine({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '- ',
          style: TextStyle(
            color: color,
            fontSize: 15,
            height: 1.55,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _ButtonText extends StatelessWidget {
  const _ButtonText({super.key, required this.text, this.fontSize = 16});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
      ),
    );
  }
}

String _formatReleaseTime(DateTime? value) {
  final date = (value ?? DateTime.now()).toLocal();
  final period = date.hour < 12 ? '오전' : '오후';
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.year}년 ${date.month}월 ${date.day}일 $period $hour:$minute';
}
