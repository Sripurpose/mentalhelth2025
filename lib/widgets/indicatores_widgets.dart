import 'package:flutter/material.dart';
import 'package:mentalhelth/utils/theme/colors.dart';

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
            color: index == currentIndex ? ColorsContent.newThemeColor : Colors.grey,
          ),
        );
      },
    ),
  );
}
