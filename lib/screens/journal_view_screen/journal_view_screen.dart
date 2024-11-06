import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/home_screen/model/journal_details.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/screens/journal_list_screen/provider/journal_list_provider.dart';
import 'package:mentalhelth/screens/journal_list_screen/screens/edit_journal/edit_journal.dart';
import 'package:mentalhelth/screens/journal_view_screen/widgets/jouranl_view_google_map.dart';
import 'package:mentalhelth/screens/journal_view_screen/widgets/journal_audio_player.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/all_model.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/get_goals_model.dart'
// ignore: library_prefixes
    as goalMain;
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/list_goal_actions.dart'
    as action;
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/logic/date_format.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/custom_rating_bar.dart';
import 'package:mentalhelth/widgets/functions/popup.dart';
import 'package:mentalhelth/widgets/indicatores_widgets.dart';
import 'package:mentalhelth/widgets/video_player.dart';
import 'package:mentalhelth/widgets/widget/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:html_unescape/html_unescape.dart';

import '../../utils/logic/logic.dart';
import '../../widgets/background_image/background_imager.dart';
import '../journal_list_screen/journal_list_page.dart';

class JournalViewScreen extends StatefulWidget {
  const JournalViewScreen(
      {Key? key, required this.journalId, required this.index})
      : super(
          key: key,
        );

  final String journalId;
  final int index;

  @override
  State<JournalViewScreen> createState() => _JournalViewScreenState();
}

class _JournalViewScreenState extends State<JournalViewScreen> {
  late HomeProvider homeProvider;
  var logger = Logger();
  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {

    homeProvider = Provider.of<HomeProvider>(
      context,
      listen: false,
    );
    await homeProvider.fetchJournalDetails(
      journalId: widget.journalId,
    );
    if (homeProvider.journalDetails != null) {
      addAudio(
        journalDetails: homeProvider.journalDetails!,
      );
      addImage(
        journalDetails: homeProvider.journalDetails!,
      );
      addVideo(
        journalDetails: homeProvider.journalDetails!,
      );
    }
  }

  int sliderIndex = 1;

  PageController photoController = PageController();

  int photoCurrentIndex = 0;
  PageController videoController = PageController();

  int videoCurrentIndex = 0;
  List<String> audioList = [];

  List<String> imageList = [];

  List<String> videoList = [];

  void addAudio({required JournalDetails journalDetails}) {
    for (int i = 0; i < journalDetails.journals!.journalMedia!.length; i++) {
      if (journalDetails.journals!.journalMedia![i].mediaType == 'audio') {
        // setState(() {
        audioList.add(journalDetails.journals!.journalMedia![i].gemMedia!);
        // });
      }
    }
  }

  void addImage({required JournalDetails journalDetails}) {
    for (int i = 0; i < journalDetails.journals!.journalMedia!.length; i++) {
      if (journalDetails.journals!.journalMedia![i].mediaType == 'image') {
        // setState(() {
        imageList.add(journalDetails.journals!.journalMedia![i].gemMedia!);
        // });
      }
    }
  }

  void addVideo({required JournalDetails journalDetails}) {
    for (int i = 0; i < journalDetails.journals!.journalMedia!.length; i++) {
      if (journalDetails.journals!.journalMedia![i].mediaType == 'video') {
        // setState(() {
        videoList.add(journalDetails.journals!.journalMedia![i].gemMedia!);
        // });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Consumer2<DashBoardProvider,HomeProvider>(builder: (context, dashBoardProvider,homeProvider, _) {
        return Scaffold(
          appBar: buildAppBarJournalViewScreen(context, size, heading: "View your journal",
            onTap: (){
              Navigator.of(context).pop();
            }
          ),
          body: backGroundImager(
            size: size,
            child: Padding(
              padding: const EdgeInsets.only(
                  // left: 20,
                  // right: 20,
                  ),
              child:
                  Consumer<HomeProvider>(builder: (context, homeProvider, _) {
                    logger.w("audioList.length ${audioList.length}");
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      homeProvider.journalDetails == null
                          ? shimmerView(size: size)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildUntitledOne(context, size),
                                const SizedBox(height: 20),
                                Text(
                                  "In your mind",
                                  style: theme.textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 2),
                                SizedBox(
                                  width: size.width * 0.70,
                                 // color: Colors.amber,
                                  child: Text(
                                    homeProvider.journalDetails == null
                                        ? ""
                                        : HtmlUnescape().convert(homeProvider
                                        .journalDetails!.journals!.journalDesc
                                        .toString(),),
                                    maxLines:HtmlUnescape().convert(homeProvider
                                        .journalDetails!.journals!.journalDesc
                                        .toString(),).length,
                                    overflow: TextOverflow.ellipsis,
                                    style: CustomTextStyles.bodyMediumGray700_1,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                audioList.isEmpty
                                    ? const SizedBox()
                                    :
                                Padding(
                                        padding: const EdgeInsets.only(left: 2),
                                        child: Text(
                                          "Audio",
                                          style: theme.textTheme.bodyLarge,
                                        ),
                                      ),
                                audioList.isEmpty
                                    ? const SizedBox()
                                    : const SizedBox(height: 2),
                                audioList.isEmpty
                                    ?
                                const SizedBox()
                                    :
                                SizedBox(
                                  height: audioList.length <= 2
                                      ? size.height * 0.1 * audioList.length // Adjust height based on the number of audios
                                      : size.height * 0.25,  // Default height if more than 2 audios
                                  child: ListView.builder(
                                    itemCount: audioList.length,
                                    itemBuilder: (context, index) {
                                      return JournalAudioPlayer(
                                        url: audioList[index],
                                      );
                                    },
                                  ),
                                ),

                                imageList.isEmpty
                                    ? const SizedBox()
                                    : const SizedBox(
                                        height: 23,
                                      ),
                                // imageList.isEmpty
                                //     ? const SizedBox()
                                //     :
                                audioList.isEmpty?
                                    const SizedBox():
                                const SizedBox(height: 5),
                                imageList.isEmpty?
                     const SizedBox():
                                Padding(
                                        padding: const EdgeInsets.only(left: 2),
                                        child: Text(
                                          "Photo",
                                          style: theme.textTheme.bodyLarge,
                                        ),
                                      ),
                                imageList.isEmpty
                                    ? const SizedBox()
                                    : const SizedBox(height: 4),
                                imageList.isEmpty
                                    ?  const SizedBox()
                                    : SizedBox(
                                        height: size.height * 0.3,
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
                                              child: SizedBox(
                                                width: imageList.length *
                                                    size.width *
                                                    0.1,
                                                child: buildIndicators(
                                                  imageList.length,
                                                  photoCurrentIndex,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                imageList.isEmpty?
                                const SizedBox():
                                const SizedBox(height: 28),
                                videoList.isEmpty
                                    ? const SizedBox()
                                    : const SizedBox(
                                        height: 10,
                                      ),
                                videoList.isEmpty
                                    ? const SizedBox()
                                    :
                                Padding(
                                        padding: const EdgeInsets.only(left: 2),
                                        child: Text(
                                          "Video",
                                          style: theme.textTheme.bodyLarge,
                                        ),
                                      ),
                                videoList.isEmpty
                                    ? const SizedBox()
                                    : const SizedBox(height: 4),
                                videoList.isEmpty
                                    ?  const SizedBox()
                                    : SizedBox(
                                        height: size.height * 0.3,
                                        child: Stack(
                                          children: [
                                            PageView.builder(
                                              controller: videoController,
                                              itemCount: videoList.length,
                                              itemBuilder: (context, index) {
                                                logger.w("videoList${videoList}");
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
                                                width: videoList.length *
                                                    size.width *
                                                    0.1,
                                                child: buildIndicators(
                                                  videoList.length,
                                                  videoCurrentIndex,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                videoList.isEmpty?
                                const SizedBox():
                                const SizedBox(height: 28),
                                homeProvider.journalDetails!.journals!.location == null ?
                                    const SizedBox():
                                Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: Text(
                                    "Your Location",
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                homeProvider.journalDetails!.journals!.location == null
                                    ?
                             const SizedBox()
                                    :
                                Row(
                                  children: [
                                    CustomImageView(
                                      imagePath: ImageConstant.imgLinkedin,
                                      height: 23,
                                      width: 23,
                                    ),
                                    Text(
                                      homeProvider.journalDetails == null
                                          ? ""
                                          : homeProvider.journalDetails!.journals == null
                                          ? ""
                                          : homeProvider.journalDetails!.journals!.location ==
                                          null
                                          ? ""
                                          : homeProvider.journalDetails!.journals!
                                          .location!.locationName
                                          .toString(),
                                      style: CustomTextStyles.bodyMediumGray700_1,
                                    ),
                                  ],
                                ),
                                homeProvider.journalDetails!.journals!.location == null ?
                                const SizedBox():
                                const SizedBox(height: 19),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Text(
                                    "Rating as how you felt",
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                homeProvider.journalDetails == null
                                    ? const SizedBox()
                                    : CustomRatingBar(
                                        color: Colors.blue,
                                  initialRating: double.parse(
                                    homeProvider.journalDetails!.journals!.emotionValue?.toString() ?? '0',
                                  ),
                                        itemSize: 30,
                                      ),
                                const SizedBox(height: 22),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 6,
                                  ),
                                  child: Text(
                                    "Your emotional state ",
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                homeProvider.journalDetails == null
                                    ? const SizedBox()
                                    : Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Text(
                                          homeProvider.journalDetails!.journals!
                                              .emotionTitle
                                              .toString(),
                                          style: CustomTextStyles
                                              .bodyMediumGray700_1,
                                        ),
                                      ),
                                const SizedBox(height: 22),
                                Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: Text(
                                    "Like towards the reaction to the situation?",
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                homeProvider.journalDetails == null
                                    ? const SizedBox()
                                    : CustomRatingBar(
                                        color: Colors.blue,
                                        initialRating: double.parse(
                                          (homeProvider.journalDetails!.journals!.driveValue ?? 0).toString(),
                                        ),
                                        itemSize: 30,
                                      ),
                                const SizedBox(height: 29),
                                homeProvider.journalDetails?.journals?.goal == null?
                                const SizedBox():
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Text(
                                    "Goal  affected by your reaction",
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                homeProvider.journalDetails?.journals?.goal == null
                                    ?   const SizedBox()
                                    : Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(
                                          homeProvider.journalDetails!.journals!
                                                      .goal ==
                                                  null
                                              ? ""
                                              : homeProvider.journalDetails!
                                                  .journals!.goal!.goalTitle
                                                  .toString(),
                                          style: CustomTextStyles
                                              .bodyMediumGray700_1,
                                        ),
                                      ),
                                homeProvider.journalDetails?.journals?.goal == null ?
                                    const SizedBox():
                                const SizedBox(height: 33),
                                homeProvider.journalDetails?.journals?.goal == null?
                                    const SizedBox():
                                Padding(
                                  padding: const EdgeInsets.only(left: 7),
                                  child: Text(
                                    "Your action",
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                homeProvider.journalDetails?.journals?.goal == null
                                    ?
                                const SizedBox()

                                    : Padding(
                                        padding: const EdgeInsets.only(left: 7),
                                        child: Text(
                                          homeProvider.journalDetails!.journals!.action == null ||
                                              homeProvider.journalDetails!.journals!.action!.isEmpty
                                              ? ""
                                              : homeProvider.journalDetails!.journals!.action!
                                              .map((e) => e.actionTitle)
                                              .join(", "), // Join action titles with a comma, for example.
                                          style: CustomTextStyles.bodyMediumGray700_1,
                                        ),

                                ),
                                const SizedBox(height: 33),
                              ],
                            ),
                    ],
                  ),
                );
              }),
            ),
          ),
        );
      }),
    );
  }

  /// Section Widget
  Widget _buildUntitledOne(BuildContext context, Size size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Consumer2<HomeProvider, EditProfileProvider>(
            builder: (context, homeProvider, editProfileProvider, _) {
          return editProfileProvider.getProfileModel == null
              ? const SizedBox()
              : CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(
                    editProfileProvider.getProfileModel!.profileurl.toString(),
                  ),
                );
          // CustomImageView(
          //         imagePath:
          //             homeProvider.journalDetails!.journals!.displayImage,
          //         height: 71,
          //         width: 71,
          //         radius: BorderRadius.circular(
          //           35,
          //         ),
          //         alignment: Alignment.center,
          //       );
        }),
        SizedBox(
          width: size.width * 0.05,
        ),
        Consumer2<EditProfileProvider,HomeProvider>(builder: (context,editProfileProvider, homeProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                //color: Colors.red,
                width: size.width * 0.50,
                child: Text(
                  capitalText(editProfileProvider.getProfileModel == null
                      ? ""
                      : editProfileProvider.getProfileModel!.firstname.toString()),
                  style: CustomTextStyles.bodyLarge18,
                ),
              ),
              Text(
                homeProvider.journalDetails == null
                    ? ""
                    : dateTimeFormatter(
                        date: homeProvider
                            .journalDetails!.journals!.journalDatetime
                            .toString(),
                      ),
                style: CustomTextStyles.bodyMediumGray700,
              ),
              homeProvider.journalDetails!.journals!.location == null ?
                  const SizedBox():
              Row(
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgLinkedin,
                    height: 23,
                    width: 23,
                  ),
                  Text(
                    homeProvider.journalDetails == null
                        ? ""
                        : homeProvider.journalDetails!.journals == null
                            ? ""
                            : homeProvider.journalDetails!.journals!.location ==
                                    null
                                ? ""
                                : homeProvider.journalDetails!.journals!
                                    .location!.locationName
                                    .toString(),
                    style: CustomTextStyles.bodyMediumGray700_1,
                  ),
                ],
              ),
            ],
          );
        }),
        const Spacer(),
        Consumer5<DashBoardProvider,JournalListProvider, HomeProvider, MentalStrengthEditProvider,
                EditProfileProvider>(
            builder: (contexts, dashBoardProvider,journalListProvider, homeProvider,
                mentalStrengthEditProvider, editProfileProvider, _) {
          return PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  onTap: () async {
                    mentalStrengthEditProvider.openAllCloser();
                    editProfileProvider.fetchUserProfile();
                    if (homeProvider.journalDetails != null) {
                      mentalStrengthEditProvider
                              .descriptionEditTextController.text =
                          homeProvider.journalDetails!.journals!.journalDesc
                              .toString();
                      for (int i = 0;
                          i <
                              homeProvider.journalDetails!.journals!
                                  .journalMedia!.length;
                          i++) {
                        if (homeProvider.journalDetails!.journals!
                                .journalMedia![i].mediaType ==
                            'audio') {
                          mentalStrengthEditProvider.alreadyRecordedFilePath
                              .add(
                            AllModel(
                              id: homeProvider.journalDetails!.journals!
                                  .journalMedia![i].mediaId
                                  .toString(),
                              value: homeProvider.journalDetails!.journals!
                                  .journalMedia![i].gemMedia!,
                            ),
                          );
                        }
                      }
                      for (int i = 0;
                          i <
                              homeProvider.journalDetails!.journals!
                                  .journalMedia!.length;
                          i++) {
                        if (homeProvider.journalDetails!.journals!
                                .journalMedia![i].mediaType ==
                            'image') {
                          mentalStrengthEditProvider.alreadyPickedImages.add(
                            AllModel(
                              id: homeProvider.journalDetails!.journals!
                                  .journalMedia![i].mediaId
                                  .toString(),
                              value: homeProvider.journalDetails!.journals!
                                  .journalMedia![i].gemMedia!,
                            ),
                          );
                        }
                      }
                      for (int i = 0;
                          i <
                              homeProvider.journalDetails!.journals!
                                  .journalMedia!.length;
                          i++) {
                        if (homeProvider.journalDetails!.journals!
                                .journalMedia![i].mediaType ==
                            'video') {
                          mentalStrengthEditProvider.alreadyPickedImages.add(
                            AllModel(
                              id: homeProvider.journalDetails!.journals!
                                  .journalMedia![i].mediaId
                                  .toString(),
                              value: homeProvider.journalDetails!.journals!
                                  .journalMedia![i].gemMedia!,
                            ),
                          );
                        }
                      }

                      if (homeProvider.journalDetails!.journals!.location !=
                          null) {
                        mentalStrengthEditProvider.selectedLocationName =
                            homeProvider.journalDetails!.journals!.location!
                                .locationName!
                                .toString();
                        mentalStrengthEditProvider.selectedLocationAddress =
                            homeProvider.journalDetails!.journals!.location!
                                .locationAddress!
                                .toString();
                        mentalStrengthEditProvider.selectedLatitude =
                            homeProvider.journalDetails!.journals!.location!
                                .locationLatitude!
                                .toString();

                        mentalStrengthEditProvider.locationLongitude =
                            homeProvider.journalDetails!.journals!.location!
                                .locationLongitude!
                                .toString();
                      }
                      mentalStrengthEditProvider.emotionalValueStar =
                          double.parse(
                        homeProvider.journalDetails!.journals!.emotionValue
                            .toString(),
                      );
                      mentalStrengthEditProvider.fetchEmotions(
                        editing: true,
                        emotionId: homeProvider
                            .journalDetails!.journals!.emotionId
                            .toString(),
                      );
                      // log(message)

                      mentalStrengthEditProvider.driveValueStar = double.parse(
                          homeProvider.journalDetails!.journals!.driveValue
                              .toString());
                      if (homeProvider.journalDetails!.journals!.goal != null) {
                        mentalStrengthEditProvider.goalsValue = goalMain.Goal(
                          id: homeProvider
                              .journalDetails!.journals!.goal!.goalId
                              .toString(),
                          title: homeProvider
                              .journalDetails!.journals!.goal!.goalTitle
                              .toString(),
                        );
                      }

                      for (int i = 0;
                          i <
                              homeProvider
                                  .journalDetails!.journals!.action!.length;
                          i++) {
                        mentalStrengthEditProvider.actionList.add(action.Action(
                          title: homeProvider
                              .journalDetails!.journals!.action![i].actionTitle,
                          id: homeProvider
                              .journalDetails!.journals!.action![i].actionId,
                        ));
                      }
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EditJournalMentalStrength(
                          valueBool: true,
                        ),
                      ),
                    );
                  },
                  value: 'Edit',
                  child: Text(
                    'Edit',
                    style: CustomTextStyles.bodyMedium14,
                  ),
                ),
                // PopupMenuItem<String>(
                //   value: 'Share',
                //   child: Text(
                //     'Share',
                //     style: CustomTextStyles.bodyMedium14,
                //   ),
                // ),
                PopupMenuItem<String>(
                  onTap: () {
                    customPopup(
                      context: context,
                      onPressedDelete: () {
                        journalListProvider
                            .deleteJournalsFunction(
                          journalId: homeProvider.journalDetails!.journals!.journalId.toString(),
                        )
                            .then((value) {
                          homeProvider.fetchJournals(initial: true);

                          // Check if the journal exists in the list and remove it
                          for (var journals in homeProvider.journalsModelList) {
                            if (journals.journalId ==
                                homeProvider.journalDetails!.journals!.journalId.toString()) {
                              homeProvider.journalsModelList.removeAt(widget.index);
                              break; // Stop the loop once item is removed
                            }
                          }

                          // Close the dialog and then close the previous screen if needed
                          Navigator.of(context).pop(); // Close the customPopup dialog
                          Future.delayed(Duration(milliseconds: 200), () {
                            Navigator.of(context).pop(); // Close the previous screen
                          });
                        });
                      },
                      title: 'Confirm Delete',
                      content: 'Are you sure you want to delete this journal?',
                    );
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
        }),
        // const Icon(
        //   Icons.more_vert,
        // ),
      ],
    );
  }

  /// Section Widget
}
