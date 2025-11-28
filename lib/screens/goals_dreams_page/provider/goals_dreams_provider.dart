import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';

import '../../../utils/core/constent.dart';
import '../../../utils/logic/shared_prefrence.dart';
import '../../../widgets/functions/snack_bar.dart';
import '../../maintenence_screen/maintenence_screen.dart';
import '../../token_expiry/token_expiry.dart';
import '../model/goals_and_dreams_model.dart';

class GoalsDreamsProvider extends ChangeNotifier {
  bool isScrolling = false;
  var logger = Logger();

  void scrollTrue({required bool value}) {
    isScrolling = value;
    notifyListeners();
  }

  int curselIndex = 0;

  void changeValue({required int index}) {
    curselIndex = index;
    notifyListeners();
  }

  int openBox = 0;

  void openBoxFunction({required int index}) {
    openBox = index;
    notifyListeners();
  }

  List<Goalsanddream> fullGoalsList = [];
  String searchQuery = "";
  TextEditingController searchController = TextEditingController();

  GoalsDreamsProvider() {
    searchController.addListener(() {
      searchQuery = searchController.text;
      notifyListeners();
    });
  }



  GoalsAndDreamsModel? goalsAndDreamsModel;
  bool goalsAndDreamsModelLoading = false;
  List<Goalsanddream> goalsanddreams = [];

  int pageLoad = 1;
  int fetchGoalsAndDreamsStatus = 0;
  DateTime? fromDate;
  DateTime? toDate;

  String? formattedFromDate;
  String? formattedToDate;


  int totalPages = 1;
  int currentPage = 1;


// assuming 10 items per page; adjust if your API uses a different page size


  Future fetchGoalsAndDreams({
    bool initial = false,
    String? pageNo,
    required BuildContext context,
    bool fullList = false,
    DateTime? fromDateParam,
    DateTime? toDateParam,
    String keyword = "",      // 🔥 NEW SEARCH VALUE
  }) async {
    fetchGoalsAndDreamsStatus = 0;

    String? token = await getUserTokenSharePref();
    goalsAndDreamsModelLoading = true;

    String deviceType = Platform.isAndroid ? 'android' : 'ios';
    String? versionCode = await getVersionSharePref();

    notifyListeners();

    Map<String, String> headers = {
      'device-type': deviceType,
      'version': versionCode.toString(),
      'authorization': token!,
    };

    // ---------------------------------------------
    // PAGE RESET
    // ---------------------------------------------
// PAGE LOGIC
    // If first load → reset
    if (initial) {
      goalsanddreams.clear();
      fullGoalsList.clear();
    }

    notifyListeners();

    // ---------------------------------------------
    // DATE FILTER LOGIC
    // ---------------------------------------------
    if (!fullList) {
      final start = fromDateParam ?? this.fromDate ?? DateTime.now();
      final end = toDateParam ?? this.toDate ?? DateTime.now();

      this.fromDate = start;
      this.toDate = end;

      formattedFromDate = _formatDateForApi(start);
      formattedToDate = _formatDateForApi(end);
    } else {
      this.fromDate = null;
      this.toDate = null;
      formattedFromDate = null;
      formattedToDate = null;
    }

    // ---------------------------------------------
    // POST BODY
    // ---------------------------------------------
// ---- POST BODY ----
    final body = {
      "page_no": pageNo ?? "1",
      "keyword": keyword,     // 🔥 Add search text here

      if (!fullList) ...{
        "from_date": formattedFromDate ?? "",
        "to_date": formattedToDate ?? "",
      }
    };


    Uri url = Uri.parse(UrlConstant.goalsanddreamsUrl(page: '1'));

    logger.i("POST URL: $url");
    logger.i("POST BODY: $body");

    final response = await http.post(url, headers: headers, body: body);

    log(response.body.toString(), name: "fetchGoalsAndDreams");

    // ---------------------------------------------
    // RESPONSE HANDLING
    // ---------------------------------------------
    if (response.statusCode == 200 || response.statusCode == 201) {
      fetchGoalsAndDreamsStatus = 200;

      goalsAndDreamsModel =
          goalsAndDreamsModelFromJson(response.body);

      // Read pagination from API
      currentPage = int.parse(goalsAndDreamsModel!.currentPage.toString()) ?? 1;
      totalPages = goalsAndDreamsModel?.pageCount ?? 1;

      /// IMPORTANT FIX!
      goalsanddreams.clear();
      fullGoalsList.clear();

      if (goalsAndDreamsModel?.goalsanddreams != null &&
          goalsAndDreamsModel!.goalsanddreams!.isNotEmpty) {

        fullGoalsList = List.from(
          goalsAndDreamsModel!.goalsanddreams!,
        );

        goalsanddreams = List.from(fullGoalsList);
      }

      goalsAndDreamsModelLoading = false;
      notifyListeners();
    }

    else if (response.statusCode == 503) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MaintenenceScreen(
            title:
            "App is in maintenance mode, Please be patient, we'll be back in a couple of hours!",
            message: "",
          ),
        ),
      );
    }

    else {
      fetchGoalsAndDreamsStatus = response.statusCode;
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      TokenManager.setTokenStatus(true);
    }

    goalsAndDreamsModelLoading = false;
    notifyListeners();
  }



  // Helper function to format date as YYYY-MM-DD
  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }



  void filterGoalsBySearch(String query) {
    searchQuery = query.toLowerCase();

    if (query.isEmpty) {
      goalsanddreams = List.from(fullGoalsList);
    } else {
      goalsanddreams = fullGoalsList.where((goal) {
        final title = goal.goalTitle?.toLowerCase() ?? "";
        return title.contains(searchQuery);
      }).toList();
    }

    notifyListeners();
  }




  //update goal status
  bool updateGoalStatusLoading = false;

  Future<void> updateGoalsStatus(BuildContext context,
      {required String goalId, required String status}) async {
    try {
      String? token = await getUserTokenSharePref();
      // log(phone);
      updateGoalStatusLoading = true;
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
        'goal_id': goalId,
        'status': status,
      };
      final response = await http.post(
        Uri.parse(
          UrlConstant.updateGoalstatusUrl,
        ),
        headers: <String, String>{
          'device-type': deviceType,
          'version': versionCode.toString(),
          // 'Content-Type': 'application/x-www-form-urlencoded',
          'authorization': token!,
        },
        body: body,
      );

      if (response.statusCode == 200) {
        showCustomSnackBar(context: context, message: 'goal update success.');
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
        showCustomSnackBar(context: context, message: 'goal update failed.');
      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      updateGoalStatusLoading = false;
      notifyListeners();
    } catch (error) {
      updateGoalStatusLoading = false;
      notifyListeners();
    }
  }

  //delete goal
  bool deleteGoalsLoading = false;

  Future<bool> deleteGoalsFunction(BuildContext context,{required String deleteId}) async {
    try {
      deleteGoalsLoading = true;
      notifyListeners();
      String? token = await getUserTokenSharePref();
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
        'device-type': deviceType,
        'version': versionCode.toString(),
        'authorization': token!, // Assuming token is not null
      };
      notifyListeners();
      Uri url = Uri.parse(
        UrlConstant.deleteGoal(
          goal: deleteId,
        ),
      );
      final response = await http.delete(
        url,
        headers: headers,
      );

      notifyListeners();
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
       if(response.statusCode == 503){
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
      if (response.statusCode == 200) {
        showCustomSnackBar(
          context: context,
          message: "Goal Deleted Successfully",
        );
        // notifyListeners();
        fetchGoalsAndDreams(
          initial: true,
          context: context
        );
        deleteGoalsLoading = false;

        notifyListeners();
        return true;
      }

      else {
        deleteGoalsLoading = false;
        notifyListeners();
        return false;
      }


    } catch (e) {
      deleteGoalsLoading = false;
      notifyListeners();
      return false;
    }
  }
}
