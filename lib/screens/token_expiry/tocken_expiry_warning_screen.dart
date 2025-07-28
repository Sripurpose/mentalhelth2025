import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:mentalhelth/screens/token_expiry/token_expiry.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/core/firebase_api.dart';
import '../../utils/core/image_constant.dart';
import '../../utils/logic/shared_prefrence.dart';
import '../../utils/theme/custom_text_style.dart';
import '../auth/sign_in/provider/sign_in_provider.dart';
import '../auth/sign_in/screen_sign_in.dart';




class TokenExpireScreen extends StatefulWidget {
  const TokenExpireScreen({super.key});

  @override
  State<TokenExpireScreen> createState() => _TokenExpireScreenState();
}

class _TokenExpireScreenState extends State<TokenExpireScreen> {
  late SignInProvider signInProvider;


  @override
  void initState() {
    super.initState();
    signInProvider = Provider.of<SignInProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final signInProvider = Provider.of<SignInProvider>(context, listen: false);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        TokenManager.setTokenStatus(false);
        addUserEmailSharePref(
          email: "",
        );
        addUserPasswordSharePref(
          password: "",
        );
        return false;
      },
      child: Scaffold(
          body: Container(
              height: height,
              width: width,
              decoration: ShapeDecoration(
                color: ColorsContent.homeBackGroundColor,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 0, color: Colors.white),
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Gap(25),
                    Column(
                      children: [
                        const Gap(15),
                        Image.asset(
                          ImageConstant.sessionExpiredLogo, // Path to your Lottie file
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        const Gap(20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'Your session has expired.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Open Sans',
                              color: ColorsContent.tokenExpiryTextColor,
                            ),
                          ),
                        ),
                        const Gap(2),
                         Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            'Please log in again',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Open Sans',
                              color: ColorsContent.tokenExpiryTextColor,
                            ),
                          ),
                        ),
                        const Gap(30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: SizedBox(
                            width: width * 0.80,
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    addFCMTokenToSharePref(token: '');
                                    TokenManager.setTokenStatus(false);
                                    await signInProvider.logOutUser(context);
                                    await removeUserDetailsSharePref(context: context);
                                    removeAllValuesLogout(context: context);
                                    addUserEmailSharePref(
                                      email: "",
                                    );
                                    addUserPasswordSharePref(
                                      password: "",
                                    );
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
                                    width: width * 0.65,
                                    height: 50,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: ShapeDecoration(
                                      color: ColorsContent.newThemeColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                            'Login',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Roboto',
                                            color: ColorsContent.whiteText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Gap(20),
                                GestureDetector(
                                  onTap: () async {
                                    TokenManager.setTokenStatus(false);
                                    addUserEmailSharePref(
                                      email: "",
                                    );
                                    addUserPasswordSharePref(
                                      password: "",
                                    );
                                    if(Platform.isAndroid){
                                      await PushNotifications.subscribeToTopic("live_doLogin");
                                      await PushNotifications.unsubscribeFromTopic("message");
                                    }else{
                                      OneSignal.logout();
                                      OneSignal.User.addTagWithKey("topic","live_doLogin");
                                      OneSignal.User.removeTag("message");
                                    }
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.remove('lastSkippedTimestamp');
                                    addFCMTokenToSharePref(token: "");
                                    addVersionSharePref(version:"");
                                    // GoogleSignInService.logout();
                                    await signInProvider.logOutUser(context);
                                    await removeUserDetailsSharePref(context: context);
                                    removeAllValuesLogout(context: context);
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Cancel',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'Roboto',
                                          color: ColorsContent.tokenExpiryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(15),
                      ],
                    ),

                  ],
                ),
              ))),
    );
  }
}
