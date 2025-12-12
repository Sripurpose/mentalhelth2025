import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import 'package:mentalhelth/screens/addactions_screen/provider/add_actions_provider.dart';
import 'package:mentalhelth/screens/dash_borad_screen/dash_board_screen.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/home_screen/home_screen.dart';

import 'package:mentalhelth/utils/core/image_constant.dart';

import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';

import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';

import 'package:provider/provider.dart';

import '../../../../widgets/app_bar/appbar_subtitle.dart';
import '../../../../widgets/app_bar/custom_app_bar.dart';

class ReminderPushViewScreen extends StatefulWidget {
  final Map<String, dynamic> reminderData;

  const ReminderPushViewScreen({Key? key, required this.reminderData})
      : super(
          key: key,
        );

  @override
  State<ReminderPushViewScreen> createState() => _ReminderPushViewScreenState();
}

class _ReminderPushViewScreenState extends State<ReminderPushViewScreen> {
  late DashBoardProvider dashBoardProvider;

  var logger = Logger();

  @override
  void initState() {
    dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final dashBoardProvider =
        Provider.of<DashBoardProvider>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorsContent.homeBackGroundColor,
          // Set the background color
          leading: IconButton(
            icon:
                Icon(Icons.arrow_back_ios, color: ColorsContent.newThemeColor),
            // Default back arrow icon
            onPressed: () {
              print("object");
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const DashBoardScreen(),
                  transitionDuration: const Duration(seconds: 0),
                ),
              );
            },
          ),
          title: const Text(
            "Action Details", // Set the title text
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: Colors.black,
            ),
          ),
          elevation: 0,
          // Optional: Set elevation to 0 if you want a flat app bar
          centerTitle: false, // Align title to the left
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: ColorsContent.homeBackGroundColor,
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //   const SizedBox(height: 15),
                          Consumer<AddActionsProvider>(
                              builder: (context, addActionsProvider, _) {
                            return Column(
                              children: [
                                const SizedBox(height: 15),
                                Padding(
                                    padding: EdgeInsets.only(
                                      left: size.width * 0.01,
                                      bottom: 10,
                                    ),
                                    child: SizedBox(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 5),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8), // Optional: adds inner spacing
                                                    decoration: BoxDecoration(
                                                      color: Colors.white, // White background
                                                      borderRadius: BorderRadius.circular(5), // Rounded corners
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          ImageConstant
                                                              .actionDetailsMark, // Replace with your actual asset path
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        const Text(
                                                          "Status             : ",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily: 'Poppins',
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          widget.reminderData[
                                                                      'reminder_status'] ==
                                                                  0
                                                              ? "Inactive"
                                                              : "Active",
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontFamily: 'Poppins',
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8), // Optional: adds inner spacing
                                                    decoration: BoxDecoration(
                                                      color: Colors.white, // White background
                                                      borderRadius: BorderRadius.circular(5), // Rounded corners
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          ImageConstant
                                                              .actionDetailsMark, // Replace with your actual asset path
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        const Text(
                                                          "Goal Title       : ",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily: 'Poppins',
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        /// 👇 THIS IS THE FIX — allows multiline
                                                        Expanded(
                                                          child: Text(
                                                            widget.reminderData['goal_title'].toString(),
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w400,
                                                              fontFamily: 'Poppins',
                                                              color: Colors.black,
                                                            ),
                                                            softWrap: true,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8), // Optional: adds inner spacing
                                                    decoration: BoxDecoration(
                                                      color: Colors.white, // White background
                                                      borderRadius: BorderRadius.circular(5), // Rounded corners
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          ImageConstant
                                                              .actionDetailsMark, // Replace with your actual asset path
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        const Text(
                                                          "Action Title   : ",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily: 'Poppins',
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        /// 👇 THIS IS THE FIX — allows multiline
                                                        Expanded(
                                                          child: Text(
                                                            widget.reminderData[
                                                            'reminder_title']
                                                                .toString(),
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w400,
                                                              fontFamily: 'Poppins',
                                                              color: Colors.black,
                                                            ),
                                                            softWrap: true,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8), // Optional: adds inner spacing
                                                    decoration: BoxDecoration(
                                                      color: Colors.white, // White background
                                                      borderRadius: BorderRadius.circular(5), // Rounded corners
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          ImageConstant
                                                              .actionDetailsMark, // Replace with your actual asset path
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        const Text(
                                                          "Action Desc  : ",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily: 'Poppins',
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            widget.reminderData[
                                                            'reminder_desc']
                                                                .toString(),
                                                            style: const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w400,
                                                              fontFamily: 'Poppins',
                                                              color: Colors.black,
                                                            ),
                                                            softWrap: true,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                ]),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            SvgPicture.asset(
                                                              ImageConstant.actionDetailsMark,
                                                            ),
                                                            const SizedBox(width: 10),
                                                            Text(
                                                              "Reminder",
                                                              style: CustomTextStyles.blackText16000000W700(),
                                                            ),
                                                            const Text(
                                                              " : ",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w600,
                                                                fontFamily: 'Poppins',
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SvgPicture.asset(
                                                        ImageConstant.reminderClock,

                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  Row(
                                                    children: [

                                                      const SizedBox(width: 10),
                                                      const Text(
                                                        "Date      :",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontFamily: 'Poppins',
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        "${unixTimestampToDate(widget.reminderData['reminder_startdate'].toString())} to ${unixTimestampToDate(widget.reminderData['reminder_enddate'].toString())}",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily: 'Poppins',
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 10),
                                                      const Text(
                                                        "Time     : ",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontFamily:
                                                              'Open Sans',
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        "${_formatTime(widget.reminderData['from_time'])} to ${_formatTime(widget.reminderData['to_time'])}",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w400,
                                                          fontFamily: 'Poppins',
                                                          color: Colors.black,
                                                        ),
                                                      ),

                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 10),
                                                      const Text(
                                                        "Repeat : ",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontFamily: 'Poppins',
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        widget.reminderData[
                                                                'reminder_repeat'] ??
                                                            "None",
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontFamily: 'Poppins',
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ]),
                                          ),
                                        ],
                                      ),
                                    ))
                              ],
                            );
                          }),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildUntitledOne(BuildContext context, Size size,
      {required String category,
      required String createDate,
      required String achiveDate,
      required String status,
      required String comments}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              "Status : ",
              style: CustomTextStyles.blackText16000000W600(),
            ),
            Text(
              status == "0" ? "Active" : "DeActive",
              style: CustomTextStyles.bodyLargeGray700,
            ),
          ],
        ),
        Row(
          children: [
            Text(
              "Goal : ",
              style: CustomTextStyles.blackText16000000W600(),
            ),
            SizedBox(
              width: size.width * 0.60,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                child: Text(
                  category,
                  style: CustomTextStyles.bodyLargeGray700,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // Set the maximum number of lines to 3
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              "Action Description : ",
              style: CustomTextStyles.blackText16000000W600(),
            ),
            SizedBox(
              width: size.width * 0.60,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                child: Text(
                  comments,
                  style: CustomTextStyles.bodyLargeGray700,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // Set the maximum number of lines to 3
                ),
              ),
            ),
          ],
        ),
      ],
    );
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

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod; // Hour within the 12-hour range
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    final formattedHour =
        (hour == 0 ? 12 : hour).toString(); // Adjust for midnight and noon
    final formattedMinute =
        time.minute.toString().padLeft(2, '0'); // Ensure two-digit minute

    return "$formattedHour:$formattedMinute $period";
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

  Widget buildIndicators(int pageCount, int currentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        pageCount,
        (index) {
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == currentIndex
                  ? ColorsContent.newThemeColor
                  : Colors.grey,
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget buildAppBarActionView(BuildContext context, Size size,
      {String? heading, required String id, required actionStatus}) {
    return CustomAppBarNumu(
      backgroundColor: ColorsContent.homeBackGroundColor,
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
    );
  }
}

String _formatTime(dynamic time) {
  if (time is TimeOfDay) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt); // Example: 12:05 PM
  } else if (time is String) {
    try {
      // Parse from string like "12:05 PM"
      final parsedTime = DateFormat.jm().parse(time);
      return DateFormat.jm().format(parsedTime);
    } catch (e) {
      return time.toString().replaceAll('?', '').trim();
    }
  } else {
    return time.toString().replaceAll('?', '').trim();
  }
}
