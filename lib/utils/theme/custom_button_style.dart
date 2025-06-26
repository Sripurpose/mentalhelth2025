import 'package:flutter/material.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';

class CustomButtonStyles {
  // Filled button style
  static ButtonStyle get fillBlueBL10 => ElevatedButton.styleFrom(
        backgroundColor: appTheme.blue300,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(
              10,
            ),
          ),
        ),
      );

  static ButtonStyle get fillRedBL10 => ElevatedButton.styleFrom(
    backgroundColor: appTheme.red500,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(
          10,
        ),
      ),
    ),
  );

  static ButtonStyle get fillBlueTL13 => ElevatedButton.styleFrom(
        backgroundColor: appTheme.blue300,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      );

  static ButtonStyle get fillGray => ElevatedButton.styleFrom(
        backgroundColor: appTheme.gray500,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      );

  static ButtonStyle get fillPrimary => ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary.withOpacity(1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      );

  // Outline button style
  static ButtonStyle get outlineGray => OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        side: BorderSide(
          color: appTheme.gray50001,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      );

  static ButtonStyle get continueWithPhone => OutlinedButton.styleFrom(
    backgroundColor: ColorsContent.signInGradientColorBlueNew,
    side: BorderSide(
      color: appTheme.gray50001,
      width: 0.4,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  );

  static ButtonStyle get outlineGrayTL5 => OutlinedButton.styleFrom(
        backgroundColor: ColorsContent.whatsOnYourMindBoxColor,
        side: BorderSide(
          color: appTheme.gray700,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      );

  static ButtonStyle get outlineWhiteNew => OutlinedButton.styleFrom(
    backgroundColor: ColorsContent.whiteText,
    side: BorderSide(
      color: appTheme.gray700,
      width: 0.5,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  );

  static ButtonStyle get editProfileCountryCode => OutlinedButton.styleFrom(
    backgroundColor: Colors.transparent,
    side: BorderSide(
      color: appTheme.gray700,
      width: 0.8,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  );

  static ButtonStyle get outlinePrimary => ElevatedButton.styleFrom(
        backgroundColor: appTheme.blue300,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        shadowColor: theme.colorScheme.primary,
        elevation: 38,
      );

  static ButtonStyle get outlinePrimaryDelete => ElevatedButton.styleFrom(
    backgroundColor: ColorsContent.newThemeColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    shadowColor: theme.colorScheme.primary,
    elevation: 38,
  );

  static ButtonStyle get outlineNewTheme => ElevatedButton.styleFrom(
    backgroundColor: ColorsContent.newThemeColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    shadowColor: theme.colorScheme.primary,
    elevation: 38,
  );

  static ButtonStyle get signInButton => ElevatedButton.styleFrom(
    backgroundColor: ColorsContent.blackThemeColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    shadowColor: theme.colorScheme.primary,
    elevation: 38,
  );

  static ButtonStyle get addActionButtonStyle => ElevatedButton.styleFrom(
    backgroundColor:ColorsContent.newThemeColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    shadowColor: theme.colorScheme.primary,
    elevation: 38,
  );

  static ButtonStyle get outlinePrimaryTL5 => ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary.withOpacity(1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        shadowColor: theme.colorScheme.primary,
        elevation: 38,
      );

  static ButtonStyle get outlinePrimaryReminder => ElevatedButton.styleFrom(
    backgroundColor: ColorsContent.newThemeColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    shadowColor: theme.colorScheme.primary,
    elevation: 38,
  );
  static ButtonStyle get outlinePrimaryBlue => ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,  // Use blue from Material design palette
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(5),
    ),
    shadowColor: Colors.blue,  // Shadow color also set to blue
  );


  // text button style
  static ButtonStyle get none => ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
        elevation: WidgetStateProperty.all<double>(0),
      );

  static ButtonStyle get buttonBorder4 => ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(
            width: 2.0,
          ),
        ),
        elevation: 38,
      );
}
