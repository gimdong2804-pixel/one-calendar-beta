import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/update_service.dart';

class SoftwareUpdateDetailScreen extends StatelessWidget {
  final UpdateInfo updateInfo;

  const SoftwareUpdateDetailScreen({
    super.key,
    required this.updateInfo,
  });

  @override
  Widget build(BuildContext context) {
    const darkBgColor = Color(0xFF121216); // Premium Dark Gray/Black for One UI Dark Theme
    const cardBgColor = Color(0xFF1C1C22); // Card background
    
    // Transparent system bar style tailored for premium dark mode
    final systemOverlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: darkBgColor,
      systemNavigationBarIconBrightness: Brightness.light,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlay,
      child: Scaffold(
        backgroundColor: darkBgColor,
        body: Stack(
          children: [
            // 1. Top Wallpaper Hero Area (approx. 42% height)
            Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.42,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/one_ui_8_5_wallpaper.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if image asset fails to load
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
                            'One UI 8.5',
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
                const Expanded(child: SizedBox()),
              ],
            ),

            // 2. Sliding/Scrollable Detail Card
            Positioned.fill(
              top: MediaQuery.of(context).size.height * 0.38, // Slightly overlapping the image for a unified look
              child: Container(
                decoration: const BoxDecoration(
                  color: darkBgColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(32), // High roundness matching premium Samsung cards
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 15,
                      offset: Offset(0, -5),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: Column(
                    children: [
                      // Smooth drag/accent line indicator at the top
                      const SizedBox(height: 12),
                      Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Scrollable changelog body
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          physics: const BouncingScrollPhysics(),
                          children: [
                            const Text(
                              '마지막으로 완료된 업데이트',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '2026년 5월 18일 오후 5:15',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Main Letter / Announcement text
                            const Text(
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
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.6,
                                letterSpacing: -0.3,
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Real Changelog block if present in server data
                            if (updateInfo.changelog.isNotEmpty) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: cardBgColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.07)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.system_update_alt_rounded, color: Color(0xFF2A7DFC), size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          '새로운 업데이트 상세 내용',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      updateInfo.changelog,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '버전: ${updateInfo.versionName}',
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

                      // Elegant Bottom Button Section
                      Container(
                        padding: EdgeInsets.only(
                          left: 24,
                          right: 24,
                          bottom: MediaQuery.of(context).padding.bottom + 16,
                          top: 12,
                        ),
                        decoration: BoxDecoration(
                          color: darkBgColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, -3),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              // Perform standard download and installation workflow
                              // Directly pass the top context so it remains active even if this page pops
                              UpdateService.downloadAndInstall(
                                Navigator.of(context).context,
                                updateInfo.downloadUrl,
                                updateInfo.versionName,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A7DFC), // Samsung Premium Blue
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: const StadiumBorder(),
                            ),
                            child: const Text(
                              '다운로드 및 설치',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                    color: Colors.black.withOpacity(0.3),
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
}
