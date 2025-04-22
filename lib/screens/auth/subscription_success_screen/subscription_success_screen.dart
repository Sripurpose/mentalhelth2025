import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/dash_borad_screen/dash_board_screen.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';

// ignore_for_file: must_be_immutable
class SubscriptionSuccessScreen extends StatelessWidget {
  SubscriptionSuccessScreen({Key? key}) : super(key: key);

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(context, size, heading: "Payment Success"),
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
            color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
            image: DecorationImage(
                image: AssetImage(ImageConstant.imgGroup193),
                fit: BoxFit.cover)),
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(vertical: 42),
          child: Column(
            children: [
              const Spacer(flex: 44),
              SizedBox(
                  width: 226,
                  child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: "Hi ",
                            style: CustomTextStyles.bodyMediumRobotoff333333),
                        TextSpan(
                            text: "Josh",
                            style: CustomTextStyles.titleSmallRobotoff333333),
                        TextSpan(
                            text: ", received a",
                            style: CustomTextStyles.bodyMediumRobotoff333333),
                        TextSpan(
                            text: " payment of",
                            style: CustomTextStyles.bodyMediumRobotoff333333),
                        TextSpan(
                            text: " 1 \n(Ref Id: 110345)",
                            style: CustomTextStyles.titleSmallRobotoff333333
                                .copyWith(height: 1.57)),
                        TextSpan(
                            text:
                                "  for a monthly plan. Enjoy the premium service.",
                            style: CustomTextStyles.bodyMediumRobotoff333333)
                      ]),
                      textAlign: TextAlign.center)),
              const Spacer(flex: 55),
              CustomElevatedButton(
                buttonStyle: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                width: size.width * 0.4,
                text: "Go Home",
                onPressed: () {
                  HomeProvider homeProvider =
                      Provider.of<HomeProvider>(context, listen: false);
                  EditProfileProvider editProfileProvider =
                      Provider.of<EditProfileProvider>(context, listen: false);
                 // homeProvider.fetchChartView(context);
                 // homeProvider.fetchJournals(initial: true);
                  editProfileProvider.fetchUserProfile();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const DashBoardScreen(),
                    ),
                    (route) => false,
                  );
                },
              )
            ],
          ),
        ),
      ),
    ));
  }
}
