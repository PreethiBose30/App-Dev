import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Material ThemeData for the Swiss / editorial look: flat surfaces, square
/// corners, hairline rules, heavy tight headings, one accent colour.
class AppTheme {
  static ThemeData build(Brightness brightness) {
    final p = brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
    final base = brightness == Brightness.dark ? ThemeData.dark() : ThemeData.light();
    const square = RoundedRectangleBorder(borderRadius: BorderRadius.zero);

    return base.copyWith(
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      dividerColor: p.ruleSoft,
      colorScheme: ColorScheme.fromSeed(seedColor: p.accent, brightness: brightness).copyWith(
        primary: p.accent,
        onPrimary: Colors.white,
        surface: p.background,
        onSurface: p.textPrimary,
        outline: p.textPrimary,
      ),
      textTheme: base.textTheme.apply(bodyColor: p.textPrimary, displayColor: p.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: p.textPrimary, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: square,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: square,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.textPrimary,
          side: BorderSide(color: p.textPrimary),
          shape: square,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.accent, shape: square),
      ),
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: p.textPrimary)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: p.accent, width: 2)),
        hintStyle: TextStyle(color: p.textSecondary),
        labelStyle: TextStyle(color: p.textSecondary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : p.textSecondary),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.accent : p.ruleSoft),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        side: BorderSide(color: p.textPrimary),
        backgroundColor: Colors.transparent,
        selectedColor: p.accent,
      ),
      cardTheme: CardThemeData(elevation: 0, shape: square, color: p.surface),
      dialogTheme: DialogThemeData(backgroundColor: p.background, shape: square),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: p.background, shape: square),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.textPrimary,
        contentTextStyle: TextStyle(color: p.background),
        shape: square,
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accent),
      listTileTheme: ListTileThemeData(iconColor: p.textPrimary, textColor: p.textPrimary),
    );
  }
}
