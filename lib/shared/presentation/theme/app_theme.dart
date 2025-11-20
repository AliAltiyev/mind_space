import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/constants/app_colors.dart';

/// Универсальная система дизайна для Android и iOS
/// Использует Material 3 с адаптацией для iOS
class AppTheme {
  /// Определение платформы
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;

  /// Получение светлой темы
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,

      // Scaffold
      scaffoldBackgroundColor: colorScheme.surface,

      // AppBar - адаптирован для обеих платформ
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: isIOS ? 0 : 1,
        scrolledUnderElevation: isIOS ? 0 : 1,
        centerTitle: isIOS ? false : true,
        titleTextStyle: TextStyle(
          fontSize: isIOS ? 17 : 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: isIOS ? -0.41 : 0,
        ),
        systemOverlayStyle: isIOS ? null : SystemUiOverlayStyle.dark,
      ),

      // Card - современный дизайн для обеих платформ
      cardTheme: CardThemeData(
        elevation: isIOS ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 12 : 16),
        ),
        color: colorScheme.surface,
        margin: EdgeInsets.symmetric(
          horizontal: isIOS ? 16 : 16,
          vertical: isIOS ? 8 : 8,
        ),
      ),

      // ElevatedButton - адаптирован для iOS
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: isIOS ? 0 : 2,
          padding: EdgeInsets.symmetric(
            horizontal: isIOS ? 16 : 24,
            vertical: isIOS ? 12 : 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isIOS ? 10 : 12),
          ),
          textStyle: TextStyle(
            fontSize: isIOS ? 17 : 16,
            fontWeight: FontWeight.w600,
            letterSpacing: isIOS ? -0.41 : 0,
          ),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: EdgeInsets.symmetric(
            horizontal: isIOS ? 16 : 24,
            vertical: isIOS ? 12 : 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isIOS ? 10 : 12),
          ),
          side: BorderSide(color: colorScheme.primary, width: isIOS ? 0.5 : 1),
          textStyle: TextStyle(
            fontSize: isIOS ? 17 : 16,
            fontWeight: FontWeight.w600,
            letterSpacing: isIOS ? -0.41 : 0,
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: EdgeInsets.symmetric(
            horizontal: isIOS ? 12 : 16,
            vertical: isIOS ? 8 : 12,
          ),
          textStyle: TextStyle(
            fontSize: isIOS ? 17 : 16,
            fontWeight: FontWeight.w600,
            letterSpacing: isIOS ? -0.41 : 0,
          ),
        ),
      ),

      // InputDecoration - адаптирован для iOS
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isIOS ? 10 : 12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: isIOS ? 0.5 : 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isIOS ? 10 : 12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: isIOS ? 0.5 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isIOS ? 10 : 12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: isIOS ? 1 : 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isIOS ? 16 : 16,
          vertical: isIOS ? 14 : 16,
        ),
      ),

      // ListTile - адаптирован для iOS
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isIOS ? 16 : 16,
          vertical: isIOS ? 8 : 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 10 : 0),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.12),
        thickness: isIOS ? 0.5 : 1,
        space: 1,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withOpacity(0.5);
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        deleteIconColor: colorScheme.onSurface,
        disabledColor: colorScheme.onSurface.withOpacity(0.12),
        selectedColor: colorScheme.primaryContainer,
        secondarySelectedColor: colorScheme.secondaryContainer,
        padding: EdgeInsets.symmetric(
          horizontal: isIOS ? 12 : 12,
          vertical: isIOS ? 8 : 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 10 : 8),
        ),
        labelStyle: TextStyle(
          fontSize: isIOS ? 15 : 14,
          fontWeight: FontWeight.w500,
          letterSpacing: isIOS ? -0.24 : 0,
        ),
      ),

      // Dialog - адаптирован для iOS
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 14 : 28),
        ),
        elevation: isIOS ? 0 : 24,
        backgroundColor: colorScheme.surface,
      ),

      // BottomSheet
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(isIOS ? 14 : 28),
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: isIOS ? 0 : 8,
      ),
    );
  }

  /// Получение темной темы
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,

      // Scaffold
      scaffoldBackgroundColor: colorScheme.surface,

      // AppBar - адаптирован для обеих платформ
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: isIOS ? 0 : 0,
        scrolledUnderElevation: isIOS ? 0 : 1,
        centerTitle: isIOS ? false : true,
        titleTextStyle: TextStyle(
          fontSize: isIOS ? 17 : 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: isIOS ? -0.41 : 0,
        ),
        systemOverlayStyle: isIOS ? null : SystemUiOverlayStyle.light,
      ),

      // Card - современный дизайн для обеих платформ
      cardTheme: CardThemeData(
        elevation: isIOS ? 0 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 12 : 16),
        ),
        color: colorScheme.surfaceContainerHighest,
        margin: EdgeInsets.symmetric(
          horizontal: isIOS ? 16 : 16,
          vertical: isIOS ? 8 : 8,
        ),
      ),

      // ElevatedButton - адаптирован для iOS
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: isIOS ? 0 : 0,
          padding: EdgeInsets.symmetric(
            horizontal: isIOS ? 16 : 24,
            vertical: isIOS ? 12 : 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isIOS ? 10 : 12),
          ),
          textStyle: TextStyle(
            fontSize: isIOS ? 17 : 16,
            fontWeight: FontWeight.w600,
            letterSpacing: isIOS ? -0.41 : 0,
          ),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: EdgeInsets.symmetric(
            horizontal: isIOS ? 16 : 24,
            vertical: isIOS ? 12 : 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isIOS ? 10 : 12),
          ),
          side: BorderSide(color: colorScheme.outline, width: isIOS ? 0.5 : 1),
          textStyle: TextStyle(
            fontSize: isIOS ? 17 : 16,
            fontWeight: FontWeight.w600,
            letterSpacing: isIOS ? -0.41 : 0,
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: EdgeInsets.symmetric(
            horizontal: isIOS ? 12 : 16,
            vertical: isIOS ? 8 : 12,
          ),
          textStyle: TextStyle(
            fontSize: isIOS ? 17 : 16,
            fontWeight: FontWeight.w600,
            letterSpacing: isIOS ? -0.41 : 0,
          ),
        ),
      ),

      // InputDecoration - адаптирован для iOS
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isIOS ? 10 : 12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: isIOS ? 0.5 : 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isIOS ? 10 : 12),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
            width: isIOS ? 0.5 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isIOS ? 10 : 12),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: isIOS ? 1 : 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isIOS ? 16 : 16,
          vertical: isIOS ? 14 : 16,
        ),
      ),

      // ListTile - адаптирован для iOS
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isIOS ? 16 : 16,
          vertical: isIOS ? 8 : 4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 10 : 0),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.12),
        thickness: isIOS ? 0.5 : 1,
        space: 1,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withOpacity(0.5);
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        deleteIconColor: colorScheme.onSurface,
        disabledColor: colorScheme.onSurface.withOpacity(0.12),
        selectedColor: colorScheme.primaryContainer,
        secondarySelectedColor: colorScheme.secondaryContainer,
        padding: EdgeInsets.symmetric(
          horizontal: isIOS ? 12 : 12,
          vertical: isIOS ? 8 : 8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 10 : 8),
        ),
        labelStyle: TextStyle(
          fontSize: isIOS ? 15 : 14,
          fontWeight: FontWeight.w500,
          letterSpacing: isIOS ? -0.24 : 0,
        ),
      ),

      // Dialog - адаптирован для iOS
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isIOS ? 14 : 28),
        ),
        elevation: isIOS ? 0 : 24,
        backgroundColor: colorScheme.surface,
      ),

      // BottomSheet
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(isIOS ? 14 : 28),
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: isIOS ? 0 : 8,
      ),
    );
  }

  /// Получение темы по типу
  static ThemeData getTheme(Brightness brightness) {
    switch (brightness) {
      case Brightness.light:
        return lightTheme;
      case Brightness.dark:
        return darkTheme;
    }
  }

  /// Получение темы по строке
  static ThemeData getThemeByName(String themeName) {
    switch (themeName) {
      case 'light':
        return lightTheme;
      case 'dark':
        return darkTheme;
      default:
        return lightTheme;
    }
  }
}
