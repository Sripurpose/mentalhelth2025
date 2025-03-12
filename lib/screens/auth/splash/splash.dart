import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mentalhelth/screens/auth/sign_in/provider/sign_in_provider.dart';
import 'package:mentalhelth/screens/auth/sign_in/screen_sign_in.dart';
import 'package:mentalhelth/screens/auth/subscribe_plan_page/subscribe_plan_page.dart';
import 'package:mentalhelth/screens/dash_borad_screen/dash_board_screen.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:provider/provider.dart';

import '../sign_in/landing_register_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SignInProvider signInProvider;
  String? getSubScribed;

  @override
  void initState() {
    signInProvider = Provider.of<SignInProvider>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        Future.microtask(() async {
          getSubScribed = await getUserSubScribeSharePref();
          await init();
        }).whenComplete(() {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) {
            if (getSubScribed != null) {
              if (getSubScribed.toString() == "0") {
                //commented for purpose
               // return SubscribePlanPage();
                return const DashBoardScreen();
              } else if (getSubScribed.toString() == "1") {
                return const DashBoardScreen();
              } else {
                return const LandingRegisterScreenScreen(
                );
              }
            } else {
              return const LandingRegisterScreenScreen(
              );
            }
          }));
        });
      } catch (e) {
        init();
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (context) {
          if (getSubScribed != null) {
            if (getSubScribed.toString() == "0") {
              return const DashBoardScreen();
              //commented for purpose
             // return SubscribePlanPage();
            } else {
              return const DashBoardScreen();
            }
          } else {
            return const ScreenSignIn();
          }
        }));
      }
    });
  }

  Future<void> init() async {
    SignInProvider signInProvider = Provider.of<SignInProvider>(context, listen: false);
    HomeProvider homeProvider =
        Provider.of<HomeProvider>(context, listen: false);
    EditProfileProvider editProfileProvider =
        Provider.of<EditProfileProvider>(context, listen: false);
    signInProvider.fetchSettings(context);
    signInProvider.fetchAppRegister(context);
    //signInProvider.fetchSettings(context);
    homeProvider.fetchChartView(context);

    //homeProvider.fetchJournals(initial: true);
    checkAndFetchVersionUpdate(context,);
  }
  void checkAndFetchVersionUpdate(BuildContext context) {
    String deviceType = Platform.isAndroid ? 'android' : 'ios';
    signInProvider.fetchVersionUpdate(context, deviceType);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(
          30,
        ),
        child: SvgPicture.asset(
          ImageConstant.logo,
        ),
      ),
    );
  }
}
