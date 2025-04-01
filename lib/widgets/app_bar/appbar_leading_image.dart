import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mentalhelth/screens/dash_borad_screen/dash_board_screen.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/home_screen/widgets/home_menu/home_menu.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_subtitle.dart';
import 'package:mentalhelth/widgets/app_bar/custom_app_bar.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:provider/provider.dart';

import '../../utils/theme/theme_helper.dart';

// ignore: must_be_immutable
class AppbarLeadingImage extends StatelessWidget {
  AppbarLeadingImage({
    Key? key,
    this.imagePath,
    this.margin,
    this.onTap,
  }) : super(
          key: key,
        );

  String? imagePath;

  EdgeInsetsGeometry? margin;

  Function? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap!.call();
      },
      child: Padding(
        padding: margin ?? EdgeInsets.zero,
        child: CustomImageView(
          margin: const EdgeInsets.only(
            right: 5,
          ),
          imagePath: imagePath,
          height: 13,
          width: 8,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

PreferredSizeWidget buildAppBar(BuildContext context, Size size,
    {String? heading, Function? onTap, bool isSigned = true}) {
  return CustomAppBar(
    leadingWidth: 36,
    leading:
        Consumer<DashBoardProvider>(builder: (context, dashBoardProvider, _) {
      return AppbarLeadingImage(
        onTap: onTap ??
            () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const DashBoardScreen(),
                ),
                (route) => false,
              );
              dashBoardProvider.changeCommentPage(
                index: 0,
              );
            },
        imagePath: ImageConstant.imgTelevision,
        margin: const EdgeInsets.only(
          left: 20,
          top: 19,
          bottom: 23,
        ),
      );
    }),
    title: AppbarSubtitle(
      text: heading ?? "My profile",
      margin: const EdgeInsets.only(
        left: 11,
      ),
    ),
    actions: [
      !isSigned
          ? const SizedBox()
          : GestureDetector(
              onTap: () {
                if (isSigned) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) =>
                        buildPopupDialog(context, size),
                  );
                } else {}
              },
              child: Padding(
                padding: EdgeInsets.only(
                  right: size.width * 0.07,
                ),
                child:
                SvgPicture.asset(
                  ImageConstant.menuBarSvg,
                ),
              ),
            ),
    ],
  );
}

PreferredSizeWidget buildAppBarNumu(BuildContext context, Size size,
    {String? heading, Function? onTap, bool isSigned = true}) {
  return CustomAppBarNumu(
    backgroundColor: ColorsContent.homeBackGroundColor, // Set your desired background color here
    leadingWidth: 36,
    leading:
    Consumer<DashBoardProvider>(builder: (context, dashBoardProvider, _) {
      return AppbarLeadingImage(
        onTap: onTap ??
                () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const DashBoardScreen(),
                ),
                    (route) => false,
              );
              dashBoardProvider.changeCommentPage(
                index: 0,
              );
            },
        imagePath: ImageConstant.imgTelevision,
        margin: const EdgeInsets.only(
          left: 20,
          top: 19,
          bottom: 23,
        ),
      );
    }),
    title: AppbarSubtitle(
      text: heading ?? "My profile",
      margin: const EdgeInsets.only(
        left: 11,
      ),
    ),
    actions: [
      !isSigned
          ? const SizedBox()
          : GestureDetector(
        onTap: () {
          if (isSigned) {
            showDialog(
              context: context,
              builder: (BuildContext context) =>
                  buildPopupDialog(context, size),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            right: size.width * 0.07,
          ),
          child: SvgPicture.asset(
            ImageConstant.menuBarSvg,
          ),
        ),
      ),
    ],
  );
}


PreferredSizeWidget buildAppBarBuildMental(BuildContext context, Size size,
    {String? heading, bool isSigned = true}) {
  return CustomAppBarBuild(
    automaticallyImplyLeading: false, // Removes the back button
    leadingWidth: 36,
    leading: Consumer<DashBoardProvider>(builder: (context, dashBoardProvider, _) {
      return AppbarLeadingImage(
        imagePath: ImageConstant.imgTelevision,
        margin: const EdgeInsets.only(
          left: 20,
          top: 19,
          bottom: 23,
        ),
      );
    }),
    actions: [
      !isSigned
          ? const SizedBox()
          : GestureDetector(
        onTap: () {
          if (isSigned) {
            showDialog(
              context: context,
              builder: (BuildContext context) =>
                  buildPopupDialog(context, size),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            right: size.width * 0.07,
          ),
          child: SvgPicture.asset(
            ImageConstant.menuBarSvg,
          ),
        ),
      ),
    ],
  );
}



PreferredSizeWidget buildAppBarJournalViewScreen(BuildContext context, Size size,
    {String? heading, Function? onTap, bool isSigned = true}) {
  return CustomAppBarNumu(
    backgroundColor: ColorsContent.homeBackGroundColor,
    leadingWidth: 36,
    leading:
    Consumer<DashBoardProvider>(builder: (context, dashBoardProvider, _) {
      return AppbarLeadingImage(
        onTap: onTap ??
                () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const DashBoardScreen(),
                ),
                    (route) => false,
              );
              dashBoardProvider.changeCommentPage(
                index: 0,
              );
            },
        imagePath: ImageConstant.imgTelevision,
        margin: const EdgeInsets.only(
          left: 20,
          top: 19,
          bottom: 23,
        ),
      );
    }),
    title: AppbarSubtitle(
      text: heading ?? "My profile",
      margin: const EdgeInsets.only(
        left: 11,
      ),
    ),
  );
}
