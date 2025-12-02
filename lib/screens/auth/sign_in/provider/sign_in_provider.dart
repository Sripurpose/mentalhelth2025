import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/auth/sign_in/model/login_model.dart';
import 'package:mentalhelth/screens/auth/sign_in/model/social_media_login.dart';
import 'package:mentalhelth/screens/dash_borad_screen/dash_board_screen.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';

import '../../../../utils/core/constent.dart';
import '../../../maintenence_screen/maintenence_screen.dart';
import '../../../token_expiry/token_expiry.dart';
import '../../subscribe_plan_page/subscribe_plan_page.dart';
import '../model/app_settings_model.dart';
import '../model/app_settings_register_model.dart';
import '../model/app_share_response.dart';
import '../model/dynamic_Menu_Response_Model.dart';
import '../model/messages_model.dart';
import '../model/version_update_model.dart';

class SignInProvider extends ChangeNotifier {
  TextEditingController emailFieldController = TextEditingController();
  TextEditingController passwordFieldController = TextEditingController();
  TextEditingController forgotEmailFieldController = TextEditingController();
  int forgotPasswordStatus = 0;
  String? forgotPasswordMessage = "";
  var logger = Logger();
  String? continueWithGoogleId = "";
  String? continueWithGoogleMail = "";
  String? continueWithGoogleName = "";
  bool gotoVisibility = false;
  //stripe webview functions

  void clearTextEditingController() {
    emailFieldController.clear();
    passwordFieldController.clear();
    forgotEmailFieldController.clear();
    notifyListeners();
  }

  // bool isWebViewSuccessStarted = false;
  LoginModel? loginModel;
  bool loginLoading = false;
  int? loginStatus;

  Future<void> loginUser(BuildContext context,
      {required String email, required String password, required String deviceType,}) async
  {
    try {
      loginStatus = 0;
      loginLoading = true;


      String? versionCode = '';
      if (Platform.isAndroid) {
        versionCode = Constent.versionCodeAndroid.isNotEmpty
            ? Constent.versionCodeAndroid
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      } else if (Platform.isIOS) {
        versionCode = Constent.versionCodeIOS.isNotEmpty
            ? Constent.versionCodeIOS
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      }
      notifyListeners();
      var body = {
        'email': email,
        'password': password,
      };
      logger.i("body${body}");
      final response = await http.post(
        Uri.parse(
          UrlConstant.loginUrl,
        ),
        headers: <String, String>{
          'device-type': deviceType,
          'version': versionCode.toString(),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      logger.i("responsePharse${response.body}");
      if (response.statusCode == 200) {
        loginStatus = response.statusCode;
        TokenManager.setTokenStatus(false);
        loginModel = loginModelFromJson(
          response.body,
        );
        addUserIdSharePref(
          userId: loginModel!.userId!,
        );
        addUserTokenSharePref(
          token: loginModel!.userToken!,
        );
        addUserStatusSharePref(
          token: loginModel!.status!,
        );
        await addUserSubScribeSharePref(
            subscribe: loginModel!.isSubscribed.toString());
        addUserEmailSharePref(
          email: email,
        );
        addUserPasswordSharePref(
          password: password,
        );
        if (loginModel!.status!) {

          if (loginModel!.isSubscribed == "0") {
             fetchMessages(context);
            checkAndFetchVersionUpdate(context,);
        //    fetchSettings(context);
            // Navigator.of(context).pushAndRemoveUntil(
            //   MaterialPageRoute(
            //     builder: (context) => SubscribePlanPage(),
            //   ),
            //   (route) => false,
            // );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const DashBoardScreen(),
              ),
                  (route) => false,
            );
          } else {
            fetchMessages(context);
            checkAndFetchVersionUpdate(context,);
          //  fetchSettings(context);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const DashBoardScreen(),
              ),
              (route) => false,
            );
          }
        }
      } else if (response.statusCode == 400) {
        loginStatus = response.statusCode;

        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          String errorMessage = responseData['text'] ?? "Something went wrong";

          showCustomSnackBar(
            context: context,
            message: errorMessage,
          );
        } catch (e) {
          // fallback if body is not valid JSON
          showCustomSnackBar(
            context: context,
            message: "An unexpected error occurred",
          );
        }
      }

      else if(response.statusCode == 503){
        logger.w("response.statusCode == 503${response.statusCode == 503}");
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MaintenenceScreen(
                title: "App is in maintainance mode, Please be patient, we'll be back in a couple of hours!",
                message: "",
              ),
            ),
          );
        });
      } else if(response.statusCode == 201){
        loginStatus = response.statusCode;
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          String errorMessage = responseData['text'] ?? "Something went wrong";

          showCustomSnackBar(
            context: context,
            message: errorMessage,
          );
        } catch (e) {
          // fallback if body is not valid JSON
          showCustomSnackBar(
            context: context,
            message: "An unexpected error occurred",
          );
        }
      }
      else{
        loginStatus = response.statusCode;
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          String errorMessage = responseData['text'] ?? "Something went wrong";

          showCustomSnackBar(
            context: context,
            message: errorMessage,
          );
        } catch (e) {
          // fallback if body is not valid JSON
          showCustomSnackBar(
            context: context,
            message: "An unexpected error occurred",
          );
        }
      }
      if(response.statusCode == 401){
        loginStatus = response.statusCode;
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        loginStatus = response.statusCode;
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 400){
        //TokenManager.setTokenStatus(true);
        loginStatus = response.statusCode;
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      loginStatus = response.statusCode;
      loginLoading = false;
      notifyListeners();
      emailFieldController.clear();
      passwordFieldController.clear();
    } catch (error) {
      emailFieldController.clear();
      passwordFieldController.clear();
      loginLoading = false;
      notifyListeners();
    }
  }

  void checkAndFetchVersionUpdate(BuildContext context,) {
    String deviceType = Platform.isAndroid ? 'android' : 'ios';
   fetchVersionUpdate(context, deviceType);
  }


  bool logOutLoading = false;
  Future<void> logOutUser(BuildContext context) async {
    try {
      logOutLoading = true;
      notifyListeners();

      // Retrieve and print the token for debugging
      String? token = await getUserTokenSharePref();
      print('Token: $token');

      // Check if token is valid before making API call
      if (token == null || token.isEmpty) {
        throw Exception("Token is null or empty");
      }

      // Log the request details
      print("Logging out with URL: ${UrlConstant.logOutUrl}");

      final response = await http.post(
        Uri.parse(UrlConstant.logOutUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'authorization': token, // Corrected token usage
        },
      );

      // Print response status and body for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 401 || response.statusCode == 403 || response.statusCode == 400) {

        print('Authorization error: Token may be invalid or expired');
        // Optionally, handle the token refresh or invalidation
      }

      logOutLoading = false;
      notifyListeners();
    } catch (error) {
      print('Logout error: $error');
      logOutLoading = false;
      notifyListeners();
    }
  }



  bool forgetLoading = false;

  Future<void> forgetPassword(
    BuildContext context,
      String deviceType,
  ) async {
    try {
      forgetLoading = true;
      forgotPasswordStatus = 0;
      forgotPasswordMessage = '';
      String? versionCode = '';
      if (Platform.isAndroid) {
        versionCode = Constent.versionCodeAndroid.isNotEmpty
            ? Constent.versionCodeAndroid
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      } else if (Platform.isIOS) {
        versionCode = Constent.versionCodeIOS.isNotEmpty
            ? Constent.versionCodeIOS
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      }
      notifyListeners();
      var body = {
        'email': forgotEmailFieldController.text,
      };
      final response = await http.post(
        Uri.parse(
          UrlConstant.forgotPassword,
        ),
        headers: <String, String>{
          'device-type': deviceType,
          'version': versionCode.toString(),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      var jsonResponse = jsonDecode(response.body);
      print('Decoded response: $jsonResponse');
      if (response.statusCode == 200 || response.statusCode == 201) {
        forgotPasswordStatus = response.statusCode;
        forgotPasswordMessage = response.reasonPhrase;
        showToast(
          context: context,
          message: jsonResponse['text'] ??
              "Please check your mail to reset your password!",
        );
      } else if(response.statusCode == 503){
        logger.w("response.statusCode == 503${response.statusCode == 503}");
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MaintenenceScreen(
                title: "App is in maintainance mode, Please be patient, we'll be back in a couple of hours!",
                message: "",
              ),
            ),
          );
        });
      }
      else {
        forgotPasswordStatus = response.statusCode;
        forgotPasswordMessage = response.reasonPhrase;
        logger.w("forgotPasswordMessage$forgotPasswordMessage");
        showToast(
          context: context,
          message: jsonResponse['text'] ?? 'Forget password failed',
        );
      }
      forgotPasswordMessage = jsonResponse;
      forgotPasswordStatus = response.statusCode;
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        forgotPasswordStatus = response.statusCode;
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      forgotPasswordStatus = response.statusCode;
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        forgotPasswordStatus = response.statusCode;
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      forgotPasswordStatus = response.statusCode;
      forgetLoading = false;
      notifyListeners();
      forgotEmailFieldController.clear();
      emailFieldController.clear();
      passwordFieldController.clear();
    } catch (error) {
      forgotEmailFieldController.clear();
      emailFieldController.clear();
      passwordFieldController.clear();
      forgetLoading = false;
      notifyListeners();
    }
  }

  void signInWithGoogle({required BuildContext context}) async {
    try {
      socialMediaModelLoading = true;
      notifyListeners();

      print("Attempting to sign in with Google...");

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        debugPrint("Google sign-in canceled by user.");
        return;
      }
      print("Google user obtained: ${googleUser.displayName}");

      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      if (googleAuth == null || googleAuth.accessToken == null || googleAuth.idToken == null) {
        debugPrint("Failed to retrieve Google authentication tokens.");
        return;
      }
      print("Google auth tokens obtained.");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print("Firebase credential created with Google tokens.");

      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) {
        debugPrint("Firebase sign-in failed, no user returned.");
        return;
      }
      print("Firebase user signed in: ${user.uid}");

      String? firebaseRegistrationId = await user.getIdToken();
      String os = Platform.operatingSystem;

      // Social media function
      await socialMediaFunction(
        context,
        googleid: googleUser.id,
      );
      print("Social media function executed.");

      // Save Firebase token
      // await saveFirebaseToken(context,
      //     registrationId: firebaseRegistrationId.toString(), deviceOs: os);
      // print("Firebase token saved.");

    } catch (e) {
      print("Error during Google Sign-In: $e");
    } finally {
      socialMediaModelLoading = false;
      notifyListeners();
      print("Google Sign-In process complete.");
    }
  }



  void googleSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // ignore: empty_catches
    } catch (e) {}
  }

// social MediaLoagin

  SocialMediaModel? socialMediaModel;
  bool socialMediaModelLoading = false;

  Future<void> socialMediaFunction(BuildContext context,
      {String? fbid, String? googleid, String? appleid,String? firstname, String? email}) async {
    try {
      // var body = {
      //   'fbid': email,
      //   'googleid': password,
      //   'appleid': appleid,
      // };
      var body = {};
      if (fbid != null) {
        body = {'fbid': fbid};
      } else if (googleid != null) {
        body = {'googleid': googleid,'firstname':firstname,'email':email};
      } else if (appleid != null) {
        body = {'appleid': appleid};
      }
      final response = await http.post(
        Uri.parse(
          UrlConstant.socialmedialoginUrl,
        ),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        socialMediaModel = socialMediaModelFromJson(
          response.body,
        );
        addUserIdSharePref(
          userId: socialMediaModel!.userId!,
        );
        addUserTokenSharePref(
          token: socialMediaModel!.userToken!,
        );
        addUserStatusSharePref(
          token: socialMediaModel!.status!,
        );
        addUserSubScribeSharePref(
            subscribe: socialMediaModel!.isSubscribed.toString());

        if (socialMediaModel!.status!) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const DashBoardScreen(),
            ),
                (route) => false,
          );
        }
      } else {
        showCustomSnackBar(context: context, message: 'Login failed.');
      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      socialMediaModelLoading = false;
      notifyListeners();
    } catch (error) {
      socialMediaModelLoading = false;
      notifyListeners();
    }
  }

  //save firebase token
  bool saveFirebaseLoading = false;

  Future<void> saveFirebaseToken(BuildContext context,
      {required String registrationId, required String deviceOs}) async {
    try {
      saveFirebaseLoading = true;
      notifyListeners();
      String? token = await getUserTokenSharePref();
      var headers = {
        'Device-Type': 'android',
        'Version': '2.0',
        'authorization': token.toString()
      };
      var body = {
        'registration_id': registrationId,
        'device_os': deviceOs,
      };

      final response = await http.post(
        Uri.parse(
          UrlConstant.savefirebasetokenUrl,
        ),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
      } else {}
      if(response.statusCode == 401){

      }
      if(response.statusCode == 403){

      }
      saveFirebaseLoading = false;
      notifyListeners();
    } catch (error) {
      saveFirebaseLoading = false;
      notifyListeners();
    }
  }

  Future callSignInButton(BuildContext context,String deviceType) async {
    if (emailFieldController.text.isNotEmpty &&
        passwordFieldController.text.isNotEmpty) {
      await loginUser(
        context,
        email: emailFieldController.text,
        password: passwordFieldController.text,
        deviceType: deviceType
      );
    } else if (emailFieldController.text.isEmpty) {
      showCustomSnackBar(
        context: context,
        message: "Enter your email and password",
      );
      emailFieldController.clear();
      passwordFieldController.clear();
    } else {
      showCustomSnackBar(
        context: context,
        message: "Enter your email and password",
      );
      emailFieldController.clear();
      passwordFieldController.clear();
    }
  }
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<UserCredential?> loginWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        print('Google sign-in was canceled by the user.');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print("googleAuth.idToken${googleAuth.idToken}");
      print("googleAuth.accessToken${googleAuth.accessToken}");

      // Check for null tokens
      if (googleAuth.idToken == null || googleAuth.accessToken == null) {
        print('Error: Google Auth tokens are null.');
        return null;
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // Sign in with the credential
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Error during Google Sign-In: $e');
      debugPrint('Error during Google Sign-In: ${e.toString()}');
      return null;
    }
  }

  SettingsModel? settingsModel;
  List<Setting> settingsList = [];
  bool settingsLoading = false;

  SettingsRegisterModel? settingsRegisterModel;
  List<SettingRegister> settingsRegisterList = [];
  bool registerSettingsLoading = false;
  int? statusSub = 0;

  int? statusVersionUpdate;
  int? statusAppSetup;
  bool versionUpdateLoading = false;
  VersionUpdateModel? versionUpdateModel;

  Future<void> fetchSettings(BuildContext context) async {
    try {
      statusSub= 0;
      settingsModel = null;
      String? token = await getUserTokenSharePref();
      settingsLoading = true;
      String deviceType = Platform.isAndroid ? 'android' : 'ios';
      String? versionCode = '';
      if (Platform.isAndroid) {
        versionCode = Constent.versionCodeAndroid.isNotEmpty
            ? Constent.versionCodeAndroid
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      } else if (Platform.isIOS) {
        versionCode = Constent.versionCodeIOS.isNotEmpty
            ? Constent.versionCodeIOS
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      }
      notifyListeners();

      Map<String, String> headers = {
        'device-type': deviceType,
        'version': versionCode.toString(),
        'authorization': token!, // Assuming token is not null

      };
      Uri url = Uri.parse(
        UrlConstant.appSettingsUrl,
      );
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        statusSub = response.statusCode;
        settingsModel = settingsModelFromJson(response.body);
        logger.w("settingsModel ${settingsModel?.settings}");
        if (settingsModel != null) {
          if (settingsModel!.settings != null) {
            settingsList.addAll(settingsModel!.settings!);
            logger.w("settingsList${jsonEncode(settingsModel)}");
          }
        }
        settingsLoading = false;
        notifyListeners();
      }
      else if(response.statusCode == 503){
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MaintenenceScreen(
                title: "App is in maintainance mode, Please be patient, we'll be back in a couple of hours!",
                message: "",
              ),
            ),
          );
        });
      }
      else {
        TokenManager.setTokenStatus(false);
        statusSub = response.statusCode;
        settingsLoading = false;
        notifyListeners();
      }
      if(response.statusCode == 401){
        statusSub = response.statusCode;
       // TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        statusSub = response.statusCode;
       // TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      statusSub = response.statusCode;
      settingsLoading = false;
      notifyListeners();
    } catch (e) {
      settingsLoading = false;
      notifyListeners();
    }
    notifyListeners();
  }

  String? isRequired = '';
  // Future<void> fetchAppRegister(BuildContext context) async {
  //   try {
  //     settingsRegisterModel = null;
  //
  //     String? token = await getUserTokenSharePref();
  //     registerSettingsLoading = true;
  //     logger.w("registerSettingsLoading${registerSettingsLoading}");
  //     notifyListeners();
  //
  //     Uri url = Uri.parse(
  //       UrlConstant.appRegisterUrl,
  //     );
  //     logger.w("url ${url}");
  //     final response = await http.get(url,);
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //
  //       settingsRegisterModel = settingsRegisterModelFromJson(response.body);
  //       registerSettingsLoading = false;
  //       notifyListeners();
  //       logger.w("registerSettingsLoading${registerSettingsLoading}");
  //       logger.w("settingsRegisterModel ${settingsRegisterModel?.settings}");
  //       if (settingsRegisterModel != null) {
  //         if (settingsRegisterModel!.settings != null) {
  //           settingsRegisterList.addAll(settingsRegisterModel!.settings!);
  //           isRequired = settingsRegisterModel!.settings![0].isRequired;
  //           logger.w("isRequired${isRequired}");
  //           logger.w("settingsRegisterList${jsonEncode(settingsRegisterModel)}");
  //         }
  //       }
  //       registerSettingsLoading = false;
  //       notifyListeners();
  //     }
  //     else {
  //       registerSettingsLoading = false;
  //       notifyListeners();
  //     }
  //     if(response.statusCode == 401){
  //       TokenManager.setTokenStatus(true);
  //       //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
  //     }
  //     if(response.statusCode == 403){
  //       TokenManager.setTokenStatus(true);
  //       //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
  //     }
  //     registerSettingsLoading = false;
  //     notifyListeners();
  //   } catch (e) {
  //     registerSettingsLoading = false;
  //     notifyListeners();
  //   }
  //   notifyListeners();
  // }


  int? statusMessages;
  bool messagesLoading = false;
  MessagesModel? messagesModel;

  Future<void> fetchMessages(BuildContext context) async {
    try {
      logger.w("fetchMessages() called");

      statusMessages = 0;
      messagesLoading = true;
      notifyListeners();

      String? token = await getUserTokenSharePref();
      String deviceType = Platform.isAndroid ? 'android' : 'ios';

      String? versionCode = '';
      if (Platform.isAndroid) {
        versionCode = Constent.versionCodeAndroid.isNotEmpty
            ? Constent.versionCodeAndroid
            : await getVersionSharePref();
      } else if (Platform.isIOS) {
        versionCode = Constent.versionCodeIOS.isNotEmpty
            ? Constent.versionCodeIOS
            : await getVersionSharePref();
      }

      logger.w("Token: $token");
      logger.w("Version Code: $versionCode");

      Map<String, String> headers = {
        'Device-Type': deviceType,
        'Version': versionCode ?? '',
        'authorization': token ?? '',
      };

      logger.w("Headers: $headers");

      Uri url = Uri.parse(UrlConstant.messages);
      logger.w("Messages URL: $url");

      final response = await http.get(url, headers: headers);
      logger.w("Raw response: ${response.statusCode} - ${response.body}");

      final body = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        messagesModel = MessagesModel.fromJson(body);
        statusMessages = response.statusCode;

        logger.w("statusMessages: $statusMessages");
        logger.w("messagesModel: ${messagesModel?.toJson()}");
      }
      else if (response.statusCode == 404 && body['status'] == false) {
        // Still parse and handle 'no messages found' case
        messagesModel = MessagesModel.fromJson(body);
        statusMessages = response.statusCode;

        logger.w("No messages found: ${messagesModel?.text}");
      }
      else if (response.statusCode == 503) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MaintenenceScreen(
                title:
                "App is in maintenance mode, Please be patient, we'll be back in a couple of hours!",
                message: "",
              ),
            ),
          );
        });
      }
      else {
        statusMessages = response.statusCode;

        if (response.statusCode == 401 || response.statusCode == 403) {
          logger.w("Unauthorized or Forbidden: $statusMessages");
          TokenManager.setTokenStatus(false);
        } else {
          logger.w("Unhandled status code: ${response.statusCode}");
        }
      }

    } catch (e, stackTrace) {
      logger.e("Error in fetchMessages()", error: e, stackTrace: stackTrace);
    } finally {
      messagesLoading = false;
      notifyListeners();
    }
  }




  Future<void> fetchAppRegister(
      BuildContext context, {
        required String deviceType,
      }) async {
    try {
      statusAppSetup = 0;
      settingsRegisterModel = null;

      String? token = await getUserTokenSharePref();
      registerSettingsLoading = true;
      logger.w("registerSettingsLoading $registerSettingsLoading");
      notifyListeners();

      Uri url = Uri.parse(UrlConstant.appRegisterUrl);
      logger.w("url $url");


      String? versionCode = '';
      if (Platform.isAndroid) {
        versionCode = Constent.versionCodeAndroid.isNotEmpty
            ? Constent.versionCodeAndroid
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      } else if (Platform.isIOS) {
        versionCode = Constent.versionCodeIOS.isNotEmpty
            ? Constent.versionCodeIOS
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      }

      Map<String, String> headers = {
        'Device-Type': deviceType,
        'Version': versionCode.toString(),
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        statusAppSetup = response.statusCode;
        settingsRegisterModel = settingsRegisterModelFromJson(response.body);
        registerSettingsLoading = false;
        notifyListeners();

        logger.w("registerSettingsLoading $registerSettingsLoading");
        logger.w("settingsRegisterModel ${settingsRegisterModel?.settings}");

        if (settingsRegisterModel?.settings != null) {
          settingsRegisterList.addAll(settingsRegisterModel!.settings!);
          isRequired = settingsRegisterModel!.settings![0].isRequired;
          logger.w("isRequired $isRequired");
          logger.w("settingsRegisterList ${jsonEncode(settingsRegisterModel)}");
        }
      }
      else if(response.statusCode == 503){
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MaintenenceScreen(
                title: "App is in maintainance mode, Please be patient, we'll be back in a couple of hours!",
                message: "",
              ),
            ),
          );
        });
      }
      else {
        statusAppSetup = response.statusCode;
        logger.i("settingsRegisterModel${jsonEncode(settingsRegisterModel?.status)}");
        if (response.statusCode == 401 || response.statusCode == 403) {
          statusAppSetup = response.statusCode;
       //   TokenManager.setTokenStatus(true);
          // CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
        }
      }
      statusAppSetup = response.statusCode;

      registerSettingsLoading = false;
      notifyListeners();
    } catch (e) {
      logger.e("Error fetching app register: $e");
      registerSettingsLoading = false;
      notifyListeners();
    }
  }



  Future<void> fetchVersionUpdate(BuildContext context,String deviceType) async {
    try {
      versionUpdateModel = null;
      String? token = await getUserTokenSharePref();
      versionUpdateLoading = true;
      notifyListeners();


      String? versionCode = '';
      if (Platform.isAndroid) {
        versionCode = Constent.versionCodeAndroid.isNotEmpty
            ? Constent.versionCodeAndroid
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      } else if (Platform.isIOS) {
        versionCode = Constent.versionCodeIOS.isNotEmpty
            ? Constent.versionCodeIOS
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      }


      Map<String, String> headers = {
        'authorization': token!, // Assuming token is not null
        'device-type':deviceType,
        'version': versionCode.toString()
      };
      logger.w("headers${headers}");
      Uri url = Uri.parse(
        UrlConstant.version_update,
      );
      final response = await http.get(url, headers: headers);
      logger.w("response100${response.headers}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        statusVersionUpdate = response.statusCode;
        logger.w("statusVersionUpdate${statusVersionUpdate}");
        versionUpdateModel = versionUpdateModelFromJson(response.body);
        logger.w("versionUpdateModel ${versionUpdateModel}");
        // if (settingsModel != null) {
        //   if (settingsModel!.settings != null) {
        //     settingsList.addAll(settingsModel!.settings!);
        //     logger.w("settingsList${jsonEncode(settingsModel)}");
        //   }
        // }
        versionUpdateLoading = false;
        notifyListeners();
      }
      else if(response.statusCode == 503){
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MaintenenceScreen(
                title: "App is in maintainance mode, Please be patient, we'll be back in a couple of hours!",
                message: "",
              ),
            ),
          );
        });
      }
      else {
        statusVersionUpdate = response.statusCode;
        logger.w("statusVersionUpdate${statusVersionUpdate}");
        versionUpdateLoading = false;
        notifyListeners();
      }
      if(response.statusCode == 401){
        statusVersionUpdate = response.statusCode;
        logger.w("statusVersionUpdate${statusVersionUpdate}");
       // TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        statusVersionUpdate = response.statusCode;
        logger.w("statusVersionUpdate${statusVersionUpdate}");
       // TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      statusVersionUpdate = response.statusCode;
      versionUpdateLoading = false;
      notifyListeners();
    } catch (e) {
      versionUpdateLoading = false;
      notifyListeners();
    }
    notifyListeners();
  }


  int? statusAppShare;
  bool appShareLoading = false;
  AppShareResponse? appShareResponseModel;


  Future<void> fetchAppShare(
      BuildContext context)
  async {
    try {
      statusAppShare = 0;
      appShareResponseModel = null;

      String? token = await getUserTokenSharePref();
      appShareLoading = true;
      logger.w("appShareLoading $appShareLoading");
      notifyListeners();

      Uri url = Uri.parse(UrlConstant.appShareUrl);
      logger.w("url $url");

      String deviceType = Platform.isAndroid ? 'android' : 'ios';
      String? versionCode = '';
      if (Platform.isAndroid) {
        versionCode = Constent.versionCodeAndroid.isNotEmpty
            ? Constent.versionCodeAndroid
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      } else if (Platform.isIOS) {
        versionCode = Constent.versionCodeIOS.isNotEmpty
            ? Constent.versionCodeIOS
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      }

      Map<String, String> headers = {
        'Device-Type': deviceType,
        'Version': versionCode.toString(),
        'authorization': token!, // Assuming token is not null
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        statusAppShare = response.statusCode;
        appShareResponseModel = appShareResponseFromJson(response.body);
        appShareLoading = false;
        notifyListeners();

        logger.w("appShareLoading $appShareLoading");
        logger.w("appShareResponseModel $appShareResponseModel");
      }
      else if(response.statusCode == 503){
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MaintenenceScreen(
                title: "App is in maintainance mode, Please be patient, we'll be back in a couple of hours!",
                message: "",
              ),
            ),
          );
        });
      }
      else {
        statusAppShare = response.statusCode;
        logger.i("settingsRegisterModel${jsonEncode(settingsRegisterModel?.status)}");
        if (response.statusCode == 401 || response.statusCode == 403) {
          statusAppShare = response.statusCode;
          //   TokenManager.setTokenStatus(true);
          // CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
        }
      }
      statusAppShare = response.statusCode;

      appShareLoading = false;
      notifyListeners();
    } catch (e) {
      logger.e("Error fetching app register: $e");
      appShareLoading = false;
      notifyListeners();
    }
  }


  int? statusDynamicMenu;
  bool dynamicMenuLoading = false;
  DynamicMenuResponseModel? dynamicMenuResponseModel;
  List<DynamicSetting> dynamicMenuList = [];

  Future<void> fetchDynamicMenu(BuildContext context) async {
    try {
      statusDynamicMenu = 0;
      dynamicMenuResponseModel = null;
      dynamicMenuLoading = true;
      notifyListeners();

      String? token = await getUserTokenSharePref();

      Uri url = Uri.parse(UrlConstant.pageSettingsUrl);
      String deviceType = Platform.isAndroid ? 'android' : 'ios';
      String? versionCode = Platform.isAndroid
          ? (Constent.versionCodeAndroid.isNotEmpty
          ? Constent.versionCodeAndroid
          : await getVersionSharePref())
          : (Constent.versionCodeIOS.isNotEmpty
          ? Constent.versionCodeIOS
          : await getVersionSharePref());

      Map<String, String> headers = {
        'Device-Type': deviceType,
        'Version': versionCode.toString(),
        'authorization': token!,
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
        statusDynamicMenu = response.statusCode;

        dynamicMenuResponseModel =
            dynamicMenuResponseModelFromJson(response.body);

        // 👉 IMPORTANT FIX: Clear old data before inserting new
        dynamicMenuList.clear();

        if (dynamicMenuResponseModel?.dynamicSettings != null) {
          dynamicMenuList
              .addAll(dynamicMenuResponseModel!.dynamicSettings!);
        }

        dynamicMenuLoading = false;
        notifyListeners();
      }

      else if (response.statusCode == 503) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MaintenenceScreen(
                title:
                "App is in maintainance mode, Please be patient, we'll be back in a couple of hours!",
                message: "",
              ),
            ),
          );
        });
      }

      else {
        statusDynamicMenu = response.statusCode;
      }

      dynamicMenuLoading = false;
      notifyListeners();
    } catch (e) {
      logger.e("Error fetching dynamic menu: $e");
      dynamicMenuLoading = false;
      notifyListeners();
    }
  }


}
