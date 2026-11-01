import 'package:flutter/material.dart';
import '../services/hive_service.dart';

/// Mix into any State whose build() reads AppColors directly (rather than
/// Theme.of(context)) so it repaints when Appearance settings change even
/// while it's sitting underneath another route (e.g. Profile/Home behind
/// the Appearance screen) -- without that, a screen only ever picks up a
/// new theme the next time something else causes it to rebuild.
mixin ThemeAwareState<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    ThemeController.instance.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    ThemeController.instance.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }
}

/// Holds the user's appearance preference (theme mode) and
/// notifies listeners so the UI updates live, with no restart needed.
/// Persisted in the Hive settings box -- small non-sensitive key/value
/// data, same box used for other app settings.
class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const _modeKey = 'appearance_theme_mode';

  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  /// Resolves [mode] against the platform brightness for ThemeMode.system.
  bool isDark(Brightness platformBrightness) {
    switch (_mode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return platformBrightness == Brightness.dark;
    }
  }

  void load() {
    final box = HiveService.settingsBox;
    final storedMode = box.get(_modeKey) as String?;
    _mode = ThemeMode.values.firstWhere(
      (m) => m.name == storedMode,
      orElse: () => ThemeMode.light,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    await HiveService.settingsBox.put(_modeKey, mode.name);
    notifyListeners();
  }
}
