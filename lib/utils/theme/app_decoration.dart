import 'package:flutter/material.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';

class AppDecoration {
  // Fill decorations
  static BoxDecoration get fillBlue => BoxDecoration(
        color: appTheme.blue800,
      );
  static BoxDecoration get fillBlue300 => BoxDecoration(
        color: appTheme.blue300,
      );
  static BoxDecoration get fillBlue40001 => BoxDecoration(
        color: appTheme.blue40001,
      );
  static BoxDecoration get fillBlue700 => BoxDecoration(
        color: appTheme.blue700,
      );
  static BoxDecoration get fillBlueGray => BoxDecoration(
        color: appTheme.blueGray100,
      );
  static BoxDecoration get fillGray => BoxDecoration(
        color: appTheme.gray700,
      );
  static BoxDecoration get fillIndigo => BoxDecoration(
        color: appTheme.indigo400,
      );
  static BoxDecoration get fillIndigo50 => BoxDecoration(
        color: appTheme.indigo50,
      );
  static BoxDecoration get fillOnSecondaryContainer => BoxDecoration(
        color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
      );
  static BoxDecoration get fillPrimary => BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(1),
      );

  // Outline decorations
  static BoxDecoration get outlineBlue => BoxDecoration(
        color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
        border: Border.all(color: appTheme.blue300, width: 1),
      );
  static BoxDecoration get outlineGray => BoxDecoration(
        color: theme.colorScheme.onSecondaryContainer.withOpacity(0.9),
        border: Border.all(
          color: appTheme.gray200,
          width: 1,
          strokeAlign: strokeAlignOutside,
        ),
      );
  static BoxDecoration get outlineGray100 => BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(1),
        border: Border.all(color: appTheme.gray100, width: 1),
      );
  static BoxDecoration get outlineGray100WithOpacity08 => BoxDecoration(
        color: appTheme.gray100.withOpacity(0.8),
        border: Border.all(
          color: appTheme.gray100.withOpacity(0.5),
          width: 1,
          strokeAlign: strokeAlignOutside,
        ),
      );
  static BoxDecoration get outlineGray200 => BoxDecoration(
        color: appTheme.gray200,
        border: Border.all(
          color: appTheme.gray200,
          width: 1,
          strokeAlign: strokeAlignOutside,
        ),
      );
  static BoxDecoration get outlineGray2001 => BoxDecoration(
        color: appTheme.blue300,
        border: Border.all(
          color: appTheme.gray200,
          width: 1,
          strokeAlign: strokeAlignOutside,
        ),
      );
  static BoxDecoration get outlineGray700 => BoxDecoration(
        color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
        border: Border.all(color: appTheme.gray700, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary,
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(
              0,
              38.49,
            ),
          ),
        ],
      );
}

class BorderRadiusStyle {
  // Circle borders
  static BorderRadius get circleBorder15 => BorderRadius.circular(15);
  static BorderRadius get circleBorder29 => BorderRadius.circular(29);
  static BorderRadius get circleBorder34 => BorderRadius.circular(34);
  static BorderRadius get circleBorder54 => BorderRadius.circular(54);

  // Custom borders
  static BorderRadius get customBorderBL10 => const BorderRadius.vertical(
        bottom: Radius.circular(10),
      );
  static BorderRadius get customBorderTL10 => const BorderRadius.vertical(
        top: Radius.circular(10),
      );
  static BorderRadius get customBorderTL30 => const BorderRadius.vertical(
        top: Radius.circular(30),
      );
  static BorderRadius get customBorderTL33 => const BorderRadius.vertical(
        top: Radius.circular(33),
      );

  // Rounded borders
  static BorderRadius get roundedBorder10 => BorderRadius.circular(10);
  static BorderRadius get roundedBorder8 => BorderRadius.circular(8);
  static BorderRadius get roundedBorder4 => BorderRadius.circular(4);
  static BorderRadius get roundedBorder2 => BorderRadius.circular(2);
}

// Comment/Uncomment the below code based on your Flutter SDK version.

// For Flutter SDK Version 3.7.2 or greater.

double get strokeAlignInside => BorderSide.strokeAlignInside;

double get strokeAlignCenter => BorderSide.strokeAlignCenter;

double get strokeAlignOutside => BorderSide.strokeAlignOutside;

// For Flutter SDK Version 3.7.1 or less.

// StrokeAlign get strokeAlignInside => StrokeAlign.inside;
//
// StrokeAlign get strokeAlignCenter => StrokeAlign.center;
//
// StrokeAlign get strokeAlignOutside => StrokeAlign.outside;
