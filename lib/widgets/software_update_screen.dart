import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/update_service.dart';
import 'software_update_detail_screen.dart';

enum UpdateState { idle, checking, upToDate, hasUpdate }

class SoftwareUpdateScreen extends StatefulWidget {
  const SoftwareUpdateScreen({super.key});

  @override
  State<SoftwareUpdateScreen> createState() => _SoftwareUpdateScreenState();
}

class _SoftwareUpdateScreenState extends State<SoftwareUpdateScreen> {
  bool _startAnimation = false;
  UpdateState _updateState = UpdateState.idle;
  UpdateInfo? _demoUpdateInfo;

  @override
  void initState() {
    super.initState();
    // Delay animations until the page route transition has fully finished to avoid frame drop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route != null && route.animation != null) {
        if (route.animation!.isCompleted) {
          setState(() {
            _startAnimation = true;
          });
        } else {
          void listener(AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              if (mounted) {
                setState(() {
                  _startAnimation = true;
                });
              }
              route.animation!.removeStatusListener(listener);
            }
          }
          route.animation!.addStatusListener(listener);
        }
      } else {
        // Fallback if no animation exists
        setState(() {
          _startAnimation = true;
        });
      }
    });
  }

  /// Perform actual update check with premium loader transition
  Future<void> _handleUpdateCheck({bool forceUpdateDemo = false, bool forceNoUpdateDemo = false}) async {
    if (_updateState == UpdateState.checking) return;

    setState(() {
      _updateState = UpdateState.checking;
    });

    // Elegant delays to allow the luxurious dot loading animations to play naturally (approx 1.8 seconds)
    await Future.delayed(const Duration(milliseconds: 1800));

    if (forceUpdateDemo) {
      // Simulate has update
      final demoInfo = UpdateInfo(
        latestBuildNumber: currentBuildNumber + 1,
        versionName: 'One UI 8.5 (Official)',
        downloadUrl: 'https://github.com/gimdong2804-pixel/one-calendar-beta/raw/main/beta/OneCalendar-Beta27.apk',
        changelog: '★ One UI 8.5 공식 정식 빌드 출시! ★\n\n1. 고급 아크릴 블러 이중 오버레이 카드 뷰 탑재\n2. 3D 시네마틱 구체 월페이퍼 디자인 가미\n3. 120Hz 초고주사율 렌더링 최적화 설계\n4. 안드로이드 상태바 검정/하얀 하이브리드 색상 완벽 자동 동기화 기술 적용',
      );
      setState(() {
        _updateState = UpdateState.hasUpdate;
        _demoUpdateInfo = demoInfo;
      });
      _navigateToDetail(demoInfo);
      return;
    }

    if (forceNoUpdateDemo) {
      // Simulate no update
      setState(() {
        _updateState = UpdateState.upToDate;
      });
      return;
    }

    // Standard live check
    final info = await UpdateService.checkForUpdate();

    if (!mounted) return;

    if (info == null) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('업데이트 정보를 불러올 수 없습니다. 인터넷 연결을 확인해주세요.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      setState(() {
        _updateState = UpdateState.idle;
      });
      return;
    }

    if (info.hasUpdate) {
      setState(() {
        _updateState = UpdateState.hasUpdate;
        _demoUpdateInfo = info;
      });
      _navigateToDetail(info);
    } else {
      setState(() {
        _updateState = UpdateState.upToDate;
      });
    }
  }

  /// Luxurious sliding routing transition (Right to Left)
  void _navigateToDetail(UpdateInfo info) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SoftwareUpdateDetailScreen(updateInfo: info),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    ).then((_) {
      // Revert checking status back to idle if they back navigate, allowing subsequent check attempts
      if (mounted && _updateState == UpdateState.hasUpdate) {
        setState(() {
          _updateState = UpdateState.idle;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Background color: Pure black in dark mode, elegant off-white in light mode
    final bgColor = isDark ? Colors.black : const Color(0xFFF7F7FA);
    
    // Text colors
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    final systemOverlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark, // Android
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light, // iOS
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlay,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          systemOverlayStyle: systemOverlay,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: textColor,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            // Premium simulation menu to test both Update Found and Already Up-To-Date
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: textColor),
              onSelected: (value) {
                if (value == 'demo_has_update') {
                  _handleUpdateCheck(forceUpdateDemo: true);
                } else if (value == 'demo_up_to_date') {
                  _handleUpdateCheck(forceNoUpdateDemo: true);
                } else if (value == 'reset') {
                  setState(() {
                    _updateState = UpdateState.idle;
                  });
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'demo_has_update',
                  child: Text('데모: 업데이트 있음 시뮬레이션'),
                ),
                const PopupMenuItem(
                  value: 'demo_up_to_date',
                  child: Text('데모: 업데이트 없음 시뮬레이션'),
                ),
                const PopupMenuItem(
                  value: 'reset',
                  child: Text('상태 초기화'),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              
              // Central Glowing Blob & Typography
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: _startAnimation ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: 0.8 + (value * 0.2),
                      child: child,
                    ),
                  );
                },
                child: RepaintBoundary(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Beautiful Organic Glow Backdrop
                      SizedBox(
                        width: 320,
                        height: 320,
                        child: Stack(
                          children: [
                            // Top-Right: Cyan Glow
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFF00F2FE).withOpacity(isDark ? 0.38 : 0.28),
                                      const Color(0xFF00F2FE).withOpacity(0.0),
                                    ],
                                    stops: const [0.0, 1.0],
                                  ),
                                ),
                              ),
                            ),
                            // Bottom-Left: Warm Amber/Orange Glow
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Container(
                                width: 230,
                                height: 230,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFFFF8C00).withOpacity(isDark ? 0.35 : 0.24),
                                      const Color(0xFFFF8C00).withOpacity(0.0),
                                    ],
                                    stops: const [0.0, 1.0],
                                  ),
                                ),
                              ),
                            ),
                            // Center: Soft Purple Glow
                            Positioned(
                              top: 60,
                              left: 60,
                              child: Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFF8A2387).withOpacity(isDark ? 0.30 : 0.20),
                                      const Color(0xFF8A2387).withOpacity(0.0),
                                    ],
                                    stops: const [0.0, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Text overlaid exactly in the center
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'One UI 8.5',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                              height: 1.1,
                              shadows: isDark
                                  ? [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(0, 4),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : [],
                            ),
                          ),
                          
                          // Scenario A: Conditional fade-in text '최신 소프트웨어입니다.'
                          AnimatedOpacity(
                            opacity: _updateState == UpdateState.upToDate ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOutCubic,
                            child: AnimatedSlide(
                              offset: _updateState == UpdateState.upToDate ? Offset.zero : const Offset(0, 0.4),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutCubic,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  '최신 소프트웨어입니다.',
                                  style: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(flex: 4),
              
              // Bottom Check for Updates Pill Button (Animated out if already up to date)
              AnimatedOpacity(
                opacity: _updateState == UpdateState.upToDate ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                child: AnimatedScale(
                  scale: _updateState == UpdateState.upToDate ? 0.8 : 1.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  child: IgnorePointer(
                    ignoring: _updateState == UpdateState.upToDate,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: _startAnimation ? 1.0 : 0.0),
                      duration: const Duration(milliseconds: 600),
                      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Center(
                          child: SizedBox(
                            width: 240, // Elegant narrowed width
                            height: 56, // Perfect premium height
                            child: ElevatedButton(
                              onPressed: _updateState == UpdateState.checking
                                  ? null
                                  : () => _handleUpdateCheck(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2A7DFC), // Samsung Premium Blue
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(0xFF2A7DFC), // Maintain background color during loading
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: const StadiumBorder(), // Perfectly rounded pill shape
                              ),
                              child: _updateState == UpdateState.checking
                                  ? const OneUILoadingDots()
                                  : const Text(
                                      '업데이트 확인',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dynamic bouncing dot loading animation for One UI aesthetics
class OneUILoadingDots extends StatefulWidget {
  const OneUILoadingDots({super.key});

  @override
  State<OneUILoadingDots> createState() => _OneUILoadingDotsState();
}

class _OneUILoadingDotsState extends State<OneUILoadingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Distribute animation start delays for wave simulation
            final double delay = index * 0.15;
            final double progress = (_controller.value - delay) % 1.0;
            
            // Generate clean wave displacement using smooth sine curves
            final double dy = -6.0 * (progress < 0.5 ? (1.0 - (progress * 2.0 - 0.5).abs()) : 0.0);
            
            // Subtly scale concurrently to replicate dynamic UI aesthetics
            final double scale = 1.0 + 0.2 * (progress < 0.5 ? (1.0 - (progress * 2.0 - 0.5).abs()) : 0.0);

            return Transform.translate(
              offset: Offset(0, dy),
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
