import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/model/goals_and_dreams_model.dart';
import 'package:mentalhelth/screens/goals_dreams_page/provider/goals_dreams_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/screens/actions_full_view/actions_full_view.dart';
import 'package:mentalhelth/screens/goals_dreams_page/screens/edit_goals_and_dreams/edit_goals_and_dreams.dart';
import 'package:mentalhelth/screens/journal_view_screen/widgets/jouranl_view_google_map.dart';
import 'package:mentalhelth/screens/journal_view_screen/widgets/journal_audio_player.dart';
import "package:mentalhelth/screens/mental_strength_add_edit_screen/model/list_goal_actions.dart"
    as actionss;
import 'package:mentalhelth/utils/core/date_time_utils.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/custom_checkbox_button.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/video_player.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/app_bar/appbar_subtitle.dart';
import '../../../../widgets/app_bar/custom_app_bar.dart';
import '../../../../widgets/functions/popup.dart';
import '../../../addactions_screen/provider/add_actions_provider.dart';
import '../../../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../../../no_internet/duplicate_screen.dart';

class GoalAndDreamFullViewScreen extends StatefulWidget {
  const GoalAndDreamFullViewScreen(
      {Key? key,
      required this.goalsanddream,
      required this.indexs,
      required this.goalStatus})
      : super(
          key: key,
        );

  final Goalsanddream goalsanddream;

  final int indexs;
  final String goalStatus;

  @override
  State<GoalAndDreamFullViewScreen> createState() =>
      _GoalAndDreamFullViewScreenState();
}

class _GoalAndDreamFullViewScreenState
    extends State<GoalAndDreamFullViewScreen> {
  bool isCompleted = false;
  bool isSingleActionCompleted = false;
  late GoalsDreamsProvider goalsDreamsProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  var logger = Logger();

  @override
  void initState() {
    addAudio();
    addImage();
    addVideo();
    goalsDreamsProvider =
        Provider.of<GoalsDreamsProvider>(context, listen: false);
    mentalStrengthEditProvider =
        Provider.of<MentalStrengthEditProvider>(context, listen: false);
    goalsDreamsProvider.fetchGoalsAndDreams(initial: true, context: context);
    mentalStrengthEditProvider.fetchGoalActions(
      goalId: widget.goalsanddream.goalId.toString(),
    );
    isActionCompletedList =
        List.filled(widget.goalsanddream.action!.length, false);
    super.initState();
  }

  int sliderIndex = 1;
  List<bool> isActionCompletedList = [];

  PageController photoController = PageController();

  int photoCurrentIndex = 0;
  PageController videoController = PageController();

  int videoCurrentIndex = 0;
  List<String> audioList = [];

  List<String> imageList = [];

  List<String> videoList = [];

  void addAudio() {
    for (int i = 0; i < widget.goalsanddream.gemMedia!.length; i++) {
      if (widget.goalsanddream.gemMedia![i].mediaType == 'audio') {
        // setState(() {
        audioList.add(widget.goalsanddream.gemMedia![i].gemMedia!);
        // });
      }
    }
  }

  void addImage() {
    for (int i = 0; i < widget.goalsanddream.gemMedia!.length; i++) {
      if (widget.goalsanddream.gemMedia![i].mediaType == 'image') {
        // setState(() {
        imageList.add(widget.goalsanddream.gemMedia![i].gemMedia!);
        // });
      }
    }
  }

  void addVideo() {
    for (int i = 0; i < widget.goalsanddream.gemMedia!.length; i++) {
      if (widget.goalsanddream.gemMedia![i].mediaType == 'video') {
        // setState(() {
        videoList.add(widget.goalsanddream.gemMedia![i].gemMedia!);
        // });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: ConnectivityWidget(
        child: Scaffold(
          appBar: buildAppBarGoalView(context, size,
              heading: widget.goalsanddream.goalTitle.toString(),
              id: widget.goalsanddream.goalId.toString(),
              goalStatus: widget.goalStatus),
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorsContent.homeBackGroundColor,
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUntitledOne(
                          context,
                          size,
                          category:
                              widget.goalsanddream.categoryName.toString(),
                          createDate: widget.goalsanddream.createdAt.toString(),
                          achiveDate:
                              widget.goalsanddream.goalEnddate.toString(),
                          status: widget.goalsanddream.goalStatus.toString(),
                          comments: widget.goalsanddream.goalDetails.toString(),
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
                                    fontFamily: 'Poppins',
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
                                    fontFamily: 'Poppins',
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
                                                    borderRadius: BorderRadius.zero, // Remove rounded corners
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
                                              radius: BorderRadius.circular(8), // your original radius
                                            ),
                                          );
                                        },
                                        onPageChanged: (int pageIndex) {
                                          setState(() {
                                            photoCurrentIndex = pageIndex;
                                          });
                                        },
                                      ),
                                      if(imageList.length != 1)
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
                                    fontFamily: 'Poppins',
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
                                            return GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: true,
                                                  builder: (_) => Dialog(
                                                    insetPadding: EdgeInsets.zero,
                                                    backgroundColor: Colors.black,
                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.zero,
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        // ✅ No hardcoded AspectRatio
                                                        Center(
                                                          child: VideoPlayerWidgetViewAndAlreadyGoalProgressBar(
                                                            videoUrl: videoList[index],
                                                          ),
                                                        ),

                                                        // Close button
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
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(5),
                                                child: VideoPlayerWidgetViewAndAlreadyGoal(
                                                  videoUrl: videoList[index],
                                                ),
                                              ),
                                            );
                                          },
                                          onPageChanged: (int pageIndex) {
                                            setState(() {
                                              videoCurrentIndex = pageIndex;
                                            });
                                          },
                                        ),
                                        // PageView.builder(
                                        //   controller: videoController,
                                        //   itemCount: videoList.length,
                                        //   itemBuilder: (context, index) {
                                        //     return VideoPlayerWidget(
                                        //       videoUrl: videoList[index],
                                        //     );
                                        //   },
                                        //   onPageChanged: (int pageIndex) {
                                        //     setState(() {
                                        //       videoCurrentIndex = pageIndex;
                                        //     });
                                        //   },
                                        // ),
                                        if(videoList.length != 1)
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

                        widget.goalsanddream.location?.locationAddress != null
                            ? const SizedBox(
                          height: 10,
                        )
                            : const SizedBox(),
                        widget
                            .goalsanddream.location?.locationAddress !=
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
                                    fontFamily: 'Poppins',
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
                                          widget.goalsanddream.location
                                              ?.locationAddress
                                              ?.replaceAll(
                                              RegExp(r'[^a-zA-Z0-9, ]'),
                                              '') // Remove unwanted characters
                                              .replaceAll(RegExp(r',\s*,+'),
                                              ',') // Replace multiple consecutive commas with a single comma
                                              .replaceAll(RegExp(r'^,|,$'),
                                              '') // Remove leading and trailing commas
                                              .trim() ??
                                              "",
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: 'Poppins',
                                          ),
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

                        widget.goalsanddream.action!.isEmpty
                            ? const SizedBox()
                            :  const SizedBox(height: 10),
                        widget.goalsanddream.action!.isEmpty
                            ? const SizedBox()
                            : Consumer3<MentalStrengthEditProvider,
                                AddActionsProvider, AdDreamsGoalsProvider>(
                                builder: (context,
                                    mentalStrengthEditProvider,
                                    addActionsProvider,
                                    adDreamsGoalsProvider,
                                    _) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: ColorsContent.newThemeColor,
                                            width: 0.3)
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header container for "Actions"
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: ColorsContent.goalTextColor, // Light purple background
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                                          ),
                                          child:  Text(
                                            "Actions",
                                            style: TextStyle(
                                              color:ColorsContent.signInGradientColorViolet, // Purple text
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),
                                        // Content container
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: const BoxDecoration(
                                            color:Colors.white, // Light background
                                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(5)),
                                          ),
                                          child: SizedBox(
                                            height: widget.goalsanddream.action!.length * size.height * 0.065,
                                            child: ListView.builder(
                                            //  physics: const NeverScrollableScrollPhysics(),
                                              itemCount: widget.goalsanddream.action!.length,
                                              itemBuilder: (context, index) {
                                                logger.w("${widget.goalsanddream.action![index].actionTitle}--widget.goalsanddream");
                                                return Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                            builder: (context) => ActionsFullView(
                                                              id: widget.goalsanddream.action![index].actionId.toString(),
                                                              indexs: index,
                                                              action: actionss.Action(
                                                                id: widget.goalsanddream.action![index].actionId,
                                                                title: widget.goalsanddream.action![index].actionTitle,
                                                                actionStatus: widget.goalsanddream.action![index].actionStatus,
                                                                actionDate: widget.goalsanddream.action![index].actionDatetime,
                                                              ),
                                                              goalId: widget.goalsanddream.goalId.toString(),
                                                              actionStatus: mentalStrengthEditProvider.getListGoalActionsModel?.actions?[index].actionStatus,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Center(
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                          child: Container(
                                                            margin: const EdgeInsets.only(bottom: 8),
                                                            height: size.height * 0.05,
                                                            width: size.width * 0.84,
                                                            padding: const EdgeInsets.only(bottom: 5, top: 5, right: 5),
                                                            decoration: BoxDecoration(
                                                              color: ColorsContent.newThemeColor,
                                                              borderRadius: BorderRadius.circular(5),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                // mentalStrengthEditProvider.getListGoalActionsModel?.actions != null &&
                                                                //     index < isActionCompletedList.length &&
                                                                //     mentalStrengthEditProvider.getListGoalActionsModel!.actions![index].actionStatus != "1"
                                                                //     ?
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                                                                  child: CustomCheckboxButton(
                                                                    text: "",
                                                                    value: isActionCompletedList[index],
                                                                    onChange: (value) async {
                                                                      customPopup(
                                                                        context: context,
                                                                        onPressedDelete: () async {
                                                                          setState(() {
                                                                            isActionCompletedList[index] = value!;
                                                                          });
                                                                          await addActionsProvider.updateActionStatusFunction(
                                                                            context,
                                                                            goalId: widget.goalsanddream.goalId ?? "",
                                                                            actionId: widget.goalsanddream.action![index].actionId ?? "",
                                                                          );
                                                                          mentalStrengthEditProvider.fetchGoalActions(
                                                                            goalId: widget.goalsanddream.goalId ?? "",
                                                                          );
                                                                          Navigator.of(context).pop();
                                                                        },
                                                                        yes: "Yes",
                                                                        title: 'Action Completed',
                                                                        content: 'Are you sure You want to mark this action as completed?',
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                                    // : const SizedBox(),
                                                                SizedBox(
                                                                  width: size.width * 0.45,
                                                                  child: Text(
                                                                    widget.goalsanddream.action![index].actionTitle.toString(),
                                                                    overflow: TextOverflow.ellipsis,
                                                                    maxLines: 1,
                                                                   // textAlign: TextAlign.center,
                                                                    style: const TextStyle(
                                                                      fontSize: 17,
                                                                      fontWeight: FontWeight.w500,
                                                                      fontFamily: 'Poppins',
                                                                      color: Colors.white,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 90,),
                                                                CircleAvatar(
                                                                  radius: size.width * 0.03,
                                                                  backgroundColor: ColorsContent.actionBackColor,
                                                                  child: Icon(
                                                                    Icons.arrow_forward_ios,
                                                                    color: Colors.white,
                                                                    size: size.width * 0.03,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                },
                              ),
                        const SizedBox(height: 20),
                        widget.goalsanddream.goalStatus == "1"
                            ? const Text(
                              "Completed",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                              // style: theme.textTheme.titleSmall,
                            )
                            : Consumer<GoalsDreamsProvider>(
                                builder: (context, goalsDreamsProvider, _) {
                                return CustomCheckboxButton(
                                  text: "Mark this goal as Completed",
                                  value: isCompleted,
                                  onChange: (value) async {
                                    customPopup(
                                      context: context,
                                      onPressedDelete: () async {
                                        await goalsDreamsProvider
                                            .updateGoalsStatus(
                                          context,
                                          goalId: widget.goalsanddream.goalId
                                              .toString(),
                                          status: "1",
                                        );
                                        await goalsDreamsProvider
                                            .fetchGoalsAndDreams(
                                                initial: true,
                                                context: context);
                                        mentalStrengthEditProvider
                                            .fetchGoalActions(
                                          goalId: widget.goalsanddream.goalId
                                              .toString(),
                                        );
                                        setState(() {
                                          isCompleted = true;
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      yes: "Yes",
                                      title: 'Goal Completed',
                                      content:
                                          'Are you sure You want to mark this goal as completed?',
                                    );
                                  },
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
  //           title: widget.goalsanddream.goalTitle.toString(),
  //           details: widget.goalsanddream.goalDetails.toString(),
  //           mediaName: [],
  //           locationName:
  //               widget.goalsanddream.location!.locationName.toString(),
  //           locationLatitude:
  //               widget.goalsanddream.location!.locationLatitude.toString(),
  //           locationLongitude:
  //               widget.goalsanddream.location!.locationLongitude.toString(),
  //           locationAddress:
  //               widget.goalsanddream.location!.locationAddress.toString(),
  //           categoryId: "",
  //           gemEndDate: widget.goalsanddream.goalEnddate.toString(),
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
                    fontFamily: 'Poppins',
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
                    fontFamily: 'Poppins',
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
                    fontFamily: 'Poppins',
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
                    fontFamily: 'Poppins',
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
                    fontFamily: 'Poppins',
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
                    fontFamily: 'Poppins',
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
                    fontFamily: 'Poppins',
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
                    fontFamily: 'Poppins',
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
                    fontFamily: 'Poppins',
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
                    fontFamily: 'Poppins',
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
    required String goalStatus,
  }) {
    return CustomAppBarNumu(
      backgroundColor: ColorsContent.homeBackGroundColor,
      leadingWidth: 36,
      leading: AppbarLeadingImage(
        onTap: () {
          Navigator.of(context).pop();
        },
        imagePath: ImageConstant.imgTelevision,
        margin: const EdgeInsets.only(
          left: 20,
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
          builder: (contexts, goalsDreamsProvider, _) {
            return PopupMenuButton<String>(
              color: Colors.white,
              icon: Icon(Icons.more_vert, color: ColorsContent.newThemeColor), // 👈 Vertical dots icon
              padding: EdgeInsets.zero, // Removes extra padding
              constraints: const BoxConstraints(
                minWidth: 100, // 👈 Reduce width here
                maxWidth: 100,
              ),
              // 👈 Change dot color here
              onSelected: (value) {},
              itemBuilder: (BuildContext context) {
                return [
                  if (goalStatus == "0")
                    PopupMenuItem<String>(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditGoalsScreen(
                              goalsanddream: widget.goalsanddream,
                            ),
                          ),
                        );
                      },
                      value: 'Edit',
                      height: 20, // 👈 Reduce height here
                      child:
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.mode_edit_outline_outlined, color: ColorsContent.newThemeColor),
                            const SizedBox(width: 5),
                            const Padding(
                              padding: EdgeInsets.only(right: 12.0),
                              child: Text('Edit', style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Roboto',
                                color:  Colors.black,
                              )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (goalStatus == "0")
                  const PopupMenuDivider(), // 👈 This adds the divider
                  PopupMenuItem<String>(
                    onTap: () {
                      customPopup(
                        context: context,
                        onPressedDelete: () async {
                          await goalsDreamsProvider.deleteGoalsFunction(
                            context,
                            deleteId: id,
                          );
                          await Future.delayed(const Duration(seconds: 1));
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        title: 'Confirm Delete',
                        content: 'Are you sure You want to Delete this Goal?',
                      );
                    },
                    height: 20, // 👈 Reduce height here
                    value: 'Delete',
                    child:
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete_outline, color: ColorsContent.newThemeColor),
                          const SizedBox(width: 5),
                          const Text('Delete',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Roboto',
                                color:  Colors.black,
                              )),
                        ],
                      ),
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
