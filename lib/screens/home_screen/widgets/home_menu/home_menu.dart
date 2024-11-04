import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/auth/sign_in/provider/sign_in_provider.dart';
import 'package:mentalhelth/screens/auth/subscribe_plan_page/subscribe_plan_page.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/feedback_screen/feedback_screen.dart';
import 'package:mentalhelth/screens/help_screen/help_screen.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/utils/core/constent.dart';
import 'package:mentalhelth/utils/logic/logic.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:mentalhelth/widgets/functions/popup.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../utils/core/firebase_api.dart';
import '../../../../utils/core/image_constant.dart';
import '../../../../utils/theme/custom_text_style.dart';
import '../../../../utils/theme/theme_helper.dart';
import '../../../../widgets/custom_image_view.dart';
import '../../../subscription_view/subscription_view_screen.dart';
import '../../../view_reminder_screen/screens/view_reminder_screen.dart';

Widget buildPopupDialog(BuildContext context, Size size) {
  return AlertDialog(
    backgroundColor: appTheme.blue300.withOpacity(0.95), // Adjust the opacity as needed
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        20.0,
      ), // Adjust the radius as needed
    ),
    content: SizedBox(
      width: double.maxFinite,
      child: Consumer2<EditProfileProvider,DashBoardProvider>(builder: (context, editProvider,dashBoardProvider, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: CustomImageView(
                  imagePath: ImageConstant.imgClose,
                  height: 30,
                  width: 30,
                ),
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: (){
                    dashBoardProvider
                        .changeCommentPage(
                      index: 8,
                    );
                    Navigator.of(context).pop();
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: size.width * 0.075,
                    child: CustomImageView(
                      imagePath:
                          editProvider.getProfileModel?.profileurl.toString(),
                      height: 58,
                      width: 58,
                      radius: BorderRadius.circular(
                        34,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  width: size.width * 0.02,
                ),
                SizedBox(
                  width: size.width * 0.40,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    // Enable horizontal scrolling
                    child: Text(
                      capitalText(
                        editProvider.getProfileModel?.firstname.toString() ??
                            "",
                      ),
                      style: CustomTextStyles.blackText24000000W500(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
//hided on purpose//
            // Row(
            //   children: [
            //     Text(
            //       "Active Monthly plan ",
            //       style: CustomTextStyles.titleMediumffffffff15,
            //     ),
            //     Expanded(
            //       child: Text(
            //         "( ${editProvider.getProfileModel?.subscription?.planValidity!.toString()} Days remaining ) ",
            //         style: CustomTextStyles.titleMediumffffffff13,
            //         overflow: TextOverflow.ellipsis,
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // Align(
            //   alignment: Alignment.topLeft,
            //   child: GestureDetector(
            //     onTap: () {
            //       Navigator.of(context).push(MaterialPageRoute(
            //         builder: (context) => SubscribePlanPage(
            //           signed: true,
            //         ),
            //       ));
            //     },
            //     child: Text(
            //       "Renew Now",
            //       style: CustomTextStyles.labelLargeffffffff,
            //     ),
            //   ),
            // ),
//hided on purpose//
            Consumer<DashBoardProvider>(
                builder: (context, dashBoardProvider, _) {
              return GestureDetector(
                onTap: () {
                  dashBoardProvider.changePage(index: 1);
                  Navigator.of(context).pop();
                },
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Mental strength",
                    maxLines: 13,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles
                        .titleMediumOnSecondaryContainerMedium
                        .copyWith(
                      height: 2.19,
                    ),
                  ),
                ),
              );
            }),
            SizedBox(
              height: size.height * 0.001,
            ),
            Consumer<DashBoardProvider>(
                builder: (context, dashBoardProvider, _) {
              return GestureDetector(
                onTap: () {
                  dashBoardProvider.changePage(index: 2);
                  Navigator.of(context).pop();
                },
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Smart Journal",
                    maxLines: 13,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles
                        .titleMediumOnSecondaryContainerMedium
                        .copyWith(
                      height: 2.19,
                    ),
                  ),
                ),
              );
            }),
            SizedBox(
              height: size.height * 0.001,
            ),
            Consumer<DashBoardProvider>(
                builder: (context, dashBoardProvider, _) {
              return GestureDetector(
                onTap: () {
                  dashBoardProvider.changePage(index: 3);
                  Navigator.of(context).pop();
                },
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Goals & Dreams",
                    maxLines: 13,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles
                        .titleMediumOnSecondaryContainerMedium
                        .copyWith(
                      height: 2.19,
                    ),
                  ),
                ),
              );
            }),
            SizedBox(
              height: size.height * 0.001,
            ),
            Consumer<HomeProvider>(builder: (context, homeProvider, _) {
              return GestureDetector(
                onTap: () async {
                  await homeProvider.fetchRemindersDetails();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ViewReminderScreen(),
                    ),
                  );
                 //  dashBoardProvider.changeCommentPage(index: 10);
                 // Navigator.of(context).pop();
                },
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Reminders",
                    maxLines: 13,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles
                        .titleMediumOnSecondaryContainerMedium
                        .copyWith(
                      height: 2.19,
                    ),
                  ),
                ),
              );
            }),
            SizedBox(
              height: size.height * 0.001,
            ),
            // Consumer2<SignInProvider,EditProfileProvider>(
            //   builder: (context, signInProvider,editProfileProvider, _) {
            //     // Check the conditions for showing the "Subscription" button
            //     bool showSubscription = editProfileProvider.getProfileModel?.show_subscription == "1" ;
            //
            //
            //     // If conditions are met, display the GestureDetector for "Subscription"
            //     return showSubscription
            //         ? GestureDetector(
            //             onTap: () async {
            //               Navigator.of(context).push(
            //                 MaterialPageRoute(
            //                   builder: (context) => SubscriptionViewScreen(
            //                     url: signInProvider
            //                             .settingsList[0].subscription_url ??
            //                         "",
            //                   ),
            //                 ),
            //               );
            //             },
            //             child: Align(
            //               alignment: Alignment.topLeft,
            //               child: Text(
            //                 "Subscription",
            //                 maxLines: 13,
            //                 overflow: TextOverflow.ellipsis,
            //                 style: CustomTextStyles
            //                     .titleMediumOnSecondaryContainerMedium
            //                     .copyWith(
            //                   height: 2.19,
            //                 ),
            //               ),
            //             ),
            //           )
            //         : SizedBox
            //             .shrink(); // Hide the button if the conditions are not met
            //   },
            // ),

            SizedBox(
              height: size.height * 0.03,
            ),
            Consumer<DashBoardProvider>(
                builder: (context, dashBoardProvider, _) {
              return GestureDetector(
                onTap: () {
                  dashBoardProvider.changeCommentPage(index: 6);
                  Navigator.of(context).pop();
                },
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Privacy policy",
                    maxLines: 13,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles
                        .titleMediumOnSecondaryContainerMedium
                        .copyWith(
                      height: 2.19,
                    ),
                  ),
                ),
              );
            }),
            SizedBox(
              height: size.height * 0.001,
            ),
            Consumer<DashBoardProvider>(
                builder: (context, dashBoardProvider, _) {
              return GestureDetector(
                onTap: () {
                  dashBoardProvider.changeCommentPage(index: 11);
                  Navigator.of(context).pop();
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => const HelpScreen(
                  //       url: "https://mh.featureme.live/v1/terms",
                  //     ),
                  //   ),
                  // );
                },
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Terms of service",
                    maxLines: 13,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles
                        .titleMediumOnSecondaryContainerMedium
                        .copyWith(
                      height: 2.19,
                    ),
                  ),
                ),
              );
            }),
            SizedBox(
              height: size.height * 0.001,
            ),
            GestureDetector(
              onTap: () {
                dashBoardProvider.changeCommentPage(index: 12);
                Navigator.of(context).pop();
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => const HelpScreen(
                //       url: "https://mh.featureme.live/v1/help/",
                //     ),
                //   ),
                // );
              },
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Help",
                  maxLines: 13,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyles.titleMediumOnSecondaryContainerMedium
                      .copyWith(
                    height: 2.19,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.001,
            ),
            GestureDetector(
              onTap: () async {
                // final url
                await Share.share(
                    "Download Now https://play.google.com/store/apps/details?id=${Constent.appId}");
              },
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "App share",
                  maxLines: 13,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyles.titleMediumOnSecondaryContainerMedium
                      .copyWith(
                    height: 2.19,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.005,
            ),
            GestureDetector(
              onTap: () {
                dashBoardProvider.changeCommentPage(index: 13);
                Navigator.of(context).pop();
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => FeedbackScreen(),
                //   ),
                // );
              },
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Feedback",
                  maxLines: 13,
                  overflow: TextOverflow.ellipsis,
                  style: CustomTextStyles.titleMediumOnSecondaryContainerMedium
                      .copyWith(
                    height: 2.19,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Consumer<SignInProvider>(
              builder: (context, signInProvider, _) {
                return GestureDetector(
                  onTap: () async {
                    customPopup(
                      context: context,
                      onPressedDelete: () async {
                        if(Platform.isAndroid){
                          await PushNotifications.subscribeToTopic("live_doLogin");
                          await PushNotifications.unsubscribeFromTopic("message");
                        }else{
                          OneSignal.logout();
                          OneSignal.User.addTagWithKey("topic","live_doLogin");
                          OneSignal.User.removeTag("message");
                        }
                        addFCMTokenToSharePref(token: "");
                        await signInProvider.logOutUser(context);
                        await removeUserDetailsSharePref(context: context);
                        removeAllValuesLogout(context: context);
                      },
                      title: 'Confirm Logout',
                      content: 'Are you sure You want to logout?',
                      yes: "Logout",
                    );
                  },
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Logout",
                      maxLines: 13,
                      overflow: TextOverflow.ellipsis,
                      style: CustomTextStyles
                          .titleMediumOnSecondaryContainerMedium
                          .copyWith(
                        height: 2.19,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              height: size.height * 0.001,
            ),
            Consumer<DashBoardProvider>(
                builder: (context, dashBoardProvider, _) {
              return GestureDetector(
                onTap: () {
                  dashBoardProvider.changeCommentPage(index: 5);
                  Navigator.of(context).pop();
                },
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Delete Account",
                    maxLines: 13,
                    overflow: TextOverflow.ellipsis,
                    style: CustomTextStyles
                        .titleMediumOnSecondaryContainerMedium
                        .copyWith(
                      height: 2.19,
                    ),
                  ),
                ),
              );
            }),
            SizedBox(
              height: size.height * 0.03,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                "App Version 1.0.1",
                maxLines: 13,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStyles.titleMediumOnSecondaryContainerMedium
                    .copyWith(
                  height: 2.19,
                ),
              ),
            ),
          ],
        );
      }),
    ),
  );
}
