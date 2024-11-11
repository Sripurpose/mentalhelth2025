import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mentalhelth/screens/auth/sign_in/screen_sign_in.dart';
import 'package:mentalhelth/screens/auth/signup_screen/model/signup_model.dart';
import 'package:mentalhelth/screens/auth/signup_screen/wigets/signup_widget.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';

import '../../../token_expiry/token_expiry.dart';
import '../../subscribe_plan_page/subscribe_plan_page.dart';
import '../signup_screen.dart';

class SignUpProvider extends ChangeNotifier {
  TextEditingController nameEditTextController = TextEditingController();

  TextEditingController emailEditTextController = TextEditingController();

  TextEditingController passwordEditTextController = TextEditingController();

  TextEditingController confirmPasswordEditTextController =
      TextEditingController();

  SignUpModel? signUpModel;
  bool signUpLoading = false;

  Future<void> signUpFunction(BuildContext context,
      {required String firstName,
      required String email,
      required String password}) async {
    try {
      FocusScope.of(context).unfocus();
      signUpLoading = true;
      notifyListeners();
      var body = {
        'firstname': firstName,
        'email': email,
        'password': password,
      };
      final response = await http.post(
        Uri.parse(
          UrlConstant.signupUrl,
        ),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        signUpModel = signUpModelFromJson(
          response.body,
        );

        addUserIdSharePref(
          userId: signUpModel!.userId!,
        );
        addUserTokenSharePref(
          token: signUpModel!.userToken!,
        );
        addUserStatusSharePref(
          token: signUpModel!.status!,
        );
        addUserSubScribeSharePref(
            subscribe: signUpModel!.isSubscribed.toString());
        addUserEmailSharePref(
          email: email,
        );
        addUserPasswordSharePref(
          password: password,
        );
        if (signUpModel!.status!) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SignupScreen(),
            ),
          );

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ScreenSignIn(),
            ),
          );

        }

        // ignore: use_build_context_synchronously
        showToast(context: context, message: 'Register successful.');
        clearSignupControllers();
      } else {
        // ignore: use_build_context_synchronously
        showToast(context: context, message: "Email is already registered !");
      }

      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      signUpLoading = false;
      notifyListeners();
    } catch (error) {
      signUpLoading = false;
      notifyListeners();
    }
  }

  void clearSignupControllers() {
    nameEditTextController.clear();
    emailEditTextController.clear();
    passwordEditTextController.clear();
    confirmPasswordEditTextController.clear();
    notifyListeners();
  }

  void callSignInButton(BuildContext context) async {
    if (nameEditTextController.text.isEmpty) {
      showToastTop(context: context, message: 'Enter your name');
      // showCustomSnackBar(context: context, message: 'Enter your name');
    } else if (emailEditTextController.text.isEmpty) {
      showToastTop(context: context, message: 'Enter your email');
    } else if (!isEmailValid(emailEditTextController.text)) {
      showToastTop(context: context, message: 'Enter a valid email address');
    } else if (passwordEditTextController.text.isEmpty) {
      showToastTop(context: context, message: 'Enter your password');
    } else if (passwordEditTextController.text !=
        confirmPasswordEditTextController.text) {
      showToastTop(context: context, message: 'Entered password not match');
    } else {
      signUpFunction(
        context,
        firstName: nameEditTextController.text,
        email: emailEditTextController.text,
        password: passwordEditTextController.text,
      );
    }
  }
}

