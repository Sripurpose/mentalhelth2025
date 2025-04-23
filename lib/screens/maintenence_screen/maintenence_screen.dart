import 'dart:async';

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

import '../../utils/logic/shared_prefrence.dart';
import '../../utils/theme/colors.dart';
import '../../utils/theme/custom_text_style.dart';
import '../../utils/theme/theme_helper.dart';
import '../auth/sign_in/coninue_with_google_class.dart';
import '../auth/sign_in/landing_register_screen.dart';
import '../auth/splash/splash.dart';
import '../no_internet/duplicate_screen.dart';

class MaintenenceScreen extends StatefulWidget {
  const MaintenenceScreen(
      {Key? key,
        required this.title,
        required this.message})
      : super(key: key);
  final String title;
  final String message;

  @override
  _MaintenenceScreenState createState() =>
      _MaintenenceScreenState();
}

class _MaintenenceScreenState extends State<MaintenenceScreen> {
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

    });
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
        child: ConnectivityWidget(
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
                                  widget.title ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Open Sans',
                                    color: Colors.white,
                                  ),
                                ),
          
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.04,
                            ),
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                });
                                await signInProvider.logOutUser(context);
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.remove('lastSkippedTimestamp');
                                addFCMTokenToSharePref(token: "");
                                addVersionSharePref(version:"");
                                // GoogleSignInService.logout();
                                await signInProvider.logOutUser(context);
                                await removeUserDetailsSharePref(context: context);
                                removeAllValuesLogout(context: context);
                                //await googleSignOut();
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => const SplashScreen(),
                                    transitionDuration: const Duration(seconds: 0),
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
                                      "Cancel",
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
