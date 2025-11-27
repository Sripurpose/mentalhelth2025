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


  int _currentPage = 1; // Store the current page number

  int get currentPage => _currentPage;

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners(); // Notify UI to update
  }
  List<Goalsanddream> fullGoalsList = [];
  String searchQuery = "";

  GoalsAndDreamsModel? goalsAndDreamsModel;
  bool goalsAndDreamsModelLoading = false;
  List<Goalsanddream> goalsanddreams = [];

  int pageLoad = 1;
  int fetchGoalsAndDreamsStatus = 0;
  Future fetchGoalsAndDreams({bool initial = false,String? pageNo,required BuildContext context}) async {
    fetchGoalsAndDreamsStatus = 0;
    // try {
    // goalsAndDreamsModel = null;
    String? token = await getUserTokenSharePref();
    goalsAndDreamsModelLoading = true;
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
      // Always clear before adding fresh data
      goalsanddreams.clear();
      fullGoalsList.clear();

      if (goalsAndDreamsModel != null) {
        if (goalsAndDreamsModel!.goalsanddreams != null) {
          fullGoalsList = List.from(goalsAndDreamsModel!.goalsanddreams!);
          goalsanddreams = List.from(fullGoalsList);
        }
      }


      // if (goalsAndDreamsModel != null) {
        //   if (goalsAndDreamsModel!.goalsanddreams != null) {
        //     goalsanddreams.addAll(goalsAndDreamsModel!.goalsanddreams!);
        //   }
        // }


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
