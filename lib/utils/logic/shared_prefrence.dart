import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/addactions_screen/provider/add_actions_provider.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import 'package:mentalhelth/screens/auth/sign_in/landing_register_screen.dart';
import 'package:mentalhelth/screens/auth/sign_in/provider/sign_in_provider.dart';
import 'package:mentalhelth/screens/auth/sign_in/screen_sign_in.dart';
import 'package:mentalhelth/screens/auth/signup_screen/provider/signup_provider.dart';
import 'package:mentalhelth/screens/auth/signup_screen/signup_screen.dart';
import 'package:mentalhelth/screens/auth/subscribe_plan_page/provider/subscribe_plan_provider.dart';
import 'package:mentalhelth/screens/confirm_plan_screen/provider/my_plan_provider.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/provider/goals_dreams_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/screens/journal_list_screen/provider/journal_list_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/screens/phone_singin_screen/provider/phone_sign_in_provider.dart';
import 'package:mentalhelth/screens/privacy_screen/provider/privacy_policy_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//ad user id
void addUserIdSharePref({required String userId}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("userId", userId);
}

//get user id
Future<String?> getUserIdSharePref() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("userId");
}


void addVersionSharePref({required String version}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("version", version);
}

//get user id
Future<String?> getVersionSharePref() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("version");
}

//remove user id
Future<void> removeUserDetailsSharePref({required BuildContext context}) async {
  DashBoardProvider dashBoardProvider = Provider.of(context, listen: false);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
  dashBoardProvider.changePage(index: 0);
  // ignore: use_build_context_synchronously
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => const LandingRegisterScreenScreen(),
    ),
    (route) => false,
  );
}

//ad user token
void addUserTokenSharePref({required String token}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("token", token);
}

//get user token
Future<String?> getUserTokenSharePref() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("token");
}

//ad user status
void addUserStatusSharePref({required bool token}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool("status", token);
}

//get user status
Future<bool?> getUserStatusSharePref() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool("status");
}

//ad user subscribe
Future<void> addUserSubScribeSharePref({required String subscribe}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("subscribe", subscribe);
}

Future<void> addUserPhoneSharePref({required String phone}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("phone", phone);
}

//get user subscribe
Future<String?> getUserPhoneSharePref() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("phone");
}

Future<String?> getUserSubScribeSharePref() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("subscribe");
}

//ad user email
void addUserEmailSharePref({required String email}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("email", email);
}

//get user email
Future<String?> getUserEmailSharePref() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("email");
}

//ad user password
void addUserPasswordSharePref({required String password}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("password", password);
}

//get user email
Future<String?> getUserPasswordSharePref() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("password");
}

//  // New methods for FCM token
// Method to save FCM token
void addFCMTokenToSharePref({required String token}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("fcm_token", token);
}

// Method to retrieve FCM token
Future<String?> getFCMTokenFromSharePref() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("fcm_token");
}


void removeAllValuesLogout({required BuildContext context}) {
  SignInProvider signInProvider =
      Provider.of<SignInProvider>(context, listen: false);
  signInProvider.socialMediaModel = null;
  signInProvider.loginModel = null;

  SignUpProvider signUpProvider =
      Provider.of<SignUpProvider>(context, listen: false);
  signUpProvider.signUpModel = null;
  SubScribePlanProvider subScribePlanProvider =
      Provider.of<SubScribePlanProvider>(context, listen: false);
  subScribePlanProvider.getPlansModel = null;
  PhoneSignInProvider phoneSignInProvider =
      Provider.of<PhoneSignInProvider>(context, listen: false);
  phoneSignInProvider.verifyOtpModel = null;
  EditProfileProvider editProfileProvider =
      Provider.of<EditProfileProvider>(context, listen: false);
  editProfileProvider.getProfileModel = null;
  editProfileProvider.getCategoryModel = null;

  GoalsDreamsProvider goalsDreamsProvider =
      Provider.of<GoalsDreamsProvider>(context, listen: false);
  goalsDreamsProvider.goalsAndDreamsModel = null;
  goalsDreamsProvider.goalsanddreams = [];
  JournalListProvider journalListProvider =
      Provider.of<JournalListProvider>(context, listen: false);
  journalListProvider.journalChartViewModel = null;
  ConfirmPlanProvider confirmPlanProvider =
      Provider.of<ConfirmPlanProvider>(context, listen: false);
  confirmPlanProvider.subScribePlanModel = null;
  HomeProvider homeProvider = Provider.of<HomeProvider>(context, listen: false);
  homeProvider.chartViewModel = null;
  homeProvider.chartList = [];
  homeProvider.journalsModelList.clear();
  homeProvider.journalsModel = null;
  homeProvider.journalDetails = null;
  PrivacyPolicyProvider privacyPolicyProvider =
      Provider.of<PrivacyPolicyProvider>(context, listen: false);
  privacyPolicyProvider.policyModel = null;
  AdDreamsGoalsProvider adDreamsGoalsProvider =
      Provider.of<AdDreamsGoalsProvider>(context, listen: false);
  adDreamsGoalsProvider.addMediaUploadResponseList.clear();
  adDreamsGoalsProvider.alreadyRecordedFilePath.clear();
  adDreamsGoalsProvider.recordedFilePath.clear();
  adDreamsGoalsProvider.alreadyPickedImages.clear();
  adDreamsGoalsProvider.pickedImages.clear();
  adDreamsGoalsProvider.takedImages.clear();
  adDreamsGoalsProvider.goalModelIdName.clear();
  AddActionsProvider addActionsProvider =
      Provider.of<AddActionsProvider>(context, listen: false);
  addActionsProvider.scheduledTimes.clear();
  addActionsProvider.clearHiveBox();
  addActionsProvider.goalModelIdName = null;
  addActionsProvider.addMediaUploadResponseList.clear();
  addActionsProvider.alreadyRecordedFilePath.clear();
  addActionsProvider.recordedFilePath.clear();
  addActionsProvider.alreadyPickedImages.clear();
  addActionsProvider.pickedImages.clear();
  addActionsProvider.takedImages.clear();
  MentalStrengthEditProvider mentalStrengthEditProvider =
      Provider.of<MentalStrengthEditProvider>(context, listen: false);
  mentalStrengthEditProvider.descriptionEditTextController.clear();
  mentalStrengthEditProvider.addMediaUploadResponseList.clear();
  mentalStrengthEditProvider.recordedFilePath.clear();
  mentalStrengthEditProvider.alreadyRecordedFilePath.clear();
  mentalStrengthEditProvider.pickedImages.clear();
  mentalStrengthEditProvider.alreadyPickedImages.clear();
  mentalStrengthEditProvider.alreadyTakedImages.clear();
  mentalStrengthEditProvider.actionList.clear();
  mentalStrengthEditProvider.actionListAll.clear();
  mentalStrengthEditProvider.cleaGoalValue();
}
