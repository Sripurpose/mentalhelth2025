import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/auth/sign_in/provider/sign_in_provider.dart';
import 'package:mentalhelth/screens/auth/sign_in/screen_sign_in.dart';
import 'package:mentalhelth/screens/maintenence_screen/maintenence_screen.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'InAppBrowserScreen.dart';

class LandingRegisterScreenScreen extends StatefulWidget {
  const LandingRegisterScreenScreen({Key? key}) : super(key: key);

  @override
  State<LandingRegisterScreenScreen> createState() =>
      _LandingRegisterScreenScreenState();
}

class _LandingRegisterScreenScreenState
    extends State<LandingRegisterScreenScreen> {
  late SignInProvider signInProvider;
  final logger = Logger();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
   //_handleIncomingDeepLinks();
    signInProvider = Provider.of<SignInProvider>(context, listen: false);

    Future.delayed(const Duration(seconds: 5), () {
      setState(() => _isLoading = false);
    });

    scheduleMicrotask(() async {
      final deviceType = Platform.isAndroid ? 'android' : 'ios';
      if (signInProvider.statusAppSetup == 503) {
        logger.w("App in maintenance: ${signInProvider.statusAppSetup}");
       // WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MaintenenceScreen(
                title:
                "App is in maintenance mode. We'll be back in a couple of hours!",
                message: signInProvider.versionUpdateModel?.message ?? "",
              ),
            ),
          );
       // });
      }
    });
  }


  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }


  Future<void> _launchInAppWithBrowserOptions(Uri url) async {
    logger.i("Launching URL in custom in-app browser: $url");
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InAppBrowserScreen(initialUrl: url),
      ),
    );
  }




  Future<void> _launchInAppWithWebView(Uri url) async {
    if (url.scheme == "mental") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ScreenSignIn()),
      );
    } else {
      try {
        if (!await launchUrl(
          url,
          mode: LaunchMode.inAppBrowserView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        )) {
          throw Exception('Could not launch $url');
        }
      } catch (e) {
        logger.e("Error launching URL: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SignInProvider>(context);
    final settings = provider.settingsRegisterModel?.settings?.first;
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: landingScreenImager(
            size: size,
            padding: EdgeInsets.zero,
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 65),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomImageView(
                          imagePath: ImageConstant.newLogoNumu,
                          height: 130,
                          width: 280,
                          color: Colors.white,
                        ),
                        SizedBox(height: size.height * 0.05),
                        if (_isLoading)
                          const CupertinoActivityIndicator(
                            color: Colors.white,
                            radius: 15,
                          )
                        else
                          Column(
                            children: [
                              Text(
                                settings?.title ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Open Sans',
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),

                              Text(
                                settings?.message ?? '',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: 'Open Sans',
                                  color: Colors.white,
                                ),
                              ),
                              // RichText(
                              //   textAlign: TextAlign.center,
                              //   text: const TextSpan(
                              //     style: TextStyle(
                              //       fontSize: 14,
                              //       fontWeight: FontWeight.w400,
                              //       fontFamily: 'Open Sans',
                              //       color: Colors.white,
                              //     ),
                              //     children: [
                              //       TextSpan(
                              //           text:
                              //           'Empower your mental well-being with\n'),
                              //       TextSpan(
                              //           text:
                              //           'simple, effective tools!'),
                              //     ],
                              //   ),
                              // ),
                              SizedBox(height: size.height * 0.05),
                              if (settings?.link != null &&
                                  settings?.status == "1")
                                GestureDetector(
                                  onTap: () {
                                    final url = Uri.parse(
                                        settings?.linkUrl ?? "");
                                    if (settings?.target == "external") {
                                      _launchInAppWithBrowserOptions(url);
                                    } else {
                                      _launchInAppWithWebView(url);
                                    }
                                  },
                                  child: Container(
                                    width: size.width * 0.75,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.language,
                                            color:
                                            ColorsContent.newThemeColor),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            settings?.link ?? '',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color:
                                              ColorsContent.newThemeColor,
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
                                          child: const Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              SizedBox(height: size.height * 0.02),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                      const ScreenSignIn(),
                                      transitionDuration:
                                      const Duration(milliseconds: 0),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: size.width * 0.75,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 13),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Sign in",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: ColorsContent.whiteText,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: size.height * 0.10),
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
