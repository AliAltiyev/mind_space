import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Cupertino (iOS) тема для приложения
class CupertinoAppTheme {
  CupertinoAppTheme._();

  /// Светлая Cupertino тема
  static CupertinoThemeData get lightTheme {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: CupertinoColors.systemBlue,
      scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      barBackgroundColor: CupertinoColors.systemBackground,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          letterSpacing: -0.41,
          color: CupertinoColors.label,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
          color: CupertinoColors.label,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.37,
          color: CupertinoColors.label,
        ),
        tabLabelTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 10,
          letterSpacing: -0.24,
          color: CupertinoColors.secondaryLabel,
        ),
        pickerTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 21,
          letterSpacing: -0.41,
          color: CupertinoColors.label,
        ),
        dateTimePickerTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 21,
          letterSpacing: -0.41,
          color: CupertinoColors.label,
        ),
      ),
    );
  }

  /// Темная Cupertino тема
  static CupertinoThemeData get darkTheme {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: CupertinoColors.systemBlue,
      scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
      barBackgroundColor: CupertinoColors.systemBackground,
      textTheme: CupertinoTextThemeData(
        textStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          letterSpacing: -0.41,
          color: CupertinoColors.label,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
          color: CupertinoColors.label,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.37,
          color: CupertinoColors.label,
        ),
        tabLabelTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 10,
          letterSpacing: -0.24,
          color: CupertinoColors.secondaryLabel,
        ),
        pickerTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 21,
          letterSpacing: -0.41,
          color: CupertinoColors.label,
        ),
        dateTimePickerTextStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 21,
          letterSpacing: -0.41,
          color: CupertinoColors.label,
        ),
      ),
    );
  }

  /// Цвета для настроений в iOS стиле
  static Map<String, Color> get moodColors => {
    'very_sad': CupertinoColors.systemRed,
    'sad': CupertinoColors.systemOrange,
    'neutral': CupertinoColors.systemYellow,
    'happy': CupertinoColors.systemGreen,
    'very_happy': CupertinoColors.systemTeal,
  };

  /// iOS стиль отступов
  static EdgeInsets get defaultPadding =>
      const EdgeInsets.symmetric(horizontal: 16, vertical: 8);

  /// iOS стиль скругления
  static double get defaultBorderRadius => 10.0;

  /// iOS стиль разделителей
  static Widget buildDivider(BuildContext context) {
    return Divider(
      height: 0.5,
      thickness: 0.5,
      color: CupertinoColors.separator.resolveFrom(context),
      indent: 16,
      endIndent: 16,
    );
  }
}

