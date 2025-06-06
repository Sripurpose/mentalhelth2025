import 'package:flutter/material.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';

/// A collection of pre-defined text styles for customizing text appearance,
/// categorized by different font families and weights.
/// Additionally, this class includes extensions on [TextStyle] to easily apply specific font families to text.

class CustomTextStyles {
  // Body text style
  static get bodyLarge18 => theme.textTheme.bodyLarge!.copyWith(
        fontSize: 18,
      );

  static get bodyLargeGray700 => theme.textTheme.bodyLarge!.copyWith(
        color: appTheme.gray700,
      );

  static get bodyLargeNunitoOnSecondaryContainer =>
      theme.textTheme.bodyLarge!.nunito.copyWith(
        color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
      );

  static get bodyLargeOnSecondaryContainer =>
      theme.textTheme.bodyLarge!.copyWith(
        color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
        fontSize: 18,
        fontWeight: FontWeight.w300,
      );

  static get bodyLargeRoboto => theme.textTheme.bodyLarge!.roboto.copyWith(
        fontSize: 17,
      );

  static get bodyLargeRobotoOnSecondaryContainer =>
      theme.textTheme.bodyLarge!.roboto.copyWith(
        color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
      );

  static get bodyLargeRoboto_1 => theme.textTheme.bodyLarge!.roboto;

  static get bodyLargeff000000 => theme.textTheme.bodyLarge!.copyWith(
        color: const Color(0XFF000000),
      );

  static get bodyMedium14 => theme.textTheme.bodyMedium!.copyWith(
        fontSize: 14,
      );
  static get bodyMedium12 => theme.textTheme.bodyMedium!.copyWith(
    fontSize: 12,
  );
  static get bodyMedium18 => theme.textTheme.bodyMedium!.copyWith(
    fontSize: 18,
  );

  static get bodyMediumGray50001 => theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.gray50001,
        fontSize: 14,
      );

  static get bodyMediumGray700 => theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.gray700,
        fontSize: 14,
      );

  static get bodyMediumGray70013 => theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.gray700,
        fontSize: 13,
      );

  static get bodyMediumWhite => theme.textTheme.bodyMedium!.copyWith(
        color: Colors.white,
        fontSize: 13,
      );
  static get bodyMediumWhite18 => theme.textTheme.bodyMedium!.copyWith(
    color: Colors.white,
    fontSize: 18,
  );

  static get bodyMediumGray700_1 => theme.textTheme.bodyMedium!.copyWith(
        color: appTheme.gray700,
      );

  static get bodyMediumNunitoOnPrimary =>
      theme.textTheme.bodyMedium!.nunito.copyWith(
        color: theme.colorScheme.onPrimary,
        fontSize: 14,
      );

  static get bodyMediumOnPrimary => theme.textTheme.bodyMedium!.copyWith(
        color: theme.colorScheme.onPrimary,
        fontSize: 13,
      );

  static get bodyMediumOnPrimary14 => theme.textTheme.bodyMedium!.copyWith(
        color: theme.colorScheme.onPrimary,
        fontSize: 14,
      );

  static get bodyMediumOnSecondaryContainer =>
      theme.textTheme.bodyMedium!.copyWith(
        color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
      );

  static get bodyMediumRobotoGray700 =>
      theme.textTheme.bodyMedium!.roboto.copyWith(
        color: appTheme.gray700,
        fontSize: 14,
      );

  static get bodyMediumRobotoOnPrimary =>
      theme.textTheme.bodyMedium!.roboto.copyWith(
        color: theme.colorScheme.onPrimary,
        fontSize: 14,
      );

  static get bodyMediumRobotoOnSecondaryContainer =>
      theme.textTheme.bodyMedium!.roboto.copyWith(
        color: theme.colorScheme.onSecondaryContainer,
        fontSize: 13,
      );

  static get bodyMediumRobotoff333333 =>
      theme.textTheme.bodyMedium!.roboto.copyWith(
        color: const Color(0XFF333333),
        fontSize: 14,
      );

  static get bodyMediumRoboto16 =>
      theme.textTheme.bodyMedium!.roboto.copyWith(
        color: const Color(0XFF333333),
        fontSize: 16,
      );

  static get bodySmall10 => theme.textTheme.bodySmall!.copyWith(
        fontSize: 10,
      );

  static get bodySmallGray200 => theme.textTheme.bodySmall!.copyWith(
        color: appTheme.gray200,
      );

  static get bodySmallGray500 => theme.textTheme.bodySmall!.copyWith(
        color: appTheme.gray500,
      );

  static get bodySmallGray500_1 => theme.textTheme.bodySmall!.copyWith(
        color: appTheme.gray500,
      );

  static get bodySmallGray700 => theme.textTheme.bodySmall!.copyWith(
        color: appTheme.gray700,
      );

  static get bodySmallGray70001 => theme.textTheme.bodySmall!.copyWith(
        color: appTheme.gray70001,
      );

  static get bodySmallGray700_1 => theme.textTheme.bodySmall!.copyWith(
        color: appTheme.gray700,
      );

  static get bodySmallNunitoBlue300 =>
      theme.textTheme.bodySmall!.nunito.copyWith(
        color: appTheme.blue300,
      );

  static get bodySmallNunitoff333333 =>
      theme.textTheme.bodySmall!.nunito.copyWith(
        color: const Color(0XFF333333),
      );

  static get bodySmallNunitoff59a9f2 =>
      theme.textTheme.bodySmall!.nunito.copyWith(
        color: const Color(0XFF59A9F2),
      );

  static get bodySmallOnPrimary => theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onPrimary,
      );

  static get bodySmallOnSecondaryContainer =>
      theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
      );

  static get bodySmallPrimary => theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.primary.withOpacity(1),
      );

  static get bodySmallRobotoOnSecondaryContainer =>
      theme.textTheme.bodySmall!.roboto.copyWith(
        color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
      );

  // Display text style
  static get displayMediumRed800 => theme.textTheme.displayMedium!.copyWith(
        color: appTheme.red800,
      );

  // Headline text style
  static get headlineLargeffaa0d0d => theme.textTheme.headlineLarge!.copyWith(
        color: const Color(0XFFAA0D0D),
      );

  static get headlineLargeffe40c0c => theme.textTheme.headlineLarge!.copyWith(
        color: const Color(0XFFE40C0C),
      );

  // Label text style
  static get labelLargeHelveticaOnSecondaryContainer =>
      theme.textTheme.labelLarge!.helvetica.copyWith(
        color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
        fontSize: 13,
      );

  static get labelLargeNunitoff59a9f2 =>
      theme.textTheme.labelLarge!.nunito.copyWith(
        color: const Color(0XFF59A9F2),
      );

  static get labelLargeff59a9f2 => theme.textTheme.labelLarge!.copyWith(
        color: const Color(0XFF59A9F2),
        fontSize: 13,
      );

  static get labelLarge16 => theme.textTheme.labelLarge!.copyWith(
    color: const Color(0XFF59A9F2),
    fontSize: 16,
  );
  static get labelLarge16red => theme.textTheme.labelLarge!.copyWith(
    color: const Color(0xFFFF0000), // Example: A custom red color using hex
    fontSize: 16,
  );

  static get labelLarge14 => theme.textTheme.labelLarge!.copyWith(
    color: const Color(0XFF59A9F2),
    fontSize: 14,
  );

  static get labelLargeffffffff => theme.textTheme.labelLarge!.copyWith(
        color: const Color(0XFFFFFFFF),
        fontSize: 13,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.underline,
        decorationColor: ColorsContent.whiteText,
      );

  // Title text style
  static get titleLargeBlue300 => theme.textTheme.titleLarge!.copyWith(
        color: appTheme.blue300,
        fontSize: 21,
      );

  static get titleLargeGray50 => theme.textTheme.titleLarge!.copyWith(
        color: appTheme.gray50,
      );

  static get titleLargeff000000 => theme.textTheme.titleLarge!.copyWith(
        color: const Color(0XFF000000),
      );

  static get titleMedium16 => theme.textTheme.titleMedium!.copyWith(
        fontSize: 16,
      );

  static get titleMediumBlue300 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.blue300,
        fontSize: 16,
      );

  static get titleMediumGray500 => theme.textTheme.titleMedium!.copyWith(
        color: appTheme.gray500,
      );

  static get titleMediumOnSecondaryContainer =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
      );

  static get titleMediumOnSecondaryContainerMedium =>
      theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  static get titleMediumff000000 => theme.textTheme.titleMedium!.copyWith(
        color: const Color(0XFF000000),
        fontSize: 16,
      );

  static get titleMediumff333333 => theme.textTheme.titleMedium!.copyWith(
        color: const Color(0XFF333333),
        fontSize: 16,
      );

  static get titleMediumffffffff => theme.textTheme.titleMedium!.copyWith(
        color: const Color(0XFFFFFFFF),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );

  static get titleMediumffffffff15 => theme.textTheme.titleMedium!.copyWith(
        color: const Color(0XFFFFFFFF),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      );

  static get titleMediumffffffff13 => theme.textTheme.titleMedium!.copyWith(
        color: const Color(0XFFFFFFFF),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );

  static get titleSmallBlue300 => theme.textTheme.titleSmall!.copyWith(
        color: appTheme.blue300,
      );

  static get titleSmallHelveticaOnPrimary =>
      theme.textTheme.titleSmall!.helvetica.copyWith(
        color: theme.colorScheme.onPrimary,
      );

  static get titleSmallHelveticaOnSecondaryContainer =>
      theme.textTheme.titleSmall!.helvetica.copyWith(
        color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
      );

  static get titleSmallOnSecondaryContainer =>
      theme.textTheme.titleSmall!.copyWith(
        color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
        fontWeight: FontWeight.w500,
      );

  static get titleSmallOnSecondaryContainer15 =>
      theme.textTheme.titleSmall!.copyWith(
        color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
        fontSize: 15,
      );

  static get titleSmallOnSecondaryContainer_1 =>
      theme.textTheme.titleSmall!.copyWith(
        color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
      );

  static get titleSmallRobotoff333333 =>
      theme.textTheme.titleSmall!.roboto.copyWith(
        color: const Color(0XFF333333),
        fontWeight: FontWeight.w900,
      );

  static get titleSmallRobotoff333333ExtraBold =>
      theme.textTheme.titleSmall!.roboto.copyWith(
        color: const Color(0XFF333333),
        fontWeight: FontWeight.w800,
      );

  static get titleSmallRobotoff333333ExtraBoldDelete =>
      theme.textTheme.titleSmall!.roboto.copyWith(
        color: const Color(0XFF333333),
        fontWeight: FontWeight.w800,
        fontSize: 16
      );

  static blackTextStyleCustom({required double size}) {
    return TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w800,
      fontSize: size,
    );
  }

  static blackTextStyleCustomWhiteW800({required double size}) {
    return TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w800,
      fontSize: size,
    );
  }

  static blackText20000000W700() {
    return TextStyle(
      color: ColorsContent.blackText,
      fontWeight: FontWeight.w700,
      fontSize: 20,
    );
  }

  static blackText18000000W700() {
    return TextStyle(
      color: ColorsContent.blackText,
      fontWeight: FontWeight.w700,
      fontSize: 18,
    );
  }

  static blackText16000000W600() {
    return TextStyle(
      color: ColorsContent.blackText,
      fontWeight: FontWeight.w600,
      fontSize: 16,
    );
  }

  static blackText16000000W700() {
    return TextStyle(
      color: ColorsContent.blackText,
      fontWeight: FontWeight.w700,
      fontSize: 16,
    );
  }

  static blackText15GreyTextW400() {
    return TextStyle(
      color: ColorsContent.greyText,
      fontWeight: FontWeight.w400,
      fontSize: 15,
    );
  }

  static blackText17000000W400() {
    return TextStyle(
      color: ColorsContent.blackText,
      fontWeight: FontWeight.w400,
      fontSize: 17,
    );
  }

  static blackText24000000W500() {
    return TextStyle(
      color: ColorsContent.blackText,
      fontWeight: FontWeight.w500,
      fontSize: 24,
    );
  }
}

extension on TextStyle {
  // TextStyle get openSans {
  //   return copyWith(
  //     fontFamily: 'Open Sans',
  //   );
  // }

  TextStyle get roboto {
    return copyWith(
      fontFamily: 'Roboto',
    );
  }

  TextStyle get nunito {
    return copyWith(
      fontFamily: 'Nunito',
    );
  }

  TextStyle get helvetica {
    return copyWith(
      fontFamily: 'Helvetica',
    );
  }
}
