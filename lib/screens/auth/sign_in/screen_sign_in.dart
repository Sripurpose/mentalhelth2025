import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/auth/sign_in/landing_register_screen.dart';
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
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/theme/theme_helper.dart';
import 'forgot_password/forgot_password_screen.dart';
import 'coninue_with_google_class.dart';

class ScreenSignIn extends StatefulWidget {
  const ScreenSignIn({Key? key}) : super(key: key);

  @override
  _ScreenSignInState createState() => _ScreenSignInState();
}

class _ScreenSignInState extends State<ScreenSignIn> {
  late SignInProvider signInProvider;
  var logger = Logger();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSignedIn = false;


  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
    signInProvider = Provider.of<SignInProvider>(context, listen: false);
    scheduleMicrotask(() async {
      String deviceType = Platform.isAndroid ? 'android' : 'ios';
      // First, call fetchSettings
      await signInProvider.fetchAppRegister(context,deviceType: deviceType);
    });
  }

  Future<void> handleGoogleSignInSignOut() async {
    if (_isSignedIn) {
      await googleSignOut();
    } else {
      await googleSignIn();
    }
    setState(() {
      _isSignedIn = !_isSignedIn;
    });
  }

  Future googleSignIn() async {
    try {
      final user = await GoogleSignInService.login();
      await user?.authentication;
      logger.w(user!.displayName.toString());
      signInProvider.continueWithGoogleName = user.displayName;
      logger.w(signInProvider.continueWithGoogleName);
      signInProvider.continueWithGoogleMail = user.email;
      logger.w(signInProvider.continueWithGoogleMail);
      signInProvider.continueWithGoogleId = user.id;
      logger.w(signInProvider.continueWithGoogleId);
      if (context.mounted) {
        // Social media function
        await signInProvider.socialMediaFunction(
          context,
          googleid: signInProvider.continueWithGoogleId,
        );

        HomeProvider homeProvider =
        Provider.of<HomeProvider>(context, listen: false);
        EditProfileProvider editProfileProvider =
        Provider.of<EditProfileProvider>(context,
            listen: false);
      //  homeProvider.fetchChartView(context);
        //   homeProvider.fetchJournals(initial: true);
        editProfileProvider.fetchUserProfile(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Column(
            children: [
              Text(
                "Name: ${user.displayName}\nEmail: ${user.email}\nId: ${user.id}",
              ),
            ],
          ),
        ));
      }
    } catch (exception) {
      logger.w(exception.toString());
    }
  }

  Future googleSignOut() async {
    try {
      await GoogleSignInService.logout();
      logger.w('Sign Out Success');
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Sign Out Success')));
      }
    } catch (exception) {
      logger.w(exception.toString());
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Sign Out Failed')));
      }
    }
  }

  Future<void> _launchInAppWithBrowserOptions(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppBrowserView,
      browserConfiguration: const BrowserConfiguration(showTitle: true),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final signInProvider = Provider.of<SignInProvider>(context, listen: false);
    var isRequiredValue =
        signInProvider.settingsRegisterModel?.settings?[0].isRequired;

    final settings = signInProvider.settingsRegisterModel?.showPhonelogin;
    print("isRequired value: $isRequiredValue");

    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: Platform.isIOS
            ?
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child:  GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LandingRegisterScreenScreen()),
                  );
                },
                child: CustomImageView(
                  imagePath: ImageConstant.allBackIcon,
                ),
              ),
            ),
          ),
        )
            :  AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child:  GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LandingRegisterScreenScreen()),
                  );
                },
                child: CustomImageView(
                  imagePath: ImageConstant.allBackIcon,
                ),
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            color: ColorsContent.optimalStateColor,
            image: DecorationImage(
              image: AssetImage(ImageConstant.gradientBackgroundNumu),
              fit: BoxFit.cover,
            ),
          ),
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
                      imagePath: ImageConstant.newLogoNumu,
                      height: 130,
                      width: 280,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    Consumer<SignInProvider>(
                        builder: (context, signInProvider, _) {
                      return PopScope(
                        canPop: true,
                        onPopInvoked: (value) {
                          signInProvider.clearTextEditingController();
                        },
                        child: buildEmailField(
                          context,
                          emailFieldController:
                              signInProvider.emailFieldController,
                        ),
                      );
                    }),
                    const SizedBox(
                      height: 12,
                    ),
                    Consumer<SignInProvider>(
                        builder: (context, signInProvider, _) {
                      return buildPasswordField(
                        context,
                        passwordFieldController:
                            signInProvider.passwordFieldController,
                      );
                    }),
                    const SizedBox(
                      height: 14,
                    ),
                    Consumer3<SignInProvider, HomeProvider,
                            EditProfileProvider>(
                        builder: (context, signInProvider, homeProvider,
                            editProfileProvider, _) {
                      return buildSignInButton(
                        context,
                        isLoading: signInProvider.loginLoading,
                        buttonText: "Sign in",
                        onPressed: () async {
                          String deviceType = Platform.isAndroid ? 'android' : 'ios';
                          FocusScope.of(context).unfocus();
                          await signInProvider.callSignInButton(context,deviceType);
                          if(signInProvider.loginStatus == 200 || signInProvider.loginStatus == 201){
                         //   homeProvider.fetchChartView(context);
                            //  homeProvider.fetchJournals(initial: true);
                            editProfileProvider.fetchUserProfile(context);
                          }
                        },

                      );
                    }),
                    const SizedBox(
                      height: 11,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 9.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Consumer<SignInProvider>(
                              builder: (context, signInProvider, _) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child:  Text(
                                "Forgot your password ?",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                  color: ColorsContent.whatsOnYourMindBoxColor,
                                ),
                              ),
                            );
                          }),
                          signInProvider.settingsRegisterList.isNotEmpty
                              ? Text(
                                  "",
                                  style: CustomTextStyles.bodySmallOnPrimary,
                                )
                              : Text(
                                  "|",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              color: ColorsContent.whatsOnYourMindBoxColor,
                            ),
                                ),
                          _isLoading
                              ? const Column(
                                  children: [
                                    Center(
                                      child: SpinKitFadingCircle(
                                        color: Colors.transparent,
                                        size: 20.0,
                                      ),
                                    ),
                                  ],
                                )
                              : signInProvider.settingsRegisterList.isNotEmpty
                                  ? const SizedBox()
                                  : GestureDetector(
                                      onTap: () {
                                        onTapSignUpButton(context);
                                      },
                                      child: Text(
                                        "Sign up",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Poppins',
                                          color: ColorsContent.whatsOnYourMindBoxColor,
                                        ),
                                      ),
                                    ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 44,
                    ),
                    if(settings == "1")
                    Consumer<SignInProvider>(
                        builder: (context, signInProvider, _) {
                      return buildContinueWithPhoneButton(
                        context,
                        message: "Continue with Phone",
                        imageMessage: ImageConstant.mobileLight,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          signInProvider.clearTextEditingController();
                          onTapContinueWithPhoneButton(context);
                        },
                      );
                    }),
                    SizedBox(
                      height: size.height * 0.05,
                    ),
                  ],
                ),
              ),
            ),
          )),
        ),
      ),
    );
  }
}

