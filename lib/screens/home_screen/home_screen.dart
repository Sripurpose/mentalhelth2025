import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/screens/home_screen/widgets/chart_widget.dart';
import 'package:mentalhelth/screens/home_screen/widgets/home_menu/home_menu.dart';
import 'package:mentalhelth/screens/journal_view_screen/journal_view_screen.dart';
import 'package:mentalhelth/utils/logic/logic.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/widget/shimmer.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/core/constants.dart';
import '../../utils/core/constent.dart';
import '../../utils/core/firebase_api.dart';
import '../../utils/logic/shared_prefrence.dart';
import '../../utils/theme/custom_button_style.dart';
import '../../utils/theme/custom_text_style.dart';
import '../../utils/theme/theme_helper.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/functions/popup.dart';
import '../auth/sign_in/provider/sign_in_provider.dart';
import '../goals_dreams_page/provider/goals_dreams_provider.dart';
import '../home_screen/widgets/userprofilelist_item_widget.dart';
import '../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../subscription_view/subscription_check_screen.dart';
import '../subscription_view/subscription_in_app_screen.dart';
import '../subscription_view/subscription_view_screen.dart';
import '../token_expiry/tocken_expiry_warning_screen.dart';
import '../token_expiry/token_expiry.dart';
import '../version_update_screen/version_update_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SignInProvider signInProvider;
  late HomeProvider homeProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late EditProfileProvider editProfileProvider;
  late DashBoardProvider dashBoardProvider;
  late GoalsDreamsProvider goalsDreamsProvider;
  bool tokenStatus = false;
  var logger = Logger();
  String versionName = "";


  Future<void> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    versionName = packageInfo.version;
    if(Platform.isAndroid){
      Constent.versionCodeAndroid = packageInfo.version;
    }else{
      Constent.versionCodeIOS = packageInfo.version;
    }

    print('App Name: $appName');
    print('Package Name: $packageName');
    print('Version: $version');
    print('Build Number: $buildNumber');
  }

  Future<void> _isTokenExpired() async {

    await homeProvider.fetchJournals(initial: true);
    await homeProvider.fetchChartView(context);
  //  checkAndFetchVersionUpdate(context);

    // await homeProvider.fetchRemindersDetails();
    tokenStatus = TokenManager.checkTokenExpiry();

    if (tokenStatus) {
      setState(() {
        logger.e("Token status changed: $tokenStatus");
      });
      logger.e("Token status changed: $tokenStatus");
    }else{
      logger.e("Token status changedElse: $tokenStatus");
    }
  }

  void checkAndFetchVersionUpdate(BuildContext context,) {
    String deviceType = Platform.isAndroid ? 'android' : 'ios';
    signInProvider.fetchVersionUpdate(context, deviceType);
  }

  @override
  void initState() {
    super.initState();

    signInProvider = Provider.of<SignInProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    mentalStrengthEditProvider = Provider.of<MentalStrengthEditProvider>(context, listen: false);
    editProfileProvider = Provider.of<EditProfileProvider>(context, listen: false);
    dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
    goalsDreamsProvider = Provider.of<GoalsDreamsProvider>(context, listen: false);
    scheduleMicrotask(() async {
      getAppVersion();
      signInProvider.settingsList.clear();
      await editProfileProvider.fetchUserProfile();
      if(Platform.isIOS){
        final oneSignalId = await OneSignal.User.getOnesignalId();
        if(oneSignalId!= null){
          oneSignalIdOriginal = oneSignalId;
          await OneSignal.login("individual_${editProfileProvider.getProfileModel?.userId}");
          print("oneSignalId--${oneSignalId}");
        }
        print("oneSignalId--${oneSignalId}");
      }

      if (!kIsWeb) {
        if(Platform.isAndroid){
          await PushNotifications.subscribeToTopic("message");
          await PushNotifications.unsubscribeFromTopic("live_doLogin");
        }else{
          OneSignal.User.addTagWithKey("topic","message");
          OneSignal.User.removeTag("live_doLogin");
        }

      }

      // First, call fetchSettings
     // await signInProvider.fetchSettings(context);

      print(" new fcm token    $fcmToken");
      updateFCMTokenIfNeeded(fcmToken);

      String? cachedToken = await getFCMTokenFromSharePref();
      print(" cache fcm token    $cachedToken");



      _isTokenExpired();

      // if(fcmToken != getFCMTokenFromSharePref()){
      //   sendPushNotificationByUser();
      //   addFCMTokenToSharePref(token: fcmToken);
      // }

      // After 2 seconds delay, perform the rest of the operations

      goalsDreamsProvider.goalsanddreams.clear();
      goalsDreamsProvider.goalsanddreams = [];
      mentalStrengthEditProvider.mediaSelected = -1;
    });
  }

  void updateFCMTokenIfNeeded(String fcmToken) async {
    String? storedFCMToken = await getFCMTokenFromSharePref();  // Await the result here
    if (fcmToken != storedFCMToken) {
      sendPushNotificationByUser();
      addFCMTokenToSharePref(token: fcmToken);
      print(" cache fcm token    ${getFCMTokenFromSharePref()}");
    }
  }


  Future<void> sendPushNotificationByUser() async {
    //isLoading = true;
    final signInProvider = Provider.of<SignInProvider>(context, listen: false);
    OneSignal.User ?? '';
    if(Platform.isAndroid){
      await signInProvider.saveFirebaseToken(context,
          registrationId: fcmToken, deviceOs: 'android');
      print("Firebase token saved.");
    }else{
      await signInProvider.saveFirebaseToken(context,
          registrationId: oneSignalIdOriginal, deviceOs: 'ios');
      print("Firebase token saved.");
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


  Future<void> _launchInAppWithWebView(Uri url) async {
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
  }


  // Example of checking after data load
  void checkSubscriptionStatus() {
    if (signInProvider.settingsModel != null && signInProvider.settingsList.isNotEmpty) {
      if (signInProvider.settingsModel?.isSubscribed.toString() == "0" &&
          signInProvider.settingsModel?.settings?[0].isRequired.toString() == "1") {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SubscriptionCheckScreen(
                linkUrl: signInProvider.settingsList[0].linkUrl ?? "",link: signInProvider.settingsList[0].link ?? "",
                title: signInProvider.settingsList[0].title ?? "",message: signInProvider.settingsList[0].message ?? "",
              ),
            ),

          );
        });
      } else {
      }
    }
  }

  void checkVersionUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSkippedTimestamp = prefs.getInt('lastSkippedTimestamp');
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // 24 hours in milliseconds
    const int oneDayInMillis = 24 * 60 * 60 * 1000;


      if (signInProvider.versionUpdateModel != null) {
        logger.w("signInProvider.versionUpdateModel${signInProvider.versionUpdateModel?.notifyType}");
        if (lastSkippedTimestamp == null || (currentTime - lastSkippedTimestamp) > oneDayInMillis) {
          if (signInProvider.versionUpdateModel?.notifyType == "0") {
            Future.delayed(Duration.zero, () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VersionUpdateCheckScreen(
                    title: signInProvider.versionUpdateModel?.title ?? "",
                    message: signInProvider.versionUpdateModel?.message ?? "",
                    notifyMe: signInProvider.versionUpdateModel?.notifyType ?? "",
                  ),
                ),
              );
            });
          }
        }
        if(versionName != signInProvider.versionUpdateModel?.version){
          if (signInProvider.versionUpdateModel?.notifyType == "1") {
            Future.delayed(Duration.zero, () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VersionUpdateCheckScreen(
                    title: signInProvider.versionUpdateModel?.title ?? "",
                    message: signInProvider.versionUpdateModel?.message ?? "",
                    notifyMe: signInProvider.versionUpdateModel?.notifyType ?? "",
                  ),
                ),
              );
            });
          }
        }

        // Add any other handling logic as necessary
      }
    //}
  }

// Call this method when you know data is loaded

  @override
  Widget build(BuildContext context) {
    final signInProvider = Provider.of<SignInProvider>(context, listen: false);
    Size size = MediaQuery.of(context).size;

    // Check if token has expired, return the TokenExpireScreen if true
    if (tokenStatus == true) {
      return const TokenExpireScreen();
    }

    // Use FutureBuilder to fetch settings
    return FutureBuilder(
      future: signInProvider.fetchSettings(context), // Your method to fetch settings
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child:  SpinKitWave(
            color: Colors.blue,
            size: 25,
          ),); // Show loading indicator
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Handle error
        } else {
          // Now you can safely check your conditions and show the main content
          checkSubscriptionStatus();
          checkVersionUpdate();
          // The main content if no token issues or settingsPopup
          return SafeArea(
            child: Consumer4<MentalStrengthEditProvider, HomeProvider, EditProfileProvider, DashBoardProvider>(
              builder: (context, mentalStrengthEditProvider, homeProvider, editProfileProvider, dashBoardProvider, _) {
                return backGroundImager(
                  size: size,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await signInProvider.fetchSettings(context);
                      _isTokenExpired();
                      homeProvider.fetchChartView(context);
                      homeProvider.fetchJournals(initial: true);
                      editProfileProvider.fetchUserProfile();
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.01),
                          _buildHeaderRow(context, size, editProfileProvider, dashBoardProvider),
                          const SizedBox(height: 12),
                          _buildMessageColumn(context, size),
                          CustomElevatedButton(
                            onPressed: () {
                              dashBoardProvider.changePage(index: 1);
                              mentalStrengthEditProvider.fetchEmotions();
                            },
                            height: size.height * 0.06,
                            width: size.width * 0.85,
                            text: "Build your mental strength now",
                            buttonStyle: CustomButtonStyles.fillBlueBL10,
                            buttonTextStyle: CustomTextStyles.titleSmallOnSecondaryContainer15,
                          ),
                          const SizedBox(height: 31),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 1),
                              child: Text(
                                "Your recent mental strength scores",
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          ChartWidget(chartData: homeProvider.chartViewModel?.chart),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 1),
                              child: Text(
                                "${DateTime.now().year}",
                                style: CustomTextStyles.titleMediumBlue300,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 324,
                            margin: const EdgeInsets.only(left: 1, right: 10),
                            child: Text(
                              "You average mental strength according to the last 7 entries is 4 out of 5. Keep tracking...",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: CustomTextStyles.bodyMediumOnPrimary14,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 1),
                              child: Text(
                                "Your recent Journals",
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          homeProvider.chartViewModel == null
                              ? const SizedBox()
                              : _buildUserProfileList(context, size, homeProvider),
                          const SizedBox(height: 4),
                          homeProvider.chartViewModel == null
                              ? const SizedBox()
                              : (homeProvider.journalsModel?.journals?.length ?? 0) < 0
                              ? const SizedBox()
                              : GestureDetector(
                            onTap: () {
                              dashBoardProvider.changePage(index: 2);
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 1),
                                child: Text(
                                  "View more ...",
                                  style: CustomTextStyles.bodySmallPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }


  /// Section Widget
  Widget _buildHeaderRow(
      BuildContext context,
      Size size,
      EditProfileProvider editProfileProvider,
      DashBoardProvider dashBoardProvider) {
    return
      Padding(
      padding: const EdgeInsets.only(
        left: 1,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              dashBoardProvider.changeCommentPage(index: 8);
            },
            child: CustomImageView(
              imagePath: editProfileProvider.getProfileModel?.profileurl
                  .toString() ?? "",
              height: 58,
              width: 58,
              radius: BorderRadius.circular(
                34,
              ),
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 7,
              top: 21,
              bottom: 21,
            ),
            child: SizedBox(
              // color: Colors.cyan,
              width: size.width * 0.60,
              child: Text(
                capitalText(editProfileProvider.getProfileModel == null
                    ? ""
                    :editProfileProvider.getProfileModel!.firstname
                    .toString()),
                style: CustomTextStyles.bodyLarge18,
                overflow: TextOverflow.ellipsis,
                maxLines: 10, // Set the maximum number of lines to 3
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => buildPopupDialog(
                  context,
                  size,
                ),
              );
            },
            child: CircleAvatar(
              backgroundColor: PrimaryColors().blue300,
              radius: size.width * 0.04,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: size.height * 0.003,
                    width: size.width * 0.03,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          10,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.005,
                  ),
                  Container(
                    height: size.height * 0.003,
                    width: size.width * 0.03,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildMessageColumn(BuildContext context, Size size) {
    return Container(
      height: size.height * 0.06,
      width: size.width * 0.85,
      // padding: EdgeInsets.symmetric(
      //     horizontal: size.width * 0.2, vertical: size.width * 0.027),
      decoration: AppDecoration.outlineBlue.copyWith(
        borderRadius: BorderRadiusStyle.customBorderTL10,
      ),
      child: Center(
        child: Text(
          "Whats on your mind now?",
          style: CustomTextStyles.bodyMediumGray50001,
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildUserProfileList(
      BuildContext context, Size size, HomeProvider homeProvider) {
    var logger = Logger();
    return Padding(
      padding: const EdgeInsets.only(left: 1),
      child: homeProvider.journalsModelLoading
          ? shimmerList(
        height: size.height * 0.5,
        list: 4,
        shimmerHeight: size.height * 0.07,
      ):
      homeProvider.journalStatus == 404 ?
          const SizedBox():
           ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        separatorBuilder: (context, index) {
          return const SizedBox(height: 3);
        },
        itemCount: (homeProvider.journalsModel?.journals?.length ?? 0) < 4
            ? (homeProvider.journalsModel?.journals?.length ?? 0)
            : 4,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => JournalViewScreen(
                    journalId: homeProvider
                        .journalsModelList[index].journalId
                        .toString(),
                    index: index,
                  ),
                ),
              );
            },
            child: UserProfileListItemWidget(
              title: homeProvider.journalsModel!.journals![index].journalDesc!,
              date: homeProvider.journalsModel!.journals![index].journalDatetime!,
              image: homeProvider.journalsModel!.journals![index].displayImage!,
            ),
          );

        },
      ),
    );
  }
}

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: PrimaryColors().blue300,
            ),
            child: const Text(
              'Drawer Header',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Item 1'),
            onTap: () {
              // Handle item 1 tap
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            title: const Text('Item 2'),
            onTap: () {
              // Handle item 2 tap
              Navigator.pop(context); // Close the drawer
            },
          ),
          // Add more ListTile widgets for additional items
        ],
      ),
    );
  }
}
