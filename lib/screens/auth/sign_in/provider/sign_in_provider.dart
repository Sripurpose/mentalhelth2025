import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/auth/sign_in/model/login_model.dart';
import 'package:mentalhelth/screens/auth/sign_in/model/social_media_login.dart';
import 'package:mentalhelth/screens/dash_borad_screen/dash_board_screen.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';

import '../../../token_expiry/token_expiry.dart';
import '../../subscribe_plan_page/subscribe_plan_page.dart';
import '../model/app_settings_model.dart';
import '../model/app_settings_register_model.dart';

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

  Future<void> loginUser(BuildContext context,
      {required String email, required String password}) async {
    try {
      loginLoading = true;
      notifyListeners();
      var body = {
        'email': email,
        'password': password,
      };
      final response = await http.post(
        Uri.parse(
          UrlConstant.loginUrl,
        ),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
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
            fetchSettings(context);
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
            fetchSettings(context);
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const DashBoardScreen(),
              ),
              (route) => false,
            );
          }
        }
      } else if(response.statusCode == 400){
        showCustomSnackBar(
          context: context,
          message: 'This account does not exists !',
        );
      }else{
        showCustomSnackBar(
          context: context,
          message: 'Incorrect Email or password !',
        );
      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 400){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
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
        //TokenManager.setTokenStatus(true);
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
  ) async {
    try {
      forgetLoading = true;
      forgotPasswordStatus = 0;
      forgotPasswordMessage = '';
      notifyListeners();
      var body = {
        'email': forgotEmailFieldController.text,
      };
      final response = await http.post(
        Uri.parse(
          UrlConstant.forgotPassword,
        ),
        headers: <String, String>{
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
      } else {
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


  void signInWithFacebook() async {
    try {
      socialMediaModelLoading = true;
      notifyListeners();
      final LoginResult loginResult = await FacebookAuth.instance.login();
      if (loginResult.status == LoginStatus.success) {
        final AccessToken? accessToken = loginResult.accessToken;
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(accessToken!.token);
        await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);
      } else {}
      // ignore: empty_catches
    } catch (e) {}
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
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      saveFirebaseLoading = false;
      notifyListeners();
    } catch (error) {
      saveFirebaseLoading = false;
      notifyListeners();
    }
  }

  Future callSignInButton(BuildContext context) async {
    if (emailFieldController.text.isNotEmpty &&
        passwordFieldController.text.isNotEmpty) {
      await loginUser(
        context,
        email: emailFieldController.text,
        password: passwordFieldController.text,
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

  Future<void> fetchSettings(BuildContext context) async {
    try {
      settingsModel = null;
      String? token = await getUserTokenSharePref();
      settingsLoading = true;
      notifyListeners();

      Map<String, String> headers = {
        'authorization': token!, // Assuming token is not null
      };
      Uri url = Uri.parse(
        UrlConstant.appSettingsUrl,
      );
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
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
      else {
        settingsLoading = false;
        notifyListeners();
      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      settingsLoading = false;
      notifyListeners();
    } catch (e) {
      settingsLoading = false;
      notifyListeners();
    }
    notifyListeners();
  }

  String? isRequired = '';
  Future<void> fetchAppRegister(BuildContext context) async {
    try {
      settingsRegisterModel = null;

      String? token = await getUserTokenSharePref();
      registerSettingsLoading = true;
      logger.w("registerSettingsLoading${registerSettingsLoading}");
      notifyListeners();

      Uri url = Uri.parse(
        UrlConstant.appRegisterUrl,
      );
      logger.w("url ${url}");
      final response = await http.get(url,);
      if (response.statusCode == 200 || response.statusCode == 201) {
        settingsRegisterModel = settingsRegisterModelFromJson(response.body);
        registerSettingsLoading = false;
        notifyListeners();
        logger.w("registerSettingsLoading${registerSettingsLoading}");
        logger.w("settingsRegisterModel ${settingsRegisterModel?.settings}");
        if (settingsRegisterModel != null) {
          if (settingsRegisterModel!.settings != null) {
            settingsRegisterList.addAll(settingsRegisterModel!.settings!);
            isRequired = settingsRegisterModel!.settings![0].isRequired;
            logger.w("isRequired${isRequired}");
            logger.w("settingsRegisterList${jsonEncode(settingsRegisterModel)}");
          }
        }
        registerSettingsLoading = false;
        notifyListeners();
      }
      else {
        registerSettingsLoading = false;
        notifyListeners();
      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      registerSettingsLoading = false;
      notifyListeners();
    } catch (e) {
      registerSettingsLoading = false;
      notifyListeners();
    }
    notifyListeners();
  }

}
