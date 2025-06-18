import 'package:flutter/material.dart';
import 'package:mentalhelth/utils/core/date_time_utils.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';

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
                Container(
                  width:230,
                  child: Text(
                    headding,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Open Sans',
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
                    fontFamily: 'Open Sans',
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
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Open Sans',
                              color:  ColorsContent.goalCompletedTextColor,
                            ),
                          ),
                          Text(
                            " to ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Open Sans',
                              color:  ColorsContent.goalCompletedTextColor,
                            ),
                          ),
                          Text(
                            endDate == ""
                                ? ""
                                : formatDate2(int.parse(endDate)),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Open Sans',
                              color:  ColorsContent.goalCompletedTextColor,
                            ),
                          ),
                        ],
                      ),
                //
                // status == false ?
                // Column(
                //   mainAxisAlignment: MainAxisAlignment.start,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     SizedBox(height: size.height * 0.01,),
                //     Row(
                //       children: [
                //         Text(
                //         "Related Actions",
                //           style: CustomTextStyles.titleMedium16,
                //           overflow: TextOverflow.ellipsis,
                //         ),
                //       ],
                //     ),
                //     if (actions.isNotEmpty)
                //       SizedBox(
                //         width: size.width * 0.55,
                //         child: SingleChildScrollView(
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.start, // Aligns the text to the start of the column
                //             mainAxisAlignment: MainAxisAlignment.start,
                //             children: actions.map((action) {
                //               return Padding(
                //                 padding: const EdgeInsets.only(bottom: 4.0), // Space between each action
                //                 child: Container(
                //                   padding: const EdgeInsets.only(
                //                     bottom: 5,
                //                     top: 5,
                //                     left: 10,
                //                     right: 5,
                //                   ),
                //                   height: size.height * 0.04,
                //                   width: size.width * 0.55,
                //                   decoration: BoxDecoration(
                //                     color: Colors.white,
                //                     borderRadius: BorderRadius.circular(
                //                       100,
                //                     ),
                //                     border: Border.all(
                //                       color: Colors.grey,
                //                       width: 1,
                //                     ),
                //                   ),
                //                   child: Row(
                //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //                     crossAxisAlignment: CrossAxisAlignment.center,
                //                     children: [
                //                       Text(
                //                         action.actionTitle ?? "",
                //                         overflow: TextOverflow.ellipsis,
                //                         maxLines: 1,
                //                         textAlign: TextAlign.start,
                //                         style: const TextStyle(
                //                           color: Colors.grey,
                //                         ),
                //                       ),
                //                       CircleAvatar(
                //                         radius: size.width * 0.04,
                //                         backgroundColor: Colors.blue,
                //                         child: Icon(
                //                           Icons.arrow_forward_ios_outlined,
                //                           color: Colors.white,
                //                           size: size.width * 0.03,
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               );
                //             }).toList(),
                //           ),
                //         ),
                //       ),
                //
                //   ],
                // ):
                // SizedBox()
              ],
            ),
          ),
        ],
      ),
    );
  }
}