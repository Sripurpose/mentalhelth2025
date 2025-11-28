import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/screens/home_screen/widgets/chart_widget.dart';
import 'package:mentalhelth/screens/home_screen/widgets/date_range_picker_screen.dart';
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
import '../../utils/core/image_constant.dart';
import '../../utils/core/url_constant.dart';
import '../../utils/logic/shared_prefrence.dart';
import '../../utils/theme/colors.dart';
import '../../utils/theme/custom_button_style.dart';
import '../../utils/theme/custom_text_style.dart';
import '../../utils/theme/theme_helper.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/functions/popup.dart';
import '../../widgets/functions/snack_bar.dart';
import '../auth/sign_in/model/messages_model.dart';
import '../auth/sign_in/provider/sign_in_provider.dart';
import '../auth/splash/splash.dart';
import '../goals_dreams_page/provider/goals_dreams_provider.dart';
import '../home_screen/widgets/userprofilelist_item_widget.dart';
import '../maintenence_screen/maintenence_screen.dart';
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
      addVersionSharePref(version: packageInfo.version);
    }else{
      Constent.versionCodeIOS = packageInfo.version;
      addVersionSharePref(version: packageInfo.version);
    }

    print('App Name: $appName');
    print('Package Name: $packageName');
    print('Version: $version');
    print('Build Number: $buildNumber');
  }

  Future<void> _isTokenExpired() async {

    await homeProvider.fetchJournals(initial: true,context: context,fullList: true);
    await homeProvider.fetchJournalsGridView(initial: true,context: context,fullList: true);
   // await homeProvider.fetchChartView(context);
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
  void printTimeZone() {
    final offset = DateTime.now().timeZoneOffset;
    final trimmedOffset = offset.toString().split('.').first; // Remove milliseconds
    final parts = trimmedOffset.split(':'); // Split by colon

    String sign = offset.isNegative ? '' : '+';
    final formattedOffset = "$sign${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}";

     timeZone = formattedOffset;
    print("Formatted Timezone Offset: $formattedOffset"); // Example: +05:30 or -07:00
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
      signInProvider.fetchAppShare(context);
      _checkPinnedMessageTiming();
      printTimeZone();
      getAppVersion();
      signInProvider.settingsList.clear();
      await editProfileProvider.fetchUserProfile(context);
      await signInProvider.fetchMessages(context);
      if(Platform.isIOS){
        final oneSignalId = await OneSignal.User.getOnesignalId();
        if(oneSignalId!= null){
          oneSignalIdOriginal = oneSignalId;
          await OneSignal.login("individual_${UrlConstant.oneSignalRemote}_${editProfileProvider.getProfileModel?.userId}");
          print("oneSignalId--${oneSignalId}");
        }
        print("oneSignalId--${oneSignalId}");
      }

      if (!kIsWeb) {
        if(Platform.isAndroid){
          await PushNotifications.subscribeToTopic("message");
          await PushNotifications.unsubscribeFromTopic("live_doLogin");
        }else{
          var userId = await OneSignal.User.getOnesignalId();
          print("OneSignal User ID: ${userId}");
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
    //if (fcmToken != storedFCMToken) {
      sendPushNotificationByUser();
      addFCMTokenToSharePref(token: fcmToken);
      print(" cache fcm token    ${getFCMTokenFromSharePref()}");
   // }
  }


  Future<void> sendPushNotificationByUser() async {
    //isLoading = true;
    final signInProvider = Provider.of<SignInProvider>(context, listen: false);
    OneSignal.User ?? '';
    if(Platform.isAndroid){
      await signInProvider.saveFirebaseToken(context,
          registrationId: fcmToken, deviceOs: 'android');
      print("Firebase token saved.");
    }
    else{
      await signInProvider.saveFirebaseToken(context,
          registrationId: "${UrlConstant.oneSignalRemote}$oneSignalIdOriginal", deviceOs: 'ios');
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
          if(mounted){
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => SubscriptionCheckScreen(
                  linkUrl: signInProvider.settingsList[0].linkUrl ?? "",
                  link: signInProvider.settingsList[0].link ?? "",
                  title: signInProvider.settingsList[0].title ?? "",
                  message: signInProvider.settingsList[0].message ?? "",
                ),
              ),
            );

          }
        });
      } else {
      }
    }
  }


  void _checkPinnedMessageTiming() async {
    bool shouldShow = await shouldShowPinnedMessage();
    setState(() {
      showPinnedMessage = shouldShow;
    });
  }

  Future<void> _launchInAppWithBrowserOptionsVersionUpdate(BuildContext context, Uri url) async {
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

  void checkVersionUpdate() async {
    final String androidUpdateUrl = "https://play.google.com/store/apps/details?id=com.numuapp.numuapp";
    final String iosUpdateUrl = "https://apps.apple.com/app/id6736739491"; // Replace with your iOS App Store link
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

    if(signInProvider.statusVersionUpdate == 503){
      logger.w("signInProvider.statusVersionUpdate${signInProvider.statusVersionUpdate}");
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
    else if(signInProvider.statusVersionUpdate == 505){
      Uri updateUrl = Platform.isAndroid
          ? Uri.parse(androidUpdateUrl)
          : Uri.parse(iosUpdateUrl);

      // Launch the in-app browser with the correct URL
      await _launchInAppWithBrowserOptionsVersionUpdate(context, updateUrl);
    }
    //}
  }
  bool showPinnedMessage = false;
// Call this method when you know data is loaded

  @override
  Widget build(BuildContext context) {
    final signInProvider = Provider.of<SignInProvider>(context, listen: false);
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    Size size = MediaQuery.of(context).size;

    // Check if token has expired, return the TokenExpireScreen if true
    if (tokenStatus == true) {
      return const TokenExpireScreen();
    }

    // Use FutureBuilder to fetch messages
    return FutureBuilder(
      future: Future.wait([
        signInProvider.fetchSettings(context),
        signInProvider.fetchMessages(context),
        signInProvider.fetchDynamicMenu(context),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return  Center(child:  SpinKitWave(
            color: ColorsContent.newThemeColor,
            size: 25,
          ),); // Show loading indicator
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}')); // Handle error
        } else {
          // Now you can safely check your conditions and show the main content
          if(mounted){
            checkSubscriptionStatus();
            updateFCMTokenIfNeeded(fcmToken);

            final messages = signInProvider.messagesModel?.messages;
            if (signInProvider.settingsModel?.isSubscribed.toString() != "0"){
              if (messages != null && messages.isNotEmpty) {
                // Filter messages where type == "1"
                final filteredMessages = messages.where((msg) => msg.type == "1").toList();

                if (filteredMessages.isNotEmpty) {
                  final messageToShow = filteredMessages.first;

                  getAdDialogLastShownTimestamp().then((lastShown) {
                    final currentTime = DateTime.now().millisecondsSinceEpoch;
                    const oneHourInMillis = 60 * 60 * 1000;


                    if (currentTime - lastShown >= oneHourInMillis) {
                      setAdDialogLastShownTimestamp(currentTime);

                      Future.delayed(Duration.zero, () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return Dialog(
                              backgroundColor: Colors.white,
                              insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Close button
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8, right: 8),
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: ColorsContent.newThemeColor,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.close, color: Colors.white),
                                          iconSize: 20, // Smaller icon
                                          padding: EdgeInsets.zero, // Remove default padding
                                          onPressed: () => Navigator.of(context).pop(),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Image Banner
                                  if ((messageToShow.image_url ?? "").isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 5),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(0),
                                        child: Image.network(
                                          messageToShow.image_url ?? "",
                                          width: double.infinity,
                                        //  height: 180,
                                          fit: BoxFit.cover,
                                       //   errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80),
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 10),

                                  // Title
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      messageToShow.title ?? "",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Description
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      messageToShow.description ?? "",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  // CTA Button
                                  if ((messageToShow.url ?? "").isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: ColorsContent.newThemeColor,
                                          minimumSize: const Size.fromHeight(48),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () async {
                                          final url = messageToShow.url!;
                                          if (await canLaunchUrl(Uri.parse(url))) {
                                            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                          }
                                        },
                                        child: Text(
                                          messageToShow.button_text?.isNotEmpty == true
                                              ? messageToShow.button_text!
                                              : "",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 20),
                                ],
                              ),
                            );
                          },
                        );

                      });
                    }
                  });
                }
              }
            }


            /// ////
            /// this place
          }
          checkVersionUpdate();
          // The main content if no token issues or settingsPopup
          return SafeArea(
            child: Consumer4<MentalStrengthEditProvider, HomeProvider, EditProfileProvider, DashBoardProvider>(
              builder: (context, mentalStrengthEditProvider, homeProvider, editProfileProvider, dashBoardProvider, _) {
                final messages = signInProvider.messagesModel?.messages;
                return backGroundImager(
                  size: size,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await signInProvider.fetchSettings(context);
                      _isTokenExpired();
                   //   homeProvider.fetchChartView(context);
                      await homeProvider.fetchJournals(initial: true,context: context,fullList: true);
                      homeProvider.fetchJournalsGridView(initial: true,context: context,fullList: true);
                      editProfileProvider.fetchUserProfile(context);
                    },
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.035),
                        _buildHeaderRow(context, size, editProfileProvider, dashBoardProvider),
                        Expanded(
                          child: Column(
                            children: [

                              // 🔹 Pinned message UI goes here
                              if (showPinnedMessage && messages != null && messages.isNotEmpty)
                                Builder(
                                  builder: (context) {
                                    final pinnedMessage = messages.firstWhere(
                                          (msg) => msg.type == "2",
                                      orElse: () => Messages(),
                                    );

                                    if ((pinnedMessage.title ?? "").isNotEmpty || (pinnedMessage.description ?? "").isNotEmpty) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 21, vertical: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.lightbulb, color: Colors.amber),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  if (pinnedMessage.title?.isNotEmpty ?? false)
                                                    Text(
                                                      pinnedMessage.title!,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  if (pinnedMessage.description?.isNotEmpty ?? false)
                                                    Text(
                                                      pinnedMessage.description!,
                                                      style: const TextStyle(fontSize: 14),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close, size: 20),
                                              onPressed: () async {
                                                await setPinLastClosedTimestamp();
                                                setState(() {
                                                  showPinnedMessage = false;
                                                });
                                              },

                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  },
                                ),

                              const SizedBox(height: 25),
                              GestureDetector(
                                onTap: (){
                                  dashBoardProvider.changePage(index: 1);
                                  mentalStrengthEditProvider.fetchEmotions(context: context);
                                },
                                child: SizedBox(
                                  child: Image.asset(
                                    ImageConstant.homeBannerNumuNew,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // homeProvider.journalsModelList.isEmpty?
                              //    const SizedBox():
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 22),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Title
                                      Text(
                                        "My Journals",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w700,
                                          color: ColorsContent.blackThemeColor,
                                        ),
                                      ),

                                      // Search icon (always visible)
                                      GestureDetector(
                                        onTap: () {
                                          DateRangePickerScreen.show(
                                            context,
                                            onDateRangeSelected: (startDate, endDate) {
                                              homeProvider.fromDate = startDate;
                                              homeProvider.toDate = endDate;

                                              homeProvider.fetchJournalsGridView(
                                                initial: true,
                                                context: context,
                                                fromDateParam: startDate,
                                                toDateParam: endDate,
                                              );
                                            },
                                          );

                                        },
                                        child: SvgPicture.asset(
                                          ImageConstant.homeSearchNumu,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                    homeProvider.journalsGridModelLoading
                        ? Center(
                      child: CupertinoActivityIndicator(
                        color: ColorsContent.newThemeColor,
                        radius: 15,
                      ),
                    )
                        : homeProvider.journalGridStatus == 404
                        ?
                    GestureDetector(
                      onTap: () {},
                      child: SvgPicture.asset(
                        ImageConstant.homeSearchDataFoundGradient,
                        width: size.width * 0.90,
                        height: size.height * 0.43,
                      ),
                    )

                        : homeProvider.journalGridStatus == 204
                        ?
                    GestureDetector(
                      onTap: () {},
                      child: SvgPicture.asset(
                        ImageConstant.homeScreenNoData,
                        width: size.width * 0.90,
                        height: size.height * 0.43,
                      ),
                    )
                        : Expanded(
                      child: _buildUserProfileList(
                        context,
                        size,
                        homeProvider,
                      ),
                    ),

                    //   const SizedBox(height: 10),

                              // Row with Previous/Next + Search
                              // homeProvider.journalsGridModelLoading
                              //     ? const SizedBox():
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     if (homeProvider.journalsModelGridList.isNotEmpty)
                              //       Builder(
                              //         builder: (context) {
                              //           final isPrevEnabled = homeProvider.pageLoad != 1;
                              //           final isNextEnabled = homeProvider.pageLoad < homeProvider.totalPages;
                              //
                              //           // Check if dates are selected or not
                              //           final bool noDateSelected =
                              //               homeProvider.fromDate == null && homeProvider.toDate == null;
                              //
                              //           return Row(
                              //             children: [
                              //               // Previous button
                              //               GestureDetector(
                              //                 onTap: isPrevEnabled
                              //                     ? () {
                              //                   final prevPage = (homeProvider.pageLoad - 1).toString();
                              //                   homeProvider.fetchJournalsGridView(
                              //                     context: context,
                              //                     pageNo: prevPage,
                              //                     initial: false,
                              //                     fromDateParam: homeProvider.fromDate,
                              //                     toDateParam: homeProvider.toDate,
                              //                     fullList: noDateSelected, // 👈 key change
                              //                   );
                              //                 }
                              //                     : null,
                              //                 child: Container(
                              //                   width: 28,
                              //                   height: 28,
                              //                   decoration: BoxDecoration(
                              //                     color: isPrevEnabled
                              //                         ? ColorsContent.newThemeColor
                              //                         : Colors.grey.shade400,
                              //                     shape: BoxShape.circle,
                              //                   ),
                              //                   child: const Center(
                              //                     child: Icon(
                              //                       Icons.arrow_back_ios_new,
                              //                       size: 16,
                              //                       color: Colors.white,
                              //                     ),
                              //                   ),
                              //                 ),
                              //               ),
                              //
                              //               const SizedBox(width: 8),
                              //
                              //               // Next button
                              //               GestureDetector(
                              //                 onTap: isNextEnabled
                              //                     ? () {
                              //                   final nextPage = (homeProvider.pageLoad + 1).toString();
                              //                   homeProvider.fetchJournalsGridView(
                              //                     context: context,
                              //                     pageNo: nextPage,
                              //                     initial: false,
                              //                     fromDateParam: homeProvider.fromDate,
                              //                     toDateParam: homeProvider.toDate,
                              //                     fullList: noDateSelected, // 👈 key change
                              //                   );
                              //                 }
                              //                     : null,
                              //                 child: Container(
                              //                   width: 28,
                              //                   height: 28,
                              //                   decoration: BoxDecoration(
                              //                     color: isNextEnabled
                              //                         ? ColorsContent.newThemeColor
                              //                         : Colors.grey.shade400,
                              //                     shape: BoxShape.circle,
                              //                   ),
                              //                   child: const Center(
                              //                     child: Icon(
                              //                       Icons.arrow_forward_ios,
                              //                       size: 16,
                              //                       color: Colors.white,
                              //                     ),
                              //                   ),
                              //                 ),
                              //               ),
                              //             ],
                              //           );
                              //         },
                              //       ),
                              //
                              //     const SizedBox(width: 12),
                              //   ],
                              // ),


                              const SizedBox(height: 2),
                            ],
                          ),
                        ),
                      ],
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
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      child:
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: () {
                  dashBoardProvider.changeCommentPage(index: 8);
                },
                child: Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Ensures the image is circular
                    border: Border.all(
                      color: ColorsContent.newThemeColor, // Change this to any color you want
                      width: 0.5, // Adjust border thickness
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(34),
                    child: CustomImageView(
                      imagePath: editProfileProvider.getProfileModel?.profileurl?.toString() ?? "",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: (){
                    dashBoardProvider.changeCommentPage(index: 8);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorsContent.newThemeColor, // Adjust color as needed
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                capitalText(
                  editProfileProvider.getProfileModel?.firstname?.toString() ?? "",
                ),
                style: CustomTextStyles.bodyLarge18,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                         //   textAlign: TextAlign.center, // ⭐ align text center
              ),
            ),
          ),

          //  const Spacer(),
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
            child:
            SvgPicture.asset(
            ImageConstant.menuBarSvg,
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
      width: size.width * 1,
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
      BuildContext context,
      Size size,
      HomeProvider homeProvider,
      ) {
    var logger = Logger();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: homeProvider.journalsModelGridList.isEmpty
          ? const SizedBox()
          : ListView.separated(
        shrinkWrap: false,  // ✅ Change this
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        // itemCount: (homeProvider.journalsModelGrid?.journals?.length ?? 0) < 10
        //     ? (homeProvider.journalsModelGrid?.journals?.length ?? 0)
        //     : 10,
          itemCount: homeProvider.journalsModelGrid?.journals?.length ?? 0,
        itemBuilder: (context, index) {
          final journal = homeProvider.journalsModelGrid!.journals![index];
          logger.i("Media Data: ${journal.journalMedia}");

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => JournalViewScreen(
                    journalId: journal.journalId.toString(),
                    index: index,
                  ),
                ),
              );
            },
            child: UserProfileListItemWidget(
                title: journal.journalTitle ?? '',
                date: journal.journalDatetime ?? '',
                description: journal.journalDesc ?? '',
                journalMedia: journal.journalMedia ?? [],
                locationName: journal.location?.locationName,
                locationLatitude: journal.location?.locationLatitude,
                locationLongitude: journal.location?.locationLongitude,
                journalId: journal.journalId ?? "",
              viewDefImage: journal.displayImage ?? "",
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
