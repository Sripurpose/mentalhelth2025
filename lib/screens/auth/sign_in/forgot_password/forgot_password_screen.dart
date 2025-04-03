import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/auth/sign_in/provider/sign_in_provider.dart';
import 'package:mentalhelth/screens/auth/sign_in/widget/sign_in_widget.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:provider/provider.dart';

import '../../../no_internet/duplicate_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ConnectivityWidget(
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: ColorsContent.newThemeColor,
          leading: IconButton(
          icon: const Icon(
            color: Colors.white,
            Icons.arrow_back_ios,
          ),
      onPressed: () {
      Navigator.of(context).pop(); // Navigate back to the previous screen
      },
      ),),
          body: backGroundImagerGradient(
            size: size,
            padding: EdgeInsets.zero,
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Form(
                  key: _formKey,
                  child: Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        CustomImageView(
                          imagePath: ImageConstant.imgNumuLogo,
                          height: 100,
                          width: 280,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        const Center(child: Text("Forgot Password",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Urbanist',
                            color: Colors.white,
                          ),)
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Consumer<SignInProvider>(builder: (context, signInProvider, _) {
                          return PopScope(
                            canPop: true,
                            onPopInvoked: (value) {
                              signInProvider.clearTextEditingController();
                            },
                            child: buildEmailField(
                              context,
                              emailFieldController: signInProvider.forgotEmailFieldController,
                            ),
                          );
                        }),
                        const SizedBox(
                          height: 20,
                        ),
                        Consumer3<SignInProvider, HomeProvider, EditProfileProvider>(
                          builder: (context, signInProvider, homeProvider, editProfileProvider, _) {
                            return buildSignInButton(
                              context,
                              isLoading: signInProvider.forgetLoading,
                              buttonText: "Submit",
                              onPressed: () async {
                                if(signInProvider.forgotEmailFieldController.text.isNotEmpty){
                                  FocusScope.of(context).unfocus();
                                  await signInProvider.forgetPassword(context);
                                  if(signInProvider.forgotPasswordStatus == 200){

                                    Navigator.of(context).pop();

                                  }else{
                                    // showToast(
                                    //   context: context,
                                    //   message: signInProvider.forgotPasswordMessage ?? "",
                                    // );
                                  }
                                }else{
                                    showToast(
                                      context: context,
                                      message: "Please enter your email",
                                    );
                                }

                                // homeProvider.fetchChartView(context);
                                // homeProvider.fetchJournals(initial: true);
                                // editProfileProvider.fetchUserProfile();
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
        ),
      ),
    );
  }
}

