import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:mentalhelth/utils/core/date_time_utils.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';

import '../../../utils/logic/date_format.dart';
import '../../../utils/theme/app_decoration.dart';
import '../../../utils/theme/custom_text_style.dart';
import '../model/goals_and_dreams_model.dart';

// ignore: must_be_immutable
class WeightLossComponentListItemWidget extends StatelessWidget {
  const WeightLossComponentListItemWidget({
    Key? key,
    required this.image,
    required this.headding,
    required this.status,
    required this.startDate,
    required this.endDate,

  }) : super(
          key: key,
        );
  final String image;
  final String headding;
  final bool status;
  final String startDate;
  final String endDate;

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
      decoration: status
          ? BoxDecoration(
        color: ColorsContent.shadeColor,
        borderRadius: BorderRadiusStyle.roundedBorder8,
        border: Border.all(
          color: ColorsContent.allBorderColor, // Change to desired border color
          width: 1.5,         // 🔁 Change thickness if required
        ),
      )
          : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadiusStyle.roundedBorder8,
        border: Border.all(
          color: ColorsContent.allBorderColor, // Change to desired border color
          width: 1.5,         // 🔁 Change thickness if required
        ),
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          image.isEmpty
              ?  Container(
            height: size.height * 0.06,
            width: size.height * 0.06, // Same as height for square, adjust as needed
            decoration: BoxDecoration(
              color: appTheme.gray50,
              borderRadius: BorderRadius.circular(5), // ⬅ Rounded corners (optional)
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
            ),
          )

              : Container(
            height: size.height * 0.06,
            width: size.height * 0.06, // Same as height for square, adjust as needed
            decoration: BoxDecoration(
              color: appTheme.gray50,
              borderRadius: BorderRadius.circular(5), // ⬅ Rounded corners (optional)
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover,
              ),
            ),
          )
          ,
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
                  width:230,
                  child: Text(
                    capitalizeFirstLetter(
                      HtmlUnescape().convert(
                        headding.length > 30
                            ? '${headding.substring(0, 30)}...'
                            : headding,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                status
                    ? Text(
                        "Completed",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                    color:  ColorsContent.goalCompletedTextColor,
                  ),
                      )
                    : Row(
                        children: [
                          Text(
                            formatDate(
                              int.parse(startDate),
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                              color:  ColorsContent.goalCompletedTextColor,
                            ),
                          ),
                          Text(
                            " to ",
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
                                : formatDate2(int.parse(endDate)),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
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