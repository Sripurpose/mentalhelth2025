import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/auth/sign_in/provider/sign_in_provider.dart';
import 'package:mentalhelth/screens/subscription_view/subscription_in_app_screen.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/theme/custom_text_style.dart';
import '../../utils/theme/theme_helper.dart';
import '../auth/sign_in/coninue_with_google_class.dart';
import '../auth/sign_in/landing_register_screen.dart';
import '../auth/splash/splash.dart';

class VersionUpdateCheckScreen extends StatefulWidget {
  const VersionUpdateCheckScreen(
      {Key? key,
        required this.message,
        required this.title,
        required this.notifyMe})
      : super(key: key);

  final String message;
  final String title;
  final String notifyMe;
  @override
  _VersionUpdateCheckScreenState createState() =>
      _VersionUpdateCheckScreenState();
}

class _VersionUpdateCheckScreenState extends State<VersionUpdateCheckScreen> {
  late SignInProvider signInProvider;
  var logger = Logger();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  late String linkUrl;

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
      // await signInProvider.fetchSettings(context);
    });
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

  Future<void> _launchInAppWithBrowserOptions(BuildContext context, Uri url) async {
    // Check if the URL scheme is "mental"

    // Create a Completer to handle navigation after closing the browser
    final Completer<void> completer = Completer<void>();

    // Check the platform and set the update URL accordingly
    Uri updateUrl = Platform.isAndroid
        ? Uri.parse("https://play.google.com/store/apps/details?id=com.mentalhelth.mentalhelth")
        : Uri.parse("https://apps.apple.com/app/id6736739491"); // Replace with your iOS App Store link

    // Launch the update URL in an in-app browser if it's not a "mental" URL
    try {
      if (await launchUrl(
        updateUrl,
        mode: LaunchMode.inAppBrowserView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      )) {
        // Wait for the user to close the browser
        completer.future.then((_) {
          // Navigate to SplashScreen after closing the browser
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SplashScreen(),
            ),
          );
        });
      } else {
        throw Exception('Could not launch $updateUrl');
      }

      // Simulate waiting for the browser to close (you might need a better way to detect this)
      await Future.delayed(const Duration(seconds: 5));
      completer.complete(); // Complete the completer when done
    } catch (e) {
      // Handle errors like invalid URLs
      print("Error launching URL: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final String androidUpdateUrl = "https://play.google.com/store/apps/details?id=com.mentalhelth.mentalhelth";
    final String iosUpdateUrl = "https://apps.apple.com/app/id6736739491"; // Replace with your iOS App Store link
    final signInProvider = Provider.of<SignInProvider>(context, listen: false);
    var isRequiredValue =
        signInProvider.settingsRegisterModel?.settings?[0].isRequired;

    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          // Returning false prevents the back press
          return false;
        },
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: size.height * 0.30,
                          ),
                          CustomImageView(
                            imagePath: ImageConstant.imgLogo,
                            height: 70,
                            width: 280,
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: size.height * 0.10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.title ?? '',
                                style: theme.textTheme.titleMedium,
                              ),
                              SizedBox(height: size.height * 0.02),
                              Text(
                                widget.message ?? '',
                                style: theme.textTheme.bodyMedium,
                              ),
                              SizedBox(height: size.height * 0.02),

                              // GestureDetector(
                              //   onTap: () {
                              //     Future.delayed(Duration(seconds: 2), () {
                              //       setState(() {
                              //         //signInProvider.fetchSettings(context);
                              //       });
                              //     });
                              //     String chatURL = signInProvider.settingsList[0].linkUrl ?? "";
                              //     logger.w("widget.linkUrl${ signInProvider.settingsList[0].linkUrl}");
                              //     var url = Uri.parse(chatURL);
                              //     if (signInProvider.settingsList[0].target ==
                              //         "external") {
                              //       // Navigator.of(context).push(
                              //       //   MaterialPageRoute(
                              //       //     builder: (context) =>
                              //       //         SubscriptionInAppScreen(
                              //       //           url: chatURL ?? "",
                              //       //         ),
                              //       //   ),
                              //       // );
                              //       _launchInAppWithBrowserOptions(context,url);
                              //     } else {
                              //       Navigator.of(context).push(
                              //         MaterialPageRoute(
                              //           builder: (context) =>
                              //               SubscriptionInAppScreen(
                              //                 url: widget.linkUrl ?? "",
                              //               ),
                              //         ),
                              //       );
                              //     }
                              //   },
                              //   child: Container(
                              //     padding: EdgeInsets.all(10.0),
                              //     // Add padding as needed
                              //     decoration: BoxDecoration(
                              //       color: Colors.transparent,
                              //       // Change to your desired background color
                              //       borderRadius: BorderRadius.circular(5.0),
                              //       // Optional: Add border radius
                              //       border: Border.all(
                              //         color: Colors.black,
                              //         // Change to your desired border color
                              //         width: 0.5, // Optional: Adjust border width
                              //       ),
                              //     ),
                              //     child: RichText(
                              //       text: TextSpan(
                              //         text: "Go to ",
                              //         // Regular text
                              //         style: theme.textTheme.bodyMedium,
                              //         // Regular style for "Go to"
                              //         children: [
                              //           TextSpan(
                              //             text: widget.link ?? '',
                              //             // The URL text
                              //             style: CustomTextStyles.labelLarge14
                              //                 .copyWith(
                              //               decorationColor: Colors.blue,
                              //               // Optional: change the color of the underline
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                          // SizedBox(
                          //   height: size.height * 0.04,
                          // ),
                          widget.notifyMe == "1" ?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () async {

                                  Uri updateUrl = Platform.isAndroid
                                      ? Uri.parse(androidUpdateUrl)
                                      : Uri.parse(iosUpdateUrl);

                                  // Launch the in-app browser with the correct URL
                                  await _launchInAppWithBrowserOptions(context, updateUrl);

                                },
                                child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    "Update",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                              ),

                            ],
                          ):
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () async {

                                },
                                child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    "Update",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pop(context);
                                  final prefs = await SharedPreferences.getInstance();
                                  prefs.setInt('lastSkippedTimestamp', DateTime.now().millisecondsSinceEpoch);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(5.0),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    "Skip",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ),
                              ),
                            ],
                          )

                        ],
                      ),
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
