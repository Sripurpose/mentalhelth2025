import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addactions_screen/model/alaram_info.dart';
import 'package:mentalhelth/screens/addactions_screen/provider/add_actions_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/model/actions_details_model.dart';
import 'package:mentalhelth/screens/goals_dreams_page/provider/goals_dreams_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/screens/edit_actions/edit_actions_screen.dart';
import 'package:mentalhelth/screens/journal_view_screen/widgets/jouranl_view_google_map.dart';
import 'package:mentalhelth/screens/journal_view_screen/widgets/journal_audio_player.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/logic/logic.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/custom_checkbox_button.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/video_player.dart';
import 'package:mentalhelth/widgets/widget/shimmer.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/app_bar/appbar_subtitle.dart';
import '../../../../widgets/app_bar/custom_app_bar.dart';
import '../../../widgets/functions/popup.dart';
import '../../no_internet/duplicate_screen.dart';


class ActionViewInParallelScreen extends StatefulWidget {
  const ActionViewInParallelScreen({
    Key? key,
  }) : super(
    key: key,
  );

  @override
  State<ActionViewInParallelScreen> createState() =>
      _ActionViewInParallelScreenState();
}

class _ActionViewInParallelScreenState
    extends State<ActionViewInParallelScreen> {
  bool isCompleted = false;
  List<String> audioList = [];
  List<String> imageList = [];
  List<String> videoList = [];
  PageController photoController = PageController();
  int photoCurrentIndex = 0;
  PageController videoController = PageController();
  int videoCurrentIndex = 0;
  AlarmInfo? alarmInfo;
  var logger = Logger();
  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    MentalStrengthEditProvider mentalStrengthEditProvider =
    Provider.of<MentalStrengthEditProvider>(
      context,
      listen: false,
    );
    AddActionsProvider addActionsProvider = Provider.of<AddActionsProvider>(
      context,
      listen: false,
    );
    //added sarath
    if( mentalStrengthEditProvider.actionsDetailsModel != null){
      addAudio(
          actionsDetailsModel: mentalStrengthEditProvider.actionsDetailsModel!);
      addImage(
          actionsDetailsModel: mentalStrengthEditProvider.actionsDetailsModel!);
      addVideo(
          actionsDetailsModel: mentalStrengthEditProvider.actionsDetailsModel!);
      alarmInfo = await addActionsProvider.getDataByIdFromHiveBox(
        int.parse(
            mentalStrengthEditProvider.actionsDetailsModel!.actions!.actionId!),
      );
    }

    logger.w("widget.action.actionStatus${mentalStrengthEditProvider.actionsDetailsModel!.actions!.actionStatus!}");

    setState(() {});
  }

  void addAudio({required ActionsDetailsModel actionsDetailsModel}) {
    for (int i = 0; i < actionsDetailsModel.actions!.gemMedia!.length; i++) {
      if (actionsDetailsModel.actions!.gemMedia![i].mediaType == 'audio') {
        audioList.add(actionsDetailsModel.actions!.gemMedia![i].gemMedia!);
      }
    }
  }

  void addImage({required ActionsDetailsModel actionsDetailsModel}) {
    for (int i = 0; i < actionsDetailsModel.actions!.gemMedia!.length; i++) {
      if (actionsDetailsModel.actions!.gemMedia![i].mediaType == 'image') {
        // setState(() {
        imageList.add(actionsDetailsModel.actions!.gemMedia![i].gemMedia!);
        // });
      }
    }
  }

  void addVideo({required ActionsDetailsModel actionsDetailsModel}) {
    for (int i = 0; i < actionsDetailsModel.actions!.gemMedia!.length; i++) {
      if (actionsDetailsModel.actions!.gemMedia![i].mediaType == 'video') {
        // setState(() {
        videoList.add(actionsDetailsModel.actions!.gemMedia![i].gemMedia!);
        // });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<MentalStrengthEditProvider>(
        builder: (context, mentalStrengthEditProvider, _) {
          return  SafeArea(
            child: Consumer<MentalStrengthEditProvider>(
                builder: (context, mentalStrengthEditProvider, _) {
                  return Scaffold(
                    appBar: mentalStrengthEditProvider.actionsDetailsModel == null
                        ? AppBar()
                        : buildAppBarActionView(context, size,
                      heading: capitalText(mentalStrengthEditProvider
                          .actionsDetailsModel!.actions!.actionTitle
                          .toString()),
                      id: mentalStrengthEditProvider
                          .actionsDetailsModel!.actions!.actionId
                          .toString(),
                      actionStatus:  mentalStrengthEditProvider
                          .actionsDetailsModel!.actions!.actionStatus
                          .toString(),),
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
                                  mentalStrengthEditProvider.actionsDetailsModel == null
                                      ? shimmerView(size: size)
                                      : Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      mentalStrengthEditProvider.actionsDetailsModel ==
                                          null
                                          ? const SizedBox()
                                          : _buildUntitledOne(
                                        context,
                                        size,
                                        category: mentalStrengthEditProvider
                                            .actionsDetailsModel!.actions!.goalTitle
                                            .toString(),
                                        createDate: mentalStrengthEditProvider
                                            .actionsDetailsModel!
                                            .actions!
                                            .actionDatetime
                                            .toString(),
                                        achiveDate: mentalStrengthEditProvider
                                            .actionsDetailsModel!
                                            .actions!
                                            .actionDatetime
                                            .toString(),
                                        status: mentalStrengthEditProvider
                                            .actionsDetailsModel!
                                            .actions!
                                            .actionStatus
                                            .toString(),
                                        comments:  mentalStrengthEditProvider
                                            .actionsDetailsModel!
                                            .actions!
                                            .actionDetails
                                            .toString(),
                                        title: mentalStrengthEditProvider
                                            .actionsDetailsModel!
                                            .actions!
                                            .actionTitle
                                            .toString(),
                                      ),
                                      audioList.isEmpty ?
                                      const SizedBox():
                                      const SizedBox(height: 10),
                                      audioList.isEmpty
                                          ? const SizedBox() :
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        height: size.height * 0.18, // Adjusted height for text + list
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  ImageConstant.actionDetailsMark, // Replace with your actual SVG asset path
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  "Audio",
                                                  style: CustomTextStyles.blackText16000000W700(),
                                                ),
                                                Text(
                                                  " : ",
                                                  style: CustomTextStyles.blackText16000000W700(),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10), // Space between text row and list
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: audioList.length,
                                                itemBuilder: (context, index) {
                                                  return JournalAudioPlayer(
                                                    url: audioList[index],
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      imageList.isEmpty?const SizedBox():
                                      const SizedBox(height: 10),
                                      imageList.isEmpty
                                          ?  const SizedBox() :
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        height: imageList.isNotEmpty ? size.height * 0.35 : 0, // increased for label + images
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  ImageConstant.actionDetailsMark, // Replace with your photo SVG path
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  "Photo",
                                                  style: CustomTextStyles.blackText16000000W700(),
                                                ),
                                                Text(
                                                  " : ",
                                                  style: CustomTextStyles.blackText16000000W700(),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  PageView.builder(
                                                    controller: photoController,
                                                    itemCount: imageList.length,
                                                    itemBuilder: (context, index) {
                                                      return CustomImageView(
                                                        fit: BoxFit.cover,
                                                        imagePath: imageList[index],
                                                        height: size.height * 0.30,
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
                                                    child: Center(
                                                      child: buildIndicators(
                                                        imageList.length,
                                                        photoCurrentIndex,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      videoList.isEmpty?
                                      SizedBox():
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      videoList.isEmpty? const SizedBox():
                                      const SizedBox(
                                        height: 0,
                                      ),
                                      videoList.isEmpty
                                          ? const SizedBox()
                                          : Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        height: videoList.isNotEmpty ? size.height * 0.35 : 0, // increased to include title
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  ImageConstant.actionDetailsMark, // Replace with your SVG icon for video
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  "Video",
                                                  style: CustomTextStyles.blackText16000000W700(),
                                                ),
                                                Text(
                                                  " : ",
                                                  style: CustomTextStyles.blackText16000000W700(),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  PageView.builder(
                                                    controller: videoController,
                                                    itemCount: videoList.length,
                                                    itemBuilder: (context, index) {
                                                      return VideoPlayerWidgetViewAndAlready(
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
                                                    child: Center(
                                                      child: buildIndicators(
                                                        videoList.length,
                                                        videoCurrentIndex,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      mentalStrengthEditProvider.actionsDetailsModel!.actions!.location?.locationAddress != null?
                                      const SizedBox(height: 10):const SizedBox(),
                                      mentalStrengthEditProvider.actionsDetailsModel!.actions!.location?.locationAddress != null?
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  ImageConstant.actionDetailsMark, // Replace with your location SVG asset
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  "Location",
                                                  style: CustomTextStyles.blackText16000000W700(),
                                                ),
                                                Text(
                                                  " : ",
                                                  style: CustomTextStyles.blackText16000000W700(),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  color: ColorsContent.newThemeColor,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: SingleChildScrollView(
                                                    scrollDirection: Axis.vertical,
                                                    child: Text(
                                                      mentalStrengthEditProvider.actionsDetailsModel?.actions?.location?.locationAddress
                                                          ?.replaceAll(RegExp(r'[^a-zA-Z0-9, ]'), '') // Remove unwanted characters
                                                          .replaceAll(RegExp(r',\s*,+'), ',') // Replace multiple consecutive commas
                                                          .replaceAll(RegExp(r'^,|,$'), '') // Trim leading/trailing commas
                                                          .trim() ??
                                                          "",
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w400,
                                                        fontFamily: 'Open Sans',
                                                        color: Colors.black,
                                                      ),
                                                      overflow: TextOverflow.visible,
                                                      maxLines: 4,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                          :
                                      const SizedBox(),
                                      const SizedBox(height: 2),
                                      mentalStrengthEditProvider.actionsDetailsModel!.actions!.actionStatus == "1" ||
                                          mentalStrengthEditProvider.actionsDetailsModel!.actions!.reminder == null ? const SizedBox():const SizedBox(height: 10),
                                      Consumer<AddActionsProvider>(
                                          builder: (context, addActionsProvider, _) {
                                            return Column(
                                              children: [
                                                mentalStrengthEditProvider.actionsDetailsModel!.actions!.actionStatus == "1" ||
                                                    mentalStrengthEditProvider.actionsDetailsModel!.actions!.reminder == null
                                                    ? const SizedBox()
                                                    : Container(
                                                  padding: const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Header row with SVG and "Reminder" label
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Expanded(
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                SvgPicture.asset(
                                                                  ImageConstant.actionDetailsMark,
                                                                ),
                                                                const SizedBox(width: 10),
                                                                Text(
                                                                  "Reminder",
                                                                  style: CustomTextStyles.blackText16000000W700(),
                                                                ),
                                                                const Text(
                                                                  " : ",
                                                                  style: TextStyle(
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.w600,
                                                                    fontFamily: 'Open Sans',
                                                                    color: Colors.black,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SvgPicture.asset(
                                                            ImageConstant.reminderClock,

                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(height: 10),

                                                      // Date row
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            "Date  : ",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w600,
                                                              fontFamily: 'Open Sans',
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              mentalStrengthEditProvider.actionsDetailsModel?.actions?.reminder?.reminder_startdate != null &&
                                                                  mentalStrengthEditProvider.actionsDetailsModel?.actions?.reminder?.reminder_enddate != null
                                                                  ? "${unixTimestampToDate(mentalStrengthEditProvider.actionsDetailsModel!.actions!.reminder!.reminder_startdate!)} to ${unixTimestampToDate(mentalStrengthEditProvider.actionsDetailsModel!.actions!.reminder!.reminder_enddate!)}"
                                                                  : "",
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w400,
                                                                fontFamily: 'Open Sans',
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(height: 5),

                                                      // Time row
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            "Time  : ",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w600,
                                                              fontFamily: 'Open Sans',
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              mentalStrengthEditProvider.actionsDetailsModel?.actions?.reminder?.from_time != null &&
                                                                  mentalStrengthEditProvider.actionsDetailsModel?.actions?.reminder?.to_time != null
                                                                  ? "${formatTimeOfDay(stringToTimeOfDay(mentalStrengthEditProvider.actionsDetailsModel!.actions!.reminder!.from_time!)!)} to ${formatTimeOfDay(stringToTimeOfDay(mentalStrengthEditProvider.actionsDetailsModel!.actions!.reminder!.to_time!)!)}"
                                                                  : "",
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w400,
                                                                fontFamily: 'Open Sans',
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(height: 5),

                                                      // Repeat row
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            "Repeat: ",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w600,
                                                              fontFamily: 'Open Sans',
                                                              color: Colors.black,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              mentalStrengthEditProvider.actionsDetailsModel?.actions?.reminder?.reminder_repeat ?? "",
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w400,
                                                                fontFamily: 'Open Sans',
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            );
                                          }),
                                      const SizedBox(height: 30),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          );
        });
  }

  /// Section Widget
  Widget _buildUntitledOne(BuildContext context, Size size,
      {required String category,
        required String createDate,
        required String achiveDate,
        required String status,
        required String comments,
        required String title,}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8), // Optional: adds inner spacing
          decoration: BoxDecoration(
            color: Colors.white, // White background
            borderRadius: BorderRadius.circular(5), // Rounded corners
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                ImageConstant.actionDetailsMark, // Replace with your actual asset path
              ),
              const SizedBox(width: 10,),
              Text(
                "Status : ",
                style: CustomTextStyles.blackText16000000W700(),
              ),
              SizedBox(
                // color: Colors.blue,
                width: size.width * 0.60,
                child: Text(
                  status == "0" ? "Active" : "DeActive",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Open Sans',
                    color: Colors.black,
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    ImageConstant.actionDetailsMark,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Goal",
                    style: CustomTextStyles.blackText16000000W700(),
                  ),
                  Text(
                    " : ",
                    style: CustomTextStyles.blackText16000000W700(),
                  ),
                  if (category.length < 25)
                    Flexible(
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Open Sans',
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
              if (category.length >= 25)
                SizedBox(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Open Sans',
                        color: Colors.black,
                      ),
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    ImageConstant.actionDetailsMark,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Title",
                    style: CustomTextStyles.blackText16000000W700(),
                  ),
                  Text(
                    " : ",
                    style: CustomTextStyles.blackText16000000W700(),
                  ),
                  if (title.length < 25)
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Open Sans',
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
              if (title.length >= 25)
                SizedBox(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Open Sans',
                        color: Colors.black,
                      ),
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    ImageConstant.actionDetailsMark,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Description",
                    style: CustomTextStyles.blackText16000000W700(),
                  ),
                  Text(
                    " : ",
                    style: CustomTextStyles.blackText16000000W700(),
                  ),
                  if (comments.length < 25)
                    Flexible(
                      child: Text(
                        comments,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Open Sans',
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
              if (comments.length >= 25)
                SizedBox(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Text(
                      comments,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Open Sans',
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String unixTimestampToDate(String timestamp) {
    try {
      // Convert the timestamp to an integer
      int unixTimestamp = int.parse(timestamp);

      // Create a DateTime object from the Unix timestamp (assumes timestamp is in seconds)
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);

      // Format the DateTime object into the desired string format
      final DateFormat formatter = DateFormat('dd MMM yyyy');
      String formattedDate = formatter.format(dateTime);

      return formattedDate;
    } catch (e) {
      print("Error converting timestamp: $e");
      return "Invalid date";
    }
  }

  String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod; // Hour within the 12-hour range
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    final formattedHour = (hour == 0 ? 12 : hour).toString(); // Adjust for midnight and noon
    final formattedMinute = time.minute.toString().padLeft(2, '0'); // Ensure two-digit minute

    return "$formattedHour:$formattedMinute $period";
  }
  TimeOfDay? stringToTimeOfDay(String time) {
    try {
      // Trim and normalize to uppercase
      String trimmedTime = time.trim().toUpperCase();

      // Remove any extraneous characters (e.g., '?')
      String cleanedTime = trimmedTime.replaceAll(RegExp(r'[^\d:APM]'), '');

      // Check if the cleaned time contains AM/PM
      bool isPM = cleanedTime.contains("PM");
      bool isAM = cleanedTime.contains("AM");

      // Remove AM/PM suffix
      cleanedTime = cleanedTime.replaceAll(RegExp(r'[APM]'), '').trim();

      // Validate format
      RegExp timeRegExp = RegExp(r'^(\d{1,2}):(\d{2})$');
      Match? match = timeRegExp.firstMatch(cleanedTime);

      if (match == null) {
        print("Invalid time format: $time");
        return null;
      }

      // Parse hour and minute
      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);

      // Adjust hour based on AM/PM
      if (isPM && hour < 12) {
        hour += 12;
      } else if (isAM && hour == 12) {
        hour = 0;
      }

      // Ensure hour is within valid range (0-23)
      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        print("Invalid time values: hour $hour, minute $minute");
        return null;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print("Error parsing time: $e");
      return null;
    }
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
                  : Colors.blue,
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


  PreferredSizeWidget buildAppBarActionView(BuildContext context, Size size,
      {String? heading, required String id,required actionStatus}) {
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
    );
  }
}
