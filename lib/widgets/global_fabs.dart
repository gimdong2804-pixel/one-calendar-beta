import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'settings_modal.dart';

class GlobalFabs extends StatelessWidget {
  const GlobalFabs({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = settingsProvider.themeMode == ThemeMode.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 테마 변경 버튼 (설정에서 켜고 끌 수 있게 나중에 확장 예정)
        FloatingActionButton(
          heroTag: 'theme_fab',
          mini: true,
          onPressed: () {
            settingsProvider.setThemeMode(
              isDark ? ThemeMode.light : ThemeMode.dark,
            );
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Icon(
            isDark ? Icons.dark_mode : Icons.light_mode,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        // 터치음 버튼
        FloatingActionButton(
          heroTag: 'sound_fab',
          mini: true,
          onPressed: () {
            settingsProvider.setSoundEnabled(!settingsProvider.isSoundEnabled);
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Icon(
            settingsProvider.isSoundEnabled ? Icons.volume_up : Icons.volume_off,
            color: settingsProvider.isSoundEnabled 
                ? Theme.of(context).colorScheme.primary 
                : Colors.grey,
          ),
        ),
        const SizedBox(height: 12),
        // 설정 버튼
        FloatingActionButton(
          heroTag: 'settings_fab',
          onPressed: () {
            showSettingsModal(context);
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Icon(
            Icons.settings,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
