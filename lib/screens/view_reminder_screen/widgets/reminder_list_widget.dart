import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mentalhelth/utils/core/date_time_utils.dart';
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
        horizontal: 14,
        vertical: 13,
      ),
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadiusStyle.roundedBorder10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image == null
          //     ? const SizedBox()
          //     :
          imagePath != null && imagePath.isNotEmpty ?
           CircleAvatar(
             backgroundColor: appTheme.gray50,
             radius: size.height * 0.032,
             backgroundImage: NetworkImage(imagePath),
           ):
          SvgPicture.asset(
            'assets/images/alarmclock_fill.svg',  // Assuming 'image' is a URL to an SVG
            fit: BoxFit.cover, // Optional: Adjust fit as needed
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              bottom: 13,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: size.width * 0.5,
                  child: Text(
                    "$headding - $content",
                    style: CustomTextStyles.titleMedium16,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Row(
                  children: [
                    Text(
                      formatDate(int.parse(startDate),),
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      "  to  ",
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      endDate == ""
                          ? ""
                          : formatDate(int.parse(endDate)),
                      style: theme.textTheme.bodySmall,
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
