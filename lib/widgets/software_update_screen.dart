import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/update_service.dart';
import '../system_ui.dart';
import '../theme.dart';
import 'recent_update_screen.dart';
import 'software_update_detail_screen.dart';

enum UpdateState { idle, checking, upToDate, hasUpdate }

enum _UpdateMenuAction { recentUpdate }

class SoftwareUpdateScreen extends StatefulWidget {
  const SoftwareUpdateScreen({super.key});

  @override
  State<SoftwareUpdateScreen> createState() => _SoftwareUpdateScreenState();
}

class _SoftwareUpdateScreenState extends State<SoftwareUpdateScreen> {
  bool _startAnimation = false;
  UpdateState _updateState = UpdateState.idle;

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
  Future<void> _handleUpdateCheck() async {
    if (_updateState == UpdateState.checking) return;

    setState(() {
      _updateState = UpdateState.checking;
    });

    // Elegant delays to allow the luxurious dot loading animations to play naturally (approx 1.8 seconds)
    await Future.delayed(const Duration(milliseconds: 1800));

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

    final hasUpdate = await UpdateService.isUpdateAvailable(info);

    if (hasUpdate) {
      setState(() {
        _updateState = UpdateState.hasUpdate;
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
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => SoftwareUpdateDetailScreen(updateInfo: info),
          ),
        )
        .then((_) {
          // Revert checking status back to idle if they back navigate, allowing subsequent check attempts
          if (mounted && _updateState == UpdateState.hasUpdate) {
            setState(() {
              _updateState = UpdateState.idle;
            });
          }
        });
  }

  Future<void> _showOverflowMenu() async {
    final selected = await showGeneralDialog<_UpdateMenuAction>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return _UpdateOverflowMenu(
          isDark: isDark,
          onRecentUpdate: () {
            Navigator.of(context).pop(_UpdateMenuAction.recentUpdate);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            alignment: Alignment.topRight,
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.025),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) return;

    switch (selected) {
      case _UpdateMenuAction.recentUpdate:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const RecentUpdateScreen(),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Background color: Pure black in dark mode, elegant off-white in light mode
    final bgColor = context.updateBg;

    final textColor = context.settingsOnSurface;

    final systemOverlay = oneUiSystemOverlayStyle(
      context: context,
      navigationBarColor: bgColor,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
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
            IconButton(
              icon: Icon(Icons.more_vert_rounded, color: textColor),
              tooltip: '더보기',
              onPressed: _showOverflowMenu,
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
                tween: Tween<double>(
                  begin: 0.0,
                  end: _startAnimation ? 1.0 : 0.0,
                ),
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
                                      const Color(
                                        0xFF00F2FE,
                                      ).withValues(alpha: isDark ? 0.38 : 0.28),
                                      const Color(
                                        0xFF00F2FE,
                                      ).withValues(alpha: 0.0),
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
                                      const Color(
                                        0xFFFF8C00,
                                      ).withValues(alpha: isDark ? 0.35 : 0.24),
                                      const Color(
                                        0xFFFF8C00,
                                      ).withValues(alpha: 0.0),
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
                                      const Color(
                                        0xFF8A2387,
                                      ).withValues(alpha: isDark ? 0.30 : 0.20),
                                      const Color(
                                        0xFF8A2387,
                                      ).withValues(alpha: 0.0),
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
                            'One UI 1.0',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                              height: 1.1,
                              shadows: isDark
                                  ? [
                                      Shadow(
                                        color: context.updateLogBg,
                                        offset: const Offset(0, 4),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : [],
                            ),
                          ),

                          // Scenario A: Conditional fade-in text '최신 소프트웨어입니다.'
                          AnimatedOpacity(
                            opacity: _updateState == UpdateState.upToDate
                                ? 1.0
                                : 0.0,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOutCubic,
                            child: AnimatedSlide(
                              offset: _updateState == UpdateState.upToDate
                                  ? Offset.zero
                                  : const Offset(0, 0.4),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutCubic,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '최신 소프트웨어입니다.',
                                  style: TextStyle(
                                    color: context.updateBodyText,
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
                      tween: Tween<double>(
                        begin: 0.0,
                        end: _startAnimation ? 1.0 : 0.0,
                      ),
                      duration: const Duration(milliseconds: 600),
                      curve: const Interval(
                        0.2,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
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
                                backgroundColor: const Color(
                                  0xFF2A7DFC,
                                ), // Samsung Premium Blue
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(
                                  0xFF2A7DFC,
                                ), // Maintain background color during loading
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape:
                                    const StadiumBorder(), // Perfectly rounded pill shape
                              ),
                              child: _updateState == UpdateState.checking
                                  ? const OneUIRotatingDots()
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

class _UpdateOverflowMenu extends StatelessWidget {
  const _UpdateOverflowMenu({
    required this.isDark,
    required this.onRecentUpdate,
  });

  final bool isDark;
  final VoidCallback onRecentUpdate;

  @override
  Widget build(BuildContext context) {
    final textColor = context.settingsOnSurface;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: topPadding + 52,
            right: 18,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF202124) : Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.14),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: InkWell(
                  onTap: onRecentUpdate,
                  child: SizedBox(
                    width: 206,
                    height: 58,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Text(
                          '최근 업데이트',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
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
    );
  }
}

/// Premium 4-dot circular rotating loader for One UI 1.0
class OneUIRotatingDots extends StatefulWidget {
  const OneUIRotatingDots({super.key});

  @override
  State<OneUIRotatingDots> createState() => _OneUIRotatingDotsState();
}

class _OneUIRotatingDotsState extends State<OneUIRotatingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _rotationController,
      child: SizedBox(
        width: 24,
        height: 24,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Top Dot
            Positioned(top: 0, child: _buildDot()),
            // Bottom Dot
            Positioned(bottom: 0, child: _buildDot()),
            // Left Dot
            Positioned(left: 0, child: _buildDot()),
            // Right Dot
            Positioned(right: 0, child: _buildDot()),
          ],
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
