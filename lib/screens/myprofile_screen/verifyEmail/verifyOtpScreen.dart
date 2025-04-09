import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/custom_pin_code_text_field.dart';
import 'package:provider/provider.dart';

import '../../../utils/core/image_constant.dart';
import '../../../utils/theme/colors.dart';
import '../../../utils/theme/custom_button_style.dart';
import '../../../utils/theme/custom_text_style.dart';
import '../../../utils/theme/theme_helper.dart';
import '../../../widgets/custom_image_view.dart';
import '../../../widgets/functions/snack_bar.dart';
import '../../dash_borad_screen/provider/dash_board_provider.dart';
import '../../no_internet/duplicate_screen.dart';
import '../../phone_singin_screen/provider/phone_sign_in_provider.dart';
import '../myprofile_screen.dart';


class VerifyOtpScreen extends StatelessWidget {
  const VerifyOtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: ConnectivityWidget(
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          appBar: Platform.isIOS
              ? AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          )
              : null,
          body: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
                color: ColorsContent.homeBackGroundColor,
                image: DecorationImage(
                    image: AssetImage(ImageConstant.gradientBackground),
                    fit: BoxFit.cover)),
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(
                horizontal: 49,
                vertical: 175,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 34,
                    ),
                    CustomImageView(
                        imagePath: ImageConstant.imgNumuLogo, height: 68, width: 280),
                    const SizedBox(
                      height: 50,
                    ),
                    const Text(
                      "Enter the code sent to your email",
                      style:  TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Open Sans',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Consumer<EditProfileProvider>(
                        builder: (context, editProfileProvider, _) {
                          return CustomPinCodeTextField(
                            context: context,
                            onChanged: (value) {
                              editProfileProvider.addOtpFunction(value: value);
                            },
                          );
                        }),
                    const SizedBox(
                      height: 35,
                    ),
                Consumer2<DashBoardProvider,EditProfileProvider>(
                  builder: (context, dashBoardProvider,editProfileProvider, _) {
                    return CustomElevatedButton(
                      loading: editProfileProvider.verifyOtpLoading,
                      height: 40,
                      text: "Submit",
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      buttonStyle: CustomButtonStyles.signInButton,
                      buttonTextStyle: CustomTextStyles.titleSmallHelveticaOnSecondaryContainer,
                      onPressed: () async {
                        if(editProfileProvider.otp.isNotEmpty){
                          await editProfileProvider.verifyOtpFunction(context);
                          editProfileProvider.clearTextEditingController();
                          HomeProvider homeProvider = Provider.of<HomeProvider>(context, listen: false);
                          // You don't need to re-declare editProfileProvider
                          homeProvider.fetchChartView(context);
                         // homeProvider.fetchJournals(initial: true);
                          editProfileProvider.fetchUserProfile();
                          if(editProfileProvider.verifyOtpStatus == 200){
                            dashBoardProvider.changeCommentPage(
                              index: 8,
                            );
                            //Navigator.of(context).pop();
                
                          }else{

                          }
                        }else{
                          showToast(
                            context: context,
                            message: "Please enter your otp",
                          );
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
      ),
    );
  }
}