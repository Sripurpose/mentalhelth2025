import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/provider/goals_dreams_provider.dart';
import 'package:mentalhelth/screens/journal_view_screen/widgets/jouranl_view_google_map.dart';
import 'package:mentalhelth/screens/journal_view_screen/widgets/journal_audio_player.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/goal_details_model.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/utils/core/date_time_utils.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/logic/logic.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/custom_checkbox_button.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/video_player.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/app_bar/appbar_subtitle.dart';
import '../../../../widgets/app_bar/custom_app_bar.dart';
import '../../../no_internet/duplicate_screen.dart';

class GoalAndDreamFullViewBottomSheet extends StatefulWidget {
  const GoalAndDreamFullViewBottomSheet(
      {Key? key, required this.goalDetailModel})
      : super(
          key: key,
        );

  final GoalDetailModel goalDetailModel;

  @override
  State<GoalAndDreamFullViewBottomSheet> createState() =>
      _GoalAndDreamFullViewBottomSheetState();
}

class _GoalAndDreamFullViewBottomSheetState
    extends State<GoalAndDreamFullViewBottomSheet> {
  bool isCompleted = false;
  var logger = Logger();

  @override
  void initState() {
    if (widget.goalDetailModel != null) {
      addAudio();
      addImage();
      addVideo();
    }

    super.initState();
  }

  int sliderIndex = 1;

  PageController photoController = PageController();
  int photoCurrentIndex = 0;
  PageController videoController = PageController();

  int videoCurrentIndex = 0;
  List<String> audioList = [];

  List<String> imageList = [];

  List<String> videoList = [];

  void addAudio() {
    for (int i = 0; i < widget.goalDetailModel.goals!.gemMedia!.length; i++) {
      if (widget.goalDetailModel.goals!.gemMedia![i].mediaType == 'audio') {
        // setState(() {
        audioList.add(widget.goalDetailModel.goals!.gemMedia![i].gemMedia!);
        // });
      }
    }
  }

  void addImage() {
    for (int i = 0; i < widget.goalDetailModel.goals!.gemMedia!.length; i++) {
      if (widget.goalDetailModel.goals!.gemMedia![i].mediaType == 'image') {
        imageList.add(widget.goalDetailModel.goals!.gemMedia![i].gemMedia!);
      }
    }
  }

  void addVideo() {
    for (int i = 0; i < widget.goalDetailModel.goals!.gemMedia!.length; i++) {
      if (widget.goalDetailModel.goals!.gemMedia![i].mediaType == 'video') {
        videoList.add(widget.goalDetailModel.goals!.gemMedia![i].gemMedia!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color:ColorsContent.homeBackGroundColor,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(
              25,
            ),
            topLeft: Radius.circular(
              25,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Shadow color
              spreadRadius: 5, // Spread radius
              blurRadius: 7, // Blur radius
              offset: const Offset(0, 3), // Offset
            ),
          ],
        ),
        margin: EdgeInsets.only(
          top: size.height * 0.15,
        ),
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height * 0.02,
              ),
              Consumer<MentalStrengthEditProvider>(
                  builder: (context, mentalStrengthEditProvider, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: size.width * 0.2,
                    ),
                    SizedBox(
                      width: size.width * 0.2,
                      child: Column(
                        children: [
                          SvgPicture.asset(
                            ImageConstant.dotDot,
                            color: ColorsContent.newThemeColor,
                            height: 8,
                            width: 8,
                            fit: BoxFit.contain,
                          ),
                          SvgPicture.asset(
                            ImageConstant.dotDot,
                            color: ColorsContent.newThemeColor,
                            height: 8,
                            width: 8,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        mentalStrengthEditProvider.openGoalViewSheetFunction();
                      },
                      child: SizedBox(
                        width: size.width * 0.2,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: CustomImageView(
                            imagePath: ImageConstant.imgClosePrimaryNew,
                            height: 40,
                            width: 40,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: SizedBox(
                  width: size.width * 0.85,
                  child: Text(
                    capitalText(
                        widget.goalDetailModel.goals!.goalTitle.toString()),
                    style: CustomTextStyles.blackText18000000W700(),
                   // textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4, // Set the maximum number of lines to 3
                  ),
                ),
              ),
              const SizedBox(height: 10,),
              _buildUntitledOne(
                context,
                size,
                category: widget.goalDetailModel.goals!.categoryName.toString(),
                createDate: widget.goalDetailModel.goals!.createdAt.toString(),
                achiveDate:
                    widget.goalDetailModel.goals!.goalEnddate.toString(),
                status: widget.goalDetailModel.goals!.goalStatus.toString(),
                comments: widget.goalDetailModel.goals!.goalDetails.toString(),
              ),


              audioList.isNotEmpty
                  ? const SizedBox(height: 10)
                  : const SizedBox(),
              audioList.isEmpty
                  ? const SizedBox() :
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      color: ColorsContent.newThemeColor,
                      width: 0.3), // Light purple border
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ColorsContent.goalTextColor, // Light purple background
                        borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(5)),
                      ),
                      child:  Text(
                        "Audio",
                        style: TextStyle(
                          color:ColorsContent.signInGradientColorViolet, // Purple text
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white, // Off-white background
                        borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(5)),
                      ),
                      child: SizedBox(
                        height: size.height * 0.113,
                        child: ListView.builder(
                          //   physics: const NeverScrollableScrollPhysics(),
                          itemCount: audioList.length,
                          itemBuilder: (context, index) {
                            return JournalAudioPlayer(
                              url: audioList[index],
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),



              imageList.isNotEmpty
                  ? const SizedBox(height: 10)
                  : const SizedBox(),
              imageList.isNotEmpty
                  ?
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      color: ColorsContent.newThemeColor,
                      width: 0.3), // Light purple border
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ColorsContent.goalTextColor, // Light purple background
                        borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(5)),
                      ),
                      child:  Text(
                        "Photo",
                        style: TextStyle(
                          color:ColorsContent.signInGradientColorViolet, // Purple text
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white, // Off-white background
                          borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(5)),
                        ),
                        child:  SizedBox(
                          height: imageList.isNotEmpty
                              ? size.height * 0.3
                              : 0,
                          child: Stack(
                            children: [
                              PageView.builder(
                                controller: photoController,
                                itemCount: imageList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: true,
                                        builder: (_) => Dialog(
                                          insetPadding: EdgeInsets.zero,
                                          backgroundColor: Colors.black,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.zero, // Removes rounded corners
                                          ),
                                          child: Stack(
                                            children: [
                                              InteractiveViewer(
                                                child: Center(
                                                  child: Image.network(
                                                    imageList[index],
                                                    fit: BoxFit.contain,
                                                    loadingBuilder: (context, child, loadingProgress) {
                                                      if (loadingProgress == null) return child;
                                                      return const Center(child: CupertinoActivityIndicator());
                                                    },
                                                    errorBuilder: (context, error, stackTrace) =>
                                                    const Center(child: Icon(Icons.broken_image, color: Colors.white)),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 40,
                                                right: 20,
                                                child: IconButton(
                                                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                                  onPressed: () => Navigator.of(context).pop(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    child: CustomImageView(
                                      fit: BoxFit.cover,
                                      imagePath: imageList[index],
                                      height: size.height * 0.30,
                                      width: size.width,
                                      alignment: Alignment.center,
                                      radius: BorderRadius.circular(8), // Your original rounded radius
                                    ),
                                  );
                                },
                                onPageChanged: (int pageIndex) {
                                  setState(() {
                                    photoCurrentIndex = pageIndex;
                                  });
                                },
                              ),

                              Positioned(
                                bottom: 10,
                                left: 0,
                                right: 0,
                                child: SizedBox(
                                  width:
                                  imageList.length * size.width * 0.1,
                                  child: buildIndicators(
                                    imageList.length,
                                    photoCurrentIndex,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                    ),
                  ],
                ),
              )
                  : const SizedBox(),



              videoList.isNotEmpty
                  ?   const SizedBox(height: 10)
                  : const SizedBox(),
              videoList.isNotEmpty
                  ?
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      color: ColorsContent.newThemeColor,
                      width: 0.3), // Light purple border
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ColorsContent.goalTextColor, // Light purple background
                        borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(5)),
                      ),
                      child:  Text(
                        "Video",
                        style: TextStyle(
                          color:ColorsContent.signInGradientColorViolet, // Purple text
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white, // Off-white background
                          borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(5)),
                        ),
                        child:  SizedBox(
                          height: videoList.isNotEmpty
                              ? size.height * 0.3
                              : 0,
                          child: Stack(
                            children: [
                              PageView.builder(
                                controller: videoController,
                                itemCount: videoList.length,
                                itemBuilder: (context, index) {
                                  return VideoPlayerWidget(
                                    videoUrl: videoList[index],
                                  );
                                },
                                onPageChanged: (int pageIndex) {
                                  setState(() {
                                    videoCurrentIndex = pageIndex;
                                  });
                                },
                              ),
                              Positioned(
                                bottom: 10,
                                left: 0,
                                right: 0,
                                child: SizedBox(
                                  width:
                                  videoList.length * size.width * 0.1,
                                  child: buildIndicators(
                                    videoList.length,
                                    videoCurrentIndex,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                    ),
                  ],
                ),
              )
                  : const SizedBox(),



              widget.goalDetailModel.goals!.location?.locationAddress != null
                  ? const SizedBox(
                height: 10,
              )
                  : const SizedBox(),
              widget.goalDetailModel.goals!.location?.locationAddress !=
                  null ?
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      color: ColorsContent.newThemeColor,
                      width: 0.3), // Light purple border
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ColorsContent.goalTextColor, // Light purple background
                        borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(5)),
                      ),
                      child:  Text(
                        "Your Location",
                        style: TextStyle(
                          color:ColorsContent.signInGradientColorViolet, // Purple text
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white, // Off-white background
                        borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(5)),
                      ),
                      child:  Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: ColorsContent.newThemeColor,
                            size: size.width * 0.06,
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Text(
                                widget.goalDetailModel.goals!.location?.locationAddress
                                    ?.replaceAll(
                                    RegExp(r'[^a-zA-Z0-9, ]'),
                                    '') // Remove unwanted characters
                                    .replaceAll(RegExp(r',\s*,+'),
                                    ',') // Replace multiple consecutive commas with a single comma
                                    .replaceAll(RegExp(r'^,|,$'),
                                    '') // Remove leading and trailing commas
                                    .trim() ??
                                    "",
                                style: CustomTextStyles
                                    .bodyMediumGray700_1,
                                overflow: TextOverflow.visible,
                                maxLines: 4, // Ensures scrolling works
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ):
              const SizedBox(),
              


              widget.goalDetailModel.goals!.action!.isEmpty
                  ? const SizedBox()
                  :  const SizedBox(height: 10),
              Consumer<AdDreamsGoalsProvider>(
                builder: (context, adDreamsGoalsProvider, _) {
                  logger.w("adDreamsGoalsProvider.goalModelIdName: ${adDreamsGoalsProvider.goalModelIdName}");

                  return widget.goalDetailModel.goals!.action!.isNotEmpty
                      ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: ColorsContent.newThemeColor,
                        width: 0.3,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header container
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: ColorsContent.goalTextColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(5),
                            ),
                          ),
                          child: Text(
                            "Actions",
                            style: TextStyle(
                              color: ColorsContent.signInGradientColorViolet,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Content container
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(5),
                            ),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: widget.goalDetailModel.goals!.action!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: GestureDetector(
                                  onTap: () {
                                    // Handle tap
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ColorsContent.newThemeColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Text(
                                              widget.goalDetailModel.goals!.action![index].actionTitle ?? "",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Open Sans',
                                                color: Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                      : const SizedBox();
                },
              ),

              SizedBox(
                height: size.height * 0.04,
              ),

            ],
          ),
        ),
      ),
    );
  }

  // Widget _buildSaveButton(BuildContext context) {
  //   return Consumer<AdDreamsGoalsProvider>(
  //       builder: (context, adDreamsGoalsProvider, _) {
  //     return CustomElevatedButton(
  //       loading: adDreamsGoalsProvider.saveAddActionsLoading,
  //       onPressed: () async {
  //         List<GoalModelIdName> actionIds = [];
  //         actionIds.addAll(adDreamsGoalsProvider.goalModelIdName);
  //
  //         await adDreamsGoalsProvider.updateGoalFunction(
  //           context,
  //           title: widget.goalDetailModel.goals!.goalTitle.toString(),
  //           details: widget.goalDetailModel.goals!.goalDetails.toString(),
  //           mediaName: [],
  //           locationName:
  //               widget.goalDetailModel.goals!.location!.locationName.toString(),
  //           locationLatitude:
  //               widget.goalDetailModel.goals!.location!.locationLatitude.toString(),
  //           locationLongitude:
  //               widget.goalDetailModel.goals!.location!.locationLongitude.toString(),
  //           locationAddress:
  //               widget.goalDetailModel.goals!.location!.locationAddress.toString(),
  //           categoryId: "",
  //           gemEndDate: widget.goalDetailModel.goals!.goalEnddate.toString(),
  //           actionId: adDreamsGoalsProvider.goalModelIdName,
  //         );
  //         GoalsDreamsProvider goalsDreamsProvider =
  //             Provider.of<GoalsDreamsProvider>(
  //           context,
  //           listen: false,
  //         );
  //         goalsDreamsProvider.fetchGoalsAndDreams(initial: true);
  //       },
  //       height: 40,
  //       text: "Update",
  //       margin: const EdgeInsets.only(left: 2),
  //       buttonStyle: CustomButtonStyles.outlinePrimaryTL5,
  //       buttonTextStyle:
  //           CustomTextStyles.titleSmallHelveticaOnSecondaryContainer,
  //     );
  //   });
  // }
  //
  // Widget _buildCloseEditText(
  //   BuildContext context, {
  //   required String content,
  //   void Function()? onTap,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 2),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         border: Border.all(),
  //         borderRadius: BorderRadius.circular(
  //           1,
  //         ),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(content),
  //           CustomImageView(
  //             onTap: onTap,
  //             imagePath: ImageConstant.imgCloseGray700,
  //             height: 30,
  //             width: 30,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildAddActionsButton(BuildContext context) {
  //   return CustomElevatedButton(
  //     onPressed: () {
  //       Navigator.of(context).push(
  //         MaterialPageRoute(
  //           builder: (context) => const AddactionsScreen(),
  //         ),
  //       );
  //     },
  //     height: 40,
  //     text: "Add Actions",
  //     margin: const EdgeInsets.only(left: 2),
  //     buttonStyle: CustomButtonStyles.outlinePrimary,
  //     buttonTextStyle: CustomTextStyles.titleSmallOnSecondaryContainer_1,
  //   );
  // }

  Widget _buildUntitledOne(BuildContext context, Size size,
      {required String category,
        required String createDate,
        required String achiveDate,
        required String status,
        required String comments}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
                color: ColorsContent.newThemeColor,
                width: 0.3), // Light purple border
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorsContent.goalTextColor, // Light purple background
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(5)),
                ),
                child:  Text(
                  "Category",
                  style: TextStyle(
                    color:ColorsContent.signInGradientColorViolet, // Purple text
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white, // Off-white background
                  borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(5)),
                ),
                child: Text(
                  category, // e.g., "Health & Fitness"
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
                color: ColorsContent.newThemeColor,
                width: 0.3), // Light purple border
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorsContent.goalTextColor, // Light purple background
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(5)),
                ),
                child:  Text(
                  "Created Date",
                  style: TextStyle(
                    color:ColorsContent.signInGradientColorViolet, // Purple text
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white, // Off-white background
                  borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(5)),
                ),
                child: Text(
                  formatDate(int.parse(createDate)), // e.g., "Health & Fitness"
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
                color: ColorsContent.newThemeColor,
                width: 0.3), // Light purple border
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorsContent.goalTextColor, // Light purple background
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(5)),
                ),
                child:  Text(
                  "Achievement Date",
                  style: TextStyle(
                    color:ColorsContent.signInGradientColorViolet, // Purple text
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white, // Off-white background
                  borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(5)),
                ),
                child: Text(
                  achiveDate == "" ? "" : formatDate2(int.parse(achiveDate)),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
                color: ColorsContent.newThemeColor,
                width: 0.3), // Light purple border
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorsContent.goalTextColor, // Light purple background
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(5)),
                ),
                child:  Text(
                  "Status",
                  style: TextStyle(
                    color:ColorsContent.signInGradientColorViolet, // Purple text
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white, // Off-white background
                  borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(5)),
                ),
                child: Text(
                  status == "0" ? "Active" : "DeActive",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
                color: ColorsContent.newThemeColor,
                width: 0.3), // Light purple border
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorsContent.goalTextColor, // Light purple background
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(5)),
                ),
                child:  Text(
                  "Description",
                  style: TextStyle(
                    color:ColorsContent.signInGradientColorViolet, // Purple text
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white, // Off-white background
                  borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(5)),
                ),
                child: Text(
                  comments,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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
              color: index == currentIndex
                  ? ColorsContent.newThemeColor
                  : ColorsContent.goalNotCompletedColorNew,
              border: Border.all(
                color: Colors.white, // Change to your desired border color
                width: 1.0,           // Adjust thickness as needed
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget buildAppBarGoalView(
    BuildContext context,
    Size size, {
    String? heading,
    required String id,
  }) {
    return CustomAppBar(
      leadingWidth: 36,
      leading: AppbarLeadingImage(
        onTap: () {
          Navigator.of(context).pop();
        },
        imagePath: ImageConstant.imgTelevision,
        margin: const EdgeInsets.only(
          left: 28,
          top: 19,
          bottom: 23,
        ),
      ),
      title: AppbarSubtitle(
        text: heading ?? "",
        margin: const EdgeInsets.only(
          left: 11,
        ),
      ),
      actions: [
        Consumer<GoalsDreamsProvider>(
          builder: (context, goalsDreamsProvider, _) {
            return PopupMenuButton<String>(
              onSelected: (value) {},
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    onTap: () {},
                    value: 'Edit',
                    child: Text(
                      'Edit',
                      style: CustomTextStyles.bodyMedium14,
                    ),
                  ),
                  PopupMenuItem<String>(
                    onTap: () {
                      goalsDreamsProvider.deleteGoalsFunction(
                        context,
                        deleteId: id,
                      );
                      Navigator.of(context).pop();
                    },
                    value: 'Delete',
                    child: Text(
                      'Delete',
                      style: CustomTextStyles.bodyMedium14,
                    ),
                  ),
                ];
              },
            );
          },
        ),
      ],
    );
  }
}
