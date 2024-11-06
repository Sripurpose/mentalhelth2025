import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/goals_dreams_page/model/goals_and_dreams_model.dart';
import 'package:mentalhelth/screens/goals_dreams_page/provider/goals_dreams_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/app_bar/appbar_subtitle.dart';
import '../../../../widgets/app_bar/custom_app_bar.dart';
import '../../../utils/logic/date_format.dart';
import '../../../utils/theme/app_decoration.dart';
import '../../../utils/theme/custom_button_style.dart';
import '../../../utils/theme/theme_helper.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_image_view.dart';
import '../../../widgets/custom_text_form_field.dart';
import '../../../widgets/functions/popup.dart';
import '../../../widgets/functions/snack_bar.dart';
import '../../addactions_screen/provider/add_actions_provider.dart';
import '../../addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import '../../home_screen/model/reminder_details.dart';
import '../../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';

class EditReminderScreenScreen extends StatefulWidget {
  const EditReminderScreenScreen(
      {Key? key, required this.title,required this.description,
        required this.startDate,required this.endDate,
        required this.startTime,required this.endTime,required this.reminderBefore,
        required this.repeat,required this.goalId,required this.actionId,required this.reminderId})
      : super(
    key: key,
  );

  final String? title;
  final String? description;
  final String? startDate;
  final String? endDate;
  final String? startTime;
  final String? endTime;
  final String? reminderBefore;
  final String? repeat;
  final String? goalId;
  final String? actionId;
  final String? reminderId;

  @override
  State<EditReminderScreenScreen> createState() =>
      _EditReminderScreenScreenScreenState();
}

class _EditReminderScreenScreenScreenState
    extends State<EditReminderScreenScreen> {
  bool isCompleted = false;
  bool isSingleActionCompleted = false;
  late GoalsDreamsProvider goalsDreamsProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late HomeProvider homeProvider;
  late AddActionsProvider addActionsProvider;
  var logger = Logger();

  @override
  void initState() {


    goalsDreamsProvider= Provider.of<GoalsDreamsProvider>(context, listen: false);
    mentalStrengthEditProvider = Provider.of<MentalStrengthEditProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    goalsDreamsProvider.fetchGoalsAndDreams(initial: true);
    addActionsProvider =  Provider.of<AddActionsProvider>(context, listen: false);
    init();

    super.initState();
  }

  void init() {
    HomeProvider homeProvider = Provider.of(context, listen: false);
    AddActionsProvider addActionsProvider = Provider.of(context, listen: false);
    homeProvider
        .reminderStartDate = unixTimestampToDate(widget.startDate ?? "");
    homeProvider
        .reminderEndDate = unixTimestampToDate(widget.endDate?? "");
    homeProvider
        .reminderStartTime = stringToTimeOfDay(widget.startTime ?? "");
    homeProvider
        .reminderEndTime = stringToTimeOfDay(widget.endTime ?? "");
    homeProvider.repeat = widget.repeat ?? "";
    homeProvider.titleEditTextController.text =
        widget.title ?? "";
    homeProvider.descriptionEditTextController.text =
        widget.description ?? "";
    if (widget.reminderBefore != null && widget.reminderBefore!.isNotEmpty) {
      // Parse the hour and minute from widget.reminderBefore (assuming the format is "HH:mm")
      List<String> timeParts = widget.reminderBefore!.split(":");
      if (timeParts.length == 2) {
        int hour = int.tryParse(timeParts[0]) ?? 0;
        int minute = int.tryParse(timeParts[1]) ?? 0;

        // Assign both hour and minute to homeProvider.remindTime
        homeProvider.remindTime = TimeOfDay(hour: hour, minute: minute);
      } else {
        // Handle incorrect format
        homeProvider.remindTime = TimeOfDay(hour: 0, minute: 0); // Default to 00:00 if format is invalid
      }
    }

  }

  TimeOfDay? parseTimeOfDay(String time) {
    if (time.isEmpty) return null; // Handle empty string
    final parts = time.split(":");
    if (parts.length != 2) return null; // Handle incorrect format
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }


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
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);

      // Format the DateTime object into the desired string format
      final DateFormat formatter = DateFormat('dd MMM yyyy');
      String formattedDate = formatter.format(dateTime);

      return formattedDate;
    } catch (e) {
      print("Error converting timestamp: $e");
      return "Invalid date";
    }
  }




  @override
  Widget build(BuildContext context) {
   // final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: buildAppBarGoalView(context, size,
            heading: widget.title,
            id: ""),
        body: Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Consumer <HomeProvider>(
              builder: (context, homeProvider, _){
               return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildTitleEditText(context),
                    const SizedBox(height: 20),
                    _buildDescriptionEditText(context),
                    const SizedBox(height: 50),
                    SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                            MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  homeProvider.reminderStartDateFunction(context,);
                                  setState(() {
                                    logger.w("${homeProvider.reminderStartDate}new");
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    left: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme
                                        .onSecondaryContainer
                                        .withOpacity(1),
                                    border: Border.all(
                                      color: appTheme.gray700,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadiusStyle
                                        .roundedBorder4,
                                  ),
                                  child: SizedBox(
                                    width: size.width * 0.32,
                                    child: Row(
                                      children: [
                                        CustomImageView(
                                          imagePath: ImageConstant
                                              .imgThumbsUpGray700,
                                          height: 20,
                                          width: 20,
                                          margin:
                                          const EdgeInsets.only(
                                            bottom: 2,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(
                                            left: 5,
                                            top: 2,
                                            bottom: 1,
                                          ),
                                          child: Text(
                                            //importent
                                            homeProvider
                                                .reminderStartDate
                                                .isNotEmpty
                                                ? homeProvider
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
                                    fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: () {
                                  homeProvider.reminderEndDateFunction(context,);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    left: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme
                                        .onSecondaryContainer
                                        .withOpacity(1),
                                    border: Border.all(
                                      color: appTheme.gray700,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadiusStyle
                                        .roundedBorder4,
                                  ),
                                  child: SizedBox(
                                    width: size.width * 0.32,
                                    child: Row(
                                      children: [
                                        CustomImageView(
                                          imagePath: ImageConstant
                                              .imgThumbsUpGray700,
                                          height: 20,
                                          width: 20,
                                          margin:
                                          const EdgeInsets.only(
                                            bottom: 2,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(
                                            left: 5,
                                            top: 2,
                                            bottom: 1,
                                          ),
                                          child: Text(
                                            homeProvider
                                                .reminderEndDate
                                                .isNotEmpty
                                                ? homeProvider
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
                            MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  homeProvider.reminderStartTimeFunction(context,);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    left: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme
                                        .onSecondaryContainer
                                        .withOpacity(1),
                                    border: Border.all(
                                      color: appTheme.gray700,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadiusStyle
                                        .roundedBorder4,
                                  ),
                                  child: SizedBox(
                                    width: size.width * 0.32,
                                    child: Row(
                                      children: [
                                        CustomImageView(
                                          imagePath: ImageConstant
                                              .imgThumbsUpGray700,
                                          height: 20,
                                          width: 20,
                                          margin:
                                          const EdgeInsets.only(
                                            bottom: 2,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(
                                            left: 5,
                                            top: 2,
                                            bottom: 1,
                                          ),
                                          child: Text(
                                            homeProvider
                                                .reminderStartTime !=
                                                null
                                                ? formatTimeOfDay(
                                                homeProvider
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
                                    fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: () {
                                  homeProvider
                                      .reminderEndTimeFunction(
                                    context,
                                  );
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                    left: 2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme
                                        .onSecondaryContainer
                                        .withOpacity(1),
                                    border: Border.all(
                                      color: appTheme.gray700,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadiusStyle
                                        .roundedBorder4,
                                  ),
                                  child: SizedBox(
                                    width: size.width * 0.32,
                                    child: Row(
                                      children: [
                                        CustomImageView(
                                          imagePath: ImageConstant
                                              .imgThumbsUpGray700,
                                          height: 20,
                                          width: 20,
                                          margin:
                                          const EdgeInsets.only(
                                            bottom: 2,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(
                                            left: 5,
                                            top: 2,
                                            bottom: 1,
                                          ),
                                          child: Text(
                                            homeProvider
                                                .reminderEndTime !=
                                                null
                                                ? formatTimeOfDay(
                                                homeProvider
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
                            MainAxisAlignment.spaceBetween,
                            children: [
                              // Column(
                              //   crossAxisAlignment:
                              //   CrossAxisAlignment.start,
                              //   children: [
                              //     const Text(
                              //       "Remind before",
                              //       style: TextStyle(
                              //         fontWeight: FontWeight.bold,
                              //         fontSize: 15,
                              //       ),
                              //     ),
                              //     const SizedBox(
                              //       height: 5,
                              //     ),
                              //     GestureDetector(
                              //       onTap: () {
                              //         homeProvider
                              //             .remindTimeFunction(
                              //           context,
                              //         );
                              //       },
                              //       child: Container(
                              //         margin: const EdgeInsets.only(
                              //           left: 2,
                              //         ),
                              //         padding: const EdgeInsets.only(
                              //           left: 11,
                              //           right: 8,
                              //           bottom: 6,
                              //           top: 6,
                              //         ),
                              //         decoration: BoxDecoration(
                              //           color: theme.colorScheme
                              //               .onSecondaryContainer
                              //               .withOpacity(
                              //             1,
                              //           ),
                              //           border: Border.all(
                              //             color: appTheme.gray700,
                              //             width: 1,
                              //           ),
                              //           borderRadius:
                              //           BorderRadiusStyle
                              //               .roundedBorder4,
                              //         ),
                              //         child: SizedBox(
                              //           width: size.width * 0.32,
                              //           child: Row(
                              //             children: [
                              //               Padding(
                              //                 padding:
                              //                 const EdgeInsets
                              //                     .only(
                              //                   left: 3,
                              //                   top: 2,
                              //                   bottom: 1,
                              //                 ),
                              //                 child: Text(
                              //                   homeProvider.remindTime != null
                              //                       ? (homeProvider.remindTime!.hour == 0
                              //                       ? '${homeProvider.remindTime!.minute} Minute'
                              //                       : '${homeProvider.remindTime!.hour} Hour ${homeProvider.remindTime!.minute} Minute')
                              //                       : "Choose Time",
                              //                   style: CustomTextStyles.bodySmallGray700,
                              //                 ),
                              //
                              //               ),
                              //               const Spacer(),
                              //               const Icon(
                              //                 Icons
                              //                     .keyboard_arrow_down_sharp,
                              //                 color: Colors.blue,
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
                                CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Repeat",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      AlertDialog alert = AlertDialog(
                                        content: Column(
                                          mainAxisSize:
                                          MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              onTap: () {
                                                homeProvider
                                                    .addRepeatValue(
                                                  "Never",
                                                );
                                                Navigator.of(context)
                                                    .pop();
                                              },
                                              title: const Text(
                                                "Never",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              onTap: () {
                                                homeProvider
                                                    .addRepeatValue(
                                                    "Daily");
                                                Navigator.of(context)
                                                    .pop();
                                              },
                                              title: const Text(
                                                "Daily",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              onTap: () {
                                                homeProvider
                                                    .addRepeatValue(
                                                    "Weekly");
                                                Navigator.of(context)
                                                    .pop();
                                              },
                                              title: const Text(
                                                "Weekly",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              onTap: () {
                                                homeProvider
                                                    .addRepeatValue(
                                                    "Monthly");
                                                Navigator.of(context)
                                                    .pop();
                                              },
                                              title: const Text(
                                                "Monthly",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              onTap: () {
                                                homeProvider
                                                    .addRepeatValue(
                                                    "Yearly");
                                                Navigator.of(context)
                                                    .pop();
                                              },
                                              title: const Text(
                                                "Yearly",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      showDialog(
                                        context: context,
                                        builder:
                                            (BuildContext context) {
                                          return alert;
                                        },
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                        left: 2,
                                      ),
                                      padding: const EdgeInsets.only(
                                        left: 11,
                                        right: 8,
                                        bottom: 6,
                                        top: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme
                                            .onSecondaryContainer
                                            .withOpacity(1),
                                        border: Border.all(
                                          color: appTheme.gray700,
                                          width: 1,
                                        ),
                                        borderRadius:
                                        BorderRadiusStyle
                                            .roundedBorder4,
                                      ),
                                      child: SizedBox(
                                        width: size.width * 0.32,
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
                                                homeProvider
                                                    .repeat,
                                                style: CustomTextStyles
                                                    .bodySmallGray700,
                                              ),
                                            ),
                                            const Spacer(),
                                            const Icon(
                                              Icons
                                                  .keyboard_arrow_down_sharp,
                                              color: Colors.blue,
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
                    ),
                    const SizedBox(height: 50),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildSaveButton(
                        context,
                      ),
                    ),
                  ],
                );
              }

            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleEditText(BuildContext context) {
    return Consumer<HomeProvider>(
        builder: (context, homeProvider, _) {
          return CustomTextFormField(
            controller: homeProvider.titleEditTextController,
            hintText: "Title",
            hintStyle: CustomTextStyles.bodySmallGray700,
            readOnly: homeProvider.titleEditTextController.text != null, // Makes the text field read-only
          );
        });
  }

  /// Section Widget
  Widget _buildDescriptionEditText(BuildContext context) {
    return Consumer<HomeProvider>(
        builder: (context, homeProvider, _) {
          return CustomTextFormField(
            controller: homeProvider.descriptionEditTextController,
            hintText: "Description",
            hintStyle: CustomTextStyles.bodySmallGray700,
            textInputAction: TextInputAction.done,
            maxLines: 4,
            readOnly: homeProvider.titleEditTextController.text != null, // Makes the text field read-only
          );
        });
  }

  Widget _buildSaveButton(BuildContext context) {
    return Consumer2<HomeProvider, AdDreamsGoalsProvider>(
        builder: (context, homeProvider, adDreamsGoalsProvider, _) {
          return CustomElevatedButton(
            loading: homeProvider.editRemindersDetailsLoading,
            onPressed: () async {
              customPopup(
                context: context,
                onPressedDelete: () async {
                  if (homeProvider.titleEditTextController.text.isNotEmpty &&
                      homeProvider
                          .descriptionEditTextController.text.isNotEmpty) {
                    await homeProvider.editReminderFunction(
                        context,
                        title: homeProvider.titleEditTextController.text,
                        details: homeProvider.descriptionEditTextController.text,
                        goalId:  widget.goalId ?? "",
                        actionId: widget.actionId ?? "",
                        reminderId: widget.reminderId ?? ""
                    );
                    homeProvider.fetchRemindersDetails();
                    Fluttertoast.showToast(
                      msg: "Updated",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM, // You can change the position
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                    // adDreamsGoalsProvider.getAddActionIdAndName(
                    //   value: addActionsProvider.goalModelIdName!,
                    // );

                    homeProvider.clearFunction();
                    Navigator.of(context).pop();
                    // Navigator.of(context).pop();

                  }
                  else {
                    showCustomSnackBar(
                      context: context,
                      message: "Please fill in all the fields",
                    );
                  }
                  Navigator.of(context).pop();
                },
                yes: "Yes",
                title: 'Remainder Update',
                content:
                'Are you sure You want to Update?',
              );



            },
            height: 40,
            text: "Update Reminder",
            buttonStyle: CustomButtonStyles.outlinePrimaryTL5,
            buttonTextStyle:
            CustomTextStyles.titleSmallHelveticaOnSecondaryContainer,
          );
        });
  }

  PreferredSizeWidget buildAppBarGoalView(
      BuildContext context,
      Size size, {
        String? heading,
        required String id,
      }) {
    return CustomAppBar(
      leadingWidth: 36,
      leading: AppbarLeadingImage(
        onTap: () {
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
        text: heading ?? "",
        margin: const EdgeInsets.only(
          left: 11,
        ),
      ),
      actions: [
        Consumer2<HomeProvider,GoalsDreamsProvider>(
          builder: (contexts, homeProvider,goalsDreamsProvider, _) {
            return PopupMenuButton<String>(
              onSelected: (value) {},
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    onTap: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => EditGoalsScreen(
                      //       goalsanddream: widget.goalsanddream,
                      //     ),
                      //   ),
                      // );
                    },
                    value: 'Edit',
                    child: Text(
                      'Edit',
                      style: CustomTextStyles.bodyMedium14,
                    ),
                  ),
                  PopupMenuItem<String>(
                    onTap: () {
                      customPopup(
                        context: context,
                        onPressedDelete: () {
                          homeProvider.deleteReminderFunction(reminder_id: widget.reminderId ?? "");
                          homeProvider.fetchRemindersDetails();
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        title: 'Confirm Delete',
                        content: 'Are you sure You want to Delete this Reminder ?',
                      );
                    },
                    value: 'Delete',
                    child: Text(
                      'Delete',
                      style: CustomTextStyles.bodyMedium14,
                    ),
                  ),
                ];
              },
            );
          },
        ),
      ],
    );
  }
}
