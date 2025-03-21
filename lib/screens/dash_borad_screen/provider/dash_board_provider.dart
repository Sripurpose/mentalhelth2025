import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/confirm_delete_screen/confirm_delete_screen.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/edit_add_profile_screen.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/mental_strength_add_edit_page.dart';
import 'package:mentalhelth/screens/myprofile_screen/myprofile_screen.dart';
import 'package:mentalhelth/screens/privacy_screen/privacy_screen.dart';
import 'package:mentalhelth/screens/terms_service_screen/terms_serivce_screen.dart';

import '../../feedback_screen/feedback_screen.dart';
import '../../goals_dreams_page/goals_dreams_page.dart';
import '../../help_screen/help_screen.dart';
import '../../home_screen/home_screen.dart';
import '../../journal_list_screen/journal_list_page.dart';
import '../../mental_strength_add_edit_screen/numu_mental_strength_add_edit_page.dart';
import '../../terms_of_services/terms_of_services_screen.dart';
import '../../view_reminder_screen/screens/view_reminder_screen.dart';

class DashBoardProvider extends ChangeNotifier {
  int currentIndex = 0;
  int changeCommenPageIndex = 0;

  // List<Widget> pages = [
  //   currentIndex == 0
  //       ? changeCommenPageIndex == 0
  //           ? const HomeScreen()
  //           : changeCommenPageIndex == 5
  //               ? ConfirmDeleteScreen()
  //               : changeCommenPageIndex == 6
  //                   ? const PrivacyScreen()
  //                   : changeCommenPageIndex == 7
  //                       ? const TermsServiceScreen()
  //                       : changeCommenPageIndex == 8
  //                           ? const MyProfileScreen()
  //                           : changeCommenPageIndex == 9
  //                               ? EditAddProfileScreen()
  //                               : const HomeScreen()
  //       : currentIndex == 1
  //           ? const MentalStrengthAddEditFullViewScreen()
  //           : currentIndex == 2
  //               ? const JournalListPage()
  //               : currentIndex == 3
  //                   ? const GoalsDreamsPage()
  //                   : const HomeScreen()
  // ];
  // Widget getPage() {
  //   if (currentIndex == 0) {
  //     if (changeCommenPageIndex == 0) {
  //       return const HomeScreen();
  //     } else if (changeCommenPageIndex == 5) {
  //       return ConfirmDeleteScreen();
  //     } else if (changeCommenPageIndex == 6) {
  //       return const PrivacyScreen();
  //     } else if (changeCommenPageIndex == 7) {
  //       return const TermsServiceScreen();
  //     } else if (changeCommenPageIndex == 8) {
  //       return const MyProfileScreen();
  //     } else if (changeCommenPageIndex == 9) {
  //       return EditAddProfileScreen();
  //     } else {
  //       return const HomeScreen();
  //     }
  //   } else if (currentIndex == 1) {
  //     return const MentalStrengthAddEditFullViewScreen();
  //   } else if (currentIndex == 2) {
  //     return const JournalListPage();
  //   } else if (currentIndex == 3) {
  //     return const GoalsDreamsPage();
  //   } else {
  //     return const HomeScreen();
  //   }
  // }
  Widget getPage() {
    if (currentIndex == 0) {
      switch (changeCommenPageIndex) {
        case 5:
          return ConfirmDeleteScreen();
        case 6:
          return const PrivacyScreen();
        case 7:
          return const TermsServiceScreen();
        case 8:
          return const MyProfileScreen();
        case 9:
          return const EditAddProfileScreen();
        case 10:
          return const ViewReminderScreen();
        case 11:
          return const TermsOfServicesScreen(
            url: "https://mh.featureme.live/v1/terms",
          );
        case 12:
          return const HelpScreen(
            url: "https://mh.featureme.live/v1/help/",
          );
        case 13:
          return FeedbackScreen();
        default:
          return const HomeScreen();
      }
    } else if (currentIndex == 1) {
      //return const MentalStrengthAddEditFullViewScreen();
      return const NumuMentalStrengthAddEditPage();
    } else if (currentIndex == 2) {
      return const JournalListPage();
    } else if (currentIndex == 3) {
      return const GoalsDreamsPage();
    } else {
      return const HomeScreen();
    }
  }

  void changePage({required int index}) {
    currentIndex = index;
    changeCommenPageIndex = 0;
    notifyListeners();
  }

  void changeCommentPage({required int index}) {
    currentIndex = 0;
    changeCommenPageIndex = index;
    notifyListeners();
  }
}
