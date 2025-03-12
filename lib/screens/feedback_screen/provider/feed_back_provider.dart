import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';

import '../../token_expiry/token_expiry.dart';

class FeedBackProvider extends ChangeNotifier {
  TextEditingController nameEditTextController = TextEditingController();

  TextEditingController emailEditTextController = TextEditingController();

  TextEditingController messageEditTextController = TextEditingController();

  bool saveFeedBackLoading = false;
  var logger = Logger();

  Future<void> saveFeedBack(BuildContext context,
      {required String name,
      required String email,
      required String message}) async {
    try {
      saveFeedBackLoading = true;
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
        headers: <String, String>{"authorization": "$token"},
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        showToastTop(context: context, message:  json.decode(response.body)["text"]);
        // showCustomSnackBar(
        //     context: context, message: json.decode(response.body)["text"]);
        Navigator.of(context).pop();
        nameEditTextController.clear();
        emailEditTextController.clear();
        messageEditTextController.clear();
      } else {
        showToastTop(context: context, message:  json.decode(response.body)["text"]);
        // showCustomSnackBar(
        //     context: context, message: json.decode(response.body)["text"]);
      }
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


