import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/auth/sign_in/provider/sign_in_provider.dart';
import 'package:mentalhelth/screens/auth/sign_in/widget/sign_in_widget.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

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
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
    signInProvider = Provider.of<SignInProvider>(context, listen: false);
    scheduleMicrotask(() async {
      // First, call fetchSettings
      await signInProvider.fetchAppRegister(context);
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
        homeProvider.fetchChartView(context);
        //   homeProvider.fetchJournals(initial: true);
        editProfileProvider.fetchUserProfile();
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
    print("isRequired value: $isRequiredValue");

    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: Platform.isIOS
            ? AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        )
            : null, // No AppBar on Android
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
                      height: 40,
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
                          FocusScope.of(context).unfocus();
                          await signInProvider.callSignInButton(context);
                          homeProvider.fetchChartView(context);
                          //  homeProvider.fetchJournals(initial: true);
                          editProfileProvider.fetchUserProfile();
                        },
                      );
                    }),
                    const SizedBox(
                      height: 11,
                    ),
                    Row(
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
                            child: Text(
                              "Forgot your password ?",
                              style: CustomTextStyles.bodySmallOnPrimary,
                            ),
                          );
                        }),
                        isRequiredValue == "1"
                            ? Text(
                                "",
                                style: CustomTextStyles.bodySmallOnPrimary,
                              )
                            : Text(
                                "|",
                                style: CustomTextStyles.bodySmallOnPrimary,
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
                            : isRequiredValue == "1"
                                ? const SizedBox()
                                : GestureDetector(
                                    onTap: () {
                                      onTapSignUpButton(context);
                                    },
                                    child: Text(
                                      "Sign up",
                                      style:
                                          CustomTextStyles.bodySmallOnPrimary,
                                    ),
                                  ),
                      ],
                    ),
                    const SizedBox(
                      height: 44,
                    ),
                    Consumer<SignInProvider>(
                        builder: (context, signInProvider, _) {
                      return buildContinueWithPhoneButton(
                        context,
                        message: "Continue with Phone ",
                        imageMessage: ImageConstant.imgMobilelight,
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
                    // Column(
                    //   children: [
                    //     _isLoading
                    //         ? Shimmer.fromColors(
                    //             baseColor: Colors.grey[300]!,
                    //             highlightColor: Colors.grey[100]!,
                    //             child: Column(
                    //               children: [
                    //                 Center(
                    //                   child: Container(
                    //                     color: Colors.grey[100],
                    //                     height: 40.0,
                    //                     width: size.width * 0.75,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           )
                    //         : signInProvider.settingsRegisterModel?.settings?[0]
                    //                     .isRequired ==
                    //                 "1"
                    //             ? Column(
                    //                 children: [
                    //                   Text(
                    //                     signInProvider.settingsRegisterModel
                    //                             ?.settings?[0].message ??
                    //                         "",
                    //                     style:
                    //                         CustomTextStyles.bodySmallOnPrimary,
                    //                   ),
                    //                   GestureDetector(
                    //                     onTap: () {
                    //                       String chatURL = signInProvider
                    //                               .settingsRegisterModel
                    //                               ?.settings?[0]
                    //                               .linkUrl ??
                    //                           "";
                    //                       var url = Uri.parse(chatURL);
                    //                       _launchInAppWithBrowserOptions(url);
                    //                     },
                    //                     child:Text(
                    //                       signInProvider.settingsRegisterModel?.settings?[0].link ?? "",
                    //                       style: CustomTextStyles.labelLarge16.copyWith(
                    //                         decoration: TextDecoration.underline,
                    //                         decorationColor: Colors.blue, // Optional: change the color of the underline
                    //                         decorationThickness: 1.5, // Optional: adjust the thickness of the underline
                    //                       ),
                    //                     ),
                    //                   ),
                    //
                    //
                    //                 ],
                    //               )
                    //             : const SizedBox(),
                    //   ],
                    // ),

                    // const SizedBox(
                    //   height: 10,
                    // ),
                    // Consumer<SignInProvider>(
                    //     builder: (context, signInProvider, _) {
                    //   return buildContinueWithPhoneButton(
                    //     context,
                    //     message: "Continue with Facebook",
                    //     imageMessage: ImageConstant.imgFacebook,
                    //     onPressed: () {
                    //       signInProvider.signInWithFacebook();
                    //     },
                    //   );
                    // }),
                    // const SizedBox(
                    //   height: 8,
                    // // ),
                    // Consumer<SignInProvider>(
                    //   builder: (context, signInProvider, _) {
                    //     return buildContinueWithPhoneButton(
                    //       context,
                    //       message: _isSignedIn ? "Sign Out from Google" : "Continue with Google",
                    //       imageMessage: ImageConstant.imgGoogle,
                    //       onPressed: () async {
                    //         handleGoogleSignInSignOut();
                    //       },
                    //     );
                    //   },
                    // ),
                    // const SizedBox(
                    //   height: 8,
                    // ),
                    // Consumer<SignInProvider>(
                    //   builder: (context, signInProvider, _) {
                    //     return buildContinueWithPhoneButton(
                    //       context,
                    //       message: "Continue with Apple",
                    //       imageMessage: ImageConstant.imgPath4,
                    //       onPressed: () {
                    //         signInProvider.googleSignOut();
                    //       },
                    //     );
                    //   },
                    // ),
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

