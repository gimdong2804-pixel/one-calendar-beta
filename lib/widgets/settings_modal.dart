import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../theme.dart';

import '../providers/settings_provider.dart';
import '../services/update_service.dart';
import 'software_update_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.settingsBg;
    final onSurfaceColor = context.settingsOnSurface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: onSurfaceColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '설정',
          style: TextStyle(fontWeight: FontWeight.w700, color: onSurfaceColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Profile Section
          _SettingGroup(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  '김동현',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: onSurfaceColor,
                  ),
                ),
                subtitle: Text(
                  '삼성 계정',
                  style: TextStyle(
                    color: onSurfaceColor.withValues(alpha: 0.54),
                  ),
                ),
                trailing: const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white, size: 30),
                ),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Decoration Settings
          _SettingGroup(
            children: [
              _SettingTile(
                icon: Icons.palette_rounded,
                iconColor: Colors.blueAccent,
                title: '테마',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ThemeSettingsScreen(),
                    ),
                  );
                },
              ),
              _Divider(),
              _SettingTile(
                icon: Icons.tune_rounded,
                iconColor: Colors.indigoAccent,
                title: '액션 바',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ActionBarSettingsScreen(),
                    ),
                  );
                },
              ),
              _Divider(),
              _SettingTile(
                icon: Icons.motion_photos_auto_rounded,
                iconColor: Colors.purpleAccent,
                title: '애니메이션',
                onTap: () =>
                    _showSnack(context, '애니메이션 옵션은 Flutter 전환 효과 정리 후 연결됩니다.'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // App Settings (Sound)
          _SettingGroup(
            children: [
              _SettingTile(
                icon: Icons.volume_up_rounded,
                iconColor: Colors.lightBlue,
                title: '소리',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SoundSettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Update Settings
          _SettingGroup(
            children: [
              _SettingTile(
                icon: Icons.system_update_rounded,
                iconColor: Colors.teal,
                title: '소프트웨어 업데이트',
                subtitle: '현재: $currentVersionName',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SoftwareUpdateScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SettingGroup extends StatelessWidget {
  const _SettingGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.settingsGroupBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final onSurfaceColor = context.settingsOnSurface;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: onSurfaceColor),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(color: onSurfaceColor.withValues(alpha: 0.54)),
            )
          : null,
      trailing:
          trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right_rounded,
                  color: onSurfaceColor.withValues(alpha: 0.54),
                )
              : null),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final onSurfaceColor = context.settingsOnSurface;
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 16),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: onSurfaceColor.withValues(alpha: 0.12),
      ),
    );
  }
}

void showSettingsModal(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();
  Navigator.of(context).push(
    PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SettingsScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    ),
  );
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.settingsBg;
    final onSurfaceColor = context.settingsOnSurface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: onSurfaceColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '테마',
          style: TextStyle(fontWeight: FontWeight.w700, color: onSurfaceColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _SettingGroup(
            children: [
              _SettingTile(
                icon: Icons.dark_mode_rounded,
                iconColor: Colors.purpleAccent,
                title: '다크 모드',
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    unawaited(
                      settings.setThemeMode(
                        value ? ThemeMode.dark : ThemeMode.light,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SoundSettingsScreen extends StatelessWidget {
  const SoundSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.settingsBg;
    final onSurfaceColor = context.settingsOnSurface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: onSurfaceColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '터치음',
          style: TextStyle(fontWeight: FontWeight.w700, color: onSurfaceColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _SettingGroup(
            children: [
              _SettingTile(
                icon: Icons.touch_app_rounded,
                iconColor: Colors.orangeAccent,
                title: '터치음',
                trailing: Switch(
                  value: settings.isSoundEnabled,
                  onChanged: (value) =>
                      unawaited(settings.setSoundEnabled(value)),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                clipBehavior: Clip.none,
                child: settings.isSoundEnabled
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _Divider(),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            opacity: settings.isSoundEnabled ? 1.0 : 0.0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      '터치음 크기: ${(settings.soundVolume * 100).round()}%',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: onSurfaceColor,
                                      ),
                                    ),
                                  ),
                                  Slider(
                                    value: settings.soundVolume,
                                    min: 0,
                                    max: 1,
                                    divisions: 20,
                                    onChanged: (value) => unawaited(
                                      settings.setSoundVolume(value),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionBarSettingsScreen extends StatelessWidget {
  const ActionBarSettingsScreen({super.key});

  String _getButtonLabel(String id) {
    switch (id) {
      case 'btnAIChat':
        return '🤖 AI 어시스턴트';
      case 'btnToggleAI':
        return '✨ AI 예시 보기';
      case 'btnReset':
        return '🔄 전체 초기화';
      case 'btnSave':
        return '💾 자동 저장 상태';
      case 'btnCloudSync':
        return '☁️ 클라우드 업로드/받기';
      case 'btnLoginLogout':
        return '👤 로그인 / 가입';
      case 'btnPrint':
        return '🖨️ PDF 인쇄';
      default:
        return id;
    }
  }

  IconData _getButtonIcon(String id) {
    switch (id) {
      case 'btnAIChat':
        return Icons.smart_toy_rounded;
      case 'btnToggleAI':
        return Icons.auto_awesome_rounded;
      case 'btnReset':
        return Icons.refresh_rounded;
      case 'btnSave':
        return Icons.save_rounded;
      case 'btnCloudSync':
        return Icons.cloud_rounded;
      case 'btnLoginLogout':
        return Icons.key_rounded;
      case 'btnPrint':
        return Icons.print_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.settingsBg;
    final onSurfaceColor = context.settingsOnSurface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: onSurfaceColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '액션 바 커스텀',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: onSurfaceColor,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section 1: Blur Intensity
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      '배경 블러 설정',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: onSurfaceColor.withValues(alpha: 0.54),
                      ),
                    ),
                  ),
                  _SettingGroup(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '블러 강도',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: onSurfaceColor,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${settings.actionBarBlur.round()}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: settings.actionBarBlur,
                              min: 0,
                              max: 50,
                              divisions: 50,
                              onChanged: (value) => settings.setActionBarBlur(value),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Section 2: Buttons
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      '버튼 정렬 및 표시 여부 (드래그하여 순서 변경)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: onSurfaceColor.withValues(alpha: 0.54),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: context.settingsGroupBg,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: settings.actionBarOrder.length,
                    onReorder: settings.reorderActionBar,
                    itemBuilder: (context, index) {
                      final id = settings.actionBarOrder[index];
                      final isVisible = settings.isButtonVisible(id);
                      return ListTile(
                        key: ValueKey(id),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              child: Icon(
                                Icons.drag_indicator_rounded,
                                color: onSurfaceColor.withValues(alpha: 0.35),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isVisible 
                                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                                    : onSurfaceColor.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getButtonIcon(id),
                                color: isVisible 
                                    ? Theme.of(context).colorScheme.primary 
                                    : onSurfaceColor.withValues(alpha: 0.35),
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          _getButtonLabel(id),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isVisible 
                                ? onSurfaceColor 
                                : onSurfaceColor.withValues(alpha: 0.35),
                          ),
                        ),
                        trailing: Switch(
                          value: isVisible,
                          onChanged: (value) => settings.toggleButtonVisibility(id, value),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }
}
