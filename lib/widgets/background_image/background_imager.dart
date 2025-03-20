import 'package:flutter/material.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';

Widget backGroundImager({
  required Size size,
  EdgeInsets? padding,
  Widget? child,
}) {
  return Container(
    width: size.width,
    height: size.height,
    decoration: BoxDecoration(
      color: ColorsContent.homeBackGroundColor, // Replace image with a solid color
      // image: DecorationImage(
      //   image: AssetImage(
      //     ImageConstant.imgGroup22,
      //   ),
      //   fit: BoxFit.cover,
      // ),
    ),
    child: Container(
      width: double.maxFinite,
      padding: padding ??
          EdgeInsets.only(
            left: size.width * 0.05,
            right: size.width * 0.05,
          ),
      child: child,
    ),
  );
}
