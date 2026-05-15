import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../services/update_service.dart';
import '../theme.dart';

class SettingsModal extends StatelessWidget {
  const SettingsModal({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border.all(color: context.borderSubtle),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: context.borderSubtle,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '설정',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: '닫기',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const _CategoryLabel('꾸미기 (Decoration)'),
                _SettingTile(
                  icon: Icons.palette_rounded,
                  title: '테마 설정',
                  subtitle: '라이트/다크 모드와 외부 버튼 표시',
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
                _SettingTile(
                  icon: Icons.tune_rounded,
                  title: '액션 바 커스텀',
                  subtitle: '순서 변경, 블러 강도, 버튼 표시',
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () =>
                      _showSnack(context, '액션 바 세부 커스텀은 다음 단계에서 연결됩니다.'),
                ),
                _SettingTile(
                  icon: Icons.motion_photos_auto_rounded,
                  title: '애니메이션 설정',
                  subtitle: '전환 효과 및 스타일 커스텀',
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showSnack(
                    context,
                    '애니메이션 옵션은 Flutter 전환 효과 정리 후 연결됩니다.',
                  ),
                ),
                const SizedBox(height: 20),
                const _CategoryLabel('앱 설정 (General)'),
                _SettingTile(
                  icon: settings.isSoundEnabled
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  title: '소리 설정',
                  subtitle: '터치음 효과 켜기',
                  trailing: Switch(
                    value: settings.isSoundEnabled,
                    onChanged: (value) =>
                        unawaited(settings.setSoundEnabled(value)),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: settings.isSoundEnabled
                      ? Padding(
                          key: const ValueKey('volume'),
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '소리 크기: ${(settings.soundVolume * 100).round()}%',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              Slider(
                                value: settings.soundVolume,
                                min: 0,
                                max: 1,
                                divisions: 20,
                                onChanged: (value) =>
                                    unawaited(settings.setSoundVolume(value)),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 20),
                const _CategoryLabel('업데이트 (Update)'),
                _SettingTile(
                  icon: Icons.system_update_rounded,
                  title: '업데이트 확인',
                  subtitle: '현재: $currentVersionName',
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).pop();
                    UpdateService.checkAndShowDialog(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryLabel extends StatelessWidget {
  const _CategoryLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: context.mutedText,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderSubtle),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: context.softInput,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }
}

void showSettingsModal(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.36),
    builder: (context) =>
        const Align(alignment: Alignment.bottomCenter, child: SettingsModal()),
  );
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
}
