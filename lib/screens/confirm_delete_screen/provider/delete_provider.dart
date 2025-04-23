import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';

import '../../../utils/core/constent.dart';
import '../../auth/sign_in/screen_sign_in.dart';
import '../../maintenence_screen/maintenence_screen.dart';
import '../../token_expiry/token_expiry.dart';

class DeleteProvider extends ChangeNotifier {
  // SignUpModel? signUpModel;
  bool deleteAccountLoading = false;

  Future<void> deleteAccount({required BuildContext context}) async {
    try {
      String? token = await getUserTokenSharePref();
      deleteAccountLoading = true;
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
      var body = {
        'type': "delete",
      };
      final response = await http.post(
        Uri.parse(
          UrlConstant.accountUrl,
        ),
        headers: <String, String>{
          'device-type': deviceType,
          'version': versionCode.toString(),
          'Content-Type': 'application/x-www-form-urlencoded',
          'authorization': token.toString()
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await removeUserDetailsSharePref(context: context);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => ScreenSignIn(),
          ),
          (route) => false,
        );

        showCustomSnackBar(context: context, message: 'Account Deleted');
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
        showCustomSnackBar(context: context, message: 'failed.');
      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      deleteAccountLoading = false;
      notifyListeners();
    } catch (error) {
      deleteAccountLoading = false;
      notifyListeners();
      showCustomSnackBar(context: context, message: error.toString());
    }
  }
}
