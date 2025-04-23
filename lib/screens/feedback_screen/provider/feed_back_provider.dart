import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';

import '../../../utils/core/constent.dart';
import '../../maintenence_screen/maintenence_screen.dart';
import '../../token_expiry/token_expiry.dart';

class FeedBackProvider extends ChangeNotifier {
  TextEditingController nameEditTextController = TextEditingController();

  TextEditingController emailEditTextController = TextEditingController();

  TextEditingController messageEditTextController = TextEditingController();

  bool saveFeedBackLoading = false;
  var logger = Logger();
  int? feedbackStatusCode;

  Future<void> saveFeedBack(BuildContext context,
      {required String name,
      required String email,
      required String message}) async {
    try {
      feedbackStatusCode = 0;
      saveFeedBackLoading = true;
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
      String? token = await getUserTokenSharePref();
      var body = {
        'name': name,
        'email': email,
        'msg': message,
      };
      logger.w("body${body}");
      final response = await http.post(
        Uri.parse(
          UrlConstant.feedbackUrl,
        ),
        headers: <String, String>{
          'device-type': deviceType,
          'version': versionCode.toString(),
          "authorization": "$token"},
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        showToastTop(context: context, message:  json.decode(response.body)["text"]);
        // showCustomSnackBar(
        //     context: context, message: json.decode(response.body)["text"]);
        feedbackStatusCode = response.statusCode;
        logger.i("feedbackStatusCode${feedbackStatusCode}");
        nameEditTextController.clear();
        emailEditTextController.clear();
        messageEditTextController.clear();
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
        feedbackStatusCode = response.statusCode;
        logger.i("feedbackStatusCodeelse${feedbackStatusCode}");
        showToastTop(context: context, message:  json.decode(response.body)["text"]);
        // showCustomSnackBar(
        //     context: context, message: json.decode(response.body)["text"]);
      }
      feedbackStatusCode = response.statusCode;
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      saveFeedBackLoading = false;
      notifyListeners();
    } catch (error) {
      logger.w("error${error}");
      saveFeedBackLoading = false;
      notifyListeners();
    }
  }
}


