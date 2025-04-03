import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/auth/sign_in/provider/sign_in_provider.dart';
import 'package:mentalhelth/screens/auth/sign_in/widget/sign_in_widget.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/screens/myprofile_screen/verifyEmail/verifyOtpScreen.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:provider/provider.dart';

import '../../no_internet/duplicate_screen.dart';

class SendOtpMailScreen extends StatefulWidget {
  const SendOtpMailScreen({Key? key}) : super(key: key);

  @override
  _SendOtpMailScreenState createState() => _SendOtpMailScreenState();
}

class _SendOtpMailScreenState extends State<SendOtpMailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: ConnectivityWidget(
        child: Scaffold(
          body: backGroundImager(
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
                        SizedBox(
                          height: size.height * 0.05,
                        ),
                        CustomImageView(
                          imagePath: ImageConstant.imgLogo,
                          height: 68,
                          width: 280,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Center(child: Text("Verify your email",  style: CustomTextStyles.bodyMedium18)),
                        const SizedBox(
                          height: 20,
                        ),
                        Consumer<EditProfileProvider>(builder: (context, editProfileProvider, _) {
                          return PopScope(
                            canPop: true,
                            onPopInvoked: (value) {
                              editProfileProvider.clearTextEditingController();
                            },
                            child: buildEmailField(
                              context,
                              emailFieldController: editProfileProvider.sendOtpEmailController,
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
                              isLoading: editProfileProvider.sendOtpLoading,
                              buttonText: "Verify",
                              onPressed: () async {
                                if(editProfileProvider.sendOtpEmailController.text.isNotEmpty){
                                  FocusScope.of(context).unfocus();
                                  await editProfileProvider.sendOtpFunction(context);
                                  if(editProfileProvider.sendOtpStatus == 200){

                                    Navigator.of(context)
                                        .push(
                                      MaterialPageRoute(
                                        builder: (context) => const VerifyOtpScreen(),
                                      ),
                                    );

                                    //Navigator.of(context).pop();

                                  }else{
                                    showToast(
                                      context: context,
                                      message: editProfileProvider.sendOtpMailMessage ?? "",
                                    );
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
                        const SizedBox(
                          height: 20,
                        ),  Center(child: Text(" A 6 digit code has been sent to your email !",  style: CustomTextStyles.bodyMedium12)),


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

