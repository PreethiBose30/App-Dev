import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_controller.dart';

/// Theme mode + accent color, persisted via ThemeController (Hive settings
/// box) and applied live -- no restart needed.
class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        final controller = ThemeController.instance;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            iconTheme: IconThemeData(color: AppColors.textPrimary),
            title: Text('APPEARANCE', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 35),
              children: [
                Text(
                  'THEME',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      _modeTile(controller, ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
                      _divider(),
                      _modeTile(controller, ThemeMode.light, 'Light', Icons.light_mode_outlined),
                      _divider(),
                      _modeTile(controller, ThemeMode.system, 'System', Icons.settings_suggest_outlined),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'ACCENT COLOR',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  children: ThemeController.accentPresets.map((color) {
                    final isSelected = color.toARGB32() == controller.accent.toARGB32();
                    return GestureDetector(
                      onTap: () => controller.setAccent(color),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppColors.textPrimary : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: isSelected
                            ? Icon(Icons.check, color: AppColors.onAccent, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _divider() => Divider(height: 1, color: AppColors.background.withOpacity(0.4));

  Widget _modeTile(ThemeController controller, ThemeMode mode, String label, IconData icon) {
    final selected = controller.mode == mode;
    return ListTile(
      leading: Icon(icon, color: selected ? AppColors.accent : AppColors.textSecondary),
      title: Text(label, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      trailing: selected ? Icon(Icons.check_circle, color: AppColors.accent) : null,
      onTap: () => controller.setMode(mode),
    );
  }
}
