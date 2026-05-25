import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/update_service.dart';
import '../theme.dart';

class RecentUpdateScreen extends StatelessWidget {
  const RecentUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final info = UpdateService.currentReleaseInfo;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.updateDetailBg;
    final textColor = context.settingsOnSurface;
    final bodyTextColor = context.updateBodyText;
    final changes = info.changelog
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final systemOverlay = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: bgColor,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );

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
                        return const ColoredBox(color: Color(0xFF202124));
                      },
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: Container(
                      width: double.infinity,
                      color: bgColor,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(24, 30, 24, 40),
                        physics: const ClampingScrollPhysics(),
                        children: [
                          Text(
                            '최근 업데이트',
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
                            _formatReleaseTime(info.releasedAt),
                            style: TextStyle(
                              color: context.updateSubText,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 26),
                          Text(
                            info.versionName,
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
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '- ',
                                    style: TextStyle(
                                      color: bodyTextColor,
                                      fontSize: 15,
                                      height: 1.55,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        color: bodyTextColor,
                                        fontSize: 15,
                                        height: 1.55,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
}

String _formatReleaseTime(DateTime? value) {
  final date = (value ?? DateTime.now()).toLocal();
  final period = date.hour < 12 ? '오전' : '오후';
  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2, '0');
  return '${date.year}년 ${date.month}월 ${date.day}일 $period $hour:$minute';
}
