import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  HomeProvider homeProvider = Provider.of(context, listen: false);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('adDialogLastShown');
  prefs.clear();
  dashBoardProvider.changePage(index: 0);
  homeProvider.reset();

  // ignore: use_build_context_synchronously
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (context) => const ScreenSignIn(),
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

//ad user location
void saveLocationSharePref({required String location}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString("location", location);
}

//get user location
Future<String?> getSaveLocationSharePref() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString("location");
}

//ad user location
void saveLocationCoSharePref({required LatLng location}) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Convert LatLng to string (latitude,longitude)
  String locationString = '${location.latitude},${location.longitude}';

  // Save the string to SharedPreferences
  await prefs.setString("locationCo", locationString);
}


//get user location
Future<LatLng?> getSaveLocationCoSharePref() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Get the saved location string
  String? locationString = prefs.getString("locationCo");

  if (locationString != null) {
    // Split the string into latitude and longitude
    List<String> coordinates = locationString.split(',');

    // Parse the latitude and longitude
    double latitude = double.parse(coordinates[0]);
    double longitude = double.parse(coordinates[1]);

    // Return the LatLng object
    return LatLng(latitude, longitude);
  } else {
    // Return null if no location is saved
    return null;
  }
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


Future<int> getAdDialogLastShownTimestamp() async {
final prefs = await SharedPreferences.getInstance();
return prefs.getInt('adDialogLastShown') ?? 0;
}

Future<void> setAdDialogLastShownTimestamp(int timestamp) async {
final prefs = await SharedPreferences.getInstance();
await prefs.setInt('adDialogLastShown', timestamp);
}

Future<void> setPinLastClosedTimestamp() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt('pin_last_closed', DateTime.now().millisecondsSinceEpoch);
}

Future<bool> shouldShowPinnedMessage() async {
  final prefs = await SharedPreferences.getInstance();
  final lastClosed = prefs.getInt('pin_last_closed') ?? 0;
  final now = DateTime.now().millisecondsSinceEpoch;

  // 10 minutes = 600,000 milliseconds
  return now - lastClosed >= 3600000;
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
