import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
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
import 'package:mentalhelth/utils/theme/colors.dart';
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

import '../../../../utils/logic/permissions.dart';
import '../../../addactions_screen/model/alaram_info.dart';
import '../../../dash_borad_screen/provider/dash_board_provider.dart';
import '../../../edit_add_profile_screen/provider/edit_provider.dart';
import '../../../home_screen/provider/home_provider.dart';
import '../../../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../../../no_internet/duplicate_screen.dart';
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
  late FocusNode _descriptionFocusNode;
  late FocusNode _titleFocusNode;

  @override
  void initState() {
    _descriptionFocusNode = FocusNode();
    _titleFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _descriptionFocusNode.unfocus();
      _titleFocusNode.unfocus();// Ensure it does not get focus automatically
    });
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    mentalStrengthEditProvider =
        Provider.of<MentalStrengthEditProvider>(context, listen: false);
    dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
    editProfileProvider =
        Provider.of<EditProfileProvider>(context, listen: false);
    addActionsProvider =
        Provider.of<AddActionsProvider>(context, listen: false);
    addActionsProvider.editDetectedLinks.clear();
    logger.w(
        "addActionsProvider.reminderStartDate${addActionsProvider.reminderStartDate}");
    alarmDetails();
    _isTokenExpired();
    init();



    super.initState();
  }

  Future<void> _isTokenExpired() async {
   // await homeProvider.fetchChartView(context);
    await homeProvider.fetchJournals(initial: true,context: context);
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
      await Permission.manageExternalStorage
          .request(); // For Android 11 and above
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
    logger.i("addActionsProvider.reminderStartTime${addActionsProvider.reminderStartTime}");
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
      addActionsProvider.selectedLongitude =
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
    if(addActionsProvider.reminderStartTime != null){
      addActionsProvider.setRemainder = true;
    }else{
      addActionsProvider.setRemainder = false;
    }

    logger.i("addActionsProvider.reminderEndDate${addActionsProvider.reminderEndDate}");
    logger.i("addActionsProvider.reminderEndDate${addActionsProvider.reminderStartDate}");
  }


  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
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
            ? ConnectivityWidget(
              child: SafeArea(
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
                        color: ColorsContent.homeBackGroundColor
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
                                    SizedBox(height: size.height * 0.03),
                                    Row(
                                      children: [
                                        Checkbox(
                                          side:  BorderSide(color: ColorsContent.locationCountColor, width: 2), // Change border color
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
                                            fontFamily: 'Poppins',
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
                                                      fontFamily: 'Poppins',
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
                                                                imagePath: ImageConstant
                                                                    .actionDatePickerNumu,
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
                                                                  (addActionsProvider.reminderStartDate.isNotEmpty &&
                                                                      addActionsProvider.reminderStartDate != "Invalid date")
                                                                      ? addActionsProvider.reminderStartDate
                                                                      : "Choose Date",
                                                                  style: CustomTextStyles.bodySmallGray700,
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
                                                                imagePath: ImageConstant
                                                                    .actionDatePickerNumu,
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
                                                                  (addActionsProvider.reminderEndDate.isNotEmpty &&
                                                                      addActionsProvider.reminderEndDate != "Invalid date")
                                                                      ? addActionsProvider.reminderEndDate
                                                                      : "Choose Date",
                                                                  style: CustomTextStyles.bodySmallGray700,
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
                                                      fontFamily: 'Poppins',
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
                                                                imagePath: ImageConstant
                                                                    .actionDatePickerNumu,
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
                                                          fontFamily: 'Poppins',
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
                                                                imagePath: ImageConstant
                                                                    .actionDatePickerNumu,
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
                                                            fontFamily: 'Poppins',
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
                                                                   Icon(
                                                                    Icons
                                                                        .arrow_drop_down_sharp,
                                                                    color: ColorsContent.newThemeColor,
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
                ),
            )
            : const TokenExpireScreen());
  }

  Widget _buildTitleEditText(BuildContext context) {
    return Consumer<AddActionsProvider>(
        builder: (context, addActionsProvider, _) {
      return CustomTextFormFieldNumu(
        controller: addActionsProvider.titleEditTextController,
        hintText: _titleFocusNode.hasFocus ? '' : "Title",
        hintStyle: CustomTextStyles.bodySmallGray700,
        textInputAction: TextInputAction.done,
        maxLines: 1,
        focusNode: _titleFocusNode,
        onTap: () => setState(() {}),
        // Rebuild when tapped
        onEditingComplete: () {
          _titleFocusNode.unfocus(); // Ensure focus is removed when done
          setState(() {});
        }, // Rebuild when focus is lost
      );
    });
  }

  /// Section Widget
  /// Section Widget
  Widget _buildDescriptionEditText(BuildContext context) {
    return Consumer<AddActionsProvider>(
        builder: (context, addActionsProvider, _) {
          final previewLink = widget.actionsDetailsModel!.actions!.preview_link.toString().trim() ?? "";

          // ✅ Initialize backend link ONLY on first load
          if (previewLink.isNotEmpty &&
              addActionsProvider.editDetectedLinks.isEmpty &&
              !addActionsProvider.hasUserClearedLink) {
            addActionsProvider.editDetectedLinks = [previewLink];
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📝 Text field shown only when no preview
                if (addActionsProvider.editDetectedLinks.isEmpty)
                  CustomTextFormFieldNumu(
                    controller: addActionsProvider.descriptionEditTextController,
                    hintText: _descriptionFocusNode.hasFocus ? '' : "Description",
                    hintStyle: CustomTextStyles.bodySmallGray700,
                    textInputAction: TextInputAction.newline,
                    textInputType: TextInputType.multiline,
                    maxLines: 4,
                    focusNode: _descriptionFocusNode,
                    borderDecoration: InputBorder.none,
                    textAlign: TextAlign.start,
                    onTap: () => setState(() {}),
                    onEditingComplete: () {
                      _descriptionFocusNode.unfocus();
                      setState(() {});
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[\u0000-\uFFFF]'),
                      ),
                    ],
                    onChanged: (text) {
                      // ✅ Detect new link
                      final matches = addActionsProvider.editUrlRegex
                          .allMatches(text)
                          .map((m) => m.group(0)!)
                          .toList();

                      if (matches.isNotEmpty) {
                        addActionsProvider.editDetectedLinks = [matches.first];
                        addActionsProvider.hasUserClearedLink = false;
                        addActionsProvider.descriptionEditTextController.clear();
                        setState(() {});
                      }
                    },
                  ),

                // 🔗 Link preview (either backend or user-pasted)
                if (addActionsProvider.editDetectedLinks.isNotEmpty)
                  ...addActionsProvider.editDetectedLinks.map((link) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinkPreviewGenerator(
                                link: link,
                                linkPreviewStyle: LinkPreviewStyle.small,
                                showDomain: true,
                                showTitle: true,
                                bodyMaxLines: 1,
                                borderRadius: 10,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ❌ Close icon - FIXED
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () {
                                logger.i(
                                    "addActionsProvider.editDetectedLinks before clear: ${addActionsProvider.editDetectedLinks}");

                                // ✅ Mark that user cleared the link
                                addActionsProvider.hasUserClearedLink = true;
                                addActionsProvider.editDetectedLinks = [];
                                addActionsProvider.descriptionEditTextController.clear();
                                setState(() {});
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black54,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
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
                // addActionsProvider
                //     .descriptionEditTextController.text.isNotEmpty &&
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
                    details:
                        addActionsProvider.descriptionEditTextController.text,
                    mediaName: addActionsProvider.addMediaUploadResponseList,
                    locationName: addActionsProvider.selectedLocationName,
                    locationLatitude: addActionsProvider.selectedLatitude,
                    locationLongitude: addActionsProvider.selectedLongitude,
                    locationAddress: addActionsProvider.selectedLocationAddress,
                    actionId: widget.actionsDetailsModel!.actions!.actionId
                        .toString(),
                    goalId: widget.actionsDetailsModel!.actions?.goalId ?? "",
                    mediaThumbs: addActionsProvider.mediaThumbList, // ✅ pass here
                    isReminder: "1",
                  editDetectedLinks: addActionsProvider.editDetectedLinks,
                );
              } else {
                await addActionsProvider.editActionFunction(context,
                    title: addActionsProvider.titleEditTextController.text,
                    details:
                        addActionsProvider.descriptionEditTextController.text,
                    mediaName: addActionsProvider.addMediaUploadResponseList,
                    locationName: addActionsProvider.selectedLocationName,
                    locationLatitude: addActionsProvider.selectedLatitude,
                    locationLongitude: addActionsProvider.selectedLongitude,
                    locationAddress: addActionsProvider.selectedLocationAddress,
                    actionId: widget.actionsDetailsModel!.actions!.actionId
                        .toString(),
                    goalId: widget.actionsDetailsModel!.actions?.goalId ?? "",
                    mediaThumbs: addActionsProvider.mediaThumbList, // ✅ pass here
                    isReminder: "0",
                  editDetectedLinks: addActionsProvider.editDetectedLinks,
                );
              }

              mentalStrengthEditProvider.fetchGoalActions(
                goalId: widget.actionsDetailsModel!.actions!.goalId ?? "",
              );

              // adDreamsGoalsProvider.getAddActionIdAndName(
              //   value: addActionsProvider.goalModelIdName!,
              // );
               Navigator.of(context).pop();
              // Navigator.of(context).pop();
              addActionsProvider.clearFunction();

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
        height: 45,
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
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (await requestGalleryPermission() && Platform.isAndroid) {
                            addActionsProvider.selectedMedia(1);
                            await galleryBottomSheetAction(
                              context: context,
                              title: 'Gallery',
                            );
                          } else if(Platform.isIOS) {
                            addActionsProvider.selectedMedia(1);
                            await galleryBottomSheetAction(
                              context: context,
                              title: 'Gallery',
                            );
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                  Text("Gallery permission is required.")),
                            );
                          }

                        },
                        child: SvgPicture.asset(
                          ImageConstant
                              .galleryAddMediaNumu, // Replace with your SVG asset path
                        ),
                      ),

                      Positioned(
                        bottom: Platform.isIOS ? 50 : 45, // Adjust this value as needed
                        right: 0, // Move to the right
                        left: 40,
                        child: Consumer<AddActionsProvider>(
                          builder: (context, addActionsProvider, _) {
                            if (addActionsProvider.alreadyPickedImages.isEmpty &&
                                addActionsProvider.pickedImages.isEmpty) {
                              return const SizedBox();
                            } else {
                              return Container(
                                width: size.height * 0.04,
                                // Set width
                                height: size.height * 0.04,
                                // Set height same as width to make it a circle
                                decoration: BoxDecoration(
                                  color: ColorsContent.galleryCountColor,
                                  shape: BoxShape.circle,
                                  // Ensures the container is circular
                                  image: DecorationImage(
                                    image: AssetImage(ImageConstant.imgMenu),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "${addActionsProvider.pickedImages.length + addActionsProvider.alreadyPickedImages.length}"
                                        .toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      )

                      // Positioned(
                      //   bottom: 0,
                      //   left: 10,
                      //   right: 10,
                      //   child: Consumer<AddActionsProvider>(
                      //       builder: (context, addActionsProvider, _) {
                      //     if (addActionsProvider.alreadyPickedImages.isEmpty &&
                      //         addActionsProvider.pickedImages.isEmpty) {
                      //       return const SizedBox();
                      //     } else {
                      //       return Container(
                      //         width: size.height * 0.04,
                      //         decoration: BoxDecoration(
                      //           color: Colors.white,
                      //           image: DecorationImage(
                      //             image: AssetImage(ImageConstant.imgMenu),
                      //             fit: BoxFit.cover,
                      //           ),
                      //           borderRadius: const BorderRadius.all(
                      //             Radius.circular(
                      //               50.0,
                      //             ),
                      //           ),
                      //           border: Border.all(
                      //             color: appTheme.blue300,
                      //             width: 2.0,
                      //           ),
                      //         ),
                      //         child: Center(
                      //           child: Text(
                      //             "${addActionsProvider.pickedImages.length + addActionsProvider.alreadyPickedImages.length}"
                      //                 .toString(),
                      //             style: const TextStyle(
                      //               color: Colors.blue,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //         ),
                      //       );
                      //     }
                      //   }),
                      // )
                    ],
                  ),
                ),

                SizedBox(
                  height: size.height * 0.09,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          if (await requestGalleryPermission() && Platform.isAndroid) {
                            addActionsProvider.selectedMedia(2);
                            cameraBottomSheetAction(
                              context: context,
                              title: "Camera",
                            );
                          } else if(Platform.isIOS) {
                            addActionsProvider.selectedMedia(2);
                            cameraBottomSheetAction(
                              context: context,
                              title: "Camera",
                            );

                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                  Text("Camera permission is required.")),
                            );
                          }
                        },
                        child: SvgPicture.asset(
                          ImageConstant
                              .cameraAddMediaNumu, // Replace with your SVG asset path
                        ),
                      ),

                      Positioned(
                        bottom: Platform.isIOS ? 50 : 45, // Adjust this value as needed
                        right: 0, // Move to the right
                        left: 40,
                        child: Consumer<AddActionsProvider>(
                          builder: (context, addActionsProvider, _) {
                            if (addActionsProvider.takedImages.isEmpty) {
                              return const SizedBox();
                            } else {
                              return Container(
                                width: size.height * 0.04,
                                // Ensure width
                                height: size.height * 0.04,
                                // Ensure height matches width for a circle
                                decoration: BoxDecoration(
                                  color: ColorsContent.cameraCountColor,
                                  shape: BoxShape.circle,
                                  // This makes it perfectly round
                                  image: DecorationImage(
                                    image: AssetImage(ImageConstant.imgMenu),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    addActionsProvider.takedImages.length
                                        .toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      )

                      // Positioned(
                      //   bottom: 0,
                      //   left: 10,
                      //   right: 10,
                      //   child: Consumer<AddActionsProvider>(
                      //       builder: (context, addActionsProvider, _) {
                      //     if (addActionsProvider.takedImages.isEmpty) {
                      //       return const SizedBox();
                      //     } else {
                      //       return Container(
                      //         width: size.height * 0.04,
                      //         decoration: BoxDecoration(
                      //           color: Colors.white,
                      //           image: DecorationImage(
                      //             image: AssetImage(ImageConstant.imgMenu),
                      //             fit: BoxFit.cover,
                      //           ),
                      //           borderRadius: const BorderRadius.all(
                      //             Radius.circular(
                      //               50.0,
                      //             ),
                      //           ),
                      //           border: Border.all(
                      //             color: appTheme.blue300,
                      //             width: 2.0,
                      //           ),
                      //         ),
                      //         child: Center(
                      //           child: Text(
                      //             addActionsProvider.takedImages.length
                      //                 .toString(),
                      //             style: const TextStyle(
                      //               color: Colors.blue,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //         ),
                      //       );
                      //     }
                      //   }),
                      // )
                    ],
                  ),
                ),

                SizedBox(
                  height: size.height * 0.09,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          addActionsProvider.selectedMedia(0);
                          await audioBottomSheetAction(
                            context: context,
                            title: 'Record Audio',
                          );
                          // }
                        },
                        child: SvgPicture.asset(
                          ImageConstant
                              .recordAddMediaNumu, // Replace with your SVG asset path
                        ),
                      ),
                      Positioned(
                        bottom: Platform.isIOS ? 50 : 45, // Adjust this value as needed
                        right: 0, // Move to the right
                        left: 40,
                        child: Consumer<AddActionsProvider>(
                          builder: (context, addActionsProvider, _) {
                            if (addActionsProvider.recordedFilePath.isEmpty &&
                                addActionsProvider
                                    .alreadyRecordedFilePath.isEmpty) {
                              return const SizedBox();
                            } else {
                              return Container(
                                width: size.height * 0.04,
                                // Ensuring width
                                height: size.height * 0.04,
                                // Ensuring height for a circle
                                decoration: BoxDecoration(
                                  color: ColorsContent.recordCountColor,
                                  shape: BoxShape.circle,
                                  // Ensuring a perfect circle
                                  image: DecorationImage(
                                    image: AssetImage(ImageConstant.imgMenu),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "${addActionsProvider.recordedFilePath.length + addActionsProvider.alreadyRecordedFilePath.length}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      )
                      // Positioned(
                      //   bottom: 0,
                      //   left: 10,
                      //   right: 10,
                      //   child: Consumer<AddActionsProvider>(
                      //       builder: (context, addActionsProvider, _) {
                      //         if (addActionsProvider.recordedFilePath.isEmpty &&
                      //             addActionsProvider
                      //                 .alreadyRecordedFilePath.isEmpty) {
                      //           return const SizedBox();
                      //         } else {
                      //           return Container(
                      //             width: size.height * 0.04,
                      //             decoration: BoxDecoration(
                      //               color: Colors.white,
                      //               image: DecorationImage(
                      //                 image: AssetImage(ImageConstant.imgMenu),
                      //                 fit: BoxFit.cover,
                      //               ),
                      //               borderRadius: const BorderRadius.all(
                      //                 Radius.circular(
                      //                   50.0,
                      //                 ),
                      //               ),
                      //               border: Border.all(
                      //                 color: appTheme.blue300,
                      //                 width: 2.0,
                      //               ),
                      //             ),
                      //             child: Center(
                      //               child: Text(
                      //                 "${addActionsProvider.recordedFilePath.length + addActionsProvider.alreadyRecordedFilePath.length}",
                      //                 style: const TextStyle(
                      //                   color: Colors.blue,
                      //                   fontWeight: FontWeight.bold,
                      //                 ),
                      //               ),
                      //             ),
                      //           );
                      //         }
                      //       }),
                      // )
                    ],
                  ),
                ),

                SizedBox(
                  height: size.height * 0.09,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _checkPermissionStatus();
                          _requestPermissions();
                          addActionsProvider.selectedMedia(
                            3,
                          );

                          final status = await Permission.locationWhenInUse.status;

                          print("Permission status is ${status}");
                          if (status.isDenied || status.isPermanentlyDenied) {
                            final result =
                                await Permission.locationWhenInUse.request();

                            if (result.isDenied || result.isPermanentlyDenied) {
                              if (mounted) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                        'Location Permission Required'),
                                    content: const Text(
                                        'Location permission is needed to add your current location to the mental strength entry. Please enable it in settings.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await openAppSettings();
                                        },
                                        child: const Text('Open Settings'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return;
                            }
                          }
                          if (await Permission.locationWhenInUse.isGranted){
                            if (mounted) {

                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true, // <== Helps with full height layout
                                backgroundColor: Colors.transparent, // Optional for rounded corners
                                builder: (BuildContext context) {
                                  return SafeArea(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context).viewInsets.bottom, // Avoid overlap with keyboard or bottom inset
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                        ),
                                        child: const AddActionGoogleMap(

                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          }

                        },
                        child: SvgPicture.asset(
                          ImageConstant
                              .locationAddMediaNumu, // Replace with your SVG asset path
                        ),
                      ),

                      Positioned(
                        bottom: Platform.isIOS ? 50 : 45, // Adjust this value as needed
                        right: 0, // Move to the right
                        left: 40,
                        child: Consumer<AddActionsProvider>(
                          builder: (context, addActionsProvider, _) {
                            if (addActionsProvider.selectedLocationName.isEmpty) {
                              return const SizedBox();
                            } else {
                              return Container(
                                width: size.height * 0.04,
                                height: size.height * 0.04,
                                decoration: BoxDecoration(
                                  color: ColorsContent.locationCountColor,
                                  shape: BoxShape.circle,
                                  // Ensuring a perfect circle
                                  image: DecorationImage(
                                    image: AssetImage(ImageConstant.imgMenu),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.0,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "1",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      // Positioned(
                      //   bottom: 0,
                      //   left: 10,
                      //   right: 10,
                      //   child: Consumer<AddActionsProvider>(
                      //       builder: (context, addActionsProvider, _) {
                      //     if (addActionsProvider.selectedLocationName.isEmpty) {
                      //       return const SizedBox();
                      //     } else {
                      //       return Container(
                      //         width: size.height * 0.04,
                      //         decoration: BoxDecoration(
                      //           color: Colors.white,
                      //           image: DecorationImage(
                      //             image: AssetImage(ImageConstant.imgMenu),
                      //             fit: BoxFit.cover,
                      //           ),
                      //           borderRadius: const BorderRadius.all(
                      //             Radius.circular(
                      //               50.0,
                      //             ),
                      //           ),
                      //           border: Border.all(
                      //             color: appTheme.blue300,
                      //             width: 2.0,
                      //           ),
                      //         ),
                      //         child: const Center(
                      //           child: Text(
                      //             "1",
                      //             style: TextStyle(
                      //               color: Colors.blue,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //         ),
                      //       );
                      //     }
                      //   }),
                      // )
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
    return CustomAppBarAction(
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
            backgroundColor: ColorsContent.newThemeColor,
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
