import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mentalhelth/utils/theme/colors.dart';

// ignore: must_be_immutable
class CustomRatingBar extends StatelessWidget {
  CustomRatingBar({
    Key? key,
    this.alignment,
    this.ignoreGestures,
    this.initialRating,
    this.itemSize,
    this.itemCount,
    this.color,
    this.unselectedColor,
    this.onRatingUpdate,
    this.isRatingStatic = false, // New bool variable
  }) : super(key: key);

  final Alignment? alignment;
  final bool? ignoreGestures;
  final double? initialRating;
  final double? itemSize;
  final int? itemCount;
  final Color? color;
  final Color? unselectedColor;
  final bool isRatingStatic; // Controls if rating should be static
  Function(double)? onRatingUpdate;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
      alignment: alignment ?? Alignment.center,
      child: ratingBarWidget,
    )
        : ratingBarWidget;
  }

  Widget get ratingBarWidget => RatingBar.builder(
    ignoreGestures: ignoreGestures ?? isRatingStatic,
    initialRating: initialRating ?? 0.0,
    minRating: 0.1,
    direction: Axis.horizontal,
    allowHalfRating: false,
    itemSize: itemSize ?? 26,
    unratedColor: ColorsContent.newThemeColor, // set to transparent to handle our own logic
    itemCount: itemCount ?? 5,
    updateOnDrag: true,
    itemBuilder: (context, index) {
      bool isRated = (initialRating ?? 0.0) > index;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Icon(
          isRated ? Icons.star : Icons.star_border,
          color: color ?? Colors.yellow,
        ),
      );
    },
    onRatingUpdate: (rating) {
      if (!isRatingStatic && rating >= 0.1) {
        onRatingUpdate?.call(rating);
      }
    },
  );
}

