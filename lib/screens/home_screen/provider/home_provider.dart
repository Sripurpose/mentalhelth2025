import 'dart:convert';
import 'dart:io';

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

import '../../../utils/core/constants.dart';
import '../../../utils/core/constent.dart';
import '../../maintenence_screen/maintenence_screen.dart';
import '../../mental_strength_add_edit_screen/model/get_goals_model.dart';
import '../../mental_strength_add_edit_screen/model/list_goal_actions.dart';
import '../../token_expiry/token_expiry.dart';
import '../model/chart_view_model.dart';
import '../model/journal_details.dart';
import '../model/journal_model_grid.dart';
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
       // TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
      //  TokenManager.setTokenStatus(true);
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

  int _currentPage = 1; // Store the current page number

  int get currentPage => _currentPage;

  void setCurrentPage(int page) {
    _currentPage = page;
    notifyListeners(); // Notify UI to update
  }

  //get the journels
  JournalsModel? journalsModel;
  List<Journal> journalsModelList = [];
  int pageLoad = 1;
  bool journalsModelLoading = false;
  int journalStatus = 0;

  List<Journal> fullJournalsModelList = [];
  String searchQuery = "";

  Future fetchJournals({bool initial = false,String? pageNo,required BuildContext context}) async {
    try {
      String? token = await getUserTokenSharePref();
      journalsModelLoading = true;
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
      journalStatus = 0;
      notifyListeners();

      Map<String, String> headers = {
        'device-type': deviceType,
        'version': versionCode.toString(),
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

        final newJournals = journalsModel!.journals ?? [];

        for (var journal in newJournals) {
          if (!journalsModelList.any((existingJournal) =>
          existingJournal.journalId == journal.journalId)) {
            journalsModelList.add(journal);
          }
        }

        /// 👉 VERY IMPORTANT for search
        fullJournalsModelList = List.from(journalsModelList);

        journalsModelLoading = false;
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
        TokenManager.setTokenStatus(false);
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

  void filterJournalsBySearch(String query) {
    searchQuery = query.toLowerCase();

    if (query.isEmpty) {
      journalsModelList = List.from(fullJournalsModelList);
    } else {
      journalsModelList = fullJournalsModelList.where((goal) {
        final title = goal.journalTitle?.toLowerCase() ?? "";
        return title.contains(searchQuery);
      }).toList();
    }

    notifyListeners();
  }



  JournalsModelGrid? journalsModelGrid;
  List<JournalGrid> journalsModelGridList = [];
  int journalGridStatus = 0;
  bool journalsGridModelLoading = false;
  int totalPages = 1; // default

  DateTime? fromDate;
  DateTime? toDate;

  Future fetchJournalsGridView({
    bool initial = false,
    String? pageNo,
    required BuildContext context,
    DateTime? fromDateParam,
    DateTime? toDateParam,
    bool fullList = false, // 👈 new parameter
  }) async {
    try {
      String? token = await getUserTokenSharePref();
      journalsGridModelLoading = true;

      String deviceType = Platform.isAndroid ? 'android' : 'ios';
      String? versionCode = Platform.isAndroid
          ? (Constent.versionCodeAndroid.isNotEmpty
          ? Constent.versionCodeAndroid
          : await getVersionSharePref())
          : (Constent.versionCodeIOS.isNotEmpty
          ? Constent.versionCodeIOS
          : await getVersionSharePref());

      journalGridStatus = 0;
      notifyListeners();

      // Determine current page
      if (pageNo != null) {
        pageLoad = int.tryParse(pageNo) ?? 1;
      } else if (initial) {
        pageLoad = 1;
      } else {
        pageLoad += 1;
      }

      // API URL
      Uri url = Uri.parse(UrlConstant.journalsUrlGrid(
        page: pageLoad.toString(),
      ));

      logger.w("url $url");

      // 👇 Handle dates conditionally
      String? formattedFromDate;
      String? formattedToDate;

      if (!fullList) {
        // Only set if not fullList
        final start = fromDateParam ?? this.fromDate ?? DateTime.now();
        final end = toDateParam ?? this.toDate ?? DateTime.now();

        this.fromDate = start;
        this.toDate = end;

        formattedFromDate = _formatDateForApi(start);
        formattedToDate = _formatDateForApi(end);
      } else {
        // Clear stored dates if full list requested
        this.fromDate = null;
        this.toDate = null;
      }

      // 👇 Build body conditionally based on fullList flag
      final body = {
        "page_no": pageLoad.toString(),
        if (!fullList) ...{
          "from_date": formattedFromDate!,
          "to_date": formattedToDate!,
        },
      };

      logger.w("Request body: $body");

      final response = await http.post(
        url,
        headers: {
          'device-type': deviceType,
          'version': versionCode.toString(),
          'authorization': token ?? "",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        journalGridStatus = response.statusCode;
        journalsModelGrid = journalsModelGridFromJson(response.body);

        final newJournals = journalsModelGrid!.journals ?? [];

        // Always replace list on page change
        journalsModelGridList.clear();
        journalsModelGridList.addAll(newJournals);

        // Update total pages
        final totalCount =
            journalsModelGrid?.totalCount ?? journalsModelGridList.length;
        totalPages = (totalCount / 10).ceil();
      } else if (response.statusCode == 503) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MaintenenceScreen(
                title:
                "App is in maintenance mode, Please be patient, we'll be back in a couple of hours!",
                message: "",
              ),
            ),
          );
        });
      } else {
        TokenManager.setTokenStatus(false);
        journalGridStatus = response.statusCode;
        journalsModelGridList.clear();
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        journalGridStatus = response.statusCode;
        TokenManager.setTokenStatus(true);
      }
    } catch (e) {
      logger.w("catch $e");
      journalsModelGridList.clear();
    }

    journalsGridModelLoading = false;
    notifyListeners();
  }



// Helper function to format date as YYYY-MM-DD
  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }





  //get journal details
  JournalDetails? journalDetails;
  bool journalDetailsLoading = false;



  Future<void> fetchJournalDetails({required String journalId,required BuildContext context}) async {
    try {
      journalDetails = null;
      String? token = await getUserTokenSharePref();
      journalDetailsLoading = true;
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



  Future<void> fetchRemindersDetails({required BuildContext context}) async {
    try {
      remindersDetails = null;
      String? token = await getUserTokenSharePref();
      remindersDetailsLoading = true;
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


//fix1
  void reminderStartDateFunction(BuildContext context) async {
    reminderStartDate = await selectReminder(
      context,
    );
    logger.i("reminderStartDate${reminderStartDate}");
    notifyListeners();
  }

  void reminderEndDateFunction(BuildContext context) async {
    reminderEndDate = await selectReminder(
      context,
      reminderStartDates: DateFormat('yyyy-MM-dd').parse(reminderStartDate),
    );
    logger.i("reminderStartDate${reminderEndDate}");
    notifyListeners();
  }


  // Future<String> selectReminder(BuildContext context,
  //     {DateTime? reminderStartDates}) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: reminderStartDates ?? DateTime.now(),
  //     firstDate: reminderStartDates ?? DateTime.now(),
  //     lastDate: DateTime(2100),
  //   );
  //
  //   if (picked != null && picked != date) {
  //     // reminderStartDate = ;
  //     // selectedDate = dateFormatter(date: picked.toString());
  //     // log(formattedDate.toString(), name: "formattedDate");
  //     notifyListeners();
  //   }
  //   return formatPickedDateFor2(picked!);
  // }

  Future<String> selectReminder(BuildContext context,
      {DateTime? reminderStartDates}) async {
    final DateTime nowUtc = DateTime.now().toUtc();
    final DateTime nowLocal = nowUtc.toLocal();

    final DateTime initial = reminderStartDates?.toLocal() ?? nowLocal;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: initial,
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final DateTime localPicked = picked.toLocal(); // ⬅️ Ensure it's local
      // Do any logic here using `localPicked`
      notifyListeners();

      return formatPickedDateFor1(localPicked);
    }

    return formatPickedDateFor1(initial); // fallback
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
      })
  async {
    try {
      editRemindersDetailsLoading = true;
      notifyListeners();
      String? token = await getUserTokenSharePref();
      var body = {
        'goal_id': goalId,
        'action_id': actionId,
        'reminder_title': title,
        'reminder_desc': details,
        'reminder_startdate': reminderStartDate,
        'reminder_enddate': reminderEndDate,
        'from_time': convertTimeOfDayTo12Hour(reminderStartTime!).toString(),
        'to_time': convertTimeOfDayTo12Hour(reminderEndTime!).toString(),
        'reminder_before': '',
        'reminder_repeat':repeat,
        'reminder_id':reminderId,
        'timezone_offset': timeZone

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

    // Format the time in 12-hour format without spaces
    return DateFormat('h:mma').format(dateTime);
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

  Future<void> fetchGoals({required BuildContext context}) async {
    try {
      String? token = await getUserTokenSharePref();
      getGoalsModelLoading = true;
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

      final response = await http.get(
        Uri.parse(
          UrlConstant.goalsUrl,
        ),
        headers: <String, String>{
          'device-type': deviceType,
          'version': versionCode.toString(),
          "authorization": "$token"},
      );
      if (response.statusCode == 200) {
        getGoalsModelDropDown = getGoalsModelFromJson(response.body);
        logger.w("getGoalsModelDropDown ${getGoalsModelDropDown}");
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

  Future<void> fetchGoalActions({required String goalId,required BuildContext context}) async {
    try {
      String? token = await getUserTokenSharePref();
      getListGoalActionsModelLoading = true;
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
      final response = await http.get(
        Uri.parse(
          UrlConstant.goalActionsUrl(goalId: goalId.toString()),
        ),
        headers: <String, String>{
          'device-type': deviceType,
          'version': versionCode.toString(),
          "authorization": "$token"},
      );

      if (response.statusCode == 200) {
        getListGoalActionsModel =
            getListGoalActionsModelFromJson(response.body);

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
      else {}
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
  Future<bool> deleteReminderFunction({required String reminder_id,required BuildContext context}) async {
    try {
      // String? userId = await getUserIdSharePref();
      String? token = await getUserTokenSharePref();
      deleteActionLoading = true;
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
        deleteActionLoading = false;

        notifyListeners();
        return true;
      }
      else {
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
