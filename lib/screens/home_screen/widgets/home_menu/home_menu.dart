import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mentalhelth/screens/auth/sign_in/provider/sign_in_provider.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/utils/core/constent.dart';
import 'package:mentalhelth/utils/logic/logic.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/widgets/functions/popup.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../utils/core/firebase_api.dart';
import '../../../../utils/core/image_constant.dart';
import '../../../../utils/core/url_constant.dart';
import '../../../../utils/theme/custom_text_style.dart';
import '../../../../widgets/custom_image_view.dart';
import '../../../dynamic_menu_pages/dynamic_Menu_Webview_Screen.dart';

Widget buildPopupDialog(BuildContext context, Size size) {
  return Consumer3<EditProfileProvider, DashBoardProvider, SignInProvider>(
    builder: (context, editProvider, dashBoardProvider, signInProvider, _) {
      return AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(ImageConstant.gradientBackgroundNumu),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: size.height * 0.75),
              child: Column(
                children: [
                  const SizedBox(height: 15),


                  /// ===================== PROFILE INFO ======================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: Platform.isAndroid ? size.width * 0.58 : size.width * 0.60,
                        decoration: BoxDecoration(
                          color: ColorsContent.whiteText,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                dashBoardProvider.changeCommentPage(index: 8);
                                Navigator.pop(context);
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                radius: size.width * 0.05,
                                child: CustomImageView(
                                  imagePath:
                                  editProvider.getProfileModel?.profileurl ?? "",
                                  height: 50,
                                  width: 50,
                                  radius: BorderRadius.circular(34),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                            SizedBox(
                              width: size.width * 0.40,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  capitalText(
                                    editProvider.getProfileModel?.firstname ?? "",
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                    color: ColorsContent.newThemeColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: CustomImageView(
                            imagePath: ImageConstant.imgCloseNumu,
                            height: 30,
                            width: 30,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.02),

                  /// ===================== SCROLLABLE CONTENT ======================
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _menuItem(
                            title: "Mental strength",
                            onTap: () {
                              dashBoardProvider.changePage(index: 1);
                              Navigator.pop(context);
                            },
                          ),
                          _menuItem(
                            title: "Smart Journals",
                            onTap: () {
                              dashBoardProvider.changePage(index: 2);
                              Navigator.pop(context);
                            },
                          ),
                          _menuItem(
                            title: "Goals & Dreams",
                            onTap: () {
                              dashBoardProvider.changePage(index: 3);
                              Navigator.pop(context);
                            },
                          ),
                          _menuItem(
                            title: "Reminders",
                            onTap: () {
                              dashBoardProvider.changeCommentPage(index: 10);
                              Navigator.pop(context);
                            },
                          ),

                        //  SizedBox(height: size.height * 0.01),

                          /// ===================== DYNAMIC MENU (NOW WORKS) ======================
                          Builder(builder: (_) {
                            final list = signInProvider.dynamicMenuList;

                            if (list == null || list.isEmpty)
                              return SizedBox.shrink();

                            final added = <String>{};
                            final items = list.where((e) {
                              final active = e.status == "1";
                              final unique = !added.contains(e.title);
                              if (active && unique) {
                                added.add(e.title!);
                                return true;
                              }
                              return false;
                            }).toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: items.map((item) {
                                return _menuItem(
                                  title: item.title ?? "",
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            DynamicMenuWebviewScreen(
                                              title: item.title,
                                              url: item.linkUrl,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            );
                          }),
                           SizedBox(height: size.height * 0.02),

                          _menuItem(
                            title: "Privacy policy",
                            onTap: () {
                              dashBoardProvider.changeCommentPage(index: 6);
                              Navigator.pop(context);
                            },
                          ),
                          _menuItem(
                            title: "Terms of service",
                            onTap: () {
                              dashBoardProvider.changeCommentPage(index: 11);
                              Navigator.pop(context);
                            },
                          ),
                          _menuItem(
                            title: "Help",
                            onTap: () {
                              dashBoardProvider.changeCommentPage(index: 12);
                              Navigator.pop(context);
                            },
                          ),

                          /// ===================== APP SHARE ======================
                          Builder(builder: (_) {
                            final shareData =
                                signInProvider.appShareResponseModel;
                            final url = Theme.of(context).platform ==
                                TargetPlatform.iOS
                                ? shareData?.appstoreUrl
                                : shareData?.playstoreUrl;

                            final bool showShare =
                                shareData != null &&
                                    (shareData.title?.isNotEmpty ?? false) &&
                                    (shareData.message?.isNotEmpty ?? false) &&
                                    (url?.isNotEmpty ?? false);

                            if (!showShare) return SizedBox.shrink();

                            return _menuItem(
                              title: "App share",
                              onTap: () async {
                                final message = """
${shareData!.title}

${shareData.message}

Download now: $url
""";
                                await Share.share(message);
                              },
                            );
                          }),

                          _menuItem(
                            title: "Feedback",
                            onTap: () {
                              dashBoardProvider.changeCommentPage(index: 14);
                              Navigator.pop(context);
                            },
                          ),

                          /// ===================== LOGOUT ======================
                          _menuItem(
                            title: "Logout",
                            onTap: () {
                              customPopupNew(
                                context: context,
                                title: "Confirm Logout",
                                content: "Are you sure You want to logout?",
                                yes: "Logout",
                                onPressedDelete: () async {
                                  editProvider.profileUrl = "";

                                  if (Platform.isAndroid) {
                                    await PushNotifications
                                        .subscribeToTopic("live_doLogin");
                                    await PushNotifications
                                        .unsubscribeFromTopic("message");
                                  } else {
                                    OneSignal.logout();
                                    OneSignal.User.addTagWithKey(
                                        "topic", "live_doLogin");
                                    OneSignal.User.removeTag("message");
                                  }

                                  final prefs =
                                  await SharedPreferences.getInstance();
                                  await prefs
                                      .remove('lastSkippedTimestamp');

                                  addFCMTokenToSharePref(token: "");
                                  addVersionSharePref(version: "");

                                  await signInProvider.logOutUser(context);
                                  await removeUserDetailsSharePref(
                                      context: context);
                                  removeAllValuesLogout(context: context);
                                },
                              );
                            },
                          ),

                          _menuItem(
                            title: "Delete Account",
                            onTap: () {
                              dashBoardProvider.changeCommentPage(index: 5);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),

                  /// ===================== VERSION ======================
                  Text(
                    "App Version ${Platform.isAndroid ? Constent.versionCodeAndroid : Constent.versionCodeIOS}",
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: ColorsContent.whiteText,
                    ),
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}



/// Reusable item widget
Widget _menuItem({required String title, required VoidCallback onTap}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: GestureDetector(
      onTap: onTap,
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          title,
          style: CustomTextStyles.titleMediumOnSecondaryContainerMedium
              .copyWith(height: 2.19),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
  );
}


Future<void> shareImageWithText() async {
  // Load image from assets
  final byteData = await rootBundle.load(ImageConstant.appsharenew);

  // Get temp directory
  final tempDir = await getTemporaryDirectory();

  // Extract file name only
  final fileName = ImageConstant.appsharenew.split('/').last;
  final file = File('${tempDir.path}/$fileName');

  // Save image file
  await file.writeAsBytes(byteData.buffer.asUint8List());

  // Share image with text
  await Share.shareXFiles(
    [XFile(file.path)],
    text: '''
Check out the Numu app! 🌿

Build mental strength,reduce anxiety,and stay focused on your goals with Numu.

Download now: https://mh.featureme.live/downloads
''',
  );
}
