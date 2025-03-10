import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/home_screen/model/jounals_model.dart';
import 'package:mentalhelth/utils/core/date_time_utils.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';

import '../../mental_strength_add_edit_screen/model/get_goals_model.dart';
import '../../mental_strength_add_edit_screen/model/list_goal_actions.dart';
import '../../token_expiry/token_expiry.dart';
import '../model/chart_view_model.dart';
import '../model/journal_details.dart';
import '../model/reminder_details.dart';

class HomeProvider extends ChangeNotifier {
  ChartViewModel? chartViewModel;
  List<Chart> chartList = [];
  bool chartViewLoading = false;
  var logger = Logger();


  Future<void> fetchChartView(BuildContext context) async {
    try {
      chartViewModel = null;
      // String? userId = await getUserIdSharePref();
      String? token = await getUserTokenSharePref();
      chartViewLoading = true;
      notifyListeners();

      Map<String, String> headers = {
        'authorization': token!, // Assuming token is not null
      };
      Uri url = Uri.parse(
        UrlConstant.chartviewUrl,
      );
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        chartViewModel = chartViewModelFromJson(response.body);
        logger.w("chartViewModel ${chartViewModel?.chart}");
        for (int i = 0; i < chartViewModel!.chart!.length; i++) {
          chartList.add(
            Chart(
              emotionValue: chartViewModel!.chart![i].emotionValue,
              driveValue: chartViewModel!.chart![i].driveValue,
              score: chartViewModel!.chart![i].score,
              dateTime: formatDateToString(
                int.parse(
                  chartViewModel!.chart![i].dateTime,
                ),
              ),
            ),
          );
        }
        chartViewLoading = false;
        notifyListeners();
      }
///commented on 04-09-2024 sarath p
      // else if (response.statusCode == 403) {
      //   await removeUserDetailsSharePref(context: context);
      //   showCustomSnackBar(context: context, message: "Token Expired");
      //   chartViewLoading = false;
      //   notifyListeners();
      // }
      else {
        chartViewLoading = false;
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
      chartViewLoading = false;
      notifyListeners();
    } catch (e) {
      chartViewLoading = false;
      notifyListeners();
    }
    notifyListeners();
  }

  //get the journels
  JournalsModel? journalsModel;
  List<Journal> journalsModelList = [];
  int pageLoad = 1;
  bool journalsModelLoading = false;
  int journalStatus = 0;

  Future fetchJournals({bool initial = false,String? pageNo}) async {
    try {
      String? token = await getUserTokenSharePref();
      journalsModelLoading = true;
      journalStatus = 0;
      notifyListeners();

      Map<String, String> headers = {
        'authorization': token ?? "", // Assuming token is not null
      };

      if (initial) {
        pageLoad = 1;
        journalsModelList.clear();
        notifyListeners();
      } else {
        pageLoad += 1;
        notifyListeners();
      }

      Uri url = Uri.parse(
        UrlConstant.journalsUrl(
          page: pageNo ?? "1",
        ),
      );
      logger.w("url $url");

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        journalStatus = response.statusCode;
        journalsModel = journalsModelFromJson(response.body);
        logger.w("journalsModel ${journalsModelFromJson(response.body)}");

        // Add new items without duplication
        final newJournals = journalsModel!.journals ?? [];

        // Ensure uniqueness by checking for duplicates based on a unique field like id
        for (var journal in newJournals) {
          if (!journalsModelList.any((existingJournal) => existingJournal.journalId == journal.journalId)) {
            journalsModelList.add(journal);
          }
        }

        journalsModelLoading = false;
        notifyListeners();
      } else {
        journalStatus = response.statusCode;
        logger.w("journalsModelelse ${journalsModelFromJson(response.body)}");
        journalsModelLoading = false;
        journalsModelList.clear();
        notifyListeners();
      }

      // Handle token expiry (401, 403)
      if (response.statusCode == 401 || response.statusCode == 403) {
        journalStatus = response.statusCode;
        TokenManager.setTokenStatus(true);
        // CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }

      journalsModelLoading = false;
      notifyListeners();
    } catch (e) {
      logger.w("catch $e");
      journalsModelLoading = false;
      notifyListeners();
    }
    notifyListeners();
  }


  //get journal details
  JournalDetails? journalDetails;
  bool journalDetailsLoading = false;



  Future<void> fetchJournalDetails({required String journalId}) async {
    try {
      journalDetails = null;
      String? token = await getUserTokenSharePref();
      journalDetailsLoading = true;
      notifyListeners();
      Map<String, String> headers = {
        'authorization': token ?? '', // Assuming token is not null
      };
      Uri url = Uri.parse(
        UrlConstant.fetchJournalDetails(journalId: journalId),
      );
      logger.w("fetchJournalDetailsUri${url}");
      final response = await http.get(
        url,
        headers: headers,
      );
      if (response.statusCode == 200) {
        journalDetails = journalDetailsFromJson(response.body);
        logger.w("journalDetails ${journalDetails}");
        notifyListeners();
      } else {
        journalDetailsLoading = false;
        logger.w("journalDetailsElse ${journalDetails}");
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
      journalDetailsLoading = false;
      notifyListeners();
    } catch (e) {
      logger.w("errorCatch ${e}");
      journalDetailsLoading = false;
      notifyListeners();
    }
  }

  RemindersDetails? remindersDetails;
  bool remindersDetailsLoading = false;
  int reminderStatusCode = 0;
  TextEditingController descriptionEditTextController = TextEditingController();
  TextEditingController titleEditTextController = TextEditingController();



  Future<void> fetchRemindersDetails() async {
    try {
      remindersDetails = null;
      String? token = await getUserTokenSharePref();
      remindersDetailsLoading = true;
      notifyListeners();
      Map<String, String> headers = {
        'authorization': token ?? '', // Assuming token is not null
      };
      Uri url = Uri.parse(
        UrlConstant.fetchRemindersDetails(),
      );
      logger.w("fetchRemindersDetailsUri${url}");
      final response = await http.get(
        url,
        headers: headers,
      );
      reminderStatusCode = response.statusCode;
      if (response.statusCode == 200) {
        remindersDetails = remindersDetailsFromJson(response.body);
        logger.w("remindersDetails ${remindersDetails}");
        notifyListeners();
        reminderStatusCode = response.statusCode;
      } else {
        remindersDetailsLoading = false;
        logger.w("remindersDetailsElse ${remindersDetails}");
        notifyListeners();
        reminderStatusCode = response.statusCode;
      }
      if(response.statusCode == 401){
        reminderStatusCode = response.statusCode;
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        reminderStatusCode = response.statusCode;
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      remindersDetailsLoading = false;
      reminderStatusCode = response.statusCode;
      notifyListeners();
    } catch (e) {
      logger.w("errorCatch ${e}");
      remindersDetailsLoading = false;
      notifyListeners();
    }
  }

  String reminderStartDate = '';
  String reminderEndDate = '';
  TimeOfDay? reminderStartTime;
  TimeOfDay? reminderEndTime;
  String repeat = "Never";
  DateTime? date;
  TimeOfDay? remindTime;

  void reminderStartDateFunction(BuildContext context) async {
    reminderStartDate = await selectReminder(
      context,
    );
    notifyListeners();
  }

  void reminderEndDateFunction(BuildContext context) async {
    reminderEndDate = await selectReminder(
      context,
      reminderStartDates: DateFormat('d MMM y').parse(reminderStartDate),
    );
    notifyListeners();
  }


  Future<String> selectReminder(BuildContext context,
      {DateTime? reminderStartDates}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: reminderStartDates ?? DateTime.now(),
      firstDate: reminderStartDates ?? DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != date) {
      // reminderStartDate = ;
      // selectedDate = dateFormatter(date: picked.toString());
      // log(formattedDate.toString(), name: "formattedDate");
      notifyListeners();
    }
    return formatPickedDateFor2(picked!);
  }

  Future<TimeOfDay?> selectReminderTime(BuildContext context,
      {TimeOfDay? reminderStartTimes}) async {
    TimeOfDay? pickedTime;
    TimeOfDay? adjustedInitialTime;
    if (reminderStartTimes != null) {
      final DateTime adjustedInitialDateTime = DateTime(
          0, 0, 0, reminderStartTimes.hour, reminderStartTimes.minute + 1);
      adjustedInitialTime = TimeOfDay.fromDateTime(adjustedInitialDateTime);
      // Loop until the picked time is after the start time
      do {
        pickedTime = await showTimePicker(
          context: context,
          initialTime: adjustedInitialTime,
        );

        // Check if the picked time is not null and is before or equal to the start time
        if (pickedTime != null &&
            (pickedTime.hour < reminderStartTimes.hour ||
                (pickedTime.hour == reminderStartTimes.hour &&
                    pickedTime.minute <= reminderStartTimes.minute))) {
          // Show a warning Snackbar
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('End time must be after start time.'),
          ));
        }
      } while (pickedTime != null &&
          (pickedTime.hour < reminderStartTimes.hour ||
              (pickedTime.hour == reminderStartTimes.hour &&
                  pickedTime.minute <= reminderStartTimes.minute)));
    } else {
      // If no start time is provided, show the TimePicker with the current time
      pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
    }

    return pickedTime;
  }

  void reminderStartTimeFunction(BuildContext context) async {
    reminderStartTime = await selectReminderTime(
      context,
    );
    reminderEndTime = null;
    notifyListeners();
  }

  void reminderEndTimeFunction(BuildContext context) async {
    reminderEndTime = await selectReminderTime(
      context,
      reminderStartTimes: reminderStartTime,
    );
    notifyListeners();
  }

  void addRepeatValue(String value) {
    repeat = value;
    notifyListeners();
  }



  Future<void> remindTimeFunction(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null && picked != remindTime) {
      remindTime = picked;
      notifyListeners();
    }
  }


  bool editRemindersDetailsLoading = false;
  Future<bool> editReminderFunction(
      BuildContext context, {
        required String title,
        required String details,
        required String actionId,
        required String goalId,
        required String reminderId,
      }) async {
    try {
      editRemindersDetailsLoading = true;
      notifyListeners();
      String? token = await getUserTokenSharePref();
      var body = {
        'goal_id': goalId,
        'action_id': actionId,
        'reminder_title': title,
        'reminder_desc': details,
        'reminder_startdate': convertToUnixTimestamp(reminderStartDate).toString(),
        'reminder_enddate': convertToUnixTimestamp(reminderEndDate).toString(),
        'from_time': convertTimeOfDayTo12Hour(reminderStartTime!).toString(),
        'to_time': convertTimeOfDayTo12Hour(reminderEndTime!).toString(),
        'reminder_before': '',
        'reminder_repeat':repeat,
        'reminder_id':reminderId,
      };
      print(body.toString() + "   editReminderFunction");
      final response = await http.post(
        Uri.parse(UrlConstant.saveReminderUrl),
        headers: <String, String>{"authorization": "$token"},
        body: body,
      );
      print(response.body.toString() + "   editReminderFunction");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseData = json.decode(response.body);
        editRemindersDetailsLoading = false;
        logger.w("responseData $responseData");
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
       // clearFunction();
        return true;
      } else {
        editRemindersDetailsLoading = false;
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        TokenManager.setTokenStatus(true);
      }
      editRemindersDetailsLoading = false;
      return false;
    } catch (error) {
      showToast(context: context, message: "Failed");
      editRemindersDetailsLoading = false;
      logger.w("error $error");
      notifyListeners();
      return false;
    }
  }
  void clearFunction() {
    titleEditTextController.clear();
    descriptionEditTextController.clear();
    reminderStartDate = '';
    reminderEndDate = '';
    reminderStartTime = null;
    reminderEndTime = null;
    remindTime = null;
    repeat = 'Never';
  }

  String convertTimeOfDayTo12Hour(TimeOfDay time) {
    // Create a DateTime object for formatting purposes
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    // Format the time using intl package in 12-hour format with AM/PM
    return DateFormat.jm().format(dateTime);
  }


  int convertToUnixTimestamp(String date) {
    try {
      // Parse the date string with the format "d MMM y" (e.g., "13 Sep 2024")
      DateTime parsedDate = DateFormat('d MMM y').parse(date);

      // Convert to Unix timestamp (seconds since epoch)
      int timestamp = parsedDate.millisecondsSinceEpoch ~/ 1000;

      return timestamp;
    } catch (e) {
      print("Error parsing date: $e");
      return 0; // Return 0 or handle the error accordingly
    }
  }

  bool getGoalsModelLoading = false;
  GetGoalsModel? getGoalsModelDropDown;

  Future<void> fetchGoals() async {
    try {
      String? token = await getUserTokenSharePref();
      getGoalsModelLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse(
          UrlConstant.goalsUrl,
        ),
        headers: <String, String>{"authorization": "$token"},
      );
      if (response.statusCode == 200) {
        getGoalsModelDropDown = getGoalsModelFromJson(response.body);
        logger.w("getGoalsModelDropDown ${getGoalsModelDropDown}");
        notifyListeners();
      } else {

      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      getGoalsModelLoading = false;
      notifyListeners();
    } catch (e) {
      getGoalsModelLoading = false;
      notifyListeners();
    }
  }



  GetListGoalActionsModel? getListGoalActionsModel;
  bool getListGoalActionsModelLoading = false;

  Future<void> fetchGoalActions({required String goalId}) async {
    try {
      String? token = await getUserTokenSharePref();
      getListGoalActionsModelLoading = true;
      notifyListeners();
      final response = await http.get(
        Uri.parse(
          UrlConstant.goalActionsUrl(goalId: goalId.toString()),
        ),
        headers: <String, String>{"authorization": "$token"},
      );

      if (response.statusCode == 200) {
        getListGoalActionsModel =
            getListGoalActionsModelFromJson(response.body);

        notifyListeners();
      } else {}
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      getListGoalActionsModelLoading = false;
      notifyListeners();
    } catch (e) {
      getListGoalActionsModelLoading = false;
      notifyListeners();
    }
  }

  bool deleteActionLoading = false;
  Future<bool> deleteReminderFunction({required String reminder_id}) async {
    try {
      // String? userId = await getUserIdSharePref();
      String? token = await getUserTokenSharePref();
      deleteActionLoading = true;
      notifyListeners();
      Map<String, String> headers = {
        'authorization': token ?? '',
      };
      notifyListeners();
      Uri url = Uri.parse(
        UrlConstant.deleteReminders(
          reminder_id: reminder_id,
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
        deleteActionLoading = false;

        notifyListeners();
        return true;
      } else {
        deleteActionLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      deleteActionLoading = false;
      notifyListeners();
      return false;
    }
  }



  /// NO DATA ITEMS
  PageController noDataPageController = PageController();

  List<String> noDataImageList = [
    'assets/images/home/slide1.jpg',
    'assets/images/home/slide2.jpg',
    'assets/images/home/slide3.jpg',
  ];

  int noDataCurrentIndex = 0;

  void noDataIndexChangeFunction(int index) {
    noDataCurrentIndex = index;
    notifyListeners();
  }
}
