import 'dart:io';

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

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}



class _OtpScreenState extends State<OtpScreen> {

  late PhoneSignInProvider phoneSignInProvider;

  @override
  void initState() {
    phoneSignInProvider = Provider.of<PhoneSignInProvider>(context, listen: false);
    phoneSignInProvider.otp = "";
    super.initState();
    // You can add initialization logic here
    print("OtpScreen initialized");
  }
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
                child: GestureDetector(
                  onTap: () {
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
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(horizontal: 49, vertical: 175),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.newLogoNumu,
                    height: 130,
                    width: 280,
                    color: Colors.white,
                  ),
                  Platform.isIOS ? const SizedBox(height: 100):
                  const SizedBox(height: 30),
                  const Text(
                    "Enter the code sent to your phone ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Open Sans',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Consumer<PhoneSignInProvider>(
                    builder: (context, phoneSignInProvider, _) {
                      return CustomPinCodeTextField(
                        context: context,
                        onChanged: (value) {
                          phoneSignInProvider.addOtpFunction(value: value);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
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

                          print("phoneSignInProvider.otp ${phoneSignInProvider.otp}");

                          if (phoneSignInProvider.otp == null || phoneSignInProvider.otp.isEmpty) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            if (context.mounted) {
                              showCustomSnackBar(context: context, message: 'Please enter a OTP');
                            }

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

                            editProfileProvider.fetchUserProfile(context);
                          } else {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            if (context.mounted) {
                              phoneSignInProvider.otp = "";
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

