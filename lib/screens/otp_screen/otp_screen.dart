import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/custom_pin_code_text_field.dart';
import 'package:provider/provider.dart';

import '../../utils/core/image_constant.dart';
import '../../utils/theme/colors.dart';
import '../../utils/theme/custom_button_style.dart';
import '../../utils/theme/custom_text_style.dart';
import '../../utils/theme/theme_helper.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/functions/snack_bar.dart';
import '../no_internet/duplicate_screen.dart';
import '../phone_singin_screen/provider/phone_sign_in_provider.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: ConnectivityWidget(
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child:  GestureDetector(
                  onTap: (){
                    Navigator.of(context).pop();
                  },
                  child: CustomImageView(
                    imagePath: ImageConstant.allBackIcon,
                  ),
                ),
              ),
            ),
          ),
          body: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
                color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
                image: DecorationImage(
                    image: AssetImage(ImageConstant.gradientBackgroundNumu),
                    fit: BoxFit.cover)),
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(
                horizontal: 49,
                vertical: 175,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //const SizedBox(height: 34,),
                  CustomImageView(
                    imagePath: ImageConstant.newLogoNumu,
                    height: 130,
                    width: 280,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  const Text(
                    "Enter the code sent to your phone ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Open Sans',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Consumer<PhoneSignInProvider>(
                      builder: (context, phoneSignInProvider, _) {
                    return CustomPinCodeTextField(
                      context: context,
                      onChanged: (value) {
                        phoneSignInProvider.addOtpFunction(value: value);
                      },
                    );
                  }),
                  const SizedBox(
                    height: 20,
                  ),
                  Consumer<PhoneSignInProvider>(
                    builder: (context, phoneSignInProvider, _) {
                      return CustomElevatedButton(
                        loading: phoneSignInProvider.verifyLoading,
                        height: 40,
                        text: "Sign in",
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        buttonStyle: CustomButtonStyles.signInButton,
                        buttonTextStyle: CustomTextStyles.titleSmallHelveticaOnSecondaryContainer,
                        onPressed: () async {
                          FocusScope.of(context).unfocus(); // close keyboard

                          if (phoneSignInProvider.otp == null || phoneSignInProvider.otp.trim().isEmpty) {
                            showCustomSnackBar(context: context, message: 'Please enter the OTP');
                            return;
                          }


                          await phoneSignInProvider.verifyFunction(
                            context,
                            phone: phoneSignInProvider.phoneNumberController.text,
                            otp: phoneSignInProvider.otp.toString(),
                          );

                          if (phoneSignInProvider.statusOtpVerify == 200 ||
                              phoneSignInProvider.statusOtpVerify == 201) {

                            final homeProvider = Provider.of<HomeProvider>(context, listen: false);
                            final editProfileProvider = Provider.of<EditProfileProvider>(context, listen: false);

                            // homeProvider.fetchChartView(context);
                            editProfileProvider.fetchUserProfile(context);

                            // Navigate to next screen and prevent back navigation
                            Navigator.of(context).pushReplacementNamed('/home'); // example route

                          } else {
                            // Clear any existing snackbar
                            ScaffoldMessenger.of(context).clearSnackBars();

                            if (context.mounted) {
                              showCustomSnackBar(context: context, message: 'Invalid OTP');
                            }
                          }
                        },
                      );
                    },
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
