import 'package:flutter/material.dart';

String _appTheme = "primary";

/// Helper class for managing themes and colors.
class ThemeHelper {
  // A map of custom color themes supported by the app
  final Map<String, PrimaryColors> _supportedCustomColor = {
    'primary': PrimaryColors()
  };

// A map of color schemes supported by the app
  final Map<String, ColorScheme> _supportedColorScheme = {
    'primary': ColorSchemes.primaryColorScheme
  };

  /// Changes the app theme to [newTheme].
  void changeTheme(String newTheme) {
    _appTheme = newTheme;
  }

  /// Returns the primary colors for the current theme.
  PrimaryColors _getThemeColors() {
    //throw exception to notify given theme is not found or not generated by the generator
    if (!_supportedCustomColor.containsKey(_appTheme)) {
      throw Exception(
          "$_appTheme is not found.Make sure you have added this theme class in JSON Try running flutter pub run build_runner");
    }
    //return theme from map

    return _supportedCustomColor[_appTheme] ?? PrimaryColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    //throw exception to notify given theme is not found or not generated by the generator
    if (!_supportedColorScheme.containsKey(_appTheme)) {
      throw Exception(
          "$_appTheme is not found.Make sure you have added this theme class in JSON Try running flutter pub run build_runner");
    }
    //return theme from map

    var colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.primaryColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
      textTheme: TextThemes.textTheme(colorScheme),
      scaffoldBackgroundColor: colorScheme.onSecondaryContainer.withOpacity(1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: appTheme.blue300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          visualDensity: const VisualDensity(
            vertical: -4,
            horizontal: -4,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: BorderSide(
              color: colorScheme.onSecondaryContainer.withOpacity(1), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          visualDensity: const VisualDensity(
            vertical: -4,
            horizontal: -4,
          ),
          padding: EdgeInsets.zero,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurface;
        }),
        side: const BorderSide(
          width: 1,
        ),
        visualDensity: const VisualDensity(
          vertical: -4,
          horizontal: -4,
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 7,
        space: 7,
        color: colorScheme.primary.withOpacity(1),
      ),
    );
  }

  PrimaryColors themeColor() => _getThemeColors();
  ThemeData themeData() => _getThemeData();
}

class TextThemes {
  static TextTheme textTheme(ColorScheme colorScheme) => TextTheme(
        bodyLarge: TextStyle(
          color: colorScheme.primary.withOpacity(1),
          fontSize: 16,
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: colorScheme.primary.withOpacity(1),
          fontSize: 15,
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: appTheme.gray50001,
          fontSize: 12,
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w400,
        ),
        displayMedium: TextStyle(
          color: appTheme.red80001,
          fontSize: 40,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w400,
        ),
        headlineLarge: TextStyle(
          color: appTheme.redA700,
          fontSize: 32,
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w400,
        ),
        headlineSmall: TextStyle(
          color: colorScheme.primary.withOpacity(1),
          fontSize: 24,
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w500,
        ),
        labelLarge: TextStyle(
          color: appTheme.gray50001,
          fontSize: 12,
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: colorScheme.primary.withOpacity(1),
          fontSize: 20,
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: colorScheme.primary.withOpacity(1),
          fontSize: 18,
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w700,
        ),
        titleSmall: TextStyle(
          color: colorScheme.primary.withOpacity(1),
          fontSize: 14,
          fontFamily: 'Open Sans',
          fontWeight: FontWeight.w700,
        ),
      );
}

/// Class containing the supported color schemes.
class ColorSchemes {
  static const primaryColorScheme = ColorScheme.light(
    // Primary colors
    primary: Color(0X11000000),
    primaryContainer: Color(0X64000000),

    // Error colors
    errorContainer: Color(0XFF7ABAF5),

    // On colors(text colors)
    onPrimary: Color(0XFF333333),
    onSecondaryContainer: Color(0X93FFFFFF),
  );
}

/// Class containing custom colors for a primary theme.
class PrimaryColors {
  // Blue
  Color get blue300 => const Color(0XFF59A9F2);
  Color get blue400 => const Color(0XFF4F97E0);
  Color get blue40001 => const Color(0XFF3E92DF);
  Color get blue700 => const Color(0XFF2E80CB);
  Color get blue800 => const Color(0XFF1D64A6);
  Color get blueA400 => const Color(0XFF1877F2);
  Color get blueA40001 => const Color(0XFF337FFF);

  // BlueGray
  Color get blueGray100 => const Color(0XFFD9D9D9);
  Color get blueGray50 => const Color(0XFFEBEDF0);

  // DeepOrange
  Color get deepOrangeA700 => const Color(0XFFF81603);
  Color get deepOrangeA70001 => const Color(0XFFF91D0B);

  // Gray
  Color get gray100 => const Color(0XFFF2F2F2);
  Color get gray200 => const Color(0XFFEEEEEE);
  Color get gray50 => const Color(0XFFFBFCFD);
  Color get gray500 => const Color(0XFFAAAAAA);
  Color get gray50001 => const Color(0XFF999999);
  Color get gray700 => const Color(0XFF666666);
  Color get gray70001 => const Color(0XFF545556);

  // Green
  Color get greenA700 => const Color(0XFF00D95F);

  // Indigo
  Color get indigo400 => const Color(0XFF447CB1);
  Color get indigo50 => const Color(0XFFE4E8EC);

  // LightBlue
  Color get lightBlueA200 => const Color(0XFF33CCFF);

  // LightGreen
  Color get lightGreen700 => const Color(0XFF70AD32);

  // Red
  Color get red500 => const Color(0XFFEA4335);
  Color get red800 => const Color(0XFFD22121);
  Color get red80001 => const Color(0XFFD21A1A);
  Color get redA700 => const Color(0XFFE40C0C);
}

PrimaryColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();
