import 'package:flutter/material.dart';
import 'theme_controller.dart';

/// Resolves to the dark or light palette depending on the current
/// ThemeController state. These used to be `static const` -- now they're
/// getters so Appearance settings can change them live, at the cost of call
/// sites no longer being usable in `const` expressions (see
/// ThemeController and the screens that were migrated off `const` for this).
class AppColors {
  static bool get _isDark =>
      ThemeController.instance.isDark(WidgetsBinding.instance.platformDispatcher.platformBrightness);

  static Color get background => _isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF4F4F2);
  static Color get surface => _isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);
  static Color get textPrimary => _isDark ? const Color(0xFFF4F4F0) : const Color(0xFF17171A);
  static Color get textSecondary => _isDark ? const Color(0xFF7A7A7A) : const Color(0xFF6B6B70);

  /// The user's chosen accent color (Appearance settings). Used for
  /// emphasis -- buttons, selected states, switches -- across the app; see
  /// `primary` below for the (non-accent) foreground-emphasis color that
  /// most existing screens use for icons/highlighted text.
  static Color get accent => ThemeController.instance.accent;

  /// Black or white, whichever reads clearly on top of [accent] -- used for
  /// icons/text drawn directly on an accent-colored surface (e.g. the FAB).
  static Color get onAccent =>
      ThemeData.estimateBrightnessForColor(accent) == Brightness.dark ? Colors.white : Colors.black;

  /// Foreground-emphasis color (icons, highlighted text, selected nav
  /// items). Kept distinct from [accent] because it was already used
  /// pervasively as "the off-white foreground" in the original dark-only
  /// design -- swapping it for an arbitrary accent color would tint body
  /// text/icons instead of just branded controls.
  static Color get primary => _isDark ? const Color(0xFFF4F4F0) : const Color(0xFF17171A);
}
