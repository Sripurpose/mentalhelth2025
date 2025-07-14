import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mentalhelth/utils/core/date_time_utils.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';

import '../../../utils/theme/app_decoration.dart';
import '../../../utils/theme/custom_text_style.dart';

// ignore: must_be_immutable
class ReminderListItemWidget extends StatelessWidget {
  const ReminderListItemWidget({
    Key? key,
    required this.headding,
    required this.content,
    required this.startDate,
    required this.endDate,
    required this.imagePath,

  }) : super(
    key: key,
  );
  final String headding;
  final String content;
  final String startDate;
  final String endDate;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9.5,
        vertical: 9.5,
      ),
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadiusStyle.roundedBorder8,
        border: Border.all(
          color: ColorsContent.goalNotCompletedColor, // Change to desired border color
          width: 0.5,         // 🔁 Change thickness if required
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          imagePath != null && imagePath.isNotEmpty ?
          Container(
            height: size.height * 0.06,
            width: size.height * 0.06, // Same as height for square, adjust as needed
            decoration: BoxDecoration(
              color: appTheme.gray50,
              borderRadius: BorderRadius.circular(5), // ⬅ Rounded corners (optional)
              image: DecorationImage(
                image: NetworkImage(imagePath),
                fit: BoxFit.cover,
              ),
              // border: Border.all(
              //   color: ColorsContent.goalNotCompletedColor, // Change to desired border color
              //   width: 0.5,         // 🔁 Change thickness if required
              // ),
            ),
          ) :
          Container(
            height: size.height * 0.06,
            width: size.height * 0.06, // Same as height for square, adjust as needed
            decoration: BoxDecoration(
              color: appTheme.gray50,
              borderRadius: BorderRadius.circular(5), // ⬅ Rounded corners (optional)
              image: DecorationImage(
                image: NetworkImage(imagePath),
                fit: BoxFit.cover,
              ),
              // border: Border.all(
              //   color: ColorsContent.goalNotCompletedColor, // Change to desired border color
              //   width: 0.5,         // 🔁 Change thickness if required
              // ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              bottom: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: size.width * 0.5,
                  child: Text(
                    "$headding - $content",
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.00,
                ),
                Row(
                  children: [
                    Text(
                      startDate.isNotEmpty && int.tryParse(startDate) != null
                          ? formatDate(int.parse(startDate))
                          : "Invalid Date", // Show default text if parsing fails
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                        color:  ColorsContent.goalCompletedTextColor,
                      ),
                    ),

                    Text(
                      "  to  ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                        color:  ColorsContent.goalCompletedTextColor,
                      ),
                    ),
                    Text(
                      endDate == ""
                          ? ""
                          : formatDate(int.parse(endDate)),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Poppins',
                        color:  ColorsContent.goalCompletedTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
