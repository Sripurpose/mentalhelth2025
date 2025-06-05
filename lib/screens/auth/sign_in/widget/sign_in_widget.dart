import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/auth/signup_screen/signup_screen.dart';
import 'package:mentalhelth/screens/phone_singin_screen/phone_sign_in_screen.dart';
import 'package:mentalhelth/utils/theme/custom_button_style.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/custom_outlined_button.dart';
import 'package:mentalhelth/widgets/custom_text_form_field.dart';

/// Section Widget
Widget buildEmailField(BuildContext context,
    {required TextEditingController emailFieldController}) {
  return Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: 4,
    ),
    child: CustomTextFormFieldEmailAndPasswordNumu(
      controller: emailFieldController,
      hintText: "Your Email ID",
      hintStyle: theme.textTheme.bodySmall,
      textInputType: TextInputType.emailAddress,
    ),
  );
}

/// Section Widget
Widget buildPasswordField(BuildContext context,
    {required TextEditingController passwordFieldController}) {
  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomTextFormFieldEmailAndPasswordNumuEye(
        controller: passwordFieldController,
        hintText: "Password",
        hintStyle: theme.textTheme.bodySmall,
        textInputAction: TextInputAction.done,
        textInputType: TextInputType.visiblePassword,
        obscureText: true,
      ));
}

/// Section Widget
Widget buildSignInButton(BuildContext context,
    {required bool isLoading,
    required String buttonText,
    required void Function()? onPressed}) {
  return CustomElevatedButton(
    loading: isLoading,
    height: 45,
    text: buttonText,
    margin: const EdgeInsets.symmetric(
      horizontal: 4,
    ),
    buttonStyle: CustomButtonStyles.signInButton,
    buttonTextStyle: CustomTextStyles.titleSmallHelveticaOnSecondaryContainer,
    onPressed: onPressed,
  );
}


Widget buildLandingSignInButton(BuildContext context,
    {required bool isLoading,
      required String buttonText,
      required void Function()? onPressed}) {
  return CustomElevatedButton(
    loading: isLoading,
    height: 45,
    width:  300,
    text: buttonText,
    margin: const EdgeInsets.symmetric(
      horizontal: 4,
    ),
    buttonStyle: CustomButtonStyles.signInButton,
    buttonTextStyle: CustomTextStyles.titleSmallHelveticaOnSecondaryContainer,
    onPressed: onPressed,
  );
}

/// Section Widget
Widget buildContinueWithPhoneButton(
  BuildContext context, {
  required String message,
  required String imageMessage,
  required VoidCallback? onPressed,
}) {
  return CustomOutlinedButtonContinueWithPhoneNumu(
    text: message,
    margin: const EdgeInsets.only(
      right: 8,
    ),
    leftIcon: SizedBox(
      child: CustomImageView(
        imagePath: imageMessage,
        height: 24,
        width: 24,
      ),
    ),
    buttonStyle: CustomButtonStyles.continueWithPhone,
    onPressed: onPressed
  );
}

onTapSignUpButton(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => SignupScreen(),
    ),
  );
}

/// Navigates to the signinOneScreen when the action is triggered.
onTapContinueWithPhoneButton(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => const PhoneSignInScreen(),
    ),
  );
}
