import 'package:flutter/material.dart';
import '../services/update_service.dart';

class SoftwareUpdateScreen extends StatelessWidget {
  const SoftwareUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Background color: Pure black in dark mode, elegant off-white in light mode
    final bgColor = isDark ? Colors.black : const Color(0xFFF7F7FA);
    
    // Text colors
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtitleColor = isDark ? Colors.white60 : Colors.black45;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
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
            icon: Icon(
              Icons.more_vert_rounded,
              color: textColor,
            ),
            onPressed: () {
              // Custom action menu if needed, matches the screenshot's three dots
            },
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
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
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
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(0, 4),
                                    blurRadius: 10,
                                  ),
                                ]
                              : [],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '현재 버전: $currentVersionName',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(flex: 4),
            
            // Bottom Check for Updates Pill Button
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
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
                      onPressed: () {
                        UpdateService.checkAndShowDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A7DFC), // Samsung Premium Blue
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: const StadiumBorder(), // Perfectly rounded pill shape
                      ),
                      child: const Text(
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
          ],
        ),
      ),
    );
  }
}
