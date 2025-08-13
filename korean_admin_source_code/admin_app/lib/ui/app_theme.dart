import 'package:flutter/material.dart';
import 'design_tokens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: DesignTokens.primary,
        secondary: DesignTokens.secondary,
        error: DesignTokens.danger,
        background: DesignTokens.bgDefault,
        surface: DesignTokens.bgAlt,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onError: Colors.white,
        onBackground: DesignTokens.textDefault,
        onSurface: DesignTokens.textDefault,
      ),
      scaffoldBackgroundColor: DesignTokens.bgDefault,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusCard),
          side: BorderSide(color: DesignTokens.border),
        ),
        color: DesignTokens.bgAlt,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingBase,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
          ),
          textStyle: TextStyle(
            fontSize: DesignTokens.fontBody,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.primary,
          minimumSize: const Size(double.infinity, 48),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacingBase,
            vertical: 12,
          ),
          side: BorderSide(color: DesignTokens.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
          ),
          textStyle: TextStyle(
            fontSize: DesignTokens.fontBody,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: DesignTokens.fontDisplay,
          fontWeight: FontWeight.bold,
          color: DesignTokens.textDefault,
        ),
        headlineLarge: TextStyle(
          fontSize: DesignTokens.fontHeading,
          fontWeight: FontWeight.bold,
          color: DesignTokens.textDefault,
        ),
        headlineMedium: TextStyle(
          fontSize: DesignTokens.fontHeading - 4,
          fontWeight: FontWeight.w600,
          color: DesignTokens.textDefault,
        ),
        bodyLarge: TextStyle(
          fontSize: DesignTokens.fontBody,
          color: DesignTokens.textDefault,
        ),
        bodyMedium: TextStyle(
          fontSize: DesignTokens.fontBody - 2,
          color: DesignTokens.textDefault,
        ),
        labelLarge: TextStyle(
          fontSize: DesignTokens.fontCaption,
          color: DesignTokens.textMuted,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignTokens.bgAlt,
        contentPadding: EdgeInsets.all(DesignTokens.spacingBase),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
          borderSide: BorderSide(color: DesignTokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
          borderSide: BorderSide(color: DesignTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
          borderSide: BorderSide(color: DesignTokens.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusButton),
          borderSide: BorderSide(color: DesignTokens.danger),
        ),
        labelStyle: TextStyle(
          fontSize: DesignTokens.fontCaption,
          color: DesignTokens.textMuted,
        ),
        hintStyle: TextStyle(
          fontSize: DesignTokens.fontBody,
          color: DesignTokens.textMuted,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: DesignTokens.border,
        thickness: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: DesignTokens.bgAlt,
        foregroundColor: DesignTokens.textDefault,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: DesignTokens.fontHeading - 4,
          fontWeight: FontWeight.w600,
          color: DesignTokens.textDefault,
        ),
      ),
    );
  }
}