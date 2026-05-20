import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/update_service.dart';

enum DownloadState { idle, downloading, completed, error }

class SoftwareUpdateDetailScreen extends StatefulWidget {
  final UpdateInfo updateInfo;

  const SoftwareUpdateDetailScreen({
    super.key,
    required this.updateInfo,
  });

  @override
  State<SoftwareUpdateDetailScreen> createState() => _SoftwareUpdateDetailScreenState();
}

class _SoftwareUpdateDetailScreenState extends State<SoftwareUpdateDetailScreen> {
  DownloadState _downloadState = DownloadState.idle;
  double _downloadProgress = 0.0;
  String _statusText = '';

  void _startDownload() {
    if (_downloadState == DownloadState.downloading) return;

    setState(() {
      _downloadState = DownloadState.downloading;
      _downloadProgress = 0.0;
      _statusText = '다운로드 준비 중...';
    });

    UpdateService.downloadAndInstallWithCallback(
      context: context,
      url: widget.updateInfo.downloadUrl,
      versionName: widget.updateInfo.versionName,
      onProgress: (progress, status) {
        if (mounted) {
          setState(() {
            _downloadProgress = progress;
            _statusText = status;
          });
        }
      },
      onError: (err) {
        if (mounted) {
          setState(() {
            _downloadState = DownloadState.error;
            _statusText = err;
          });
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(err),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFFE53935),
              ),
            );
        }
      },
      onComplete: () {
        if (mounted) {
          setState(() {
            _downloadState = DownloadState.completed;
            _downloadProgress = 1.0;
            _statusText = '설치 준비 완료';
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Premium theme-adaptive color tokens
    final bgColor = isDark ? const Color(0xFF121216) : const Color(0xFFFAFAFD);
    final cardBgColor = isDark ? const Color(0xFF1C1C22) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subTextColor = isDark ? Colors.white54 : Colors.black45;
    final bodyTextColor = isDark ? Colors.white70 : Colors.black87;
    final dragHandleColor = isDark ? Colors.white24 : Colors.black26;
    final cardBorderColor = isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.05);

    // Transparent system bar style tailored dynamically for current theme
    final systemOverlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: bgColor,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );

    final screenHeight = MediaQuery.of(context).size.height;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlay,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : const Color(0xFFF7F7FA),
        body: Stack(
          children: [
            // 1. Top Wallpaper Hero Area (Fixed Background)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight * 0.45,
              child: Image.asset(
                'assets/images/one_ui_8_5_wallpaper.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
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
                          letterSpacing: -1.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 2. Sliding/Scrollable Detail Card
            Positioned.fill(
              child: DraggableScrollableSheet(
                initialChildSize: 0.60,
                minChildSize: 0.60,
                maxChildSize: 1.0,
                snap: true,
                snapSizes: const [0.60, 1.0],
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(32), // High roundness matching premium Samsung cards
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.45 : 0.08),
                          blurRadius: 15,
                          offset: const Offset(0, -5),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        // Smooth drag/accent line indicator at the top
                        const SizedBox(height: 12),
                        Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: dragHandleColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Scrollable changelog body
                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            physics: const ClampingScrollPhysics(), // Native buttery scroll physics
                            children: [
                              Text(
                                '마지막으로 완료된 업데이트',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.8,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '2026년 5월 18일 오후 5:15',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Main Letter / Announcement text
                              Text(
                                '안녕하세요!\nOne UI 베타 프로그램 운영팀입니다.\n\n'
                                'One UI 베타에 적극 참여해 주셔서 진심으로 감사드립니다.\n'
                                '정식버전 발행과 함께, 베타 테스트가 종료되었습니다.\n\n'
                                '베타 테스트 종료 이후에는,\n'
                                ' - 새로운 베타 버전을 배포하지 않습니다.\n'
                                ' - 베타 모델 및 베타 앱과 관련된 공식적인 답변을 더 이상 드리지 않습니다.\n'
                                ' - 베타 오류에 대한 피드백이 중단됩니다.\n'
                                ' - 베타 커뮤니티를 포함한 베타 상세페이지 메뉴에 접근하실 수 없습니다.\n\n'
                                '정식버전으로 업데이트를 하지 않으시면, 이후에 진행되는 모든 업데이트를 받으실 수 없으니, 반드시 정식버전으로 업데이트 부탁드립니다.',
                                style: TextStyle(
                                  color: bodyTextColor,
                                  fontSize: 14,
                                  height: 1.6,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Real Changelog block if present in server data
                              if (widget.updateInfo.changelog.isNotEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: cardBgColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: cardBorderColor),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.system_update_alt_rounded, color: Color(0xFF2A7DFC), size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            '새로운 업데이트 상세 내용',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        widget.updateInfo.changelog,
                                        style: TextStyle(
                                          color: bodyTextColor,
                                          fontSize: 13,
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '버전: ${widget.updateInfo.versionName}',
                                        style: const TextStyle(
                                          color: Color(0xFF2A7DFC),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ],
                          ),
                        ),

                        // Elegant Bottom Button / Progress Bar Section
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
                                color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                                width: 1,
                              ),
                            ),
                          ),
                          child: _buildProgressButton(isDark),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 3. Floating Premium Acrylic Back Button (Over the Wallpaper)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: 44,
                    height: 44,
                    color: isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.3),
                    child: Center(
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
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

  /// Builds the premium transforming inline progress button
  Widget _buildProgressButton(bool isDark) {
    final hasActiveProgress = _downloadState == DownloadState.downloading;
    
    // Core button sizes
    const double buttonHeight = 56;

    // Colors
    const Color activeBlue = Color(0xFF2A7DFC);
    final Color progressTrackColor = isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05);

    // On press handler
    final VoidCallback? onPressed = (_downloadState == DownloadState.idle || _downloadState == DownloadState.error)
        ? _startDownload
        : null;

    return Container(
      width: double.infinity,
      height: buttonHeight,
      decoration: BoxDecoration(
        color: hasActiveProgress ? progressTrackColor : activeBlue,
        borderRadius: BorderRadius.circular(buttonHeight / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(buttonHeight / 2),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            highlightColor: Colors.white10,
            splashColor: Colors.white.withOpacity(0.15),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Moving progress background filler
                if (hasActiveProgress)
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        width: MediaQuery.of(context).size.width * _downloadProgress,
                        color: activeBlue,
                      ),
                    ),
                  ),

                // 2. Button Central Overlay Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildButtonTextContent(isDark),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Returns the appropriate text style and content depending on the current download state
  Widget _buildButtonTextContent(bool isDark) {
    switch (_downloadState) {
      case DownloadState.idle:
        return const Text(
          '다운로드 및 설치',
          key: ValueKey('idle'),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        );
      case DownloadState.downloading:
        return Text(
          '다운로드 중... ${(_downloadProgress * 100).toStringAsFixed(0)}% ($_statusText)',
          key: const ValueKey('downloading'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        );
      case DownloadState.completed:
        return const Text(
          '설치 준비 완료',
          key: ValueKey('completed'),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        );
      case DownloadState.error:
        return const Text(
          '다시 시도 (오류 발생)',
          key: ValueKey('error'),
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.3,
          ),
        );
    }
  }
}
