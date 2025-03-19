import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';

import '../../../utils/logic/shared_prefrence.dart';
import '../../../widgets/functions/snack_bar.dart';
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


  int _currentPage = 1; // Store the current page number

  int get currentPage => _currentPage;

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners(); // Notify UI to update
  }

  GoalsAndDreamsModel? goalsAndDreamsModel;
  bool goalsAndDreamsModelLoading = false;
  List<Goalsanddream> goalsanddreams = [];

  int pageLoad = 1;
  int fetchGoalsAndDreamsStatus = 0;
  Future fetchGoalsAndDreams({bool initial = false,String? pageNo}) async {
    fetchGoalsAndDreamsStatus = 0;
    // try {
    // goalsAndDreamsModel = null;
    String? token = await getUserTokenSharePref();
    goalsAndDreamsModelLoading = true;
    notifyListeners();
    Map<String, String> headers = {
      'authorization': token!, // Assuming token is not null
    };
    if (initial) {
      pageLoad = 1;
      goalsanddreams.clear();
      notifyListeners();
    } else {
      pageLoad += 1;
      notifyListeners();
    }

    notifyListeners();
    Uri url = Uri.parse(
      UrlConstant.goalsanddreamsUrl(
        page: pageNo ?? "1",
      ),
    );
    final response = await http.get(
      url,
      headers: headers,
    );

    logger.i("fetchGoalsAndDreamsurl$url");

    log(response.body.toString(), name: " fetchGoalsAndDreams");
    if (response.statusCode == 200) {
      fetchGoalsAndDreamsStatus = response.statusCode;
      goalsAndDreamsModel = goalsAndDreamsModelFromJson(response.body);
      logger.w("goalsAndDreamsModel ${goalsAndDreamsModel}");
     // if (initial) {
       goalsanddreams.clear();

        if (goalsAndDreamsModel != null) {
          if (goalsAndDreamsModel!.goalsanddreams != null) {
            goalsanddreams.addAll(goalsAndDreamsModel!.goalsanddreams!);
          }
        }
     // }
      // else {
      //   if (goalsAndDreamsModel != null) {
      //     if (goalsAndDreamsModel!.goalsanddreams != null) {
      //       goalsanddreams.addAll(goalsAndDreamsModel!.goalsanddreams!);
      //     }
      //   }
      // }

      notifyListeners();
    } else {
      fetchGoalsAndDreamsStatus = response.statusCode;
      goalsAndDreamsModelLoading = false;
      logger.w("goalsAndDreamsModelelse ${goalsAndDreamsModel}");
      notifyListeners();
    }
    fetchGoalsAndDreamsStatus = response.statusCode;
    if(response.statusCode == 401){
      TokenManager.setTokenStatus(true);
      //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
    }
    if(response.statusCode == 403){
      TokenManager.setTokenStatus(true);
      //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
    }
    goalsAndDreamsModelLoading = false;
    notifyListeners();
    // } catch (e) {
    //   log(e.toString());
    //   goalsAndDreamsModelLoading = false;
    //   notifyListeners();
    // }
  }

  //update goal status
  bool updateGoalStatusLoading = false;

  Future<void> updateGoalsStatus(BuildContext context,
      {required String goalId, required String status}) async {
    try {
      String? token = await getUserTokenSharePref();
      // log(phone);
      updateGoalStatusLoading = true;
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
          // 'Content-Type': 'application/x-www-form-urlencoded',
          'authorization': token!,
        },
        body: body,
      );

      if (response.statusCode == 200) {
        showCustomSnackBar(context: context, message: 'goal update success.');
      } else {
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

  Future<bool> deleteGoalsFunction({required String deleteId}) async {
    try {
      deleteGoalsLoading = true;
      notifyListeners();
      String? token = await getUserTokenSharePref();

      Map<String, String> headers = {
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
      if (response.statusCode == 200) {
        // notifyListeners();
        fetchGoalsAndDreams(
          initial: true,
        );
        deleteGoalsLoading = false;

        notifyListeners();
        return true;
      } else {
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
