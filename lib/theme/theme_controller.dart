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

/// Holds the user's appearance preferences (theme mode + accent color) and
/// notifies listeners so the UI updates live, with no restart needed.
/// Persisted in the Hive settings box -- small non-sensitive key/value
/// data, same box used for other app settings.
class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const _modeKey = 'appearance_theme_mode';
  static const _accentKey = 'appearance_accent_color';

  /// Presets shown in the Appearance screen's accent picker.
  static const List<Color> accentPresets = [
    Color(0xFFF4F4F0), // default -- matches the app's original off-white
    Color(0xFF4F8EF7), // blue
    Color(0xFF34C759), // green
    Color(0xFFFF9F0A), // orange
    Color(0xFFBF5AF2), // purple
    Color(0xFFFF375F), // pink/red
  ];

  ThemeMode _mode = ThemeMode.dark;
  Color _accent = accentPresets.first;

  ThemeMode get mode => _mode;
  Color get accent => _accent;

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
      orElse: () => ThemeMode.dark,
    );
    final storedAccent = box.get(_accentKey) as int?;
    _accent = storedAccent != null ? Color(storedAccent) : accentPresets.first;
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    await HiveService.settingsBox.put(_modeKey, mode.name);
    notifyListeners();
  }

  Future<void> setAccent(Color color) async {
    if (_accent.toARGB32() == color.toARGB32()) return;
    _accent = color;
    await HiveService.settingsBox.put(_accentKey, color.toARGB32());
    notifyListeners();
  }
}
