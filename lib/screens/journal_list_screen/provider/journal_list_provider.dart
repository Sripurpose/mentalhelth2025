import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/journal_list_screen/model/journal_chart_view.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';

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
      notifyListeners();
      Map<String, String> headers = {
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

  Future<void> fetchJournalChartView() async {
    try {
      String? token = await getUserTokenSharePref();
      journalChartViewModelLoading = true;
      notifyListeners();
      final response = await http.get(
        Uri.parse(
          UrlConstant.journalChartViewUrl,
        ),
        headers: <String, String>{
          // 'Content-Type': 'application/json',
          "authorization": "$token"
        },
      );

      logger.w("responsejournalChartViewModel ${response.statusCode}");

      if (response.statusCode == 200) {
        journalChartViewModel = journalChartViewModelFromJson(
          response.body,
        );
        logger.w("journalChartViewModel200 $journalChartViewModel");

        notifyListeners();
      } else {
        logger.w("journalChartViewModelElse $journalChartViewModel");
      }
      journalChartViewModelLoading = false;
      notifyListeners();
    } catch (e) {
      journalChartViewModelLoading = false;
      logger.w("journalChartViewModelCatch $journalChartViewModel");
      notifyListeners();
    }
  }
}
