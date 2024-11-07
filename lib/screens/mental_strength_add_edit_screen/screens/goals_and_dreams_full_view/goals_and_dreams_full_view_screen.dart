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
          color: appTheme.gray50,
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
                            color: ColorsContent.greyColor,
                            height: 8,
                            width: 8,
                            fit: BoxFit.contain,
                          ),
                          SvgPicture.asset(
                            ImageConstant.dotDot,
                            color: ColorsContent.greyColor,
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
              Center(
                child: SizedBox(
                  width: size.width * 0.55,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                    child: Text(
                      capitalText(
                          widget.goalDetailModel.goals!.goalTitle.toString()),
                      style: CustomTextStyles.blackText18000000W700(),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // Set the maximum number of lines to 3
                    ),
                  ),
                ),
              ),
              _buildUntitledOne(
                context,
                size,
                category: widget.goalDetailModel.goals!.goalTitle.toString(),
                createDate: widget.goalDetailModel.goals!.createdAt.toString(),
                achiveDate:
                    widget.goalDetailModel.goals!.goalEnddate.toString(),
                status: widget.goalDetailModel.goals!.goalStatus.toString(),
                comments: widget.goalDetailModel.goals!.goalDetails.toString(),
              ),
              audioList.isEmpty ? const SizedBox() : const SizedBox(height: 15),
              SizedBox(height: 10),
                  Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        "Audio",
                        style: CustomTextStyles.blackText16000000W600(),
                      ),
                    ),
              audioList.isEmpty
                  ? const SizedBox()
                  : const SizedBox(
                      height: 4,
                    ),
              audioList.isNotEmpty?
              SizedBox(
                height: audioList.length * size.height * 0.1,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: audioList.length,
                  itemBuilder: (context, index) {
                    return JournalAudioPlayer(
                      url: audioList[index],
                    );
                  },
                ),
              ):
              Text("NA",
                style: CustomTextStyles
                    .bodyMediumGray700_1,),
              imageList.isNotEmpty
                  ? const SizedBox(
                      height: 23,
                    )
                  : const SizedBox(),
            Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        "Photo",
                        style: CustomTextStyles.blackText16000000W600(),
                      ),
                    ),
              const SizedBox(height: 4),
              imageList.isEmpty ?
              Text("NA",
                style: CustomTextStyles
                    .bodyMediumGray700_1,):
              SizedBox(
                height: imageList.isNotEmpty ? size.height * 0.2 : 0,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: photoController,
                      itemCount: imageList.length,
                      itemBuilder: (context, index) {
                        return CustomImageView(
                          fit: BoxFit.cover,
                          imagePath: imageList[index],
                          height: size.height * 0.27,
                          width: size.width,
                          alignment: Alignment.center,
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
                        width: imageList.length * size.width * 0.1,
                        child: buildIndicators(
                          imageList.length,
                          photoCurrentIndex,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              videoList.isNotEmpty
                  ? const SizedBox(
                      height: 10,
                    )
                  : const SizedBox(),
              const SizedBox(
                height: 10,
              ),
             Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        "Video",
                        style: CustomTextStyles.blackText16000000W600(),
                      ),
                    ),
              const SizedBox(height: 4),
              videoList.isNotEmpty
                  ?
              SizedBox(
                height: videoList.isNotEmpty ? size.height * 0.3 : 0,
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
                        width: videoList.length * size.width * 0.1,
                        child: buildIndicators(
                          videoList.length,
                          videoCurrentIndex,
                        ),
                      ),
                    ),
                  ],
                ),
              ):
              Text("NA",
                style: CustomTextStyles
                    .bodyMediumGray700_1,),
              // _buildGrid(
              //   context,
              //   size,
              // ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  "Your Location",
                  style: CustomTextStyles.blackText16000000W600(),
                ),
              ),
              const SizedBox(height: 6),
              widget.goalDetailModel.goals!.location?.locationAddress != null ?
              SizedBox(
                child: Center(
                    child: Row(
                      children: [
                        CustomImageView(
                          imagePath: ImageConstant.imgLinkedin,
                          height: 23,
                          width: 23,
                        ),
                        Text(
                          widget.goalDetailModel.goals!.location!.locationAddress!.isEmpty
                              ? "NA"
                              :
                          widget.goalDetailModel.goals!.location!.locationAddress.toString(),
                          style: CustomTextStyles.bodyMediumGray700_1,
                        ),
                      ],
                    )
                ),
              )
                  :
              Text("NA",
                style: CustomTextStyles
                    .bodyMediumGray700_1,),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  "Actions",
                  style: CustomTextStyles.blackText16000000W600(),
                ),
              ),
              const SizedBox(height: 5),
              Consumer<AdDreamsGoalsProvider>(
                builder: (context, adDreamsGoalsProvider, _) {
                  logger.w("adDreamsGoalsProvider.goalModelIdName${adDreamsGoalsProvider.goalModelIdName}");
                  return
                    widget.goalDetailModel.goals!.action!.isNotEmpty ?
                    SizedBox(
                    height: widget.goalDetailModel.goals!.action!.length *
                        size.height *
                        0.06,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.goalDetailModel.goals!.action!.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                          //  Checkbox(value: false, onChanged: (value) {}),
                            GestureDetector(
                              onTap: () {
                                // Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //     builder: (context) => ActionsFullView(
                                //       id: mentalStrengthEditProvider
                                //           .getListGoalActionsModel!
                                //           .actions![index]
                                //           .id
                                //           .toString(),
                                //       indexs: index,
                                //     ),
                                //   ),
                                // );
                              },
                              child: Container(
                                height: size.height * 0.04,
                                width: size.width * 0.78,
                                padding: const EdgeInsets.only(
                                  bottom: 5,
                                  top: 5,
                                  left: 0,
                                  right: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    100,
                                  ),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [

                                    SizedBox(
                                      width: size.width * 0.6,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                                        child: Text(
                                          widget.goalDetailModel.goals!.action![index].actionTitle ?? "",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1, // Set the maximum number of lines to 3
                                        ),
                                      ),
                                    ),
                                    // CircleAvatar(
                                    //   radius: size.width * 0.04,
                                    //   backgroundColor: Colors.blue,
                                    //   child: Icon(
                                    //     Icons.arrow_forward_ios_outlined,
                                    //     color: Colors.white,
                                    //     size: size.width * 0.03,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );

                        // _buildCloseEditText(
                        //   context,
                        //   content:
                        //       adDreamsGoalsProvider.goalModelIdName[index].name,
                        //   onTap: () {
                        //     adDreamsGoalsProvider
                        //         .getAddActionIdAndNameClear(index);
                        //   },
                        // );
                      },
                    ),
                  ):
                    Text(
                      "NA",
                      style: CustomTextStyles.bodyMediumGray700_1,
                    );
                },
              ),
              const SizedBox(height: 20),

              widget.goalDetailModel.goals!.goalStatus == "1"
                  ? const Padding(
                      padding: EdgeInsets.only(
                        left: 0,
                        bottom: 10,
                      ),
                      child: Text(
                        "Completed",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        // style: theme.textTheme.titleSmall,
                      ),
                    )
                  : Consumer<GoalsDreamsProvider>(
                      builder: (context, goalsDreamsProvider, _) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 13,
                          bottom: 10,
                        ),
                        child: CustomCheckboxButton(
                          text: "Mark this goal as Completed",
                          value: isCompleted,
                          onChange: (value) async {
                            setState(() {
                              isCompleted = true;
                            });
                            await goalsDreamsProvider.updateGoalsStatus(
                              context,
                              goalId: widget.goalDetailModel.goals!.goalId!
                                  .toString(),
                              status: "1",
                            );
                            goalsDreamsProvider.fetchGoalsAndDreams(
                              initial: true,
                            );
                          },
                        ),
                      );
                    }),
              // _buildSaveButton(context),
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
        Row(
          children: [
            Text(
              "Category : ",
              style: CustomTextStyles.blackText16000000W600(),
            ),
            SizedBox(
              width: size.width * 0.45,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                child: Text(
                  category,
                  style: CustomTextStyles.bodyLargeGray700,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // Set the maximum number of lines to 3
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 6,
        ),
        Row(
          children: [
            Text(
              "Created Date : ",
              style: CustomTextStyles.blackText16000000W600(),
            ),
            Text(
              formatDate(int.parse(createDate)),
              style: CustomTextStyles.bodyLargeGray700,
            ),
          ],
        ),
        const SizedBox(
          height: 6,
        ),
        Row(
          children: [
            Text(
              "Achievement Date : ",
              style: CustomTextStyles.blackText16000000W600(),
            ),
            Text(
              achiveDate == "" ? "" : formatDate2(int.parse(achiveDate)),
              style: CustomTextStyles.bodyLargeGray700,
            ),
          ],
        ),
        const SizedBox(
          height: 6,
        ),
        Row(
          children: [
            Text(
              "Status : ",
              style: CustomTextStyles.blackText16000000W600(),
            ),
            Text(
              status == "0" ? "Active" : "DeActive",
              style: CustomTextStyles.bodyLargeGray700,
            ),
          ],
        ),
        const SizedBox(
          height: 6,
        ),
        Row(
          children: [
            Text(
              "Comments : ",
              style: CustomTextStyles.blackText16000000W600(),
            ),
            SizedBox(
              width: size.width * 0.55,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                child: comments != null ?
                Text(
                 comments,
                  style: CustomTextStyles.bodyLargeGray700,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // Set the maximum number of lines to 3
                ):
                Text(
                  "NA",
                  style: CustomTextStyles.bodyLargeGray700,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // Set the maximum number of lines to 3
                ),
              ),
            ),
          ],
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
              color: index == currentIndex ? Colors.blue : Colors.grey,
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
