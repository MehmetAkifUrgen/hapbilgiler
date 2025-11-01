import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryLight = Color(0xFFFF9800);
  static const Color secondaryLight = Color(0xFFFF5722);
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);

  static const Color primaryDark = Color(0xFFFF9800);
  static const Color secondaryDark = Color(0xFFFF5722);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF16213E);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFEF5350);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimaryDark
        : textPrimaryLight;
  }

  static Color getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textSecondaryDark
        : textSecondaryLight;
  }

  static LinearGradient getBackgroundGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFFAFAFA),
              Color(0xFFF5F5F5),
            ],
          );
  }

  static LinearGradient getCardGradient(BuildContext context, List<Color>? customColors) {
    if (customColors != null && customColors.length >= 2) {
      return LinearGradient(
        colors: customColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    return Theme.of(context).brightness == Brightness.dark
        ? LinearGradient(
            colors: [
              const Color(0xFF16213E),
              const Color(0xFF1A1A2E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );
  }
}
