import 'package:flutter/material.dart';

class DesignTokens {
  static const Map<String, dynamic> tokens = {
    // Colors
    'color.primary': 0xFF2C61C1,
    'color.primaryHover': 0xFF244FA2,
    'color.primaryLight': 0xFFE3EDFF,
    'color.secondary': 0xFF5AD2CC,
    'color.secondaryLight': 0xFFE8F9F8,
    'color.textPrimary': 0xFF1A1A1A,
    'color.textSecondary': 0xFF666666,
    'color.textMuted': 0xFF999999,
    'color.bgDefault': 0xFFFAFBFC,
    'color.bgAlt': 0xFFFFFFFF,
    'color.bgCard': 0xFFFFFFFF,
    'color.border': 0xFFE5E8EC,
    'color.borderLight': 0xFFF0F0F0,
    'color.danger': 0xFFE53E3E,
    'color.success': 0xFF10B981,
    'color.warning': 0xFFF59E0B,
    'color.info': 0xFF3B82F6,
    // Spacing - Mobile optimized
    'spacing.xs': 4.0,
    'spacing.sm': 8.0,
    'spacing.base': 16.0,
    'spacing.lg': 24.0,
    'spacing.xl': 32.0,
    'spacing.xxl': 48.0,
    // Radius - More modern and mobile-friendly
    'radius.sm': 6.0,
    'radius.base': 12.0,
    'radius.lg': 16.0,
    'radius.xl': 20.0,
    'radius.full': 999.0,
    // Typography - Mobile optimized
    'font.xs': 12.0,
    'font.sm': 14.0,
    'font.base': 16.0,
    'font.lg': 18.0,
    'font.xl': 20.0,
    'font.xxl': 24.0,
    'font.heading': 28.0,
    'font.display': 32.0,
    // Elevation
    'elevation.low': 2.0,
    'elevation.medium': 4.0,
    'elevation.high': 8.0,
  };

  // Colors
  static Color get primary => Color(tokens['color.primary'] as int);
  static Color get primaryHover => Color(tokens['color.primaryHover'] as int);
  static Color get primaryLight => Color(tokens['color.primaryLight'] as int);
  static Color get secondary => Color(tokens['color.secondary'] as int);
  static Color get secondaryLight => Color(tokens['color.secondaryLight'] as int);
  static Color get textPrimary => Color(tokens['color.textPrimary'] as int);
  static Color get textSecondary => Color(tokens['color.textSecondary'] as int);
  static Color get textMuted => Color(tokens['color.textMuted'] as int);
  static Color get bgDefault => Color(tokens['color.bgDefault'] as int);
  static Color get bgAlt => Color(tokens['color.bgAlt'] as int);
  static Color get bgCard => Color(tokens['color.bgCard'] as int);
  static Color get border => Color(tokens['color.border'] as int);
  static Color get borderLight => Color(tokens['color.borderLight'] as int);
  static Color get danger => Color(tokens['color.danger'] as int);
  static Color get success => Color(tokens['color.success'] as int);
  static Color get warning => Color(tokens['color.warning'] as int);
  static Color get info => Color(tokens['color.info'] as int);

  // Legacy getters for backward compatibility
  static Color get textDefault => textPrimary;

  // Spacing
  static double get spacingXs => tokens['spacing.xs'] as double;
  static double get spacingSm => tokens['spacing.sm'] as double;
  static double get spacingBase => tokens['spacing.base'] as double;
  static double get spacingLg => tokens['spacing.lg'] as double;
  static double get spacingXl => tokens['spacing.xl'] as double;
  static double get spacingXxl => tokens['spacing.xxl'] as double;
  
  // Legacy getters for backward compatibility
  static double get spacingSmall => spacingSm;
  static double get spacingSection => spacingLg;

  // Radius
  static double get radiusXs => 4.0;
  static double get radiusSm => tokens['radius.sm'] as double;
  static double get radiusBase => tokens['radius.base'] as double;
  static double get radiusLg => tokens['radius.lg'] as double;
  static double get radiusXl => tokens['radius.xl'] as double;
  static double get radiusFull => tokens['radius.full'] as double;
  
  // Legacy getters for backward compatibility
  static double get radiusCard => radiusLg;
  static double get radiusButton => radiusBase;

  // Typography
  static double get fontXs => tokens['font.xs'] as double;
  static double get fontSm => tokens['font.sm'] as double;
  static double get fontBase => tokens['font.base'] as double;
  static double get fontLg => tokens['font.lg'] as double;
  static double get fontXl => tokens['font.xl'] as double;
  static double get fontXxl => tokens['font.xxl'] as double;
  static double get fontHeading => tokens['font.heading'] as double;
  static double get fontDisplay => tokens['font.display'] as double;
  
  // Legacy getters for backward compatibility
  static double get fontCaption => fontSm;
  static double get fontBody => fontBase;

  // Elevation
  static double get elevationLow => tokens['elevation.low'] as double;
  static double get elevationMedium => tokens['elevation.medium'] as double;
  static double get elevationHigh => tokens['elevation.high'] as double;
}