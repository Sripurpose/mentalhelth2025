import 'package:flutter/material.dart';
import 'package:mentalhelth/utils/logic/logic.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';

// ignore: must_be_immutable
class AppbarSubtitle extends StatelessWidget {
  AppbarSubtitle({
    Key? key,
    required this.text,
    this.margin,
    this.onTap,
  }) : super(
          key: key,
        );

  String text;

  EdgeInsetsGeometry? margin;

  Function? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap!.call();
      },
      child: Padding(
        padding: margin ?? EdgeInsets.zero,
        child: SizedBox(
          width: 400,
          child: Text(
            capitalText(text),
            style: CustomTextStyles.blackText20000000W700(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
