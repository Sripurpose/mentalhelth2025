import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';


import 'package:mentalhelth/screens/confirm_delete_screen/confirm_delete_screen.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/edit_add_profile_screen.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/mental_strength_add_edit_page.dart';
import 'package:mentalhelth/screens/myprofile_screen/myprofile_screen.dart';
import 'package:mentalhelth/screens/privacy_screen/privacy_screen.dart';
import 'package:mentalhelth/screens/terms_service_screen/terms_serivce_screen.dart';

import '../../../utils/core/url_constant.dart';
import '../../dynamic_menu_pages/dynamic_Menu_Webview_Screen.dart';
import '../../feedback_screen/feedback_screen.dart';
import '../../goals_dreams_page/goals_dreams_page.dart';
import '../../help_screen/help_screen.dart';
import '../../home_screen/home_screen.dart';
import '../../journal_list_screen/journal_list_page.dart';
import '../../mental_strength_add_edit_screen/numu_mental_strength_add_edit_page.dart';
import '../../no_internet/no_internet_screen.dart';
import '../../terms_of_services/terms_of_services_screen.dart';
import '../../view_reminder_screen/screens/view_reminder_screen.dart';

class DashBoardProvider extends ChangeNotifier {
  int currentIndex = 0;
  int changeCommenPageIndex = 0;
  bool isOnline = true;

  DashBoardProvider() {
    _checkInternet();
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateInternetStatus(results);
    });
  }

  void _checkInternet() async {
    List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    _updateInternetStatus(results);
  }

  void _updateInternetStatus(List<ConnectivityResult> results) {
    bool newStatus = results.contains(ConnectivityResult.wifi) || results.contains(ConnectivityResult.mobile);
    if (isOnline != newStatus) {
      isOnline = newStatus;
      notifyListeners();
    }
  }

  Widget getPage() {
    if (!isOnline && (currentIndex == 1 || currentIndex == 2 || currentIndex == 3 || currentIndex == 0)) {
      return  NoInternetScreen();
    }

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
          );
        case 12:
          return  HelpScreen(
            url: "${UrlConstant.baseUrl}/help/",
          );
        case 13:
        // ✅ One dynamic screen for Chat / AI / Affiliation etc.
          return const DynamicMenuWebviewScreen(
          );
        case 14:
          return FeedbackScreen();
        default:
          return const HomeScreen();
      }
    } else if (currentIndex == 1) {
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
