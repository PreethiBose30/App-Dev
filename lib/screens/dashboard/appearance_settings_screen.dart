import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_controller.dart';

/// Theme mode (light / dark / system), persisted via ThemeController (Hive
/// settings box) and applied live -- no restart needed. The accent colour is
/// fixed by the design and is not customisable.
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
            title: Text('Appearance', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 35),
              children: [
                Text(
                  'Theme',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.rule), bottom: BorderSide(color: AppColors.rule)),
                  ),
                  child: Column(
                    children: [
                      _modeTile(controller, ThemeMode.light, 'Light', Icons.light_mode_outlined),
                      _divider(),
                      _modeTile(controller, ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
                      _divider(),
                      _modeTile(controller, ThemeMode.system, 'System', Icons.settings_suggest_outlined),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _divider() => Divider(height: 1, color: AppColors.ruleSoft);

  Widget _modeTile(ThemeController controller, ThemeMode mode, String label, IconData icon) {
    final selected = controller.mode == mode;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: selected ? AppColors.accent : AppColors.textSecondary),
      title: Text(label, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
      trailing: selected ? Icon(Icons.check, color: AppColors.accent) : null,
      onTap: () => controller.setMode(mode),
    );
  }
}
