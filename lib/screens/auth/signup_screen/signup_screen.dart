import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/auth/sign_in/widget/sign_in_widget.dart';
import 'package:mentalhelth/screens/auth/signup_screen/provider/signup_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/custom_text_form_field.dart';
import 'package:provider/provider.dart';

// ignore_for_file: must_be_immutable
class SignupScreen extends StatelessWidget {
  SignupScreen({Key? key}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Navigate back to the previous screen
            },
          ),),
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        body: backGroundImager(
          size: size,
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: _formKey,
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.only(left: 51, top: 208, right: 51),
                child: Consumer<SignUpProvider>(
                    builder: (contexts, signUpProvider, _) {
                  return PopScope(
                    canPop: true,
                    onPopInvoked: (value) {
                      signUpProvider.clearSignupControllers();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomImageView(
                          imagePath: ImageConstant.imgLogo,
                          height: 68,
                          width: 280,
                        ),
                        const SizedBox(
                          height: 27,
                        ),
                        CustomTextFormField(
                          hintStyle: theme.textTheme.bodySmall,
                          controller: signUpProvider.nameEditTextController,
                          hintText: "Your Name",
                        ),
                        const SizedBox(
                          height: 13,
                        ),
                        CustomTextFormField(
                          hintStyle: theme.textTheme.bodySmall,
                          controller: signUpProvider.emailEditTextController,
                          hintText: "Your Email ID",
                          textInputType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            // Regular expression for validating email format
                            String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                            RegExp regex = RegExp(pattern);
                            if (!regex.hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null; // Return null if the input is valid
                          },
                        ),

                        const SizedBox(
                          height: 12,
                        ),
                        CustomTextFormField(
                          hintStyle: theme.textTheme.bodySmall,
                          controller: signUpProvider.passwordEditTextController,
                          hintText: "Password",
                          textInputType: TextInputType.visiblePassword,
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        CustomTextFormField(
                          hintStyle: theme.textTheme.bodySmall,
                          controller:
                              signUpProvider.confirmPasswordEditTextController,
                          hintText: "Retype the Password",
                          textInputType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          obscureText: true,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        // _buildSignUpButton(
                        //   context,
                        // ),
                        buildSignInButton(
                          context,
                          isLoading: signUpProvider.signUpLoading,
                          buttonText: "Sign up",
                          onPressed: () async {
                            signUpProvider.callSignInButton(context);
                          },
                        ),
                        const SizedBox(height: 5)
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Section Widget
// Widget _buildSignUpButton(BuildContext context) {
//   return Consumer<SignUpProvider>(builder: (context, signUpProvider, _) {
//     return CustomElevatedButton(
//       loading: signUpProvider.signUpLoading,
//       height: 40,
//       text: "Sign up",
//       buttonStyle: CustomButtonStyles.outlinePrimary,
//       buttonTextStyle:
//           CustomTextStyles.titleSmallHelveticaOnSecondaryContainer,
//       onPressed: () {
//         if (signUpProvider.nameEditTextController.text.isEmpty) {
//           showCustomSnackBar(context: context, message: 'Enter your name');
//         } else if (signUpProvider.emailEditTextController.text.isEmpty) {
//           showCustomSnackBar(context: context, message: 'Enter your email');
//         } else if (!isEmailValid(
//             signUpProvider.emailEditTextController.text)) {
//           showCustomSnackBar(
//               context: context, message: 'Enter a valid email address');
//         } else if (signUpProvider.passwordEditTextController.text.isEmpty) {
//           showCustomSnackBar(
//               context: context, message: 'Enter your password');
//         } else if (signUpProvider.passwordEditTextController.text !=
//             signUpProvider.confirmPasswordEditTextController.text) {
//           showCustomSnackBar(
//               context: context, message: 'Entered password not match');
//         } else {
//           signUpProvider.signUpFunction(
//             context,
//             firstName: signUpProvider.nameEditTextController.text,
//             email: signUpProvider.emailEditTextController.text,
//             password: signUpProvider.passwordEditTextController.text,
//           );
//         }
//       },
//     );
//   });
// }
}
