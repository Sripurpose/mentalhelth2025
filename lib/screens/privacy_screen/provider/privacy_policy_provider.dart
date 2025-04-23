import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mentalhelth/screens/privacy_screen/model/content_model.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';

import '../../token_expiry/token_expiry.dart';

class PrivacyPolicyProvider extends ChangeNotifier {
  PolicyModel? policyModel;
  bool policyModelLoading = false;

  Future<void> fetchPolicy({required String type}) async {
    try {
      String? token = await getUserTokenSharePref();
      policyModelLoading = true;
      notifyListeners();

      Map<String, String> headers = {
        'authorization': token!, // Assuming token is not null
      };
      Uri url = Uri.parse(
        UrlConstant.webContentPolicy(type: type),
      );
      final response = await http.get(
        url,
        headers: headers,
      );
      if (response.statusCode == 200) {
        policyModel = policyModelFromJson(response.body);
        notifyListeners();
      }
      else {
        policyModelLoading = false;
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
      policyModelLoading = false;
      notifyListeners();
    } catch (e) {
      policyModelLoading = false;
      notifyListeners();
    }
  }
}
