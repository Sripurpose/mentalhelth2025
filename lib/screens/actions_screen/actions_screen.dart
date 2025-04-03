import 'package:flutter/material.dart';
import 'package:getwidget/components/carousel/gf_carousel.dart';
import 'package:mentalhelth/screens/actions_screen/provider/my_action_provider.dart';
import 'package:mentalhelth/screens/addactions_screen/addactions_screen.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/custom_checkbox_button.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:provider/provider.dart';
import '../actions_screen/widgets/morningwalkcomponentlist_item_widget.dart';
import '../no_internet/duplicate_screen.dart';

// ignore: must_be_immutable
class ActionsScreen extends StatelessWidget {
  ActionsScreen({Key? key})
      : super(
          key: key,
        );

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: ConnectivityWidget(
        child: Scaffold(
          appBar: buildAppBar(
            context,
            size,
            heading: "My Actions",
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
              image: DecorationImage(
                image: AssetImage(
                  ImageConstant.imgGroup193,
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                // vertical: 50,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMorningWalkComponentList(context),
                    const SizedBox(height: 10),
                    _buildEightColumn(context, size),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddactionsScreen(goalId: '',),
                          ),
                        );
                      },
                      child: CustomImageView(
                        imagePath: ImageConstant.imgFloatingIconBlue300,
                        height: size.height * 0.1,
                        width: size.height * 0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildEightColumn(BuildContext context, Size size) {
    return Container(
      // color: Colors,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: AppDecoration.outlineGray100WithOpacity08.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder10,
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Reduce weight to 60Kg",
                        style: CustomTextStyles.titleMedium16,
                      ),
                      Text(
                        "01 Aug 2023 to 30 Sep 2023",
                        style: CustomTextStyles.bodySmallGray700_1,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.more_vert,
                ),
              ],
            ),
          ),
          SizedBox(
            height: size.height * 0.03,
          ),
          Consumer<MyActionProvider>(builder: (context, myActionProvider, _) {
            return SizedBox(
              width: size.width,
              height: size.height * 0.22,
              child: Stack(
                children: [
                  GFCarousel(
                    activeDotBorder: const Border(
                      top: BorderSide(
                        color: Colors.blueAccent,
                        width: 2.0,
                      ),
                    ),
                    autoPlay: true,
                    viewportFraction: 1.0,
                    items: myActionProvider.imageList.map(
                      (url) {
                        return CustomImageView(
                          imagePath: url,
                          height: 145,
                          width: 298,
                          alignment: Alignment.center,
                        );
                      },
                    ).toList(),
                    onPageChanged: (index) {
                      myActionProvider.changeValue(index: index);
                    },
                  ),
                  Positioned(
                    bottom: size.height * 0.05,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: myActionProvider.imageList.map((url) {
                        int index = myActionProvider.imageList.indexOf(url);
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 4,
                          ),
                          child: CircleAvatar(
                            radius: size.width * 0.015,
                            backgroundColor:
                                myActionProvider.curselIndex == index
                                    ? PrimaryColors().blue300
                                    : PrimaryColors().gray50,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(left: 9),
            child: Text(
              "Related Actions",
              style: theme.textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 9),
            child: Text(
              "Daily Cycling",
              style: CustomTextStyles.bodyMedium14,
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 9),
            child: Text(
              "Avoid junk food",
              style: CustomTextStyles.bodyMedium14,
            ),
          ),
          const SizedBox(height: 23),
          Consumer<MyActionProvider>(builder: (context, myActionProvider, _) {
            return Padding(
              padding: const EdgeInsets.only(left: 13),
              child: CustomCheckboxButton(
                text: "Completed",
                value: myActionProvider.completed,
                onChange: (value) {
                  myActionProvider.completed = value;
                },
              ),
            );
          }),
          const SizedBox(height: 13),
        ],
      ),
    );
  }

  /// Section Widget
  Widget _buildMorningWalkComponentList(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      separatorBuilder: (
        context,
        index,
      ) {
        return const SizedBox(
          height: 3,
        );
      },
      itemCount: 3,
      itemBuilder: (context, index) {
        return const MorningwalkcomponentlistItemWidget();
      },
    );
  }
}
