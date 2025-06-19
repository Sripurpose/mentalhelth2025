import 'dart:convert';
import 'dart:io';



import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addactions_screen/model/alaram_info.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/model/id_model.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/all_model.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/logic/date_format.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:mentalhelth/widgets/widget/video_compessor.dart';
import 'package:permission_handler/permission_handler.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;
import 'package:video_compress/video_compress.dart';

import '../../../utils/core/constants.dart';
import '../../../utils/core/constent.dart';
import '../../../utils/core/date_time_utils.dart';
import '../../../utils/theme/colors.dart';
import '../../maintenence_screen/maintenence_screen.dart';
import '../../token_expiry/token_expiry.dart';

class AddActionsProvider extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  List<DateTime> scheduledTimes = [];
var logger = Logger();
  // Future<void> scheduleAlarm(DateTime scheduledTime) async {
  //   final tz.TZDateTime scheduledTZTime =
  //       tz.TZDateTime.from(scheduledTime, tz.local);
  //
  //   final AndroidNotificationDetails androidNotificationDetails =
  //       AndroidNotificationDetails(
  //     'alarm_channel',
  //     'Alarm Channel',
  //     channelDescription: 'Channel for alarms',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     ticker: 'ticker',
  //   );
  //
  //   final NotificationDetails notificationDetails =
  //       NotificationDetails(android: androidNotificationDetails);
  //
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     scheduledTimes.length, // unique id for each alarm
  //     'Alarm',
  //     'Alarm set for ${scheduledTime.hour}:${scheduledTime.minute}',
  //     scheduledTZTime,
  //     notificationDetails,
  //     androidAllowWhileIdle: true,
  //     payload: 'Alarm payload',
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //   );
  //
  //   scheduledTimes.add(scheduledTime);
  //   notifyListeners();
  // }
  ///impotent
  // Future<void> scheduleAlarm(
  //   DateTime scheduledTime,
  //   String actionId, {
  //   required String title,
  //   required String body,
  // }) async {
  //   // Initialize time zone data
  //   tz.initializeTimeZones();
  //   final String timeZoneName = tz.local.name;
  //
  //   final tz.TZDateTime scheduledTZTime =
  //       tz.TZDateTime.from(scheduledTime, tz.local);
  //
  //   final AndroidNotificationDetails androidNotificationDetails =
  //       AndroidNotificationDetails(
  //     'alarm_channel',
  //     'Alarm Channel',
  //     channelDescription: 'Channel for alarms',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     ticker: 'ticker',
  //   );
  //
  //   final NotificationDetails notificationDetails = NotificationDetails(
  //     android: androidNotificationDetails,
  //   );
  //
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     int.parse(actionId), // unique id for each alarm
  //     title,
  //     body,
  //     scheduledTZTime,
  //     notificationDetails,
  //     androidAllowWhileIdle: true,
  //     payload: 'Alarm payload',
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //   );
  //   scheduledTimes.add(scheduledTime);
  //   notifyListeners();
  // }

  Future<void> cancelAlarm(String actionId) async {
    await flutterLocalNotificationsPlugin.cancel(int.parse(actionId));
    scheduledTimes.removeWhere((time) => time.toString() == actionId);
    notifyListeners();
  }

  Future<void> addAlarmHive(AlarmInfo data) async {
    var box = await Hive.openBox<AlarmInfo>("alarm");
    await box.put(data.id, data);
  }

  Future<List<AlarmInfo>> getDataFromHiveBox() async {
    var box = await Hive.openBox<AlarmInfo>("alarm");

    List<AlarmInfo> dataList = [];
    for (var key in box.keys) {
      var value = box.get(key);
      if (value != null) {
        dataList.add(value);
      }
    }

    return dataList;
  }

  Future<void> clearHiveBox() async {
    try {
      await Hive.initFlutter(); // Ensure Hive is initialized
      Box<AlarmInfo> box;
      if (Hive.isBoxOpen("alarm")) {
        box = Hive.box<AlarmInfo>("alarm");
      } else {
        box = await Hive.openBox<AlarmInfo>("alarm");
      }
      await box.clear();
    } catch (e) {
      print("Error clearing Hive box: $e");
      // Handle error as needed
    }
  }

  Future<AlarmInfo?> getDataByIdFromHiveBox(int id) async {
    var box = await Hive.openBox<AlarmInfo>("alarm");
    return box.get(id);
  }

// Function to schedule the alarm
  Future<void> scheduleAlarm(
      String startTime,
      String endTime,
      DateTime startDate,
      DateTime endDate,
      String actionId,
      RepeatInterval repeatInterval, {
        required String title,
        required String body,
      }) async {

    // Initialize timezones if needed
    tzData.initializeTimeZones();

    // Ensure times are correctly parsed
    final hour = reminderStartTime?.hour ?? 0;
    final minute = reminderStartTime?.minute ?? 0;

    // Combine date and time
    final combinedDateTime = DateTime(startDate.year, startDate.month, startDate.day, hour, minute);

    // Convert to local timezone
    final tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(combinedDateTime, tz.local);

    // Check if the alarm time is in the past
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    if (scheduledTZTime.isBefore(now)) {
      print('Cannot schedule alarm in the past.');
      return;
    }

    // Configure the notification details
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Channel',
      channelDescription: 'Channel for alarms',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      fullScreenIntent: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);

    try {
      if (repeatInterval == RepeatInterval.never) {
        // Schedule a one-time alarm
        await flutterLocalNotificationsPlugin.zonedSchedule(
          int.parse(actionId),
          title,
          body,
          scheduledTZTime,
          notificationDetails,
          payload: 'Alarm payload',
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
        print('Alarm scheduled successfully for: $scheduledTZTime');
      } else {
        // Handle repeat intervals
        Duration interval;
        switch (repeatInterval) {
          case RepeatInterval.daily:
            interval = const Duration(days: 1);
            break;
          case RepeatInterval.weekly:
            interval = const Duration(days: 7);
            break;
          case RepeatInterval.monthly:
            interval = const Duration(days: 30);
            break;
          case RepeatInterval.yearly:
            interval = const Duration(days: 365);
            break;
          default:
            throw Exception("Unsupported repeat interval");
        }

        tz.TZDateTime firstInstanceTime = scheduledTZTime;
        while (firstInstanceTime.isBefore(tz.TZDateTime.from(endDate, tz.local))) {
          print('Scheduling repeat alarm for: $firstInstanceTime');
          await flutterLocalNotificationsPlugin.zonedSchedule(
            int.parse(actionId),
            title,
            body,
            firstInstanceTime,
            notificationDetails,
            payload: 'Alarm payload',
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: convertRepeatIntervalToDateTimeComponents(repeatInterval),
          );
          firstInstanceTime = firstInstanceTime.add(interval);
        }
      }
    } catch (e) {
      print('Error scheduling alarm: $e');
    }

    // Save alarm information
    await addAlarmHive(AlarmInfo(
      id: int.parse(actionId),
      title: title,
      description: body,
      startDate: DateFormat('yyyy-MM-dd').format(startDate),
      endDate: DateFormat('yyyy-MM-dd').format(endDate),
      startTime: startTime,
      endTime: endTime,
      repeat: repeteGetString(repeatInterval),
    ));

    notifyListeners();
  }



  void convertAndPrintScheduledTime(DateTime utcTime) {
    // Initialize time zones
    tz.initializeTimeZones();

    // Convert UTC DateTime to TZDateTime in local timezone
    final localTime = tz.TZDateTime.from(utcTime, tz.local);

    print("UTC Scheduled Time: $utcTime");
    print("Local Scheduled Time: $localTime");
  }



  String repeteGetString(RepeatInterval intervel) {
    return intervel == RepeatInterval.never
        ? "Never"
        : intervel == RepeatInterval.daily
            ? "Daily"
            : intervel == RepeatInterval.weekly
                ? "Weekly"
                : intervel == RepeatInterval.monthly
                    ? "Monthly"
                    : intervel == RepeatInterval.yearly
                        ? "Yearly"
                        : "Unknown";
  }

  DateTimeComponents convertRepeatIntervalToDateTimeComponents(
      RepeatInterval interval) {
    switch (interval) {
      case RepeatInterval.daily:
        return DateTimeComponents.time;
      case RepeatInterval.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case RepeatInterval.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
      case RepeatInterval.yearly:
        return DateTimeComponents.dayOfMonthAndTime;
      default:
        throw Exception("Unsupported repeat interval");
    }
  }

  Future<void> updateAlarm(
    String startTime,
    String endTime,
    String actionId,
    DateTime startDate,
    DateTime endDate,
    RepeatInterval repeatInterval, {
    required String title,
    required String body,
  }) async {
    // First, cancel the existing alarm with the given action ID
    await flutterLocalNotificationsPlugin.cancel(int.parse(actionId));

    // Then, schedule the updated alarm
    await scheduleAlarm(
        startTime, endTime, startDate, endDate, actionId, repeatInterval,
        title: title, body: body);
  }

  // Future<void> getScheduledAlarms() async {
  //   final List<PendingNotificationRequest> pendingNotifications =
  //   await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  //   scheduledTimes =
  //       pendingNotifications.map((notification) => notification.body).toList();
  //   notifyListeners();
  // }

  void addLocationSection({
    required String selectedAddress,
    required Placemark placemark,
    required LatLng location,
  }) {
    selectedLocationName =
        selectedLocationAddress =
    "${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
    selectedLatitude = location.latitude.toString();
    selectedLongitude = location.longitude.toString();
    _selectedLocation = location;
    _selectedAddress = selectedAddress;
    notifyListeners();
  }

  void clearLocationSelection() {
    selectedLocationName = '';
    selectedLocationAddress = '';
    selectedLatitude = '';
    selectedLongitude = '';
    _selectedLocation = null;
    _selectedAddress = '';
    notifyListeners();
  }

  //set reminder
  String formattedDate = '';
  String selectedDate = '';
  bool setRemainder = false;

  void changeSetRemainder(bool value) {
    setRemainder = value;
    notifyListeners();
  }

  Future<void> requestExactAlarmPermission() async {
    await Permission.notification.request();
  }

  DateTime? date;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != date) {
      formattedDate = formatPickedDateFor(picked);
      date = picked;
      selectedDate = dateFormatter(date: picked.toString());
      notifyListeners();
    }
  }

  // set reminder choose date
  String reminderStartDate = '';
  String reminderEndDate = '';

  // Future<String> selectReminder(BuildContext context,
  //     {DateTime? reminderStartDates}) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: reminderStartDates ?? DateTime.now().toUtc(),
  //     firstDate: reminderStartDates ?? DateTime.now().toUtc(),
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

//select time
  // set reminder choose date
  TimeOfDay? reminderStartTime;
  TimeOfDay? reminderEndTime;
  String repeat = "Never";

  void addRepeatValue(String value) {
    repeat = value;
    notifyListeners();
  }

  // Future<TimeOfDay> selectReminderTime(BuildContext context,
  //     {TimeOfDay? reminderStartTimes}) async {
  //   final TimeOfDay? pickedTime = await showTimePicker(
  //     context: context,
  //     initialTime: reminderStartTimes ?? TimeOfDay.now(),
  //   );
  //
  //   if (pickedTime != null) {
  //     log(pickedTime.format(context));
  //     notifyListeners();
  //
  //     // final String formattedTime = _formatTimeOfDay(pickedTime);
  //     return pickedTime;
  //   } else {
  //     // Handle the case where no time is picked
  //     return TimeOfDay.now(); // Return an appropriate default or indicator
  //   }
  // }
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

  // String _formatTimeOfDay(TimeOfDay time) {
  //   final hours = time.hour.toString().padLeft(2, '0');
  //   final minutes = time.minute.toString().padLeft(2, '0');
  //   return "$hours:$minutes";
  // }

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

  TimeOfDay? remindTime;

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

  //audio sections
  // selected location
  String selectedLocationName = '';
  String selectedLocationAddress = '';
  String selectedLatitude = '';
  String selectedLongitude = '';
  bool isVideoUploading = false;
  List<String> addMediaUploadResponseList = [];

  LatLng? _selectedLocation;
  String _selectedAddress = '';

  LatLng? get selectedLocation => _selectedLocation;
  String get selectedAddress => _selectedAddress;

  void addMediaUploadResponseListFunction(List<String> value) {
    addMediaUploadResponseList.addAll(value);
    notifyListeners();
  }

  void removeMediaUploadResponseListFunction(int index) {
    // Check if the index is valid before attempting to remove
    if (index >= 0 && index < addMediaUploadResponseList.length) {
      addMediaUploadResponseList.removeAt(index);  // Remove item at the given index

    } else {

    }
    notifyListeners();  // Notify listeners after modifying the list
  }

  TextEditingController descriptionEditTextController = TextEditingController();
  double emotionalValueStar = 0;

  void changeEmotionalValueStar(double value) {
    emotionalValueStar = value;
    notifyListeners();
  }

  double driveValueStar = 0;

  void changeDriveValueStar(double value) {
    driveValueStar = value;
    notifyListeners();
  }

  List<AllModel> alreadyRecordedFilePath = [];

  void alreadyRecorderValuesAddFunction(List<AllModel> paths) {
    alreadyRecordedFilePath.addAll(paths);
    notifyListeners();
  }

  void alreadyRecorderValuesRemove(index) {
    alreadyRecordedFilePath.removeAt(index);
    notifyListeners();
  }

  List<String> recordedFilePath = [];

  void recorderValuesAddFunction(List<String> paths) {
    recordedFilePath.addAll(paths);
    notifyListeners();
  }

  void recorderValuesRemove(index) {
    recordedFilePath.removeAt(index);
    notifyListeners();
  }

  int mediaSelected = 0;

  void selectedMedia(int index) {
    mediaSelected = index;
    notifyListeners();
  }

  //image picker section

  Future<void> pickImageFunctionOld() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    // if (pickedImagesMain != null) {
    // imageFile = File(pickedImage.path);

    // XFile? pickedImage = await compressImage(
    //   File(
    //     pickedImagesMain.path,
    //   ),
    // );
    //
    // final image = File(pickedImagesMain.path);
    // final bytes = await image.readAsBytes();
    // final imageSize = bytes.lengthInBytes;
    // final image1 = File(pickedImagesMain.path);
    // final bytes1 = await image1.readAsBytes();
    // final imageSize1 = bytes1.lengthInBytes;
    // print('Image size: $imageSize bytes');
    // print('Image size: $imageSize1 bytes1');
    if (pickedImage != null) {
      String fileExtension = pickedImage.path..split('.').last;
      String lastThreeChars = fileExtension.substring(fileExtension.length - 3);

      List<String> imagePaths = [];
      imagePaths.add(
        pickedImage.path,
      );
      pickedImagesAddFunction(
        imagePaths,
      );
      await saveMediaUploadAction(
        file: pickedImage.path,
        type: "action",
        fileType: lastThreeChars,
      );
      notifyListeners();
    }
    // }
  }

  Future<void> pickImageFunction(BuildContext context) async {
    final pickedImages = await ImagePicker().pickMultiImage(
      imageQuality: 50, // This is overridden by custom compression logic
    );

    if (pickedImages != null && pickedImages.isNotEmpty) {
      final validImages = pickedImages.where((image) {
        final extension = image.path.toLowerCase().split('.').last;
        return extension != 'gif';
      }).toList();

      if (validImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("GIF files are not supported.")),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: ColorsContent.newThemeColor,
          content: Row(
            children: [
              CupertinoActivityIndicator(color: ColorsContent.whiteText),
              const SizedBox(width: 16),
              const Text(
                "Uploading images...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Open Sans',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );

      List<String> imagePaths = [];

      for (var pickedImage in validImages) {
        try {
          final originalFile = File(pickedImage.path);
          final bytes = await originalFile.readAsBytes();
          final decodedImage = await decodeImageFromList(bytes);
          final int width = decodedImage.width;
          final int height = decodedImage.height;

          int minWidth;
          int minHeight;
          int quality;

          // --- Apply Compression Rules ---
          if (width >= 6000 || height >= 4000) {
            minWidth = 6000;
            minHeight = 4000;
            quality = 18;
          } else if (width >= 4600 || height >= 3000) {
            minWidth = 4600;
            minHeight = 3000;
            quality = 22;
          } else if (width >= 3500 || height >= 2500) {
            minWidth = 3500;
            minHeight = 2500;
            quality = 50;
          } else if (width >= 2500 || height >= 1800) {
            minWidth = 2500;
            minHeight = 1800;
            quality = 75;
          } else {
            minWidth = 2300;
            minHeight = 1500;
            quality = 94;
          }

          String pathToUpload = originalFile.path;
          String fileType = pickedImage.path.split('.').last.toLowerCase();

          final targetPath = "${originalFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

          final compressedFile = await FlutterImageCompress.compressAndGetFile(
            originalFile.absolute.path,
            targetPath,
            minWidth: minWidth,
            minHeight: minHeight,
            quality: quality,
          );

          if (compressedFile != null) {
            pathToUpload = compressedFile.path;
            fileType = 'jpg'; // output is always jpg
          }

          debugPrint("Original Size: ${await originalFile.length()} bytes");
          if (compressedFile != null) {
            debugPrint("Compressed Size: ${await compressedFile.length()} bytes");
          }

          imagePaths.add(pathToUpload);

          await saveMediaUploadAction(
            file: pathToUpload,
            type: "action",
            fileType: fileType,
          );
        } catch (e) {
          debugPrint("Error processing image: $e");
          continue;
        }
      }

      pickedImagesAddFunction(imagePaths);
      notifyListeners();

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading
      }
    }
  }







  Future<void> pickVideoFunction(BuildContext context) async {
    final pickedVideoPath = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );

    if (!isVideoUploading && pickedVideoPath != null) {
      try {
        isVideoUploading = true;
        notifyListeners();

        File originalFile = File(pickedVideoPath.path);
        final fileSizeInBytes = await originalFile.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
        print("📦 Original video size: ${fileSizeInMB.toStringAsFixed(2)} MB");

        final MediaInfo? info = await VideoCompress.getMediaInfo(pickedVideoPath.path);
        final double durationInSeconds = (info?.duration ?? 0) / 1000;
        print("⏱ Duration: ${durationInSeconds.toStringAsFixed(2)} seconds");

        if (fileSizeInMB > 100 || durationInSeconds > 30) {
          showCustomSnackBar(
            context: context,
            message: "Video must be ≤ 100MB and ≤ 30 seconds.",
          );
          isVideoUploading = false;
          notifyListeners();
          return;
        }

        File videoToUpload = originalFile;

        VideoQuality compressionQuality;
        if (fileSizeInMB <= 20) {
          compressionQuality = VideoQuality.HighestQuality;
          print('⚙️ Using HighestQuality for ≤ 20MB');
        } else if (fileSizeInMB <= 50) {
          compressionQuality = VideoQuality.MediumQuality;
          print('⚙️ Using MediumQuality for 21MB - 50MB');
        } else {
          compressionQuality = VideoQuality.LowQuality;
          print('⚙️ Using LowQuality for > 50MB');
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: ColorsContent.newThemeColor,
            content: Row(
              children: [
                CupertinoActivityIndicator(color: ColorsContent.whiteText),
                const SizedBox(width: 16),
                const Text("Compressing video...",
                  style:TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Open Sans',
                    color: Colors.white,
                  ),),
              ],
            ),
          ),
        );

        final MediaInfo? compressedVideoInfo = await VideoCompress.compressVideo(
          originalFile.path,
          quality: compressionQuality,
          deleteOrigin: false,
          includeAudio: true,
          frameRate: 30,
        );

        if (Navigator.canPop(context)) Navigator.pop(context);

        if (compressedVideoInfo == null || compressedVideoInfo.file == null) {
          showCustomSnackBar(
            context: context,
            message: "Video compression failed.",
          );
          isVideoUploading = false;
          notifyListeners();
          return;
        }

        videoToUpload = compressedVideoInfo.file!;
        final compressedSize = await videoToUpload.length();
        print("📉 Compressed video size: ${(compressedSize / (1024 * 1024)).toStringAsFixed(2)} MB");

        // ✅ Copy to safe temp file path
        final safePath = await saveVideoToTemp(videoToUpload.path);



        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: ColorsContent.newThemeColor,
            content: Row(
              children: [
                CupertinoActivityIndicator(color: ColorsContent.whiteText),
                const SizedBox(width: 16),
                const Text("Uploading video...",
                  style:TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Open Sans',
                    color: Colors.white,
                  ),),
              ],
            ),
          ),
        );

        pickedImagesAddFunction([safePath]);

        File thumbNailFile = await generateThumbnail(File(safePath));

        await saveMediaUploadAction(
          file: safePath,
          type: "action",
          fileType: "mp4",
          thumbNail: thumbNailFile.path,
        );

        if (Navigator.canPop(context)) Navigator.pop(context);

      } catch (e) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        showCustomSnackBar(
          context: context,
          message: "An error occurred: $e",
        );
      } finally {
        isVideoUploading = false;
        notifyListeners();
        VideoCompress.deleteAllCache();
      }
    } else if (isVideoUploading) {
      showCustomSnackBar(
        context: context,
        message: "Please wait, video is uploading.",
      );
    }
  }
  Future<String> saveVideoToTemp(String originalPath) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final newPath = '${tempDir.path}/$fileName';
    final copiedFile = await File(originalPath).copy(newPath);
    return copiedFile.path;
  }






  // Future<void> pickVideoFunction(BuildContext context) async {
  //   final pickedVideoPath = await ImagePicker().pickVideo(
  //     source: ImageSource.gallery,
  //   );
  //
  //   if (!isVideoUploading) {
  //     if (pickedVideoPath != null) {
  //       try {
  //         isVideoUploading = true;
  //         notifyListeners();
  //
  //         String fileExtension = pickedVideoPath.path.split('.').last;
  //         String lastThreeChars = fileExtension.substring(fileExtension.length - 3);
  //
  //         List<String> videoPaths = [];
  //         videoPaths.add(pickedVideoPath.path);
  //         pickedImagesAddFunction(videoPaths);
  //
  //         // Path for compressed video output
  //         final String outputPath = '${pickedVideoPath.path}_compressed.mp4';
  //
  //         // Compress video using optimized settings
  //         await FFmpegKit.execute(
  //             '-y -i ${pickedVideoPath.path} -vcodec libx264 -preset veryfast -crf 30 -movflags +faststart -vf "scale=320:240" -r 12 -b:v 200k -acodec aac -b:a 32k -ac 1 $outputPath'
  //         ).then((session) async {
  //           final returnCode = await session.getReturnCode();
  //
  //           if (returnCode!.isValueSuccess()) {
  //             // Video compression successful
  //             File thumbNailFile = await generateThumbnail(File(outputPath));
  //
  //             await saveMediaUploadAction(
  //               file: outputPath,
  //               type: "action",
  //               fileType: "mp4",
  //               thumbNail: thumbNailFile.path,
  //             );
  //           } else {
  //             showCustomSnackBar(
  //               context: context,
  //               message: "Video compression failed.",
  //             );
  //           }
  //         });
  //       } catch (e) {
  //         // Handle any errors that occur during the process
  //         showCustomSnackBar(
  //           context: context,
  //           message: "An error occurred: $e",
  //         );
  //       } finally {
  //         // Ensure this is always executed, regardless of success or failure
  //         isVideoUploading = false;
  //         notifyListeners();
  //       }
  //     }
  //   } else {
  //     showCustomSnackBar(
  //       context: context,
  //       message: "Please Wait, Video is Uploading",
  //     );
  //   }
  // }


  List<AllModel> alreadyPickedImages = [];

  void alreadyPickedImagesAddFunction(List<AllModel> images) {
    alreadyPickedImages.addAll(images);
    notifyListeners();
  }

  void alreadyPickedImagesRemove(index) {
    alreadyPickedImages.removeAt(index);
    notifyListeners();
  }

  List<String> pickedImages = [];

  void pickedImagesAddFunction(List<String> images) {
    pickedImages.addAll(images);
    notifyListeners();
  }

  void pickedImagesRemove(index) {
    pickedImages.removeAt(index);
    notifyListeners();
  }

  //image take section
  // File? takeFile;


  Future<void> takeFileFunction(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      try {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: ColorsContent.newThemeColor,
            content: Row(
              children: [
                CupertinoActivityIndicator(color: ColorsContent.whiteText),
                const SizedBox(width: 16),
                const Text("Capturing images...",
                  style:const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Open Sans',
                    color: Colors.white,
                  ),),
              ],
            ),
          ),
        );

        // Extract file extension
        String fileExtension = pickedFile.path.split('.').last;
        String lastThreeChars = fileExtension.substring(fileExtension.length - 3);

        List<String> imagePaths = [];
        imagePaths.add(pickedFile.path);
        takedImagesAddFunction(imagePaths);

        // Save the media (image or video) without compression
        await saveMediaUploadAction(
          file: pickedFile.path,
          type: "action",
          fileType: lastThreeChars,
        );
      } catch (e) {
        // Handle errors during the process
        showCustomSnackBar(
          context: context,
          message: "An error occurred: $e",
        );
      } finally {
        // Dismiss loading dialog
        Navigator.of(context, rootNavigator: true).pop();
        // Notify listeners to update UI
        notifyListeners();
      }
    }
  }





  // Future<void> takeFileFunction(BuildContext context) async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
  //
  //   if (pickedFile != null) {
  //     try {
  //       // Extract file extension
  //       String fileExtension = pickedFile.path.split('.').last;
  //       String lastThreeChars = fileExtension.substring(fileExtension.length - 3);
  //
  //       List<String> imagePaths = [];
  //       imagePaths.add(pickedFile.path);
  //       takedImagesAddFunction(imagePaths);
  //
  //       // Check if the file is a video based on its extension
  //       if (lastThreeChars.toLowerCase() == 'mp4' ||
  //           lastThreeChars.toLowerCase() == 'mov' ||
  //           lastThreeChars.toLowerCase() == 'avi') {
  //         // Path for compressed video output
  //         final String outputPath = '${pickedFile.path}_compressed.mp4';
  //
  //         // Compress the video using FFmpeg
  //         await FFmpegKit.execute(
  //             '-y -i ${pickedFile.path} -vcodec libx264 -preset veryfast -crf 30 -movflags +faststart -vf "scale=320:240" -r 12 -b:v 200k -acodec aac -b:a 32k -ac 1 $outputPath'
  //         ).then((session) async {
  //           final returnCode = await session.getReturnCode();
  //
  //           if (returnCode!.isValueSuccess()) {
  //             // Compression successful, save the compressed video
  //             await saveMediaUploadAction(
  //               file: outputPath,
  //               type: "action",
  //               fileType: lastThreeChars,
  //             );
  //           } else {
  //             // Handle compression failure
  //             showCustomSnackBar(
  //               context: context,
  //               message: "Video compression failed.",
  //             );
  //           }
  //         });
  //       } else {
  //         // Save the image without compression
  //         await saveMediaUploadAction(
  //           file: pickedFile.path,
  //           type: "action",
  //           fileType: lastThreeChars,
  //         );
  //       }
  //     } catch (e) {
  //       // Handle errors during the process
  //       showCustomSnackBar(
  //         context: context,
  //         message: "An error occurred: $e",
  //       );
  //     } finally {
  //       // Notify listeners to update UI
  //       notifyListeners();
  //     }
  //   }
  // }


  Future<void> takeVideoFunction(BuildContext context) async {
    final pickeVideo = await ImagePicker().pickVideo(
      source: ImageSource.camera,
    );

    if (!isVideoUploading) {
      if (pickeVideo != null) {
        try {
          isVideoUploading = true;
          notifyListeners();

          // Show loading dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              backgroundColor: ColorsContent.newThemeColor,
              content: Row(
                children: [
                  CupertinoActivityIndicator(color: ColorsContent.whiteText),
                  const SizedBox(width: 16),
                  const Text("Capturing video...",
                    style:TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Open Sans',
                      color: Colors.white,
                    ),),
                ],
              ),
            ),
          );

          // Extract the file extension
          String fileExtension = pickeVideo.path.split('.').last;
          String lastThreeChars = fileExtension.substring(fileExtension.length - 3);

          List<String> imagePaths = [pickeVideo.path];
          takedImagesAddFunction(imagePaths);

          // Generate thumbnail from the original video
          File thumbNailFile = await generateThumbnail(File(pickeVideo.path));

          await saveMediaUploadAction(
            file: pickeVideo.path,
            type: "action",
            fileType: "mp4",
            thumbNail: thumbNailFile.path,
          );
        } catch (e) {
          showCustomSnackBar(
            context: context,
            message: "An error occurred: $e",
          );
        } finally {
          isVideoUploading = false;
          Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading dialog
          notifyListeners();
        }
      }
    } else {
      showCustomSnackBar(
        context: context,
        message: "Please wait, video is uploading.",
      );
    }
  }




  // Future<void> takeVideoFunction(BuildContext context) async {
  //   final pickeVideo = await ImagePicker().pickVideo(
  //     source: ImageSource.camera,
  //   );
  //
  //   if (!isVideoUploading) {
  //     if (pickeVideo != null) {
  //       try {
  //         isVideoUploading = true;
  //         notifyListeners();
  //
  //         // Extract the file extension
  //         String fileExtension = pickeVideo.path.split('.').last;
  //         String lastThreeChars = fileExtension.substring(fileExtension.length - 3);
  //
  //         List<String> imagePaths = [];
  //         imagePaths.add(pickeVideo.path);
  //         takedImagesAddFunction(imagePaths);
  //
  //         // Path for compressed video output
  //         final String outputPath = '${pickeVideo.path}_compressed.mp4';
  //
  //         // Compress video using optimized settings
  //         await FFmpegKit.execute(
  //             '-y -i ${pickeVideo.path} -vcodec libx264 -preset veryfast -crf 30 -movflags +faststart -vf "scale=320:240" -r 12 -b:v 200k -acodec aac -b:a 32k -ac 1 $outputPath'
  //         ).then((session) async {
  //           final returnCode = await session.getReturnCode();
  //
  //           if (returnCode!.isValueSuccess()) {
  //             // Video compression successful
  //             File thumbNailFile = await generateThumbnail(File(outputPath));
  //
  //             await saveMediaUploadAction(
  //               file: outputPath,
  //               type: "action",
  //               fileType: "mp4",
  //               thumbNail: thumbNailFile.path,
  //             );
  //           } else {
  //             showCustomSnackBar(
  //               context: context,
  //               message: "Video compression failed.",
  //             );
  //           }
  //         });
  //       } catch (e) {
  //         // Handle any errors that occur during the process
  //         showCustomSnackBar(
  //           context: context,
  //           message: "An error occurred: $e",
  //         );
  //       } finally {
  //         // Ensure this is always executed, regardless of success or failure
  //         isVideoUploading = false;
  //         notifyListeners();
  //       }
  //     }
  //   } else {
  //     showCustomSnackBar(
  //       context: context,
  //       message: "Please Wait, Video is Uploading",
  //     );
  //   }
  // }


  List<String> takedImages = [];

  void takedImagesAddFunction(List<String> images) {
    takedImages.addAll(images);
    notifyListeners();
  }

  void takedImagesRemove(index) {
    takedImages.removeAt(index);
    notifyListeners();
  }

  //
  //
  // int selectedMedia = 0;
  // void selectedMediaFunction({required int index}) {
  //   selectedMedia = index;
  //   log(selectedMedia.toString());
  //   notifyListeners();
  // }
  TextEditingController titleEditTextController = TextEditingController();

  //generate thumpanial
  Future<File> generateThumbnail(File file) async {
    final thumbNailBytes = await VideoCompress.getFileThumbnail(file.path);
    return thumbNailBytes;
  }

  Future<int> getVideoSize(File file) async {
    final size = await file.length();
    return size;
  }

  bool saveAddActionsLoading = false;

  void updateSaveActionLoadingFunction(bool value) {
    saveAddActionsLoading = value;
    print(saveAddActionsLoading.toString() + " fetchedfetched");
    notifyListeners();
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

  String convertTimeOfDayTo12Hour(TimeOfDay time) {
    // Create a DateTime object for formatting purposes
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    // Format the time in 12-hour format without spaces
    return DateFormat('h:mma').format(dateTime);
  }


  GoalModelIdName? goalModelIdName;

  Future<bool> saveGemFunctionOld(
      BuildContext context, {
        required String title,
        required String details,
        required List<String> mediaName,
        required String locationName,
        required String locationLatitude,
        required String locationLongitude,
        required String locationAddress,
        required String goalId,
        String? isReminder,
      })
  async {
    try {
      updateSaveActionLoadingFunction(true);
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
      // Create the body based on the value of isReminder
      var body;
      if (isReminder == '1') {
        body = {
          'title': title,
          'gem_type': 'action',
          'details': details,
          'location_name': locationName,
          'location_latitude': locationLatitude,
          'location_longitude': locationLongitude,
          'location_address': locationAddress,
          'goal_id': goalId,
          'is_reminder': isReminder ?? '',
          'reminder_startdate': reminderStartDate,  // Convert to string
          'reminder_enddate': reminderEndDate,      // Convert to string
          //'reminder_before': '${remindTime?.hour.toString().padLeft(2, '0')}:${remindTime?.minute.toString().padLeft(2, '0')}',
          'reminder_before': '',
          'reminder_repeat': repeat.toString(),  // Ensure repeat is a string
          'from_time': convertTimeOfDayTo12Hour(reminderStartTime!).toString(),        // Convert to string
          'to_time': convertTimeOfDayTo12Hour(reminderEndTime!).toString(),            // Convert to string
          'timezone_offset': timeZone
        };
      } else {
        body = {
          'title': title,
          'gem_type': 'action',
          'details': details,
          'location_name': locationName,
          'location_latitude': locationLatitude,
          'location_longitude': locationLongitude,
          'location_address': locationAddress,
          'goal_id': goalId,
          'is_reminder': isReminder ?? '',         // Convert to string
        };
      }

      logger.w("body $body");

      print(UrlConstant.savegemUrl + " saveGemFunction");
      print(body.toString() + " saveGemFunction");

      // Add media files to the body
      for (int i = 0; i < mediaName.length; i++) {
        body['media_name[$i]'] = mediaName[i];
      }

      final response = await http.post(
        Uri.parse(UrlConstant.savegemUrl),
        headers: <String, String>{
          'device-type': deviceType,
          'version': versionCode.toString(),
          "authorization": "$token"},
        body: body,
      );

      print(response.body.toString() + " saveGemFunction");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseData = json.decode(response.body);
        goalModelIdName = GoalModelIdName(
          id: responseData["id"].toString(),
          name: responseData["title"].toString(),
        );
        showCustomSnackBar(
          context: context,
          message: responseData["text"].toString(),
        );

        if (goalId == null || goalId == "") {
          Navigator.of(context).pop();
        }

        if (setRemainder) {
          // Scheduling function call
          scheduleAlarm(
            reminderStartTime!.format(context).toString(),
            reminderEndTime!.format(context).toString(),
            DateFormat('d MMM y').parse(reminderStartDate),
            DateFormat('d MMM y').parse(reminderEndDate),
            responseData["id"].toString(),
            repeat == "Never"
                ? RepeatInterval.never
                : repeat == "Daily"
                ? RepeatInterval.daily
                : repeat == "Weekly"
                ? RepeatInterval.weekly
                : repeat == "Monthly"
                ? RepeatInterval.monthly
                : repeat == "Yearly"
                ? RepeatInterval.yearly
                : RepeatInterval.daily,
            title: title,
            body: details,
          );
        }

        clearFunction();
        updateSaveActionLoadingFunction(false);
        return true;
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
        updateSaveActionLoadingFunction(false);
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        TokenManager.setTokenStatus(true);
      }

      updateSaveActionLoadingFunction(false);
      return false;
    } catch (error) {
      logger.w("error Failed $error");
     // showToast(context: context, message: "Failed");
      updateSaveActionLoadingFunction(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveGemFunction(
      BuildContext context, {
        required String title,
        required String details,
        required List<String> mediaName,
        required String locationName,
        required String locationLatitude,
        required String locationLongitude,
        required String locationAddress,
        required String goalId,
        String? isReminder,
      }) async {
    try {
      // ✅ Keep only the last .mp3 file, preserve other media
      int lastMp3Index = mediaName.lastIndexWhere((file) => file.toLowerCase().endsWith('.mp3'));
      if (lastMp3Index != -1) {
        String lastMp3File = mediaName[lastMp3Index];
        mediaName.removeWhere((file) => file.toLowerCase().endsWith('.mp3'));
        mediaName.add(lastMp3File);
      }

      updateSaveActionLoadingFunction(true);
      notifyListeners();

      String? token = await getUserTokenSharePref();
      String deviceType = Platform.isAndroid ? 'android' : 'ios';
      String? versionCode = '';
      if (Platform.isAndroid) {
        versionCode = Constent.versionCodeAndroid.isNotEmpty
            ? Constent.versionCodeAndroid
            : await getVersionSharePref();
      } else if (Platform.isIOS) {
        versionCode = Constent.versionCodeIOS.isNotEmpty
            ? Constent.versionCodeIOS
            : await getVersionSharePref();
      }

      // Prepare body
      var body;
      if (isReminder == '1') {
        body = {
          'title': title,
          'gem_type': 'action',
          'details': details,
          'location_name': locationName,
          'location_latitude': locationLatitude,
          'location_longitude': locationLongitude,
          'location_address': locationAddress,
          'goal_id': goalId,
          'is_reminder': isReminder ?? '',
          'reminder_startdate': reminderStartDate,
          'reminder_enddate': reminderEndDate,
          'reminder_before': '',
          'reminder_repeat': repeat.toString(),
          'from_time': convertTimeOfDayTo12Hour(reminderStartTime!).toString(),
          'to_time': convertTimeOfDayTo12Hour(reminderEndTime!).toString(),
          'timezone_offset': timeZone,
        };
      } else {
        body = {
          'title': title,
          'gem_type': 'action',
          'details': details,
          'location_name': locationName,
          'location_latitude': locationLatitude,
          'location_longitude': locationLongitude,
          'location_address': locationAddress,
          'goal_id': goalId,
          'is_reminder': isReminder ?? '',
        };
      }

      // Add media files
      for (int i = 0; i < mediaName.length; i++) {
        body['media_name[$i]'] = mediaName[i];
      }

      logger.w("body $body");
      print(UrlConstant.savegemUrl + " saveGemFunction");
      print(body.toString() + " saveGemFunction");

      final response = await http.post(
        Uri.parse(UrlConstant.savegemUrl),
        headers: <String, String>{
          'device-type': deviceType,
          'version': versionCode.toString(),
          "authorization": "$token",
        },
        body: body,
      );

      print(response.body.toString() + " saveGemFunction");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseData = json.decode(response.body);
        goalModelIdName = GoalModelIdName(
          id: responseData["id"].toString(),
          name: responseData["title"].toString(),
        );
        showCustomSnackBar(
          context: context,
          message: responseData["text"].toString(),
        );

        if (goalId == null || goalId == "") {
          Navigator.of(context).pop();
        }

        if (setRemainder) {
          scheduleAlarm(
            reminderStartTime!.format(context).toString(),
            reminderEndTime!.format(context).toString(),
            DateFormat('d MMM y').parse(reminderStartDate),
            DateFormat('d MMM y').parse(reminderEndDate),
            responseData["id"].toString(),
            repeat == "Never"
                ? RepeatInterval.never
                : repeat == "Daily"
                ? RepeatInterval.daily
                : repeat == "Weekly"
                ? RepeatInterval.weekly
                : repeat == "Monthly"
                ? RepeatInterval.monthly
                : repeat == "Yearly"
                ? RepeatInterval.yearly
                : RepeatInterval.daily,
            title: title,
            body: details,
          );
        }

        clearFunction();
        updateSaveActionLoadingFunction(false);
        return true;
      } else if (response.statusCode == 503) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MaintenenceScreen(
                title:
                "App is in maintainance mode, Please be patient, we'll be back in a couple of hours!",
                message: "",
              ),
            ),
          );
        });
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        TokenManager.setTokenStatus(true);
      }

      updateSaveActionLoadingFunction(false);
      return false;
    } catch (error) {
      logger.w("error Failed $error");
      updateSaveActionLoadingFunction(false);
      notifyListeners();
      return false;
    }
  }





  //editActions function

  bool editActionLoading = false;

  Future<void> editActionFunction(
    BuildContext context, {
    required String title,
    required String details,
    required List<String> mediaName,
    required String locationName,
    required String locationLatitude,
    required String locationLongitude,
    required String locationAddress,
    required String actionId,
        required String goalId,
        String? isReminder,
  }) async {
    try {
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
      updateSaveActionLoadingFunction(true);
      notifyListeners();
      String? token = await getUserTokenSharePref();
      // Create the body based on the value of isReminder
      var body;
      if (isReminder == '1') {
        body = {
          'title': title,
          'gem_type': 'action',
          'details': details,
          'location_name': locationName,
          'location_latitude': locationLatitude,
          'location_longitude': locationLongitude,
          'location_address': locationAddress,
          'goal_id': goalId,
          'gem_id':actionId,
          'is_reminder': isReminder ?? '',
          'reminder_startdate': reminderStartDate,  // Convert to string
          'reminder_enddate': reminderEndDate,      // Convert to string
          //'reminder_before': '${remindTime?.hour.toString().padLeft(2, '0')}:${remindTime?.minute.toString().padLeft(2, '0')}',
          'reminder_before': '',
          'reminder_repeat': repeat.toString(),  // Ensure repeat is a string
          'from_time': convertTimeOfDayTo12Hour(reminderStartTime!).toString(),        // Convert to string
          'to_time': convertTimeOfDayTo12Hour(reminderEndTime!).toString(),            // Convert to string
          'timezone_offset': timeZone
        };
      } else {
        body = {
          'title': title,
          'gem_type': 'action',
          'details': details,
          'location_name': locationName,
          'location_latitude': locationLatitude,
          'location_longitude': locationLongitude,
          'location_address': locationAddress,
          'goal_id': goalId,
          'gem_id':actionId,
          'is_reminder': isReminder ?? '',         // Convert to string
        };
      }
      // var body = {
      //   'title': title,
      //   'gem_type': 'action',
      //   'details': details,
      //   'location_name': locationName,
      //   'location_latitude': locationLatitude,
      //   'location_longitude': locationLongitude,
      //   'location_address': locationAddress,
      //   'gem_id': actionId,
      //   'goal_id': goalId,
      //   'is_reminder': isReminder ?? '',
      //   'reminder_startdate': convertToUnixTimestamp(reminderStartDate).toString(),  // Convert to string
      //   'reminder_enddate': convertToUnixTimestamp(reminderEndDate).toString(),      // Convert to string
      //   'reminder_before': '${remindTime?.hour.toString().padLeft(2, '0')}:${remindTime?.minute.toString().padLeft(2, '0')}',
      //   'reminder_repeat': repeat.toString(),  // Ensure repeat is a string
      //   'from_time': convertTimeOfDayTo12Hour(reminderStartTime!).toString(),        // Convert to string
      //   'to_time': convertTimeOfDayTo12Hour(reminderEndTime!).toString(),            // Convert to string
      // };
      for (int i = 0; i < mediaName.length; i++) {
        body['media_name[$i]'] = mediaName[i];
      }
      final response = await http.post(
        Uri.parse(
          UrlConstant.savegemUrl,
        ),
        headers: <String, String>{
          'device-type': deviceType,
          'version': versionCode.toString(),
          "authorization": "$token"},
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseData = json.decode(response.body);
        goalModelIdName = GoalModelIdName(
          id: responseData["id"].toString(),
          name: responseData["title"].toString(),
        );
        Navigator.of(context).pop();
        // If a reminder is set, reschedule the updated alarm
        if (setRemainder) {
          scheduleAlarm(
            reminderStartTime!.format(context).toString(),
            reminderEndTime!.format(context).toString(),
            DateFormat('d MMM y').parse(reminderStartDate),
            DateFormat('d MMM y').parse(reminderEndDate),
            responseData["id"].toString(),
            repeat == "Never"
                ? RepeatInterval.never
                : repeat == "Daily"
                ? RepeatInterval.daily
                : repeat == "Weekly"
                ? RepeatInterval.weekly
                : repeat == "Monthly"
                ? RepeatInterval.monthly
                : repeat == "Yearly"
                ? RepeatInterval.yearly
                : RepeatInterval.daily,
            title: title,
            body: details,
          );
        }
        clearFunction();
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
        Navigator.of(context).pop();
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
        // Handle errors based on the status code
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      updateSaveActionLoadingFunction(false);
      notifyListeners();
    } catch (error) {
     // showCustomSnackBar(context: context, message: "Failed");
      updateSaveActionLoadingFunction(false);
      notifyListeners();
    }
  }

  //save media upload action
  bool saveMediaUploadLoading = false;

  Future<void> saveMediaUploadAction({
    required String file,
    required String type,
    required String fileType,
    String? thumbNail,
  }) async {
    try {
      String? token = await getUserTokenSharePref();
      saveMediaUploadLoading = true;
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
      var headers = {
        'device-type': deviceType,
        'version': versionCode.toString(),
        "authorization": "$token",
      };
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          UrlConstant.mediauploadUrl,
        ),
      );

      request.fields.addAll(
        {
          'type': type,
          'file_type': fileType,
        },
      );

      // request.fields.addAll(
      //   {
      //     'file_type': fileType,
      //   },
      // );
      request.files.add(
        await http.MultipartFile.fromPath(
          'media_name',
          file,
        ),
      );
      if (thumbNail != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'media_thumb',
            thumbNail,
          ),
        );
      }

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      // print(await response.stream.bytesToString());
      String responseBody = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        String? mediaName = jsonResponse['media_name'];
        List<String> mediaNameList = [];
        mediaNameList.add(mediaName!);
        addMediaUploadResponseListFunction(
          mediaNameList,
        );
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
      saveMediaUploadLoading = false;
      notifyListeners();
    } catch (error) {
      saveMediaUploadLoading = false;
      notifyListeners();
    }
  }

  void clearFunction() {
    titleEditTextController.clear();
    descriptionEditTextController.clear();
    addMediaUploadResponseList.clear();
    selectedLocationName = '';
    selectedLocationAddress = '';
    selectedLatitude = '';
    selectedLongitude = '';
    recordedFilePath.clear();
    pickedImages.clear();
    alreadyPickedImages.clear();
    alreadyRecordedFilePath.clear();
    takedImages.clear();
    reminderStartDate = '';
    reminderEndDate = '';
    reminderStartTime = null;
    reminderEndTime = null;
    remindTime = null;
    repeat = 'Never';
  }

  bool deleteActionLoading = false;

  Future<bool> deleteActionFunction({required String deleteId,required BuildContext context}) async {
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
        UrlConstant.deleteActions(
          action: deleteId,
        ),
      );
      final response = await http.delete(
        url,
        headers: headers,
      );
      print(response.body.toString());
      notifyListeners();      if(response.statusCode == 401){
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

  //update action
  //update goal status
  bool updateActionStatus = false;
  int? updateActionIntStatus;

  Future<void> updateActionStatusFunction(BuildContext context,
      {required String actionId, required String goalId}) async {
    try {
      String? token = await getUserTokenSharePref();
      // log(phone);
      updateActionStatus = true;
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
      updateActionIntStatus = 0;
      notifyListeners();

      var body = {
        'action_id': actionId,
        'goal_id': goalId,
      };
      final response = await http.post(
        Uri.parse(
          UrlConstant.updateActionStatusUrl,
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
        updateActionIntStatus = response.statusCode;
        logger.i("updateActionIntStatus${updateActionIntStatus}");
        showCustomSnackBar(context: context, message: 'action update success.');
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
        updateActionIntStatus = response.statusCode;
        showCustomSnackBar(context: context, message: 'action update failed.');
      }
      updateActionIntStatus = response.statusCode;
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      updateActionStatus = false;
      notifyListeners();
    } catch (error) {
      updateActionStatus = false;
      notifyListeners();
    }
  }

  static Future<void> checkAndroidScheduleExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
   // alarmPrint('Schedule exact alarm permission: $status.');
    if (status.isDenied) {
     // alarmPrint('Requesting schedule exact alarm permission...');
      final res = await Permission.scheduleExactAlarm.request();
    //  alarmPrint('Schedule exact alarm permission ${res.isGranted ? '' : 'not'} granted',);
    }
  }

}







enum RepeatInterval { never, daily, weekly, monthly, yearly }
