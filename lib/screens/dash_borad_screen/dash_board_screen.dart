import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/screens/journal_list_screen/provider/journal_list_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/widgets/functions/popup.dart';
import 'package:provider/provider.dart';

import '../../utils/core/image_constant.dart';
import '../../utils/theme/theme_helper.dart';
import '../../widgets/custom_image_view.dart';
import '../no_internet/duplicate_screen.dart';

class DashBoardScreen extends StatelessWidget {
  const DashBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer6<
            DashBoardProvider,
            MentalStrengthEditProvider,
            JournalListProvider,
            EditProfileProvider,
            HomeProvider,
            AdDreamsGoalsProvider>(
        builder: (context,
            dashBoardProvider,
            mentalStrengthEditProvider,
            journalListProvider,
            editProfileProvider,
            homeProvider,
            adDreamsGoalsProvider,
            _) {
      return PopScope(
        canPop: false,
        onPopInvoked: (value) {
          customPopup(
            context: context,
            onPressedDelete: () async {
              if (!value) {
                exit(0);
              }
            },
            yes: "Yes",
            title: 'Do you Need Exit',
            content: 'Are you sure do you need Exit',
          );
        },
        child: ConnectivityWidget(
          child: Scaffold(
            body: dashBoardProvider.getPage(),
            backgroundColor: ColorsContent.homeBackGroundColor,
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent, // Set your background color
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), // Adjust as needed
                  topRight: Radius.circular(30),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30), // Match the radius of the container
                  topRight: Radius.circular(30),
                ),
                child: BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: ColorsContent.primaryColor,
                  selectedFontSize: 0,
                  elevation: 0,
                  backgroundColor: Colors.white, // Ensure the background matches
                  currentIndex: dashBoardProvider.currentIndex,
                  onTap: (index) async {
                    dashBoardProvider.changePage(index: index);
                    if (index == 0) {
                      if (homeProvider.chartViewModel == null) {
                       // homeProvider.fetchChartView(context);
                      }
                    } else if (index == 1) {
                      mentalStrengthEditProvider.clearAllValuesInSaveTime();
                      adDreamsGoalsProvider.clearAction();
                      mentalStrengthEditProvider.openAllCloser();
                      await mentalStrengthEditProvider.fetchEmotions(context: context);
                      await editProfileProvider.fetchUserProfile(context);
                    } else if (index == 2) {
                      await journalListProvider.fetchJournalChartView(context: context);
                      await homeProvider.fetchJournals(initial: true,context: context);
                    }
                  },
                  items: [
                    BottomNavigationBarItem(
                      icon:
                      CustomImageView(
                        imagePath: ImageConstant.imgHome,
                        height: 26,
                        width: 26,
                        color: theme.colorScheme.primary.withOpacity(1),
                      ),
                      activeIcon: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Image.asset(
                          ImageConstant.home_active_png, // This should be the path to your PNG image
                         // color: theme.colorScheme.primary.withOpacity(1),
                          height: 80,
                          width: 80,
                        ),
                        // CustomImageView(
                        //   imagePath: ImageConstant.check_home_icon,
                        //   height: 80,
                        //   width: 80,
                        //   color: theme.colorScheme.primary.withOpacity(1),
                        // ),
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: CustomImageView(
                        imagePath: ImageConstant.imgSettings,
                        height: 28,
                        width: 28,
                        color: theme.colorScheme.primary.withOpacity(1),
                      ),
                      activeIcon: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Image.asset(
                          ImageConstant.mental_active_png, // This should be the path to your PNG image
                          // color: theme.colorScheme.primary.withOpacity(1),
                          height: 80,
                          width: 80,
                        ),
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: CustomImageView(
                        imagePath: ImageConstant.imgMegaphone,
                        height: 28,
                        width: 28,
                        color: theme.colorScheme.primary.withOpacity(1),
                      ),
                      activeIcon: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Image.asset(
                          ImageConstant.listview_active_png, // This should be the path to your PNG image
                          // color: theme.colorScheme.primary.withOpacity(1),
                          height: 80,
                          width: 80,
                        ),
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: CustomImageView(
                        imagePath: ImageConstant.imgArrowDown,
                        height: 28,
                        width: 28,
                        color: theme.colorScheme.primary.withOpacity(1),
                      ),
                      activeIcon: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Image.asset(
                          ImageConstant.goal_active_png, // This should be the path to your PNG image
                          // color: theme.colorScheme.primary.withOpacity(1),
                          height: 80,
                          width: 80,
                        ),
                      ),
                      label: '',
                    ),
                  ],
                ),
              ),
            ),
          
          ),
        ),
      );
    });
  }
}
