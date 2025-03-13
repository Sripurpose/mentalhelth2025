import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mentalhelth/screens/auth/subscribe_plan_page/subscribe_plan_page.dart';
import 'package:mentalhelth/screens/dash_borad_screen/dash_board_screen.dart';
import 'package:mentalhelth/screens/otp_screen/model/otp_model.dart';
import 'package:mentalhelth/screens/otp_screen/otp_screen.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';

import '../../token_expiry/token_expiry.dart';

class PhoneSignInProvider extends ChangeNotifier {
  TextEditingController phoneNumberController = TextEditingController();
  String countryCode = '91';
  String otp = '';

  void addOtpFunction({required String value}) {
    if (value.length == 6) {
      otp = value;
      notifyListeners();
    }
  }

  void addCountryCode({required String value}) {
    countryCode = value;
    notifyListeners();
  }

  // **New Method to Reset Country Code**
  void resetCountryCode() {
    countryCode = '91'; // Reset to default country code
    notifyListeners();
  }

  //phone login

  bool loginLoading = false;

  Future<void> phoneLoginUser(
    BuildContext context, {
    required String phone,
  }) async {
    try {
      loginLoading = true;
      notifyListeners();
      var body = {
        'phone': phone,
        'country_code':countryCode
      };
      final response = await http.post(
        Uri.parse(
          UrlConstant.otpPhoneLoginUrl,
        ),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );
      if (response.statusCode == 200) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const OtpScreen(),
          ),
        );
      } else {
        showCustomSnackBar(context: context, message: 'otp failed.');
      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      loginLoading = false;
      notifyListeners();
    } catch (error) {
      loginLoading = false;
      notifyListeners();
    }
  }


  void addPhoneNumber(String value) {
    phoneNumberController.text = value;
    notifyListeners();
  }

  bool verifyLoading = false;
  VerifyOtpModel? verifyOtpModel;
  int? statusOtpVerify;

  Future<void> verifyFunction(BuildContext context,
      {required String phone, required String otp}) async {
    try {
      statusOtpVerify = 0;
      verifyLoading = true;
      notifyListeners();

      var body = {
        'phone': phone,
        'otp': otp,
      };
      final response = await http.post(
        Uri.parse(
          UrlConstant.verifyOtpUrl,
        ),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        statusOtpVerify = response.statusCode;
        verifyOtpModel = verifyOtpModelFromJson(
          response.body,
        );
        await addUserSubScribeSharePref(
            subscribe: verifyOtpModel!.isSubscribed.toString());
        addUserIdSharePref(
          userId: verifyOtpModel!.userId!,
        );
        addUserTokenSharePref(
          token: verifyOtpModel!.userToken!,
        );
        addUserStatusSharePref(
          token: verifyOtpModel!.status!,
        );
        addUserPhoneSharePref(phone: phone);

        if (verifyOtpModel!.status!) {
          if (verifyOtpModel!.isSubscribed == "0") {
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
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const DashBoardScreen(),
              ),
              (route) => false,
            );
          }
        }
        phoneNumberController.clear();
      } else {
        statusOtpVerify = response.statusCode;
        showCustomSnackBar(context: context, message: 'otp failed.');
      }
      statusOtpVerify = response.statusCode;
      if(response.statusCode == 401){
        statusOtpVerify = response.statusCode;
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        statusOtpVerify = response.statusCode;
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      statusOtpVerify = response.statusCode;
      verifyLoading = false;
      notifyListeners();
    } catch (error) {
      verifyLoading = false;
      notifyListeners();
    }
  }
}
