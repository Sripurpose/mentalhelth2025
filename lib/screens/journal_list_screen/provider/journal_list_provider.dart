import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/journal_list_screen/model/journal_chart_view.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';

import '../../../utils/core/constent.dart';
import '../../maintenence_screen/maintenence_screen.dart';
import '../../token_expiry/token_expiry.dart';

class JournalListProvider extends ChangeNotifier {
  bool listViewBool = true;
  var logger = Logger();

  void changeListViewBar(bool value) {
    listViewBool = value;
    notifyListeners();
  }

  bool deleteJournals = false;

  Future<bool> deleteJournalsFunction({required String journalId}) async {
    try {
      // String? userId = await getUserIdSharePref();
      String? token = await getUserTokenSharePref();
      deleteJournals = true;
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
      notifyListeners();
      Uri url = Uri.parse(
        UrlConstant.deleteJournal(
          journalId: journalId,
        ),
      );
      final response = await http.delete(
        url,
        headers: headers,
      );
      print(response.body.toString());
      notifyListeners();
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }

      if (response.statusCode == 200) {
        // notifyListeners();
        deleteJournals = false;
        notifyListeners();
        return true;
      } else {
        deleteJournals = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print(e.toString());
      deleteJournals = false;
      notifyListeners();
      return false;
    }
  }

  JournalChartViewModel? journalChartViewModel;
  bool journalChartViewModelLoading = false;
  int? journalChartStatusCode;

  Future<void> fetchJournalChartView({required BuildContext context}) async {
    try {
      String? token = await getUserTokenSharePref();
      journalChartViewModelLoading = true;
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
      journalChartStatusCode = 0;
      notifyListeners();
      final response = await http.get(
        Uri.parse(
          UrlConstant.journalChartViewUrl,
        ),
        headers: <String, String>{
          'device-type': deviceType,
          'version': versionCode.toString(),
          // 'Content-Type': 'application/json',
          "authorization": "$token"
        },
      );

      logger.w("responsejournalChartViewModel ${response.statusCode}");

      if (response.statusCode == 200) {
        journalChartStatusCode = response.statusCode;
        journalChartViewModel = journalChartViewModelFromJson(
          response.body,
        );
        logger.w("journalChartViewModel200 $journalChartViewModel");

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
        journalChartStatusCode = response.statusCode;
        logger.w("journalChartViewModelElse $journalChartViewModel");
      }
      journalChartStatusCode = response.statusCode;
      journalChartViewModelLoading = false;
      notifyListeners();
    } catch (e) {
      journalChartViewModelLoading = false;
      logger.w("journalChartViewModelCatch $journalChartViewModel");
      notifyListeners();
    }
  }
}
