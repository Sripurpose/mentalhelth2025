import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/auth/sign_in/provider/sign_in_provider.dart';
import 'package:mentalhelth/screens/auth/sign_in/screen_sign_in.dart';
import 'package:mentalhelth/screens/subscription_view/subscription_in_app_screen.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/theme/custom_text_style.dart';
import '../../../utils/theme/theme_helper.dart';

class LandingRegisterScreenScreen extends StatefulWidget {
  const LandingRegisterScreenScreen(
      {Key? key,})
      : super(key: key);

  @override
  _LandingRegisterScreenScreenState createState() =>
      _LandingRegisterScreenScreenState();
}

class _LandingRegisterScreenScreenState extends State<LandingRegisterScreenScreen> {
  late SignInProvider signInProvider;
  var logger = Logger();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

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



  Future<void> _launchInAppWithBrowserOptions(Uri url) async {
    // Check if the URL is a deep link
    if (url.scheme == "mental") {
      // Handle the deep link (navigate to a specific screen in your app)
      // For example, navigate to a MentalScreen page
      Navigator.pushNamed(context, '/mentalScreen', arguments: url);
    } else {
      // If it's a regular URL, open it in an in-app browser
      if (!await launchUrl(
        url,
        mode: LaunchMode.inAppBrowserView,
        browserConfiguration: const BrowserConfiguration(showTitle: true),
      )) {
        throw Exception('Could not launch $url');
      }
    }
  }

  // First, call fetchSettings

  // Future<void> _launchInAppWithBrowserOptions(Uri url) async {
  //   if (!await launchUrl(
  //     url,
  //     mode: LaunchMode.inAppBrowserView,
  //     browserConfiguration: const BrowserConfiguration(showTitle: true),
  //   )) {
  //     throw Exception('Could not launch $url');
  //   }
  // }


  Future<void> _launchInAppWithWebView(Uri url, BuildContext context) async {
    // Check if the URL is a deep link (custom scheme, e.g., mental://)
    if (url.scheme == "mental") {
      // Handle the deep link by navigating to a specific screen using MaterialPageRoute
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LandingRegisterScreenScreen(), // Pass the URL as an argument
        ),
      );
    } else {
      // If it's a regular HTTP/HTTPS URL, open it in a WebView
      try {
        if (!await launchUrl(
          url,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true, // Enable JavaScript if needed
            enableDomStorage: true, // Enable DOM storage if needed
          ),
        )) {
          throw Exception('Could not launch $url');
        }
      } catch (e) {
        // Handle errors like invalid URLs
        print("Error launching URL: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) =>
                                      ScreenSignIn(),
                                  transitionDuration:
                                  const Duration(seconds: 0),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              // Add padding as needed
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                // Change to your desired background color
                                borderRadius: BorderRadius.circular(5.0),
                                // Optional: Add border radius
                                border: Border.all(
                                  color: Colors.black,
                                  // Change to your desired border color
                                  width: 0.5, // Optional: Adjust border width
                                ),
                              ),
                              child: Text(
                                "Sign in",
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ),
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
                            height: size.height * 0.05,
                          ),
                          _isLoading
                              ? Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Column(
                              children: [
                                Center(
                                  child: Container(
                                    color: Colors.grey[100],
                                    height: 200.0,
                                    width: size.width * 0.75,
                                  ),
                                ),
                              ],
                            ),
                          )
                              :
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                signInProvider.settingsRegisterModel?.settings?[0].title ?? "",
                                style: theme.textTheme.titleMedium,
                              ),
                              SizedBox(height: size.height * 0.02),
                              Text(
                                signInProvider.settingsRegisterModel?.settings?[0].message ?? "",
                                style: theme.textTheme.bodyMedium,
                              ),
                              SizedBox(height: size.height * 0.05),
                              GestureDetector(
                                onTap: () {
                                  String chatURL = signInProvider.settingsRegisterModel?.settings?[0].linkUrl ?? "";
                                  var url = Uri.parse(chatURL);
                                 if (signInProvider.settingsRegisterModel?.settings?[0].target ==
                                     "external") {
                                   _launchInAppWithBrowserOptions(url);
                                 }
                                 else {
                                   _launchInAppWithWebView(url,context);
                                 }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    // Change to your desired background color
                                    borderRadius: BorderRadius.circular(5.0),
                                    // Optional: Add border radius
                                    border: Border.all(
                                      color: Colors.black,
                                      // Change to your desired border color
                                      width: 0.5, // Optional: Adjust border width
                                    ),

                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      text: "Go to ",
                                      // Regular text
                                      style: theme.textTheme.bodyMedium,
                                      // Regular style for "Go to"
                                      children: [
                                        TextSpan(
                                          text: signInProvider.settingsRegisterModel?.settings?[0].link ?? "",
                                          // The URL text
                                          style: CustomTextStyles.labelLarge14
                                              .copyWith(
                                            decorationColor: Colors.blue,
                                            // Optional: change the color of the underline
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.height * 0.10,
                          ),
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
