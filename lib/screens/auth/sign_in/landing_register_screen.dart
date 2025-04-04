import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/auth/sign_in/provider/sign_in_provider.dart';
import 'package:mentalhelth/screens/auth/sign_in/screen_sign_in.dart';
import 'package:mentalhelth/screens/auth/sign_in/widget/sign_in_widget.dart';
import 'package:mentalhelth/screens/subscription_view/subscription_in_app_screen.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/theme/custom_text_style.dart';
import '../../../utils/theme/theme_helper.dart';
import '../../edit_add_profile_screen/provider/edit_provider.dart';
import '../../home_screen/provider/home_provider.dart';
import '../../maintenence_screen/maintenence_screen.dart';
import '../../no_internet/duplicate_screen.dart';

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
      String deviceType = Platform.isAndroid ? 'android' : 'ios';
      if(signInProvider.statusAppSetup == 503){
        logger.w("signInProvider.statusVersionUpdate${signInProvider.statusAppSetup}");
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MaintenenceScreen(
                title: "App is in maintainance mode, Please be patient, we'll be back in a couple of hours!",
                message: signInProvider.versionUpdateModel?.message ?? "",
              ),
            ),
          );
        });
      }
      // First, call fetchSettings
      //await signInProvider.fetchAppRegister(context,deviceType: deviceType);
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
          mode: LaunchMode.inAppBrowserView,
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
    return ConnectivityWidget(
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            // Returning false prevents the back press
            return false;
          },
          child: Scaffold(
            body: landingScreenImager(
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
                            CustomImageView(
                              imagePath: ImageConstant.imgNumuLogo,
                              height: 100,
                              width: 280,
                              color: Colors.white,
                            ),
                            SizedBox(
                              height: size.height * 0.05,
                            ),
                            _isLoading
                                ?    const Center(child: CupertinoActivityIndicator(
                              color: Colors.white,
                              radius: 15,
                            ))
                                :
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  signInProvider.settingsRegisterModel?.settings?[0].title ?? "",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Open Sans',
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.02),
                                Text(
                                  signInProvider.settingsRegisterModel?.settings?[0].message
                                      ?.replaceAll("with ", "with\n              ") ?? "",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Open Sans',
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.05),
                                signInProvider.settingsRegisterModel?.settings?[0].link != null ?
                                Visibility(
                                  visible: signInProvider.settingsRegisterModel?.settings?[0].status == "1" ? true : false,
                                  child: GestureDetector(
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
                                    child:Container(
                                      width: size.width * 0.75,
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0), // Adjust padding for better spacing
                                      decoration: BoxDecoration(
                                        color: Colors.white, // Background color
                                        borderRadius: BorderRadius.circular(5.0), // Optional: Add border radius
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start, // Aligns items to the start
                                        crossAxisAlignment: CrossAxisAlignment.center, // Keeps items vertically aligned
                                        children: [
                                          Icon(
                                            Icons.language,
                                            color: ColorsContent.newThemeColor,
                                            size: 24, // Reduced icon size
                                          ),
      
                                          const SizedBox(width: 8), // Add small spacing between icon and text
      
                                          Expanded(
                                            child: Text(
                                              signInProvider.settingsRegisterModel?.settings?[0].link ?? "",
                                              style:  TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold, // Set font weight to bold
                                                color:ColorsContent.newThemeColor,
                                              ),
                                              overflow: TextOverflow.ellipsis, // Avoid text overflow
                                            ),
                                          ),
      
                                          const SizedBox(width: 10), // Adjust spacing before the forward icon
      
                                          Container(
                                            width: 28, // Adjust size as needed
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: ColorsContent.newThemeColor, // Background color
                                              shape: BoxShape.circle, // Circular shape
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.arrow_forward,
                                                color: Colors.white, // Icon color
                                                size: 18, // Slightly reduced icon size
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
      
      
                                  ),
                                ):
                                    const SizedBox(),
                                SizedBox(height: size.height * 0.03),
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder: (_, __, ___) =>
                                                      const ScreenSignIn(),
                                                      transitionDuration:
                                                      const Duration(seconds: 0),
                                                    ),
                                                  );
                                  },
                                  child: Container(
                                    width: size.width * 0.75,
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 13.0), // Adjust padding for better spacing
                                    decoration: BoxDecoration(
                                      color: Colors.black, // Background color
                                      borderRadius: BorderRadius.circular(5.0), // Optional: Add border radius
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center, // Aligns items to the start
                                      crossAxisAlignment: CrossAxisAlignment.center, // Keeps items vertically aligned
                                      children: [
                                        Text(
                                          "Sign in",
                                          style:  TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold, // Set font weight to bold
                                            color:ColorsContent.whiteText,
                                          ),
                                          overflow: TextOverflow.ellipsis, // Avoid text overflow
                                        ),
                                      ],
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
      ),
    );
  }
}
