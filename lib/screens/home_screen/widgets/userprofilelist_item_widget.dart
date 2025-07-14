import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/utils/core/date_time_utils.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import '../../../utils/theme/theme_helper.dart';

// ignore: must_be_immutable
class UserProfileListItemWidget extends StatelessWidget {
  const UserProfileListItemWidget(
      {Key? key, required this.title, required this.date, required this.image})
      : super(
          key: key,
        );
  final String title;
  final String date;
  final String image;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var logger = Logger();
    //logger.w("title ${title}");
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9.5,
        vertical: 9.5,
      ),
      decoration: AppDecoration.outlineGray.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder10,
        border:  Border.all(
          color: ColorsContent.allBorderColor, // Black border color
          width: 1.5,          // Border width
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          image!=null?
          Container(
            width: size.width * 0.135, // Set the desired width
            height: size.width * 0.135, // Set the desired height
            decoration: BoxDecoration(
              color: Colors.grey[100], // Background color
              image: DecorationImage(
                image: NetworkImage(image),
                fit: BoxFit.cover, // Adjust image to fit container
              ),
              borderRadius: BorderRadius.circular(8), // Set curved edges
            ),
          )

              :
              const SizedBox(),
          Padding(
            padding: const EdgeInsets.only(
              left: 17,
              top: 2,
              bottom: 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 230,
                  child: Text(
                    HtmlUnescape().convert(
                      title.toString().length > 38
                          ? '${title.toString().substring(0, 38)}.....'
                          : title.toString(),
                    ),
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 0,),
                Text(
                  formatMilliseconds(int.parse(date)),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                    color:  ColorsContent.goalCompletedTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
