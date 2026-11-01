import 'package:flutter/material.dart';
import 'theme_controller.dart';

/// One complete set of colours for a brightness.
class AppPalette {
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color ruleSoft;
  final Color accent;
  const AppPalette({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.ruleSoft,
    required this.accent,
  });

  /// Swiss / editorial: warm paper, near-black ink, one vermilion accent.
  static const light = AppPalette(
    background: Color(0xFFF5F3EE),
    surface: Color(0xFFEBE8E1),
    textPrimary: Color(0xFF141414),
    textSecondary: Color(0xFF6B6963),
    ruleSoft: Color(0xFFC9C5BB),
    accent: Color(0xFFE03C16),
  );

  static const dark = AppPalette(
    background: Color(0xFF0F0F0F),
    surface: Color(0xFF1B1B1A),
    textPrimary: Color(0xFFF3F1EC),
    textSecondary: Color(0xFF8E8C86),
    ruleSoft: Color(0xFF3A3936),
    accent: Color(0xFFFF5A2B),
  );
}

/// Resolves to the light or dark palette from the current ThemeController
/// state. These are getters (not `static const`) so Appearance settings can
/// switch them live; call sites therefore cannot be used in `const`
/// expressions. The accent is fixed, not user-customisable.
class AppColors {
  static bool get _isDark =>
      ThemeController.instance.isDark(WidgetsBinding.instance.platformDispatcher.platformBrightness);

  static AppPalette get _p => _isDark ? AppPalette.dark : AppPalette.light;

  static Color get background => _p.background;
  static Color get surface => _p.surface;
  static Color get textPrimary => _p.textPrimary;
  static Color get textSecondary => _p.textSecondary;

  /// Hairline rules and borders: the structural element of the design.
  static Color get rule => _p.textPrimary;
  static Color get ruleSoft => _p.ruleSoft;

  /// The one accent colour: the Add button, selected states, "Expired", links.
  static Color get accent => _p.accent;

  /// Text/icons drawn directly on an accent surface.
  static Color get onAccent => Colors.white;

  /// Foreground-emphasis colour (icons, highlighted text).
  static Color get primary => _p.textPrimary;
}
