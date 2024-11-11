import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addactions_screen/provider/add_actions_provider.dart';
import 'package:mentalhelth/screens/addactions_screen/widget/googlemap_widget/google_map_widget.dart';
import 'package:mentalhelth/screens/addactions_screen/widget/popup/audio_popup.dart';
import 'package:mentalhelth/screens/addactions_screen/widget/popup/camera_popup.dart';
import 'package:mentalhelth/screens/addactions_screen/widget/popup/gallary_popup.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/model/actions_details_model.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/mental_strength_add_edit_page.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/all_model.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/logic/date_format.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:mentalhelth/utils/theme/custom_button_style.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_subtitle.dart';
import 'package:mentalhelth/widgets/app_bar/custom_app_bar.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/custom_icon_button.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/custom_text_form_field.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../addactions_screen/model/alaram_info.dart';
import '../../../dash_borad_screen/provider/dash_board_provider.dart';
import '../../../edit_add_profile_screen/provider/edit_provider.dart';
import '../../../home_screen/provider/home_provider.dart';
import '../../../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../../../token_expiry/tocken_expiry_warning_screen.dart';
import '../../../token_expiry/token_expiry.dart';

class EditActionScreen extends StatefulWidget {
  const EditActionScreen({Key? key, required this.actionsDetailsModel})
      : super(
          key: key,
        );
  final ActionsDetailsModel? actionsDetailsModel;

  @override
  State<EditActionScreen> createState() => _EditActionScreenState();
}

class _EditActionScreenState extends State<EditActionScreen> {
  late HomeProvider homeProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late EditProfileProvider editProfileProvider;
  late DashBoardProvider dashBoardProvider;
  late AddActionsProvider addActionsProvider;
  bool tokenStatus = false;
  var logger = Logger();
  AlarmInfo? alarmInfo;
  PermissionStatus permissionStatus = PermissionStatus.denied;

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    mentalStrengthEditProvider =
        Provider.of<MentalStrengthEditProvider>(context, listen: false);
    dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
    editProfileProvider =
        Provider.of<EditProfileProvider>(context, listen: false);
    addActionsProvider =
        Provider.of<AddActionsProvider>(context, listen: false);
    addActionsProvider.setRemainder = true;
    logger.w(
        "addActionsProvider.reminderStartDate${addActionsProvider.reminderStartDate}");
    alarmDetails();
    _isTokenExpired();
    init();
    super.initState();
  }

  Future<void> _isTokenExpired() async {
    await homeProvider.fetchChartView(context);
    await homeProvider.fetchJournals(initial: true);
    //   await editProfileProvider.fetchUserProfile();
    tokenStatus = TokenManager.checkTokenExpiry();
    if (tokenStatus) {
      setState(() {
        logger.e("Token status changed: $tokenStatus");
      });
      logger.e("Token status changed: $tokenStatus");
    } else {
      logger.e("Token status changedElse: $tokenStatus");
    }
  }

  Future<void> alarmDetails() async {
    alarmInfo = await addActionsProvider.getDataByIdFromHiveBox(
      int.parse(
          mentalStrengthEditProvider.actionsDetailsModel!.actions!.actionId!),
    );
    logger.w("alarmInfo $alarmInfo");
  }


  Future<void> _checkPermissionStatus() async {
    // Check location permission status
    final status = await Permission.locationWhenInUse.status;
    setState(() {
      permissionStatus = status;
    });
  }

  Future<void> _requestPermissions() async {
    // Request location permission (Platform specific)
    if (Platform.isIOS) {
      await Permission.locationWhenInUse.request();
      await Permission.notification.request();
      await Permission.photos.request();
    } else if (Platform.isAndroid) {
      await Permission.locationWhenInUse.request();
      await Permission.notification.request();
      await Permission.storage.request(); // For storage permissions
      await Permission.manageExternalStorage.request(); // For Android 11 and above
    }

    // Check updated location permission status
    final locationStatus = await Permission.locationWhenInUse.status;
    setState(() {
      permissionStatus = locationStatus;
    });
  }

  // await addActionsProvider.editActionFunction(
  // context,
  // title: addActionsProvider.titleEditTextController.text,
  // details: addActionsProvider.descriptionEditTextController.text,
  // mediaName: addActionsProvider.addMediaUploadResponseList,
  // locationName: addActionsProvider.selectedLocationName,
  // locationLatitude: addActionsProvider.selectedLatitude,
  // locationLongitude: addActionsProvider.locationLongitude,
  // locationAddress: addActionsProvider.selectedLocationAddress,
  // actionId:
  // widget.actionsDetailsModel!.actions!.actionId.toString(),
  // );
  TimeOfDay? stringToTimeOfDay(String time) {
    try {
      // Trim and normalize to uppercase
      String trimmedTime = time.trim().toUpperCase();

      // Remove any extraneous characters (e.g., '?')
      String cleanedTime = trimmedTime.replaceAll(RegExp(r'[^\d:APM]'), '');

      // Check if the cleaned time contains AM/PM
      bool isPM = cleanedTime.contains("PM");
      bool isAM = cleanedTime.contains("AM");

      // Remove AM/PM suffix
      cleanedTime = cleanedTime.replaceAll(RegExp(r'[APM]'), '').trim();

      // Validate format
      RegExp timeRegExp = RegExp(r'^(\d{1,2}):(\d{2})$');
      Match? match = timeRegExp.firstMatch(cleanedTime);

      if (match == null) {
        print("Invalid time format: $time");
        return null;
      }

      // Parse hour and minute
      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);

      // Adjust hour based on AM/PM
      if (isPM && hour < 12) {
        hour += 12;
      } else if (isAM && hour == 12) {
        hour = 0;
      }

      // Ensure hour is within valid range (0-23)
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        print("Invalid time values: hour $hour, minute $minute");
        return null;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print("Error parsing time: $e");
      return null;
    }
  }

  String unixTimestampToDate(String timestamp) {
    try {
      // Convert the timestamp to an integer
      int unixTimestamp = int.parse(timestamp);

      // Create a DateTime object from the Unix timestamp (assumes timestamp is in seconds)
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);

      // Format the DateTime object into the desired string format
      final DateFormat formatter = DateFormat('dd MMM yyyy');
      String formattedDate = formatter.format(dateTime);

      return formattedDate;
    } catch (e) {
      print("Error converting timestamp: $e");
      return "Invalid date";
    }
  }

  void init() {
    AddActionsProvider addActionsProvider = Provider.of(context, listen: false);
    // Clear lists to avoid duplicates
    addActionsProvider.alreadyRecordedFilePath.clear();
    addActionsProvider.alreadyPickedImages.clear();
    addActionsProvider.reminderStartDate = unixTimestampToDate(
        widget.actionsDetailsModel!.actions!.reminder?.reminder_startdate ??
            "");
    addActionsProvider.reminderEndDate = unixTimestampToDate(
        widget.actionsDetailsModel!.actions!.reminder?.reminder_enddate ?? "");
    addActionsProvider.reminderStartTime = stringToTimeOfDay(
        widget.actionsDetailsModel!.actions!.reminder?.from_time ?? "");
    addActionsProvider.reminderEndTime = stringToTimeOfDay(
        widget.actionsDetailsModel!.actions!.reminder?.to_time ?? "");
    addActionsProvider.repeat =
        widget.actionsDetailsModel!.actions!.reminder?.reminder_repeat ?? "";
    addActionsProvider.titleEditTextController.text =
        widget.actionsDetailsModel!.actions!.actionTitle.toString();
    if (widget.actionsDetailsModel!.actions!.reminder?.reminder_before !=
        null) {
      // Parse the hour and minute from widget.reminderBefore (assuming the format is "HH:mm")
      List<String>? timeParts = widget
          .actionsDetailsModel!.actions!.reminder?.reminder_before
          ?.split(":");
      if (timeParts?.length == 2) {
        int hour = int.tryParse(timeParts![0]) ?? 0;
        int minute = int.tryParse(timeParts[1]) ?? 0;

        // Assign both hour and minute to homeProvider.remindTime
        addActionsProvider.remindTime = TimeOfDay(hour: hour, minute: minute);
      } else {
        // Handle incorrect format
        addActionsProvider.remindTime = TimeOfDay(
            hour: 0, minute: 0); // Default to 00:00 if format is invalid
      }
    }
    addActionsProvider.descriptionEditTextController.text =
        widget.actionsDetailsModel!.actions!.actionDetails.toString();
    if (widget.actionsDetailsModel!.actions!.gemMedia != null) {
      // List<String> audioList = [];
      for (int i = 0;
          i < widget.actionsDetailsModel!.actions!.gemMedia!.length;
          i++) {
        if (widget.actionsDetailsModel!.actions!.gemMedia![i].mediaType ==
            'audio') {
          // audioList
          //     .add(widget.actionsDetailsModel!.actions!.gemMedia![i].gemMedia!);
          addActionsProvider.alreadyRecordedFilePath.add(AllModel(
              id: widget.actionsDetailsModel!.actions!.gemMedia![i].mediaId
                  .toString(),
              value: widget.actionsDetailsModel!.actions!.gemMedia![i].gemMedia!
                  .toString()));
        }
      }
      // if (audioList.isNotEmpty) {
      //   addActionsProvider.recordedFilePath.addAll(audioList);
      //   log(addActionsProvider.recordedFilePath.length.toString(),
      //       name: "audiosall");
      // }

      // List<String> imageList = [];
      for (int i = 0;
          i < widget.actionsDetailsModel!.actions!.gemMedia!.length;
          i++) {
        if (widget.actionsDetailsModel!.actions!.gemMedia![i].mediaType ==
                'image' ||
            widget.actionsDetailsModel!.actions!.gemMedia![i].mediaType ==
                'video') {
          // imageList
          //     .add(widget.actionsDetailsModel!.actions!.gemMedia![i].gemMedia!);
          addActionsProvider.alreadyPickedImages.add(
            AllModel(
              id: widget.actionsDetailsModel!.actions!.gemMedia![i].mediaId
                  .toString(),
              value: widget.actionsDetailsModel!.actions!.gemMedia![i].gemMedia!
                  .toString(),
            ),
          );
        }
      }
      // if (imageList.isNotEmpty) {
      //   addActionsProvider.pickedImages.addAll(imageList);
      //   log(addActionsProvider.pickedImages.toString(), name: "imageLists");
      // }

      addActionsProvider.selectedLocationName =
          widget.actionsDetailsModel!.actions!.location == null
              ? ""
              : widget.actionsDetailsModel!.actions!.location!.locationName
                  .toString();
      addActionsProvider.selectedLatitude =
          widget.actionsDetailsModel!.actions!.location == null
              ? ""
              : widget.actionsDetailsModel!.actions!.location!.locationLatitude
                  .toString();
      addActionsProvider.locationLongitude =
          widget.actionsDetailsModel!.actions!.location == null
              ? ""
              : widget.actionsDetailsModel!.actions!.location!.locationLongitude
                  .toString();
      addActionsProvider.selectedLocationAddress =
          widget.actionsDetailsModel!.actions!.location == null
              ? ""
              : widget.actionsDetailsModel!.actions!.location!.locationAddress
                  .toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: () async {
          AddActionsProvider addActionsProvider =
              Provider.of(context, listen: false);
          addActionsProvider.clearFunction();
          return true; // return true to allow back navigation, false to prevent it
        },
        child: tokenStatus == false
            ? SafeArea(
                child: Scaffold(
                  appBar: buildAppBarActions(
                    context,
                    size,
                    heading: "Edit Actions",
                  ),
                  body: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.onSecondaryContainer.withOpacity(1),
                      image: DecorationImage(
                        image: AssetImage(
                          ImageConstant.imgGroup193,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 15,
                      ),
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Consumer<AddActionsProvider>(
                                builder: (context, addActionsProvider, _) {
                              return Column(
                                children: [
                                  _buildTitleEditText(context),
                                  const SizedBox(height: 19),
                                  _buildDescriptionEditText(context),
                                  const SizedBox(height: 35),
                                  _buildAddMediaColumn(
                                    context,
                                    size,
                                  ),
                                  const SizedBox(height: 19),
                                  // addActionsProvider.mediaSelected == 3
                                  //     ? const AddActionGoogleMap()
                                  //     : const SizedBox(),
                                  SizedBox(height: size.height * 0.03),
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: addActionsProvider.setRemainder,
                                        onChanged: (value) async {
                                          addActionsProvider
                                              .changeSetRemainder(value!);
                                          addActionsProvider
                                              .requestExactAlarmPermission();
                                        },
                                      ),
                                      SizedBox(
                                        width: size.width * 0.01,
                                      ),
                                      const Text(
                                        "Set a reminder for this action",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  addActionsProvider.setRemainder
                                      ? SizedBox(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "Date",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      addActionsProvider
                                                          .reminderStartDateFunction(
                                                        context,
                                                      );
                                                    },
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                        left: 2,
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 11,
                                                        vertical: 8,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: theme.colorScheme
                                                            .onSecondaryContainer
                                                            .withOpacity(1),
                                                        border: Border.all(
                                                          color:
                                                              appTheme.gray700,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadiusStyle
                                                                .roundedBorder4,
                                                      ),
                                                      child: SizedBox(
                                                        width:
                                                            size.width * 0.32,
                                                        child: Row(
                                                          children: [
                                                            CustomImageView(
                                                              imagePath:
                                                                  ImageConstant
                                                                      .imgThumbsUpGray700,
                                                              height: 20,
                                                              width: 20,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                bottom: 2,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                left: 5,
                                                                top: 2,
                                                                bottom: 1,
                                                              ),
                                                              child: Text(
                                                                //importent
                                                                addActionsProvider
                                                                        .reminderStartDate
                                                                        .isNotEmpty
                                                                    ? addActionsProvider
                                                                        .reminderStartDate
                                                                    : "Choose Date   ",
                                                                style: CustomTextStyles
                                                                    .bodySmallGray700,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const Text(
                                                    "To",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      addActionsProvider
                                                          .reminderEndDateFunction(
                                                        context,
                                                      );
                                                    },
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                        left: 2,
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 11,
                                                        vertical: 8,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: theme.colorScheme
                                                            .onSecondaryContainer
                                                            .withOpacity(1),
                                                        border: Border.all(
                                                          color:
                                                              appTheme.gray700,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadiusStyle
                                                                .roundedBorder4,
                                                      ),
                                                      child: SizedBox(
                                                        width:
                                                            size.width * 0.32,
                                                        child: Row(
                                                          children: [
                                                            CustomImageView(
                                                              imagePath:
                                                                  ImageConstant
                                                                      .imgThumbsUpGray700,
                                                              height: 20,
                                                              width: 20,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                bottom: 2,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                left: 5,
                                                                top: 2,
                                                                bottom: 1,
                                                              ),
                                                              child: Text(
                                                                addActionsProvider
                                                                        .reminderEndDate
                                                                        .isNotEmpty
                                                                    ? addActionsProvider
                                                                        .reminderEndDate
                                                                    : "Choose Date   ",
                                                                style: CustomTextStyles
                                                                    .bodySmallGray700,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              const Text(
                                                "Time",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      addActionsProvider
                                                          .reminderStartTimeFunction(
                                                        context,
                                                      );
                                                    },
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                        left: 2,
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 11,
                                                        vertical: 8,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: theme.colorScheme
                                                            .onSecondaryContainer
                                                            .withOpacity(1),
                                                        border: Border.all(
                                                          color:
                                                              appTheme.gray700,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadiusStyle
                                                                .roundedBorder4,
                                                      ),
                                                      child: SizedBox(
                                                        width:
                                                            size.width * 0.32,
                                                        child: Row(
                                                          children: [
                                                            CustomImageView(
                                                              imagePath:
                                                                  ImageConstant
                                                                      .imgThumbsUpGray700,
                                                              height: 20,
                                                              width: 20,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                bottom: 2,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                left: 5,
                                                                top: 2,
                                                                bottom: 1,
                                                              ),
                                                              child: Text(
                                                                addActionsProvider
                                                                            .reminderStartTime !=
                                                                        null
                                                                    ? formatTimeOfDay(
                                                                        addActionsProvider
                                                                            .reminderStartTime!)
                                                                    : "Choose Time   ",
                                                                style: CustomTextStyles
                                                                    .bodySmallGray700,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const Text(
                                                    "To",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      addActionsProvider
                                                          .reminderEndTimeFunction(
                                                        context,
                                                      );
                                                    },
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                        left: 2,
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 11,
                                                        vertical: 8,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: theme.colorScheme
                                                            .onSecondaryContainer
                                                            .withOpacity(1),
                                                        border: Border.all(
                                                          color:
                                                              appTheme.gray700,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadiusStyle
                                                                .roundedBorder4,
                                                      ),
                                                      child: SizedBox(
                                                        width:
                                                            size.width * 0.32,
                                                        child: Row(
                                                          children: [
                                                            CustomImageView(
                                                              imagePath:
                                                                  ImageConstant
                                                                      .imgThumbsUpGray700,
                                                              height: 20,
                                                              width: 20,
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                bottom: 2,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                left: 5,
                                                                top: 2,
                                                                bottom: 1,
                                                              ),
                                                              child: Text(
                                                                addActionsProvider
                                                                            .reminderEndTime !=
                                                                        null
                                                                    ? formatTimeOfDay(
                                                                        addActionsProvider
                                                                            .reminderEndTime!)
                                                                    : "Choose Time   ",
                                                                style: CustomTextStyles
                                                                    .bodySmallGray700,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  // Column(
                                                  //   crossAxisAlignment:
                                                  //       CrossAxisAlignment
                                                  //           .start,
                                                  //   children: [
                                                  //     const Text(
                                                  //       "Remind before",
                                                  //       style: TextStyle(
                                                  //         fontWeight:
                                                  //             FontWeight.bold,
                                                  //         fontSize: 15,
                                                  //       ),
                                                  //     ),
                                                  //     const SizedBox(
                                                  //       height: 5,
                                                  //     ),
                                                  //     GestureDetector(
                                                  //       onTap: () {
                                                  //         addActionsProvider
                                                  //             .remindTimeFunction(
                                                  //           context,
                                                  //         );
                                                  //       },
                                                  //       child: Container(
                                                  //         margin:
                                                  //             const EdgeInsets
                                                  //                 .only(
                                                  //           left: 2,
                                                  //         ),
                                                  //         padding:
                                                  //             const EdgeInsets
                                                  //                 .only(
                                                  //           left: 11,
                                                  //           right: 8,
                                                  //           bottom: 6,
                                                  //           top: 6,
                                                  //         ),
                                                  //         decoration:
                                                  //             BoxDecoration(
                                                  //           color: theme
                                                  //               .colorScheme
                                                  //               .onSecondaryContainer
                                                  //               .withOpacity(
                                                  //             1,
                                                  //           ),
                                                  //           border: Border.all(
                                                  //             color: appTheme
                                                  //                 .gray700,
                                                  //             width: 1,
                                                  //           ),
                                                  //           borderRadius:
                                                  //               BorderRadiusStyle
                                                  //                   .roundedBorder4,
                                                  //         ),
                                                  //         child: SizedBox(
                                                  //           width: size.width *
                                                  //               0.32,
                                                  //           child: Row(
                                                  //             children: [
                                                  //               Padding(
                                                  //                 padding:
                                                  //                     const EdgeInsets
                                                  //                         .only(
                                                  //                   left: 3,
                                                  //                   top: 2,
                                                  //                   bottom: 1,
                                                  //                 ),
                                                  //                 child: Text(
                                                  //                   addActionsProvider.remindTime !=
                                                  //                           null
                                                  //                       ? (addActionsProvider.remindTime!.hour ==
                                                  //                               0
                                                  //                           ? '${addActionsProvider.remindTime!.minute} Minute'
                                                  //                           : '${addActionsProvider.remindTime!.hour} Hour ${addActionsProvider.remindTime!.minute} Minute')
                                                  //                       : "Choose Time",
                                                  //                   style: CustomTextStyles
                                                  //                       .bodySmallGray700,
                                                  //                 ),
                                                  //               ),
                                                  //               const Spacer(),
                                                  //               const Icon(
                                                  //                 Icons
                                                  //                     .keyboard_arrow_down_sharp,
                                                  //                 color: Colors
                                                  //                     .blue,
                                                  //               )
                                                  //             ],
                                                  //           ),
                                                  //         ),
                                                  //       ),
                                                  //     ),
                                                  //   ],
                                                  // ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        "Repeat",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          AlertDialog alert =
                                                              AlertDialog(
                                                            content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                ListTile(
                                                                  onTap: () {
                                                                    addActionsProvider
                                                                        .addRepeatValue(
                                                                      "Never",
                                                                    );
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  title:
                                                                      const Text(
                                                                    "Never",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                ListTile(
                                                                  onTap: () {
                                                                    addActionsProvider
                                                                        .addRepeatValue(
                                                                            "Daily");
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  title:
                                                                      const Text(
                                                                    "Daily",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                ListTile(
                                                                  onTap: () {
                                                                    addActionsProvider
                                                                        .addRepeatValue(
                                                                            "Weekly");
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  title:
                                                                      const Text(
                                                                    "Weekly",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                ListTile(
                                                                  onTap: () {
                                                                    addActionsProvider
                                                                        .addRepeatValue(
                                                                            "Monthly");
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  title:
                                                                      const Text(
                                                                    "Monthly",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                ListTile(
                                                                  onTap: () {
                                                                    addActionsProvider
                                                                        .addRepeatValue(
                                                                            "Yearly");
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  title:
                                                                      const Text(
                                                                    "Yearly",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return alert;
                                                            },
                                                          );
                                                        },
                                                        child: Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 2,
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 11,
                                                            right: 8,
                                                            bottom: 6,
                                                            top: 6,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: theme
                                                                .colorScheme
                                                                .onSecondaryContainer
                                                                .withOpacity(1),
                                                            border: Border.all(
                                                              color: appTheme
                                                                  .gray700,
                                                              width: 1,
                                                            ),
                                                            borderRadius:
                                                                BorderRadiusStyle
                                                                    .roundedBorder4,
                                                          ),
                                                          child: SizedBox(
                                                            width: size.width *
                                                                0.32,
                                                            child: Row(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                    left: 10,
                                                                    top: 2,
                                                                    bottom: 1,
                                                                  ),
                                                                  child: Text(
                                                                    addActionsProvider
                                                                        .repeat,
                                                                    style: CustomTextStyles
                                                                        .bodySmallGray700,
                                                                  ),
                                                                ),
                                                                const Spacer(),
                                                                const Icon(
                                                                  Icons
                                                                      .keyboard_arrow_down_sharp,
                                                                  color: Colors
                                                                      .blue,
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox(),
                                  // Row(
                                  //   children: [
                                  //     Checkbox(
                                  //       value: addActionsProvider.setRemainder,
                                  //       onChanged: (value) {
                                  //         addActionsProvider.changeSetRemainder(value!);
                                  //       },
                                  //     ),
                                  //     SizedBox(
                                  //       width: size.width * 0.01,
                                  //     ),
                                  //     const Text(
                                  //       "Set a reminder for this action",
                                  //       style: TextStyle(
                                  //         fontWeight: FontWeight.bold,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  // SizedBox(
                                  //   height: size.height * 0.02,
                                  // ),
                                  // addActionsProvider.setRemainder
                                  //     ? SizedBox(
                                  //         child: Column(
                                  //           mainAxisAlignment: MainAxisAlignment.start,
                                  //           crossAxisAlignment:
                                  //               CrossAxisAlignment.start,
                                  //           children: [
                                  //             const Text(
                                  //               "Date",
                                  //               style: TextStyle(
                                  //                   fontWeight: FontWeight.bold,
                                  //                   fontSize: 15),
                                  //             ),
                                  //             const SizedBox(
                                  //               height: 5,
                                  //             ),
                                  //             Row(
                                  //               mainAxisAlignment:
                                  //                   MainAxisAlignment.spaceBetween,
                                  //               children: [
                                  //                 GestureDetector(
                                  //                   onTap: () {
                                  //                     addActionsProvider
                                  //                         .reminderStartDateFunction(
                                  //                       context,
                                  //                     );
                                  //                   },
                                  //                   child: Container(
                                  //                     margin: const EdgeInsets.only(
                                  //                       left: 2,
                                  //                     ),
                                  //                     padding:
                                  //                         const EdgeInsets.symmetric(
                                  //                       horizontal: 11,
                                  //                       vertical: 8,
                                  //                     ),
                                  //                     decoration: BoxDecoration(
                                  //                       color: theme.colorScheme
                                  //                           .onSecondaryContainer
                                  //                           .withOpacity(1),
                                  //                       border: Border.all(
                                  //                         color: appTheme.gray700,
                                  //                         width: 1,
                                  //                       ),
                                  //                       borderRadius: BorderRadiusStyle
                                  //                           .roundedBorder4,
                                  //                     ),
                                  //                     child: SizedBox(
                                  //                       width: size.width * 0.32,
                                  //                       child: Row(
                                  //                         children: [
                                  //                           CustomImageView(
                                  //                             imagePath: ImageConstant
                                  //                                 .imgThumbsUpGray700,
                                  //                             height: 20,
                                  //                             width: 20,
                                  //                             margin:
                                  //                                 const EdgeInsets.only(
                                  //                               bottom: 2,
                                  //                             ),
                                  //                           ),
                                  //                           Padding(
                                  //                             padding:
                                  //                                 const EdgeInsets.only(
                                  //                               left: 19,
                                  //                               top: 2,
                                  //                               bottom: 1,
                                  //                             ),
                                  //                             child: Text(
                                  //                               //importent
                                  //                               addActionsProvider
                                  //                                       .reminderStartDate
                                  //                                       .isNotEmpty
                                  //                                   ? addActionsProvider
                                  //                                       .reminderStartDate
                                  //                                   : "Choose Date   ",
                                  //                               style: CustomTextStyles
                                  //                                   .bodySmallGray700,
                                  //                             ),
                                  //                           ),
                                  //                         ],
                                  //                       ),
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //                 const Text(
                                  //                   "To",
                                  //                   style: TextStyle(
                                  //                       fontWeight: FontWeight.bold),
                                  //                 ),
                                  //                 GestureDetector(
                                  //                   onTap: () {
                                  //                     addActionsProvider
                                  //                         .reminderEndDateFunction(
                                  //                       context,
                                  //                     );
                                  //                   },
                                  //                   child: Container(
                                  //                     margin: const EdgeInsets.only(
                                  //                       left: 2,
                                  //                     ),
                                  //                     padding:
                                  //                         const EdgeInsets.symmetric(
                                  //                       horizontal: 11,
                                  //                       vertical: 8,
                                  //                     ),
                                  //                     decoration: BoxDecoration(
                                  //                       color: theme.colorScheme
                                  //                           .onSecondaryContainer
                                  //                           .withOpacity(1),
                                  //                       border: Border.all(
                                  //                         color: appTheme.gray700,
                                  //                         width: 1,
                                  //                       ),
                                  //                       borderRadius: BorderRadiusStyle
                                  //                           .roundedBorder4,
                                  //                     ),
                                  //                     child: SizedBox(
                                  //                       width: size.width * 0.32,
                                  //                       child: Row(
                                  //                         children: [
                                  //                           CustomImageView(
                                  //                             imagePath: ImageConstant
                                  //                                 .imgThumbsUpGray700,
                                  //                             height: 20,
                                  //                             width: 20,
                                  //                             margin:
                                  //                                 const EdgeInsets.only(
                                  //                               bottom: 2,
                                  //                             ),
                                  //                           ),
                                  //                           Padding(
                                  //                             padding:
                                  //                                 const EdgeInsets.only(
                                  //                               left: 19,
                                  //                               top: 2,
                                  //                               bottom: 1,
                                  //                             ),
                                  //                             child: Text(
                                  //                               addActionsProvider
                                  //                                       .reminderEndDate
                                  //                                       .isNotEmpty
                                  //                                   ? addActionsProvider
                                  //                                       .reminderEndDate
                                  //                                   : "Choose Date   ",
                                  //                               style: CustomTextStyles
                                  //                                   .bodySmallGray700,
                                  //                             ),
                                  //                           ),
                                  //                         ],
                                  //                       ),
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //             const SizedBox(
                                  //               height: 5,
                                  //             ),
                                  //             const Text(
                                  //               "Time",
                                  //               style: TextStyle(
                                  //                   fontWeight: FontWeight.bold,
                                  //                   fontSize: 15),
                                  //             ),
                                  //             const SizedBox(
                                  //               height: 5,
                                  //             ),
                                  //             Row(
                                  //               mainAxisAlignment:
                                  //                   MainAxisAlignment.spaceBetween,
                                  //               children: [
                                  //                 GestureDetector(
                                  //                   onTap: () {
                                  //                     addActionsProvider
                                  //                         .reminderStartTimeFunction(
                                  //                       context,
                                  //                     );
                                  //                   },
                                  //                   child: Container(
                                  //                     margin: const EdgeInsets.only(
                                  //                       left: 2,
                                  //                     ),
                                  //                     padding:
                                  //                         const EdgeInsets.symmetric(
                                  //                       horizontal: 11,
                                  //                       vertical: 8,
                                  //                     ),
                                  //                     decoration: BoxDecoration(
                                  //                       color: theme.colorScheme
                                  //                           .onSecondaryContainer
                                  //                           .withOpacity(1),
                                  //                       border: Border.all(
                                  //                         color: appTheme.gray700,
                                  //                         width: 1,
                                  //                       ),
                                  //                       borderRadius: BorderRadiusStyle
                                  //                           .roundedBorder4,
                                  //                     ),
                                  //                     child: SizedBox(
                                  //                       width: size.width * 0.32,
                                  //                       child: Row(
                                  //                         children: [
                                  //                           CustomImageView(
                                  //                             imagePath: ImageConstant
                                  //                                 .imgThumbsUpGray700,
                                  //                             height: 20,
                                  //                             width: 20,
                                  //                             margin:
                                  //                                 const EdgeInsets.only(
                                  //                               bottom: 2,
                                  //                             ),
                                  //                           ),
                                  //                           Padding(
                                  //                             padding:
                                  //                                 const EdgeInsets.only(
                                  //                               left: 19,
                                  //                               top: 2,
                                  //                               bottom: 1,
                                  //                             ),
                                  //                             child: Text(
                                  //                               addActionsProvider
                                  //                                           .reminderStartTime !=
                                  //                                       null
                                  //                                   ? formatTimeOfDay(
                                  //                                       addActionsProvider
                                  //                                           .reminderStartTime!)
                                  //                                   : "Choose Time   ",
                                  //                               style: CustomTextStyles
                                  //                                   .bodySmallGray700,
                                  //                             ),
                                  //                           ),
                                  //                         ],
                                  //                       ),
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //                 const Text(
                                  //                   "To",
                                  //                   style: TextStyle(
                                  //                       fontWeight: FontWeight.bold),
                                  //                 ),
                                  //                 GestureDetector(
                                  //                   onTap: () {
                                  //                     addActionsProvider
                                  //                         .reminderEndTimeFunction(
                                  //                       context,
                                  //                     );
                                  //                   },
                                  //                   child: Container(
                                  //                     margin: const EdgeInsets.only(
                                  //                       left: 2,
                                  //                     ),
                                  //                     padding:
                                  //                         const EdgeInsets.symmetric(
                                  //                       horizontal: 11,
                                  //                       vertical: 8,
                                  //                     ),
                                  //                     decoration: BoxDecoration(
                                  //                       color: theme.colorScheme
                                  //                           .onSecondaryContainer
                                  //                           .withOpacity(1),
                                  //                       border: Border.all(
                                  //                         color: appTheme.gray700,
                                  //                         width: 1,
                                  //                       ),
                                  //                       borderRadius: BorderRadiusStyle
                                  //                           .roundedBorder4,
                                  //                     ),
                                  //                     child: SizedBox(
                                  //                       width: size.width * 0.32,
                                  //                       child: Row(
                                  //                         children: [
                                  //                           CustomImageView(
                                  //                             imagePath: ImageConstant
                                  //                                 .imgThumbsUpGray700,
                                  //                             height: 20,
                                  //                             width: 20,
                                  //                             margin:
                                  //                                 const EdgeInsets.only(
                                  //                               bottom: 2,
                                  //                             ),
                                  //                           ),
                                  //                           Padding(
                                  //                             padding:
                                  //                                 const EdgeInsets.only(
                                  //                               left: 19,
                                  //                               top: 2,
                                  //                               bottom: 1,
                                  //                             ),
                                  //                             child: Text(
                                  //                               addActionsProvider
                                  //                                           .reminderEndTime !=
                                  //                                       null
                                  //                                   ? formatTimeOfDay(
                                  //                                       addActionsProvider
                                  //                                           .reminderEndTime!)
                                  //                                   : "Choose Time   ",
                                  //                               style: CustomTextStyles
                                  //                                   .bodySmallGray700,
                                  //                             ),
                                  //                           ),
                                  //                         ],
                                  //                       ),
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //             const SizedBox(
                                  //               height: 5,
                                  //             ),
                                  //             Row(
                                  //               mainAxisAlignment:
                                  //                   MainAxisAlignment.spaceBetween,
                                  //               children: [
                                  //                 Column(
                                  //                   crossAxisAlignment:
                                  //                       CrossAxisAlignment.start,
                                  //                   children: [
                                  //                     const Text(
                                  //                       "Remind before",
                                  //                       style: TextStyle(
                                  //                         fontWeight: FontWeight.bold,
                                  //                         fontSize: 15,
                                  //                       ),
                                  //                     ),
                                  //                     const SizedBox(
                                  //                       height: 5,
                                  //                     ),
                                  //                     GestureDetector(
                                  //                       onTap: () {
                                  //                         addActionsProvider
                                  //                             .remindTimeFunction(
                                  //                           context,
                                  //                         );
                                  //                       },
                                  //                       child: Container(
                                  //                         margin: const EdgeInsets.only(
                                  //                           left: 2,
                                  //                         ),
                                  //                         padding:
                                  //                             const EdgeInsets.only(
                                  //                           left: 11,
                                  //                           right: 8,
                                  //                           bottom: 6,
                                  //                           top: 6,
                                  //                         ),
                                  //                         decoration: BoxDecoration(
                                  //                           color: theme.colorScheme
                                  //                               .onSecondaryContainer
                                  //                               .withOpacity(
                                  //                             1,
                                  //                           ),
                                  //                           border: Border.all(
                                  //                             color: appTheme.gray700,
                                  //                             width: 1,
                                  //                           ),
                                  //                           borderRadius:
                                  //                               BorderRadiusStyle
                                  //                                   .roundedBorder4,
                                  //                         ),
                                  //                         child: SizedBox(
                                  //                           width: size.width * 0.32,
                                  //                           child: Row(
                                  //                             children: [
                                  //                               Padding(
                                  //                                 padding:
                                  //                                     const EdgeInsets
                                  //                                         .only(
                                  //                                   left: 3,
                                  //                                   top: 2,
                                  //                                   bottom: 1,
                                  //                                 ),
                                  //                                 child: Text(
                                  //                                   addActionsProvider
                                  //                                               .remindTime !=
                                  //                                           null
                                  //                                       ?
                                  //                                       // formatTimeOfDay(
                                  //                                       //         addActionsProvider
                                  //                                       //             .reminderEndTime!)
                                  //                                       addActionsProvider
                                  //                                                   .remindTime!
                                  //                                                   .hour <=
                                  //                                               0
                                  //                                           ? '${addActionsProvider.remindTime!.minute} Minute'
                                  //                                           : '${addActionsProvider.remindTime!.hour} Hour ${addActionsProvider.remindTime!.minute} Minut'
                                  //                                       : "Choose Time   ",
                                  //                                   style: CustomTextStyles
                                  //                                       .bodySmallGray700,
                                  //                                 ),
                                  //                               ),
                                  //                               const Spacer(),
                                  //                               const Icon(
                                  //                                 Icons
                                  //                                     .keyboard_arrow_down_sharp,
                                  //                                 color: Colors.blue,
                                  //                               )
                                  //                             ],
                                  //                           ),
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                   ],
                                  //                 ),
                                  //                 Column(
                                  //                   crossAxisAlignment:
                                  //                       CrossAxisAlignment.start,
                                  //                   children: [
                                  //                     const Text(
                                  //                       "Repeat",
                                  //                       style: TextStyle(
                                  //                         fontWeight: FontWeight.bold,
                                  //                         fontSize: 15,
                                  //                       ),
                                  //                     ),
                                  //                     const SizedBox(
                                  //                       height: 5,
                                  //                     ),
                                  //                     GestureDetector(
                                  //                       onTap: () {
                                  //                         AlertDialog alert =
                                  //                             AlertDialog(
                                  //                           content: Column(
                                  //                             mainAxisSize:
                                  //                                 MainAxisSize.min,
                                  //                             children: [
                                  //                               ListTile(
                                  //                                 onTap: () {
                                  //                                   addActionsProvider
                                  //                                       .addRepeatValue(
                                  //                                     "Never",
                                  //                                   );
                                  //                                   Navigator.of(
                                  //                                           context)
                                  //                                       .pop();
                                  //                                 },
                                  //                                 title: const Text(
                                  //                                   "Never",
                                  //                                   style: TextStyle(
                                  //                                     fontSize: 16,
                                  //                                     fontWeight:
                                  //                                         FontWeight
                                  //                                             .bold,
                                  //                                   ),
                                  //                                 ),
                                  //                               ),
                                  //                               ListTile(
                                  //                                 onTap: () {
                                  //                                   addActionsProvider
                                  //                                       .addRepeatValue(
                                  //                                           "Daily");
                                  //                                   Navigator.of(
                                  //                                           context)
                                  //                                       .pop();
                                  //                                 },
                                  //                                 title: const Text(
                                  //                                   "Daily",
                                  //                                   style: TextStyle(
                                  //                                     fontSize: 16,
                                  //                                     fontWeight:
                                  //                                         FontWeight
                                  //                                             .bold,
                                  //                                   ),
                                  //                                 ),
                                  //                               ),
                                  //                               ListTile(
                                  //                                 onTap: () {
                                  //                                   addActionsProvider
                                  //                                       .addRepeatValue(
                                  //                                           "Weekly");
                                  //                                   Navigator.of(
                                  //                                           context)
                                  //                                       .pop();
                                  //                                 },
                                  //                                 title: const Text(
                                  //                                   "Weekly",
                                  //                                   style: TextStyle(
                                  //                                     fontSize: 16,
                                  //                                     fontWeight:
                                  //                                         FontWeight
                                  //                                             .bold,
                                  //                                   ),
                                  //                                 ),
                                  //                               ),
                                  //                               ListTile(
                                  //                                 onTap: () {
                                  //                                   addActionsProvider
                                  //                                       .addRepeatValue(
                                  //                                           "Monthly");
                                  //                                   Navigator.of(
                                  //                                           context)
                                  //                                       .pop();
                                  //                                 },
                                  //                                 title: const Text(
                                  //                                   "Monthly",
                                  //                                   style: TextStyle(
                                  //                                     fontSize: 16,
                                  //                                     fontWeight:
                                  //                                         FontWeight
                                  //                                             .bold,
                                  //                                   ),
                                  //                                 ),
                                  //                               ),
                                  //                               ListTile(
                                  //                                 onTap: () {
                                  //                                   addActionsProvider
                                  //                                       .addRepeatValue(
                                  //                                           "Yearly");
                                  //                                   Navigator.of(
                                  //                                           context)
                                  //                                       .pop();
                                  //                                 },
                                  //                                 title: const Text(
                                  //                                   "Yearly",
                                  //                                   style: TextStyle(
                                  //                                     fontSize: 16,
                                  //                                     fontWeight:
                                  //                                         FontWeight
                                  //                                             .bold,
                                  //                                   ),
                                  //                                 ),
                                  //                               ),
                                  //                             ],
                                  //                           ),
                                  //                         );
                                  //                         showDialog(
                                  //                           context: context,
                                  //                           builder:
                                  //                               (BuildContext context) {
                                  //                             return alert;
                                  //                           },
                                  //                         );
                                  //                       },
                                  //                       child: Container(
                                  //                         margin: const EdgeInsets.only(
                                  //                           left: 2,
                                  //                         ),
                                  //                         padding:
                                  //                             const EdgeInsets.only(
                                  //                           left: 11,
                                  //                           right: 8,
                                  //                           bottom: 6,
                                  //                           top: 6,
                                  //                         ),
                                  //                         decoration: BoxDecoration(
                                  //                           color: theme.colorScheme
                                  //                               .onSecondaryContainer
                                  //                               .withOpacity(1),
                                  //                           border: Border.all(
                                  //                             color: appTheme.gray700,
                                  //                             width: 1,
                                  //                           ),
                                  //                           borderRadius:
                                  //                               BorderRadiusStyle
                                  //                                   .roundedBorder4,
                                  //                         ),
                                  //                         child: SizedBox(
                                  //                           width: size.width * 0.32,
                                  //                           child: Row(
                                  //                             children: [
                                  //                               Padding(
                                  //                                 padding:
                                  //                                     const EdgeInsets
                                  //                                         .only(
                                  //                                   left: 10,
                                  //                                   top: 2,
                                  //                                   bottom: 1,
                                  //                                 ),
                                  //                                 child: Text(
                                  //                                   addActionsProvider
                                  //                                           .repeat ??
                                  //                                       "Choose Time   ",
                                  //                                   style: CustomTextStyles
                                  //                                       .bodySmallGray700,
                                  //                                 ),
                                  //                               ),
                                  //                               const Spacer(),
                                  //                               const Icon(
                                  //                                 Icons
                                  //                                     .keyboard_arrow_down_sharp,
                                  //                                 color: Colors.blue,
                                  //                               )
                                  //                             ],
                                  //                           ),
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                   ],
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //           ],
                                  //         ),
                                  //       )
                                  //     : const SizedBox(),
                                ],
                              );
                            }),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: _buildSaveButton(
                              context,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : const TokenExpireScreen());
  }

  Widget _buildTitleEditText(BuildContext context) {
    return Consumer<AddActionsProvider>(
        builder: (context, addActionsProvider, _) {
      return CustomTextFormField(
        controller: addActionsProvider.titleEditTextController,
        hintText: "Title",
        hintStyle: CustomTextStyles.bodySmallGray700,
      );
    });
  }

  /// Section Widget
  Widget _buildDescriptionEditText(BuildContext context) {
    return Consumer<AddActionsProvider>(
        builder: (context, addActionsProvider, _) {
      return CustomTextFormField(
        controller: addActionsProvider.descriptionEditTextController,
        hintText: "Description",
        hintStyle: CustomTextStyles.bodySmallGray700,
        textInputAction: TextInputAction.done,
        maxLines: 4,
      );
    });
  }

  /// Section Widget
  Widget _buildSaveButton(BuildContext context) {
    return Consumer2<AddActionsProvider, AdDreamsGoalsProvider>(
        builder: (context, addActionsProvider, adDreamsGoalsProvider, _) {
      return CustomElevatedButton(
        loading: addActionsProvider.saveAddActionsLoading,
        onPressed: () async {
          if (!addActionsProvider.isVideoUploading) {
            if (addActionsProvider.titleEditTextController.text.isNotEmpty &&
                addActionsProvider.descriptionEditTextController.text.isNotEmpty &&
                (addActionsProvider.setRemainder
                    ? addActionsProvider.reminderStartDate.isNotEmpty &&
                    addActionsProvider.reminderEndDate.isNotEmpty &&
                    addActionsProvider.reminderStartTime != null &&
                    addActionsProvider.reminderEndTime != null &&
                    addActionsProvider.repeat.isNotEmpty
                    : true)) {
              if (addActionsProvider.setRemainder) {
                await addActionsProvider.editActionFunction(context,
                    title: addActionsProvider.titleEditTextController.text,
                    details: addActionsProvider.descriptionEditTextController.text,
                    mediaName: addActionsProvider.addMediaUploadResponseList,
                    locationName: addActionsProvider.selectedLocationName,
                    locationLatitude: addActionsProvider.selectedLatitude,
                    locationLongitude: addActionsProvider.locationLongitude,
                    locationAddress: addActionsProvider.selectedLocationAddress,
                    actionId: widget.actionsDetailsModel!.actions!.actionId.toString(),
                    goalId: widget.actionsDetailsModel!.actions?.goalId ?? "",
                    isReminder: "1");
              } else {
                await addActionsProvider.editActionFunction(context,
                    title: addActionsProvider.titleEditTextController.text,
                    details: addActionsProvider.descriptionEditTextController.text,
                    mediaName: addActionsProvider.addMediaUploadResponseList,
                    locationName: addActionsProvider.selectedLocationName,
                    locationLatitude: addActionsProvider.selectedLatitude,
                    locationLongitude: addActionsProvider.locationLongitude,
                    locationAddress: addActionsProvider.selectedLocationAddress,
                    actionId: widget.actionsDetailsModel!.actions!.actionId.toString(),
                    goalId: widget.actionsDetailsModel!.actions?.goalId ?? "",
                    isReminder: "0");
              }

              mentalStrengthEditProvider.fetchGoalActions(goalId: widget.actionsDetailsModel!.actions!.goalId ?? "",);

              // adDreamsGoalsProvider.getAddActionIdAndName(
              //   value: addActionsProvider.goalModelIdName!,
              // );

              addActionsProvider.clearFunction();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
             // Navigator.of(context).pop();
            } else {
              showCustomSnackBar(
                context: context,
                message: "Please fill in all the fields",
              );
            }

          } else {
            showCustomSnackBar(
              context: context,
              message: "Please wait video is uploading",
            );
          }
        },
        height: 40,
        text: "Update",
        buttonStyle: CustomButtonStyles.outlinePrimaryTL5,
        buttonTextStyle:
            CustomTextStyles.titleSmallHelveticaOnSecondaryContainer,
      );
    });
  }

  Widget _buildAddMediaColumn(BuildContext context, Size size) {
    return Consumer<AddActionsProvider>(
        builder: (context, addActionsProvider, _) {
      return Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add Media",
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(
              height: 11,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: size.height * 0.09,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          addActionsProvider.selectedMedia(0);
                          await audioBottomSheetAction(
                            context: context,
                            title: 'Record Audio',
                          );
                          // }
                        },
                        child: Container(
                          height: size.height * 0.08,
                          width: size.height * 0.08,
                          decoration: BoxDecoration(
                            color: addActionsProvider.mediaSelected == 0
                                ? Colors.blue
                                : Colors.transparent,
                            image: DecorationImage(
                              image: AssetImage(ImageConstant.imgMenu),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(
                                50.0,
                              ),
                            ),
                            border: Border.all(
                              color: appTheme.blue300,
                              width: 1.0,
                            ),
                          ),
                          child: CustomIconButton(
                              height: size.height * 0.08,
                              width: size.height * 0.08,
                              padding: const EdgeInsets.all(18),
                              child: Icon(
                                Icons.mic,
                                size: 30,
                                color: addActionsProvider.mediaSelected == 0
                                    ? Colors.white
                                    : Colors.blue,
                              )),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 10,
                        right: 10,
                        child: Consumer<AddActionsProvider>(
                            builder: (context, addActionsProvider, _) {
                          if (addActionsProvider.recordedFilePath.isEmpty &&
                              addActionsProvider
                                  .alreadyRecordedFilePath.isEmpty) {
                            return const SizedBox();
                          } else {
                            return Container(
                              width: size.height * 0.04,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                  image: AssetImage(ImageConstant.imgMenu),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(
                                    50.0,
                                  ),
                                ),
                                border: Border.all(
                                  color: appTheme.blue300,
                                  width: 2.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "${addActionsProvider.recordedFilePath.length + addActionsProvider.alreadyRecordedFilePath.length}",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                      )
                    ],
                  ),
                ),
                // const AudioRecorderMentalStrengthBuild(),
                SizedBox(
                  height: size.height * 0.09,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          addActionsProvider.selectedMedia(1);
                          await galleryBottomSheetAction(
                            context: context,
                            title: 'Gallery',
                          );
                        },
                        child: buildAvatarImage(
                          widget: Icon(
                            Icons.image,
                            size: 30,
                            color: addActionsProvider.mediaSelected == 1
                                ? Colors.white
                                : Colors.blue,
                          ),
                          imagePath: ImageConstant.imgThumbsUp,
                          size: size,
                          isSelected: addActionsProvider.mediaSelected == 1
                              ? true
                              : false,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 10,
                        right: 10,
                        child: Consumer<AddActionsProvider>(
                            builder: (context, addActionsProvider, _) {
                          if (addActionsProvider.alreadyPickedImages.isEmpty &&
                              addActionsProvider.pickedImages.isEmpty) {
                            return const SizedBox();
                          } else {
                            return Container(
                              width: size.height * 0.04,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                  image: AssetImage(ImageConstant.imgMenu),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(
                                    50.0,
                                  ),
                                ),
                                border: Border.all(
                                  color: appTheme.blue300,
                                  width: 2.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "${addActionsProvider.pickedImages.length + addActionsProvider.alreadyPickedImages.length}"
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.09,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          addActionsProvider.selectedMedia(2);
                          cameraBottomSheetAction(
                            context: context,
                            title: "Camera",
                          );
                        },
                        child: buildAvatarImage(
                          widget: Icon(
                            Icons.camera_alt_outlined,
                            size: 30,
                            color: addActionsProvider.mediaSelected == 2
                                ? Colors.white
                                : Colors.blue,
                          ),
                          imagePath: ImageConstant.imgCamera,
                          size: size,
                          isSelected: addActionsProvider.mediaSelected == 2
                              ? true
                              : false,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 10,
                        right: 10,
                        child: Consumer<AddActionsProvider>(
                            builder: (context, addActionsProvider, _) {
                          if (addActionsProvider.takedImages.isEmpty) {
                            return const SizedBox();
                          } else {
                            return Container(
                              width: size.height * 0.04,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                  image: AssetImage(ImageConstant.imgMenu),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(
                                    50.0,
                                  ),
                                ),
                                border: Border.all(
                                  color: appTheme.blue300,
                                  width: 2.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  addActionsProvider.takedImages.length
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.09,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _checkPermissionStatus();
                          _requestPermissions();
                          addActionsProvider.selectedMedia(
                            3,
                          );
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                child: const AddActionGoogleMap(),
                              );
                            },
                          );
                        },
                        child: buildAvatarImage(
                          widget: Icon(
                            Icons.location_on,
                            size: 30,
                            color: addActionsProvider.mediaSelected == 3
                                ? Colors.white
                                : Colors.blue,
                          ),
                          imagePath: ImageConstant.imgLinkedin,
                          size: size,
                          // wi
                          isSelected: addActionsProvider.mediaSelected == 3
                              ? true
                              : false,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 10,
                        right: 10,
                        child: Consumer<AddActionsProvider>(
                            builder: (context, addActionsProvider, _) {
                          if (addActionsProvider.selectedLocationName.isEmpty) {
                            return const SizedBox();
                          } else {
                            return Container(
                              width: size.height * 0.04,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                  image: AssetImage(ImageConstant.imgMenu),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(
                                    50.0,
                                  ),
                                ),
                                border: Border.all(
                                  color: appTheme.blue300,
                                  width: 2.0,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "1",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  PreferredSizeWidget buildAppBarActions(BuildContext context, Size size,
      {String? heading}) {
    return CustomAppBar(
      leadingWidth: 36,
      leading: AppbarLeadingImage(
        onTap: () {
          AddActionsProvider addActionsProvider =
              Provider.of(context, listen: false);
          addActionsProvider.clearFunction();
          Navigator.of(context).pop();
        },
        imagePath: ImageConstant.imgTelevision,
        margin: const EdgeInsets.only(
          left: 20,
          top: 19,
          bottom: 23,
        ),
      ),
      title: AppbarSubtitle(
        text: heading ?? "My profile",
        margin: const EdgeInsets.only(
          left: 11,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(
            right: size.width * 0.07,
          ),
          child: CircleAvatar(
            radius: size.width * 0.04,
            backgroundColor: PrimaryColors().blue300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: size.height * 0.003,
                  width: size.width * 0.03,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.005,
                ),
                Container(
                  height: size.height * 0.003,
                  width: size.width * 0.03,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
