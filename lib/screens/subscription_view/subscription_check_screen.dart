import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/auth/sign_in/provider/sign_in_provider.dart';
import 'package:mentalhelth/screens/dash_borad_screen/dash_board_screen.dart';
import 'package:mentalhelth/screens/subscription_view/subscription_in_app_screen.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart'; // 🧹 CACHE CLEAR ADDED

import '../../utils/core/firebase_api.dart';
import '../../utils/logic/shared_prefrence.dart';
import '../../utils/theme/colors.dart';
import '../../utils/theme/custom_text_style.dart';
import '../../utils/theme/theme_helper.dart';
import '../auth/sign_in/InAppBrowserScreen.dart';
import '../auth/sign_in/coninue_with_google_class.dart';
import '../auth/sign_in/landing_register_screen.dart';
import '../auth/splash/splash.dart';
import 'InAppBrowserPaymentScreen.dart';
import 'WebViewScreen.dart';

class SubscriptionCheckScreen extends StatefulWidget {
  const SubscriptionCheckScreen(
      {Key? key,
        required this.linkUrl,
        required this.link,
        required this.title,
        required this.message})
      : super(key: key);

  final String linkUrl;
  final String link;
  final String title;
  final String message;

  @override
  _SubscriptionCheckScreenState createState() =>
      _SubscriptionCheckScreenState();
}

class _SubscriptionCheckScreenState extends State<SubscriptionCheckScreen> {
  late SignInProvider signInProvider;
  var logger = Logger();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  late String linkUrl;
  StreamSubscription? _sub;

  // 🧹 CACHE CLEAR ADDED
  Future<void> _clearWebViewCache() async {
    try {
      final WebViewController tempController = WebViewController();
      await tempController.clearCache();
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();
      debugPrint("✅ WebView cache and cookies cleared successfully.");
    } catch (e) {
      debugPrint("⚠️ Failed to clear WebView cache: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    linkUrl = widget.linkUrl;
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
    signInProvider = Provider.of<SignInProvider>(context, listen: false);
    scheduleMicrotask(() async {
      String deviceType = Platform.isAndroid ? 'android' : 'ios';
      // First, call fetchSettings
      await signInProvider.fetchAppRegister(context, deviceType: deviceType);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
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
    // 🧹 CACHE CLEAR ADDED
    await _clearWebViewCache();

    if (url.scheme == "mental") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const DashBoardScreen(),
        ),
      );
      return;
    }

    final Completer<void> completer = Completer<void>();

    try {
      if (await launchUrl(
        url,
        mode: LaunchMode.inAppBrowserView,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      )) {
        completer.future.then((_) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const DashBoardScreen(),
            ),
          );
        });
      } else {
        throw Exception('Could not launch $url');
      }

      await Future.delayed(const Duration(seconds: 5));
      completer.complete();
    } catch (e) {
      print("Error launching URL: $e");
    }
  }

  Future<void> _launchInAppWithBrowserOptions1(Uri url) async {
    // 🧹 CACHE CLEAR ADDED
    await _clearWebViewCache();

    logger.i("Launching URL in custom in-app browser: $url");
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InAppBrowserPaymentScreen(initialUrl: url),
      ),
    );
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomImageView(
                            imagePath: ImageConstant.newLogoNumu,
                            height: 130,
                            width: 280,
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: size.height * 0.05,
                          ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Open Sans',
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),
                              Text(
                                widget.message,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Open Sans',
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: size.height * 0.04),

                              GestureDetector(
                                onTap: () async {
                                  Future.delayed(const Duration(seconds: 2), () {
                                    setState(() {});
                                  });
                                  String chatURL = signInProvider.settingsList[0].linkUrl ?? "";
                                  logger.w("widget.linkUrl${signInProvider.settingsList[0].linkUrl}");
                                  var url = Uri.parse(chatURL);

                                  if (signInProvider.settingsList[0].target == "external") {
                                    if (Platform.isAndroid) {
                                      await _launchInAppWithBrowserOptions1(url);
                                    } else {
                                      await _launchInAppWithBrowserOptions1(url);
                                    }
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => SubscriptionInAppScreen(
                                          url: widget.linkUrl,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  width: size.width * 0.75,
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.language,
                                        color: ColorsContent.newThemeColor,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          widget.link,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: ColorsContent.newThemeColor,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: ColorsContent.newThemeColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.height * 0.02,
                          ),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                linkUrl = "";
                              });
                              if (Platform.isAndroid) {
                                await PushNotifications.subscribeToTopic("live_doLogin");
                                await PushNotifications.unsubscribeFromTopic("message");
                              } else {
                                OneSignal.logout();
                                OneSignal.User.addTagWithKey("topic", "live_doLogin");
                                OneSignal.User.removeTag("message");
                              }
                              await signInProvider.logOutUser(context);
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.remove('lastSkippedTimestamp');
                              addFCMTokenToSharePref(token: "");
                              addVersionSharePref(version: "");
                              await signInProvider.logOutUser(context);
                              await removeUserDetailsSharePref(context: context);
                              removeAllValuesLogout(context: context);
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, __, ___) => const LandingRegisterScreenScreen(),
                                  transitionDuration: const Duration(seconds: 0),
                                ),
                              );
                            },
                            child: Container(
                              width: size.width * 0.75,
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 13.0),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: ColorsContent.whiteText,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
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