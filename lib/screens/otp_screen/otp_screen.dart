import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/custom_pin_code_text_field.dart';
import 'package:provider/provider.dart';

import '../../utils/core/image_constant.dart';
import '../../utils/theme/custom_button_style.dart';
import '../../utils/theme/custom_text_style.dart';
import '../../utils/theme/theme_helper.dart';
import '../../widgets/custom_image_view.dart';
import '../phone_singin_screen/provider/phone_sign_in_provider.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            // IconButton(
            //   icon: Icon(
            //     Icons.arrow_back_ios,
            //     color: theme.colorScheme.primary, // You can set the color based on your theme
            //   ),
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            // ),
          ],
        ),
        body: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
              color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
              image: DecorationImage(
                  image: AssetImage(ImageConstant.imgGroup22),
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
                const SizedBox(
                  height: 34,
                ),
                CustomImageView(
                    imagePath: ImageConstant.imgLogo, height: 68, width: 280),
                const SizedBox(
                  height: 90,
                ),
                Text(
                  "Enter the code sent to your email ",
                  style: theme.textTheme.bodyLarge,
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
                  height: 29,
                ),
                Consumer<PhoneSignInProvider>(
                    builder: (context, phoneSignInProvider, _) {
                  return CustomElevatedButton(
                    loading: phoneSignInProvider.verifyLoading,
                    height: 40,
                    text: "Sign in",
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    buttonStyle: CustomButtonStyles.outlinePrimary,
                    buttonTextStyle: CustomTextStyles
                        .titleSmallHelveticaOnSecondaryContainer,
                    onPressed: () async {
                      await phoneSignInProvider.verifyFunction(
                        context,
                        phone: phoneSignInProvider.phoneNumberController.text,
                        otp: phoneSignInProvider.otp.toString(),
                      );

                      if(phoneSignInProvider.statusOtpVerify == 201 || phoneSignInProvider.statusOtpVerify == 200){
                        HomeProvider homeProvider =
                        Provider.of<HomeProvider>(context, listen: false);
                        EditProfileProvider editProfileProvider =
                        Provider.of<EditProfileProvider>(context,
                            listen: false);
                        homeProvider.fetchChartView(context);
                        //   homeProvider.fetchJournals(initial: true);
                        editProfileProvider.fetchUserProfile();
                      }
                     // phoneSignInProvider.phoneNumberController.clear();

                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
