import 'package:flutter/material.dart';
import 'package:mentalhelth/utils/core/date_time_utils.dart';
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
        horizontal: 14,
        vertical: 13,
      ),
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: status
          ? AppDecoration.outlineGray100WithOpacity08.copyWith(
              borderRadius: BorderRadiusStyle.roundedBorder10,
            )
          : BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadiusStyle.roundedBorder10,
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          image == null
              ? const SizedBox()
              : CircleAvatar(
                  backgroundColor: appTheme.gray50,
                  radius: size.height * 0.035,
                  backgroundImage: NetworkImage(image),
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
                Text(
                  headding,
                  style: CustomTextStyles.titleMedium16,
                  overflow: TextOverflow.ellipsis,
                ),

                status
                    ? Text(
                        "Completed",
                        style: CustomTextStyles.bodySmallGray700_1,
                      )
                    : Row(
                        children: [
                          Text(
                            formatDate(
                              int.parse(startDate),
                            ),
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            "  to  ",
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            endDate == ""
                                ? ""
                                : formatDate2(int.parse(endDate)),
                            style: theme.textTheme.bodySmall,
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
