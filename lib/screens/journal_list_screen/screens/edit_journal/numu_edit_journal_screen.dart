import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/emotions_model.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/screens/action_full_view_mental_helth/action_full_view_journal.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/screens/add_action/add_action_mental_strength.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/screens/add_goals_and_dreams_widget/add_goals_and_dreams_mental_strength.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/screens/choose_action/choose_action.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/screens/choose_goal/choose_goal.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/screens/goals_and_dreams_full_view/goals_and_dreams_full_view_screen.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/widgets/googlemap_widget/google_map_widget.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/widgets/popup/audio_popup.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/widgets/popup/camera_popup.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/widgets/popup/gallary_popup.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/logic/date_format.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/custom_button_style.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/custom_icon_button.dart';
import 'package:mentalhelth/widgets/custom_text_form_field.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:mentalhelth/widgets/widget/shimmer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:html_unescape/html_unescape.dart';
import '../../../../utils/logic/permissions.dart';
import '../../../../utils/theme/custom_text_style.dart';
import '../../../../utils/theme/theme_helper.dart';
import '../../../../widgets/app_bar/appbar_leading_image.dart';
import '../../../../widgets/custom_image_view.dart';
import '../../../../widgets/custom_rating_bar.dart';
import '../../../../widgets/functions/popup.dart';
import '../../../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../../../token_expiry/tocken_expiry_warning_screen.dart';
import '../../../token_expiry/token_expiry.dart';

class NumuEditJournalScreen extends StatefulWidget {
  const NumuEditJournalScreen({Key? key, this.valueBool = false})
      : super(
          key: key,
        );
  final bool valueBool;

  @override
  State<NumuEditJournalScreen> createState() => _NumuEditJournalScreenState();
}

class _NumuEditJournalScreenState extends State<NumuEditJournalScreen>
    with SingleTickerProviderStateMixin {
  late HomeProvider homeProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late EditProfileProvider editProfileProvider;
  late DashBoardProvider dashBoardProvider;
  late AdDreamsGoalsProvider adDreamsGoalsProvider;
  bool tokenStatus = false;
  var logger = Logger();
  late TabController _tabController;
  int currentTabIndex = 0;
  late FocusNode _descriptionFocusNode;
  late FocusNode _titleFocusNode;

  Emotion? _lowRangeEmotion;
  Emotion? _highRangeEmotion;

  bool isLowRange(double value) => value >= 1 && value <= 3;
  bool isHighRange(double value) => value >= 4 && value <= 5;

  @override
  void initState() {
    _descriptionFocusNode = FocusNode();
    _titleFocusNode = FocusNode();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentTabIndex = _tabController.index;
      });
    });

    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    mentalStrengthEditProvider =
        Provider.of<MentalStrengthEditProvider>(context, listen: false);
    dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
    editProfileProvider =
        Provider.of<EditProfileProvider>(context, listen: false);
    adDreamsGoalsProvider =
        Provider.of<AdDreamsGoalsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _descriptionFocusNode.unfocus();
      _titleFocusNode.unfocus(); // Ensure it does not get focus automatically
      mentalStrengthEditProvider.mediaSelected = -1;
      mentalStrengthEditProvider.editDetectedLinks.clear();
      _isTokenExpired();
    });
    logger.i(
        "mentalStrengthEditProvider.emotionValue${mentalStrengthEditProvider.emotionValue}");
    super.initState();
  }

  Future<void> _isTokenExpired() async {
    // await homeProvider.fetchChartView(context);
    await homeProvider.fetchJournals(initial: true,context: context,fullList: true);
    if (homeProvider.journalStatus == 404) {
      await homeProvider.fetchJournals(initial: true,context: context,fullList: true);
    }
    //await editProfileProvider.fetchUserProfile();
    tokenStatus = TokenManager.checkTokenExpiry();
    if (tokenStatus) {
      setState(() {
        logger.e("Token status changed: $tokenStatus");
      });
      logger.e("Token status changed: $tokenStatus");
    } else {
      logger.e("Token status changedElse: $tokenStatus");
    }
  }

  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    _titleFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // @override
  // void dispose() {
  //   MentalStrengthEditProvider mentalStrengthEditProvider =
  //       Provider.of<MentalStrengthEditProvider>(context, listen: false);
  //   mentalStrengthEditProvider.clearAllValuesInSaveTime();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
        onPopInvoked: (value) async {
          MentalStrengthEditProvider mentalStrengthEditProvider =
              Provider.of<MentalStrengthEditProvider>(context, listen: false);
          AdDreamsGoalsProvider adDreamsGoalsProvider =
              Provider.of<AdDreamsGoalsProvider>(context, listen: false);
          mentalStrengthEditProvider.clearAllValuesInSaveTime();
          adDreamsGoalsProvider.clearAction();
          mentalStrengthEditProvider.openGoalViewSheet = false;
          mentalStrengthEditProvider.goalDetailModel = null;
          mentalStrengthEditProvider.openActionFullView = false;
          mentalStrengthEditProvider.openAddAction = false;
        },
        child: tokenStatus == false
            ? Scaffold(
                body: SafeArea(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration:
                        BoxDecoration(color: ColorsContent.homeBackGroundColor),
                    child: Consumer4<
                            EditProfileProvider,
                            MentalStrengthEditProvider,
                            DashBoardProvider,
                            HomeProvider>(
                        builder: (context,
                            editProfileProvider,
                            mentalStrengthEditProvider,
                            dashBoardProvider,
                            homeProvider,
                            _) {
                      return GestureDetector(
                        onTap: () {
                          mentalStrengthEditProvider.openAllCloser();
                        },
                        child: Column(
                          children: [
                            buildAppBarJournalViewScreen(
                              context,
                              size,
                              heading: "Edit your mental strength",
                              onTap: () {
                                MentalStrengthEditProvider
                                    mentalStrengthEditProvider =
                                    Provider.of<MentalStrengthEditProvider>(
                                        context,
                                        listen: false);
                                AdDreamsGoalsProvider adDreamsGoalsProvider =
                                    Provider.of<AdDreamsGoalsProvider>(context,
                                        listen: false);
                                mentalStrengthEditProvider
                                    .clearAllValuesInSaveTime();
                                adDreamsGoalsProvider.clearAction();
                                mentalStrengthEditProvider.openGoalViewSheet =
                                    false;
                                mentalStrengthEditProvider.goalDetailModel =
                                    null;
                                mentalStrengthEditProvider.openActionFullView =
                                    false;
                                mentalStrengthEditProvider.openAddAction =
                                    false;
                                // Proper condition check before popping the screen
                                // if (mentalStrengthEditProvider.openGoalViewSheet) {
                                //   if (mentalStrengthEditProvider.goalDetailModel != null) {
                                //     Navigator.of(context).pop();
                                //   }
                                // } else {
                                //   Navigator.of(context).pop();
                                // }
                               if(mentalStrengthEditProvider.saveJournalLoading == false) {
                                 Navigator.of(context).pop();
                               }
                              },
                            ),

                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: size.width * 0.05, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Row with Back Button (Only shown if not on the first tab) and Progress Text
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Show Back Button only when on the 2nd tab or beyond
                                      if (currentTabIndex > 0)
                                        GestureDetector(
                                          onTap: () {
                                           if(mentalStrengthEditProvider.saveJournalLoading == false) {
                                             _tabController.animateTo(
                                                 currentTabIndex -
                                                     1); // Go to previous tab

                                             mentalStrengthEditProvider
                                                 .openGoalViewSheet = false;
                                             mentalStrengthEditProvider
                                                 .openActionFullView = false;
                                             mentalStrengthEditProvider
                                                 .openAddAction = false;
                                           }
                                          },
                                          child: mentalStrengthEditProvider.saveJournalLoading == false ?
                                          Row(
                                            children: [
                                              SvgPicture.asset(
                                                ImageConstant
                                                    .numuMentalBackButton,
                                                // Replace with your SVG file path
                                                width: 30,
                                                // Adjust size if needed
                                                height: 30,
                                              ),
                                              const SizedBox(width: 10),
                                              // Spacing between icon and text
                                              Text(
                                                "Back",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Poppins',
                                                  color: ColorsContent
                                                      .newThemeColor, // Adjust color as needed
                                                ),
                                              ),
                                            ],
                                          ):
                                              const SizedBox(),
                                        )
                                      else
                                        const SizedBox(width: 48),
                                      // Placeholder to keep alignment when back button is hidden

                                      // Progress Text (e.g., "1/6", "2/6")
                                      Text(
                                        "${currentTabIndex + 1}/6",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                          color: ColorsContent
                                              .newThemeColor, // Adjust color as needed
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),
                                  // Spacing between rows

                                  // Progress Bar (on a separate line)
                                  LinearProgressIndicator(
                                    value: (currentTabIndex + 1) / 6,
                                    // Dynamic progress
                                    backgroundColor: Colors.grey,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        ColorsContent.newThemeColor),
                                    minHeight: 4,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              child: Stack(
                                children: [
                                  TabBarView(
                                    controller: _tabController,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    // Prevents swipe gestures
                                    children: [
                                      _buildFirstTab(context,
                                          mentalStrengthEditProvider, size),
                                      _buildSecondTab(context, size),
                                      _buildThirdTab(context, size),
                                      _buildFourthTab(context, size),
                                      _buildFifthTab(context, size),
                                      _buildSixthTab(context, size),
                                    ],
                                  ),

                                  // Floating Button for navigation and submission
                                  if (currentTabIndex < 5 &&
                                      !(currentTabIndex == 4 &&
                                          mentalStrengthEditProvider
                                                  .goalsValue.id ==
                                              null)) ...[
                                    Positioned(
                                      bottom: size.height * 0.025,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: SizedBox(
                                          width: 70,
                                          height: 70,
                                          child: FloatingActionButton(
                                            backgroundColor: Colors.transparent,
                                            elevation: 0,
                                            // removes shadow
                                            highlightElevation: 0,
                                            focusElevation: 0,
                                            hoverElevation: 0,
                                            splashColor: Colors.transparent,
                                            // disables ripple effect
                                            foregroundColor: Colors.transparent,
                                            onPressed: () {
                                              // Check for required conditions before moving to the next tab
                                              if (currentTabIndex == 0) {
                                                mentalStrengthEditProvider.titleEditTextController.selection =
                                                const TextSelection.collapsed(offset: 0);
                                                mentalStrengthEditProvider.descriptionEditTextController.selection =
                                                const TextSelection.collapsed(offset: 0);
                                                if (mentalStrengthEditProvider
                                                        .titleEditTextController
                                                        .text
                                                        .isNotEmpty
                                                    // &&
                                                    // mentalStrengthEditProvider
                                                    //     .descriptionEditTextController
                                                    //     .text
                                                    //     .isNotEmpty
                                                ) {
                                                  _tabController.animateTo(
                                                      currentTabIndex + 1);
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "Title or Description are required."),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                  print(
                                                      "Title and Description are required.");
                                                }
                                              } else if (currentTabIndex == 1) {
                                                if (mentalStrengthEditProvider
                                                        .emotionalValueStar !=
                                                    null) {
                                                  _tabController.animateTo(
                                                      currentTabIndex + 1);
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "Emotional star rating is required."),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                  print(
                                                      "Emotional star rating,");
                                                }
                                              } else if (currentTabIndex == 2) {
                                                if (mentalStrengthEditProvider
                                                        .emotionValue !=
                                                    null) {
                                                  _tabController.animateTo(
                                                      currentTabIndex + 1);
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "Emotion selection is required."),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                  print(
                                                      "Emotion selection, is required.");
                                                }
                                              } else if (currentTabIndex == 3) {
                                                if (mentalStrengthEditProvider
                                                        .driveValueStar !=
                                                    null) {
                                                  _tabController.animateTo(
                                                      currentTabIndex + 1);
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          "Drive star rating is required."),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                  print(
                                                      "Drive star rating is required.");
                                                }
                                              } else {
                                                _tabController.animateTo(
                                                    currentTabIndex + 1);
                                              }
                                            },
                                            child: Image.asset(
                                              ImageConstant.splashNextIcon,
                                              width: 90,
                                              height: 90,
                                            ),
                                            shape: const CircleBorder(),
                                            heroTag: "next_button",
                                          ),
                                        ),
                                      ),
                                    )
                                  ] else if (currentTabIndex == 4 &&
                                      mentalStrengthEditProvider
                                              .goalsValue.id ==
                                          null) ...[
                                    Positioned(
                                      bottom: size.height * 0.02,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () async {
                                            logger.i(
                                                "homeProvider.currentPage${homeProvider.currentPage}");

                                            _isTokenExpired();
                                            if (!mentalStrengthEditProvider
                                                .isVideoUploading) {
                                              if (
                                              // mentalStrengthEditProvider
                                              //         .descriptionEditTextController
                                              //         .text
                                              //         .isNotEmpty &&
                                                  mentalStrengthEditProvider
                                                      .titleEditTextController
                                                      .text
                                                      .isNotEmpty) {
                                                if(!mentalStrengthEditProvider
                                                    .saveJournalLoading){
                                                  bool isSuccess =
                                                  await mentalStrengthEditProvider
                                                      .updateJournalLoading(
                                                    journalId: homeProvider
                                                        .journalDetails!
                                                        .journals!
                                                        .journalId
                                                        .toString(),
                                                    context,
                                                    journalTitle:
                                                    mentalStrengthEditProvider
                                                        .titleEditTextController
                                                        .text,
                                                    journalDesc:
                                                    mentalStrengthEditProvider
                                                        .descriptionEditTextController
                                                        .text,
                                                    emotionId:
                                                    mentalStrengthEditProvider
                                                        .emotionValue!.id
                                                        .toString(),
                                                    emotionValue:
                                                    mentalStrengthEditProvider
                                                        .emotionalValueStar
                                                        .toString(),
                                                    driveValue:
                                                    mentalStrengthEditProvider
                                                        .driveValueStar
                                                        .toString(),
                                                    goalId:
                                                    mentalStrengthEditProvider
                                                        .goalsValue.id
                                                        .toString(),
                                                    locationName:
                                                    mentalStrengthEditProvider
                                                        .selectedLocationName,
                                                    locationLatitude:
                                                    mentalStrengthEditProvider
                                                        .selectedLatitude,
                                                    locationLongitude:
                                                    mentalStrengthEditProvider
                                                        .selectedLongitude,
                                                    mediaThumbs: mentalStrengthEditProvider.mediaThumbList, // ✅ pass here
                                                    mediaName:
                                                    mentalStrengthEditProvider
                                                        .addMediaUploadResponseList,
                                                    locationAddress:
                                                    mentalStrengthEditProvider
                                                        .selectedLocationAddress,
                                                    actionIdList:
                                                    mentalStrengthEditProvider
                                                        .actionList
                                                        .map(
                                                            (e) => e.id ?? "")
                                                        .toList(),
                                                    editDetectedLinks: mentalStrengthEditProvider.editDetectedLinks,
                                                  );
                                                  if (isSuccess) {
                                                    Future.delayed(
                                                        const Duration(
                                                            seconds: 3),
                                                            () async {
                                                          //   homeProvider.currentPage == 1;
                                                          await homeProvider.fetchJournalsGridView(initial: true,context: context,fullList: true);

                                                          if (homeProvider
                                                              .journalGridStatus ==
                                                              404) {
                                                            await homeProvider.fetchJournalsGridView(initial: true,context: context,fullList: true);

                                                          }
                                                          logger.i(
                                                              "homeProvider.currentPage${homeProvider.currentPage}");
                                                        });

                                                    DashBoardProvider
                                                    dashBoardProvider =
                                                    Provider.of<
                                                        DashBoardProvider>(
                                                        context,
                                                        listen: false);
                                                    dashBoardProvider.changePage(
                                                        index: 2);
                                                  }
                                                }

                                              } else {
                                                showCustomSnackBar(
                                                  context: context,
                                                  message: "Enter Fields",
                                                );
                                              }
                                            } else {
                                              showCustomSnackBar(
                                                context: context,
                                                message:
                                                    "Please wait video upload",
                                              );
                                            }
                                            Navigator.of(context).pop();
                                            if (widget.valueBool) {
                                              Navigator.of(context).pop();
                                            }

                                            dashBoardProvider.changePage(
                                              index: 0,
                                            );
                                          },
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SvgPicture.asset(ImageConstant
                                                  .saveButtonNumuBuild),
                                              if (mentalStrengthEditProvider
                                                  .saveJournalLoading)
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 5, bottom: 5),
                                                  child: SpinKitWave(
                                                    color: Colors.white,
                                                    size: 25,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    Positioned(
                                      bottom: size.height * 0.02,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () async {
                                            logger.i(
                                                "homeProvider.currentPage${homeProvider.currentPage}");

                                            _isTokenExpired();
                                            if (!mentalStrengthEditProvider
                                                .isVideoUploading) {
                                              if (
                                              // mentalStrengthEditProvider
                                              //         .descriptionEditTextController
                                              //         .text
                                              //         .isNotEmpty &&
                                                  mentalStrengthEditProvider
                                                      .titleEditTextController
                                                      .text
                                                      .isNotEmpty) {

                                                if(!mentalStrengthEditProvider
                                                    .saveJournalLoading){
                                                  bool isSuccess =
                                                  await mentalStrengthEditProvider
                                                      .updateJournalLoading(
                                                    journalId: homeProvider
                                                        .journalDetails!
                                                        .journals!
                                                        .journalId
                                                        .toString(),
                                                    context,
                                                    journalTitle:
                                                    mentalStrengthEditProvider
                                                        .titleEditTextController
                                                        .text,
                                                    journalDesc:
                                                    mentalStrengthEditProvider
                                                        .descriptionEditTextController
                                                        .text,
                                                    emotionId:
                                                    mentalStrengthEditProvider
                                                        .emotionValue!.id
                                                        .toString(),
                                                    emotionValue:
                                                    mentalStrengthEditProvider
                                                        .emotionalValueStar
                                                        .toString(),
                                                    driveValue:
                                                    mentalStrengthEditProvider
                                                        .driveValueStar
                                                        .toString(),
                                                    goalId:
                                                    mentalStrengthEditProvider
                                                        .goalsValue.id
                                                        .toString(),
                                                    locationName:
                                                    mentalStrengthEditProvider
                                                        .selectedLocationName,
                                                    locationLatitude:
                                                    mentalStrengthEditProvider
                                                        .selectedLatitude,
                                                    locationLongitude:
                                                    mentalStrengthEditProvider
                                                        .selectedLongitude,
                                                    mediaThumbs: mentalStrengthEditProvider.mediaThumbList, // ✅ pass here
                                                    mediaName:
                                                    mentalStrengthEditProvider
                                                        .addMediaUploadResponseList,
                                                    locationAddress:
                                                    mentalStrengthEditProvider
                                                        .selectedLocationAddress,
                                                    actionIdList:
                                                    mentalStrengthEditProvider
                                                        .actionList
                                                        .map(
                                                            (e) => e.id ?? "")
                                                        .toList(),
                                                    editDetectedLinks: mentalStrengthEditProvider.editDetectedLinks,
                                                  );
                                                  if (isSuccess) {
                                                    Future.delayed(
                                                        const Duration(
                                                            seconds: 3),
                                                            () async {
                                                          //   homeProvider.currentPage == 1;
                                                          await homeProvider.fetchJournalsGridView(initial: true,context: context,fullList: true);
                                                          if (homeProvider
                                                              .journalGridStatus ==
                                                              404) {
                                                            await homeProvider.fetchJournalsGridView(initial: true,context: context,fullList: true);
                                                          }
                                                          logger.i(
                                                              "homeProvider.currentPage${homeProvider.currentPage}");
                                                        });

                                                    DashBoardProvider
                                                    dashBoardProvider =
                                                    Provider.of<
                                                        DashBoardProvider>(
                                                        context,
                                                        listen: false);
                                                    dashBoardProvider.changePage(
                                                        index: 2);
                                                  }



                                                }else{

                                                }



                                              } else {
                                                showCustomSnackBar(
                                                  context: context,
                                                  message: "Enter Fields",
                                                );
                                              }
                                            } else {
                                              showCustomSnackBar(
                                                context: context,
                                                message:
                                                    "Please wait video upload",
                                              );
                                            }
                                            Navigator.of(context).pop();
                                            if (widget.valueBool) {
                                              Navigator.of(context).pop();
                                            }

                                            dashBoardProvider.changePage(
                                              index: 0,
                                            );
                                          },
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SvgPicture.asset(ImageConstant
                                                  .saveButtonNumuBuild),
                                              if (mentalStrengthEditProvider
                                                  .saveJournalLoading)
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 5, bottom: 5),
                                                  child: SpinKitWave(
                                                    color: Colors.white,
                                                    size: 25,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],

                                  // Newly Added Widgets
                                  if (mentalStrengthEditProvider.openChooseGoal)
                                    const ScreenChooseGoalMentalStrength(),

                                  if (mentalStrengthEditProvider.openAddGoal)
                                    const AddGoalsDreamsBottomSheet(),

                                  if (mentalStrengthEditProvider
                                      .openGoalViewSheet)
                                    mentalStrengthEditProvider
                                                .goalDetailModel ==
                                            null
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: appTheme.gray50,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topRight: Radius.circular(25),
                                                topLeft: Radius.circular(25),
                                              ),
                                            ),
                                            margin: EdgeInsets.only(
                                                top: size.height * 0.15),
                                            child: shimmerList(
                                                height: size.height * 0.8,
                                                list: 10),
                                          )
                                        : GoalAndDreamFullViewBottomSheet(
                                            goalDetailModel:
                                                mentalStrengthEditProvider
                                                    .goalDetailModel!,
                                          ),

                                  if (mentalStrengthEditProvider
                                      .openChooseAction)
                                    ChooseActionMentalHelth(
                                        goal: mentalStrengthEditProvider
                                            .goalsValue),

                                  if (mentalStrengthEditProvider.openAddAction)
                                    AddActionMentalStrengthBottomSheet(
                                      goalId: mentalStrengthEditProvider
                                          .goalsValue.id
                                          .toString(),
                                    ),

                                  if (mentalStrengthEditProvider
                                      .openActionFullView)
                                    const ActionFullViewJournalCreateBottomSheet(),
                                ],
                              ),
                            ),

                            // Expanded(
                            //   child: Stack(
                            //     children: [
                            //       Container(
                            //         padding: EdgeInsets.only(
                            //           left: size.width * 0.05,
                            //           right: size.width * 0.05,
                            //         ),
                            //         color: mentalStrengthEditProvider
                            //             .openChooseGoal
                            //             ? Colors.blue[50]
                            //             : null,
                            //         child: SingleChildScrollView(
                            //           child: Column(
                            //             children: [
                            //               SizedBox(
                            //                 height: size.height * 0.02,
                            //               ),
                            //               Text(
                            //                 "Whats on your mind?",
                            //                 style: theme.textTheme.bodyLarge,
                            //               ),
                            //               SizedBox(
                            //                 height: size.height * 0.01,
                            //               ),
                            //               _buildTitleEditText(context),
                            //               // const Slider1ItemWidget(),
                            //               SizedBox(height: size.height * 0.01),
                            //               Text(
                            //                 "Description",
                            //                 style: theme.textTheme.bodyLarge,
                            //               ),
                            //               SizedBox(height: size.height * 0.01),
                            //               _buildDescriptionEditText(context),
                            //               CustomImageView(
                            //                 imagePath: ImageConstant.imgGroup27,
                            //                 height: 33,
                            //                 width: 5,
                            //               ),
                            //               _buildAddMediaColumn(
                            //                 context,
                            //                 size,
                            //               ),
                            //               SizedBox(height: size.height * 0.03),
                            //
                            //               // mentalStrengthEditProvider.mediaSelected == 3
                            //               //     ? const MentalGoogleMap()
                            //               //     : const SizedBox(),
                            //               const SizedBox(
                            //                 height: 10,
                            //               ),
                            //               CustomIconButton(
                            //                 height: size.height * 0.08,
                            //                 width: size.height * 0.08,
                            //                 padding: const EdgeInsets.all(
                            //                   11,
                            //                 ),
                            //                 decoration:
                            //                 IconButtonStyleHelper.fillBlue,
                            //                 child: CustomImageView(
                            //                   imagePath:
                            //                   ImageConstant.imgLightBulb,
                            //                 ),
                            //               ),
                            //               SizedBox(
                            //                 height: size.height * 0.03,
                            //               ),
                            //               CustomImageView(
                            //                 imagePath: ImageConstant.imgGroup28,
                            //                 height: 19,
                            //                 width: 5,
                            //               ),
                            //               SizedBox(height: size.height * 0.03),
                            //               Text(
                            //                 "Rate how you are feeling now?",
                            //                 style: theme.textTheme.bodyLarge,
                            //               ),
                            //               SizedBox(height: size.height * 0.01),
                            //               CustomRatingBar(
                            //                 initialRating:
                            //                 mentalStrengthEditProvider
                            //                     .emotionalValueStar,
                            //                 itemSize: 34,
                            //                 color: Colors.blue,
                            //                 onRatingUpdate: (value) {
                            //                   mentalStrengthEditProvider
                            //                       .changeEmotionalValueStar(
                            //                       value);
                            //                 },
                            //               ),
                            //               SizedBox(height: size.height * 0.01),
                            //               CustomImageView(
                            //                 imagePath: ImageConstant.imgGroup29,
                            //                 height: 33,
                            //                 width: 5,
                            //               ),
                            //               SizedBox(
                            //                 height: size.height * 0.03,
                            //               ),
                            //               Text(
                            //                 "What is your emotional state?",
                            //                 style: theme.textTheme.bodyLarge,
                            //               ),
                            //               SizedBox(height: size.height * 0.01),
                            //               mentalStrengthEditProvider
                            //                   .getEmotionsModel ==
                            //                   null
                            //                   ? const SizedBox()
                            //                   : Container(
                            //                 width: size.width * 0.60,
                            //                 // This controls the button width
                            //                 decoration: BoxDecoration(
                            //                   border: Border.all(
                            //                     color: Colors.grey,
                            //                     // Border color
                            //                     width:
                            //                     1.0, // Border width
                            //                   ),
                            //                   borderRadius:
                            //                   BorderRadius.circular(
                            //                       15.0),
                            //                   // Border radius for rounded corners
                            //                   color: Colors
                            //                       .white, // Background color (optional)
                            //                 ),
                            //                 child:
                            //                 DropdownButtonHideUnderline(
                            //                   child: DropdownButton2(
                            //                     isExpanded: true,
                            //                     // buttonWidth: size.width * 0.60, // Adjust the width of the button
                            //                     // buttonDecoration: BoxDecoration(
                            //                     //   borderRadius: BorderRadius.circular(15.0),
                            //                     //   border: Border.all(color: Colors.grey, width: 1.0),
                            //                     //   color: Colors.white,
                            //                     // ),
                            //                     // dropdownWidth: 190, // Set the desired width for the dropdown menu
                            //                     // dropdownDecoration: BoxDecoration(
                            //                     //   borderRadius: BorderRadius.circular(15.0),
                            //                     //   color: Colors.white,
                            //                     // ),
                            //                     value:
                            //                     mentalStrengthEditProvider
                            //                         .emotionValue,
                            //                     //icon: const Icon(Icons.keyboard_arrow_down),
                            //                     dropdownStyleData:
                            //                     DropdownStyleData(
                            //                       maxHeight: 300,
                            //                       width: 250,
                            //                       decoration:
                            //                       BoxDecoration(
                            //                         borderRadius:
                            //                         BorderRadius
                            //                             .circular(14),
                            //                         color: Colors.white,
                            //                       ),
                            //                       offset:
                            //                       const Offset(0, 0),
                            //                       scrollbarTheme:
                            //                       ScrollbarThemeData(
                            //                         radius: const Radius
                            //                             .circular(40),
                            //                         thickness:
                            //                         MaterialStateProperty
                            //                             .all(6),
                            //                         thumbVisibility:
                            //                         MaterialStateProperty
                            //                             .all(true),
                            //                       ),
                            //                     ),
                            //                     items:
                            //                     mentalStrengthEditProvider
                            //                         .getEmotionsModel!
                            //                         .emotions!
                            //                         .map((Emotion
                            //                     items) {
                            //                       return DropdownMenuItem(
                            //                         value: items,
                            //                         child: Padding(
                            //                           padding:
                            //                           const EdgeInsets
                            //                               .symmetric(
                            //                               horizontal:
                            //                               8.0),
                            //                           child: Text(
                            //                             items.title
                            //                                 .toString(),
                            //                             style:
                            //                             const TextStyle(
                            //                               color: Colors
                            //                                   .black, // Change to your desired color
                            //                             ),
                            //                           ),
                            //                         ),
                            //                       );
                            //                     }).toList(),
                            //                     onChanged:
                            //                         (Emotion? newValue) {
                            //                       setState(() {
                            //                         mentalStrengthEditProvider
                            //                             .emotionValue =
                            //                         newValue!;
                            //                       });
                            //                       _isTokenExpired();
                            //                     },
                            //                   ),
                            //                 ),
                            //               ),
                            //               SizedBox(height: size.height * 0.03),
                            //               CustomImageView(
                            //                 imagePath: ImageConstant.imgGroup29,
                            //                 height: 33,
                            //                 width: 5,
                            //               ),
                            //               SizedBox(height: size.height * 0.03),
                            //               Text(
                            //                 "Do you like your reaction to the situation?",
                            //                 style: theme.textTheme.bodyLarge,
                            //               ),
                            //               SizedBox(
                            //                 height: size.height * 0.01,
                            //               ),
                            //               CustomRatingBar(
                            //                 initialRating:
                            //                 mentalStrengthEditProvider
                            //                     .driveValueStar,
                            //                 itemSize: 34,
                            //                 color: Colors.blue,
                            //                 onRatingUpdate: (value) {
                            //                   mentalStrengthEditProvider
                            //                       .changeDriveValueStar(value);
                            //                 },
                            //               ),
                            //               SizedBox(height: size.height * 0.03),
                            //               CustomImageView(
                            //                 imagePath: ImageConstant.imgGroup29,
                            //                 height: 33,
                            //                 width: 5,
                            //               ),
                            //               SizedBox(height: size.height * 0.03),
                            //               Text(
                            //                 "Which goal is affected by your reaction?",
                            //                 style: theme.textTheme.bodyLarge,
                            //               ),
                            //               SizedBox(
                            //                 height: size.height * 0.02,
                            //               ),
                            //               ElevatedButton(
                            //                 onPressed: () {
                            //                   mentalStrengthEditProvider
                            //                       .openChooseGoalFunction();
                            //                 },
                            //                 style: ElevatedButton.styleFrom(
                            //                   backgroundColor: Colors.blue,
                            //                   shape: RoundedRectangleBorder(
                            //                     borderRadius:
                            //                     BorderRadius.circular(20),
                            //                   ),
                            //                 ),
                            //                 child: const Text(
                            //                   "Choose Goal",
                            //                   style: TextStyle(
                            //                     color: Colors.white,
                            //                   ),
                            //                 ),
                            //               ),
                            //               SizedBox(
                            //                 height: size.height * 0.01,
                            //               ),
                            //               mentalStrengthEditProvider
                            //                   .goalsValue.id ==
                            //                   null
                            //                   ? const SizedBox()
                            //                   : mentalStrengthEditProvider
                            //                   .goalsValue.id ==
                            //                   ""
                            //                   ? const SizedBox()
                            //                   : mentalStrengthEditProvider
                            //                   .goalsValue
                            //                   .id!
                            //                   .isEmpty
                            //                   ? const SizedBox()
                            //                   : Container(
                            //                 height: size.height *
                            //                     0.04,
                            //                 width:
                            //                 size.width * 0.7,
                            //                 padding:
                            //                 const EdgeInsets
                            //                     .only(
                            //                   bottom: 5,
                            //                   top: 5,
                            //                   left: 5,
                            //                   right: 5,
                            //                 ),
                            //                 decoration:
                            //                 BoxDecoration(
                            //                   color: Colors.white,
                            //                   borderRadius:
                            //                   BorderRadius
                            //                       .circular(
                            //                       100), // Makes it circular
                            //                   border: Border.all(
                            //                     color:
                            //                     Colors.grey,
                            //                     width: 1,
                            //                   ),
                            //                 ),
                            //                 child: Row(
                            //                   mainAxisAlignment:
                            //                   MainAxisAlignment
                            //                       .spaceBetween,
                            //                   children: [
                            //                     GestureDetector(
                            //                       onTap: () {
                            //                         customPopup(
                            //                           context:
                            //                           context,
                            //                           onPressedDelete:
                            //                               () async {
                            //                             mentalStrengthEditProvider
                            //                                 .cleaGoalValue();
                            //                             Navigator.of(
                            //                                 context)
                            //                                 .pop();
                            //                             // Close the bottom sheet after deleting
                            //                             //  Navigator.of(context).pop();  // This will close the galleryBottomSheet as well
                            //                           },
                            //                           yes: "Yes",
                            //                           title:
                            //                           'Do you Need Delete',
                            //                           content:
                            //                           'Are you sure do you need delete',
                            //                         );
                            //                       },
                            //                       child:
                            //                       CircleAvatar(
                            //                         radius:
                            //                         size.width *
                            //                             0.04,
                            //                         backgroundColor:
                            //                         Colors
                            //                             .blue,
                            //                         child: Icon(
                            //                           Icons.close,
                            //                           color: Colors
                            //                               .white,
                            //                           size: size
                            //                               .width *
                            //                               0.03,
                            //                         ),
                            //                       ),
                            //                     ),
                            //                     SizedBox(
                            //                       width:
                            //                       size.width *
                            //                           0.45,
                            //                       child:
                            //                       SingleChildScrollView(
                            //                         scrollDirection:
                            //                         Axis.horizontal,
                            //                         // Enable horizontal scrolling
                            //                         child: Text(
                            //                           mentalStrengthEditProvider
                            //                               .goalsValue
                            //                               .title
                            //                               .toString(),
                            //                           textAlign:
                            //                           TextAlign
                            //                               .center,
                            //                           style:
                            //                           const TextStyle(
                            //                             color: Colors
                            //                                 .grey,
                            //                           ),
                            //                           overflow:
                            //                           TextOverflow
                            //                               .ellipsis,
                            //                           // Add this line if you want to truncate long text
                            //                           maxLines:
                            //                           1, // Limit to 1 line for horizontal scrolling
                            //                         ),
                            //                       ),
                            //                     ),
                            //                     GestureDetector(
                            //                       onTap: () {
                            //                         mentalStrengthEditProvider
                            //                             .openGoalViewSheetFunction();
                            //                         mentalStrengthEditProvider
                            //                             .fetchGoalDetails(
                            //                           goalId: mentalStrengthEditProvider
                            //                               .goalsValue
                            //                               .id
                            //                               .toString(),
                            //                         );
                            //                       },
                            //                       child:
                            //                       CircleAvatar(
                            //                         radius:
                            //                         size.width *
                            //                             0.04,
                            //                         backgroundColor:
                            //                         Colors
                            //                             .blue,
                            //                         child: Icon(
                            //                           Icons
                            //                               .arrow_forward_ios_outlined,
                            //                           color: Colors
                            //                               .white,
                            //                           size: size
                            //                               .width *
                            //                               0.03,
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ],
                            //                 ),
                            //               ),
                            //               SizedBox(
                            //                 height: size.height * 0.03,
                            //               ),
                            //               CustomImageView(
                            //                 imagePath: ImageConstant.imgGroup29,
                            //                 height: 33,
                            //                 width: 5,
                            //               ),
                            //               SizedBox(height: size.height * 0.03),
                            //               Text(
                            //                 "Select an action?",
                            //                 style: theme.textTheme.bodyLarge,
                            //               ),
                            //               SizedBox(height: size.height * 0.03),
                            //               ElevatedButton(
                            //                 onPressed: () {
                            //                   if (mentalStrengthEditProvider
                            //                       .goalsValue.id ==
                            //                       null) {
                            //                     showCustomSnackBar(
                            //                       context: context,
                            //                       message: "Please choose your goal",
                            //                     );
                            //                   }else{
                            //                     mentalStrengthEditProvider
                            //                         .openChooseActionFunction();
                            //                   }
                            //
                            //                 },
                            //                 style: ElevatedButton.styleFrom(
                            //                   backgroundColor: Colors.blue,
                            //                   shape: RoundedRectangleBorder(
                            //                     borderRadius:
                            //                     BorderRadius.circular(20),
                            //                   ),
                            //                 ),
                            //                 child: const Text(
                            //                   "Choose Action",
                            //                   style: TextStyle(
                            //                     color: Colors.white,
                            //                   ),
                            //                 ),
                            //               ),
                            //               SizedBox(
                            //                 height: size.height * 0.01,
                            //               ),
                            //               SizedBox(
                            //                 height: mentalStrengthEditProvider
                            //                     .actionList.length *
                            //                     size.height *
                            //                     0.045,
                            //                 width: size.width * 0.7,
                            //                 child: ListView.builder(
                            //                   physics:
                            //                   const NeverScrollableScrollPhysics(),
                            //                   itemCount:
                            //                   mentalStrengthEditProvider
                            //                       .actionList.length,
                            //                   itemBuilder: (context, index) {
                            //                     return Container(
                            //                       height: size.height * 0.04,
                            //                       width: size.width * 0.7,
                            //                       padding:
                            //                       const EdgeInsets.only(
                            //                         bottom: 5,
                            //                         top: 5,
                            //                         left: 5,
                            //                         right: 5,
                            //                       ),
                            //                       margin: const EdgeInsets.only(
                            //                         bottom: 4,
                            //                       ),
                            //                       decoration: BoxDecoration(
                            //                         color: Colors.white,
                            //                         borderRadius:
                            //                         BorderRadius.circular(
                            //                             100), // Makes it circular
                            //                         border: Border.all(
                            //                           color: Colors.grey,
                            //                           width: 1,
                            //                         ),
                            //                       ),
                            //                       child: Row(
                            //                         mainAxisAlignment:
                            //                         MainAxisAlignment
                            //                             .spaceBetween,
                            //                         children: [
                            //                           GestureDetector(
                            //                             onTap: () {
                            //                               customPopup(
                            //                                 context: context,
                            //                                 onPressedDelete:
                            //                                     () async {
                            //                                   mentalStrengthEditProvider
                            //                                       .clearActionListSelected(
                            //                                     index: index,
                            //                                   );
                            //                                   Navigator.of(
                            //                                       context)
                            //                                       .pop();
                            //
                            //                                   // Close the bottom sheet after deleting
                            //                                   //  Navigator.of(context).pop();  // This will close the galleryBottomSheet as well
                            //                                 },
                            //                                 yes: "Yes",
                            //                                 title:
                            //                                 'Do you Need Delete',
                            //                                 content:
                            //                                 'Are you sure do you need delete',
                            //                               );
                            //                             },
                            //                             child: CircleAvatar(
                            //                               radius:
                            //                               size.width * 0.04,
                            //                               backgroundColor:
                            //                               Colors.blue,
                            //                               child: Icon(
                            //                                 Icons.close,
                            //                                 color: Colors.white,
                            //                                 size: size.width *
                            //                                     0.03,
                            //                               ),
                            //                             ),
                            //                           ),
                            //                           SizedBox(
                            //                             width:
                            //                             size.width * 0.45,
                            //                             // color:Colors.black,
                            //                             child:
                            //                             SingleChildScrollView(
                            //                               scrollDirection:
                            //                               Axis.horizontal,
                            //                               // Enable horizontal scrolling
                            //                               child: Text(
                            //                                 mentalStrengthEditProvider
                            //                                     .actionList[
                            //                                 index]
                            //                                     .title
                            //                                     .toString(),
                            //                                 textAlign: TextAlign
                            //                                     .center,
                            //                                 style:
                            //                                 const TextStyle(
                            //                                   color:
                            //                                   Colors.grey,
                            //                                 ),
                            //                                 overflow:
                            //                                 TextOverflow
                            //                                     .ellipsis,
                            //                                 // Add this line if you want to truncate long text
                            //                                 maxLines:
                            //                                 1, // Limit to 1 line for horizontal scrolling
                            //                               ),
                            //                             ),
                            //                           ),
                            //                           GestureDetector(
                            //                             onTap: () async {
                            //                               mentalStrengthEditProvider
                            //                                   .openActionFullViewFunction();
                            //                               await mentalStrengthEditProvider
                            //                                   .fetchActionDetails(
                            //                                 actionId:
                            //                                 mentalStrengthEditProvider
                            //                                     .actionList[
                            //                                 index]
                            //                                     .id
                            //                                     .toString(),
                            //                               );
                            //                             },
                            //                             child: CircleAvatar(
                            //                               radius:
                            //                               size.width * 0.04,
                            //                               backgroundColor:
                            //                               Colors.blue,
                            //                               child: Icon(
                            //                                 Icons
                            //                                     .arrow_forward_ios_outlined,
                            //                                 color: Colors.white,
                            //                                 size: size.width *
                            //                                     0.03,
                            //                               ),
                            //                             ),
                            //                           ),
                            //                         ],
                            //                       ),
                            //                     );
                            //                   },
                            //                 ),
                            //               ),
                            //
                            //               SizedBox(
                            //                 height: size.height * 0.03,
                            //               ),
                            //               CustomElevatedButton(
                            //                 loading: mentalStrengthEditProvider
                            //                     .saveJournalLoading,
                            //                 onPressed: () async {
                            //                   logger.i("homeProvider.currentPage${homeProvider.currentPage}");
                            //
                            //                   _isTokenExpired();
                            //                   if (!mentalStrengthEditProvider
                            //                       .isVideoUploading) {
                            //                     if (mentalStrengthEditProvider
                            //                         .descriptionEditTextController
                            //                         .text
                            //                         .isNotEmpty && mentalStrengthEditProvider
                            //                         .titleEditTextController
                            //                         .text
                            //                         .isNotEmpty) {
                            //                       bool isSuccess =
                            //                       await mentalStrengthEditProvider
                            //                           .updateJournalLoading(
                            //                         journalId: homeProvider
                            //                             .journalDetails!
                            //                             .journals!
                            //                             .journalId
                            //                             .toString(),
                            //                         context,
                            //                         journalTitle:mentalStrengthEditProvider
                            //                             .titleEditTextController
                            //                             .text,
                            //                         journalDesc:
                            //                         mentalStrengthEditProvider
                            //                             .descriptionEditTextController
                            //                             .text,
                            //                         emotionId:
                            //                         mentalStrengthEditProvider
                            //                             .emotionValue!.id
                            //                             .toString(),
                            //                         emotionValue:
                            //                         mentalStrengthEditProvider
                            //                             .emotionalValueStar
                            //                             .toString(),
                            //                         driveValue:
                            //                         mentalStrengthEditProvider
                            //                             .driveValueStar
                            //                             .toString(),
                            //                         goalId:
                            //                         mentalStrengthEditProvider
                            //                             .goalsValue.id
                            //                             .toString(),
                            //                         locationName:
                            //                         mentalStrengthEditProvider
                            //                             .selectedLocationName,
                            //                         locationLatitude:
                            //                         mentalStrengthEditProvider
                            //                             .selectedLatitude,
                            //                         locationLongitude:
                            //                         mentalStrengthEditProvider
                            //                             .locationLongitude,
                            //                         mediaName:
                            //                         mentalStrengthEditProvider
                            //                             .addMediaUploadResponseList,
                            //                         locationAddress:
                            //                         mentalStrengthEditProvider
                            //                             .selectedLocationAddress,
                            //                         actionIdList:
                            //                         mentalStrengthEditProvider
                            //                             .actionList
                            //                             .map((e) =>
                            //                         e.id ?? "")
                            //                             .toList(),
                            //                       );
                            //                       if (isSuccess) {
                            //                         Future.delayed(
                            //                             const Duration(
                            //                                 seconds: 3),
                            //                                 () async {
                            //                               //   homeProvider.currentPage == 1;
                            //                               await homeProvider.fetchJournals(pageNo:homeProvider.currentPage.toString());
                            //                               if(homeProvider.journalStatus == 404){
                            //                                 await homeProvider.fetchJournals(pageNo:1.toString());
                            //                               }
                            //                               logger.i("homeProvider.currentPage${homeProvider.currentPage}");
                            //                             });
                            //
                            //                         DashBoardProvider
                            //                         dashBoardProvider =
                            //                         Provider.of<
                            //                             DashBoardProvider>(
                            //                             context,
                            //                             listen: false);
                            //                         dashBoardProvider
                            //                             .changePage(index: 2);
                            //                       }
                            //                     } else {
                            //                       showCustomSnackBar(
                            //                         context: context,
                            //                         message: "Enter Fields",
                            //                       );
                            //                     }
                            //                   } else {
                            //                     showCustomSnackBar(
                            //                       context: context,
                            //                       message:
                            //                       "Please wait video upload",
                            //                     );
                            //                   }
                            //                   Navigator.of(context).pop();
                            //                   if (widget.valueBool) {
                            //                     Navigator.of(context).pop();
                            //                   }
                            //
                            //                   dashBoardProvider.changePage(
                            //                     index: 2,
                            //                   );
                            //                 },
                            //                 height: 65,
                            //                 text: "Update",
                            //                 buttonStyle:
                            //                 CustomButtonStyles.fillBlueTL13,
                            //                 buttonTextStyle: CustomTextStyles
                            //                     .titleLargeGray50,
                            //               ),
                            //               SizedBox(
                            //                 height: size.height * 0.03,
                            //               ),
                            //             ],
                            //           ),
                            //         ),
                            //       ),
                            //       mentalStrengthEditProvider.openChooseGoal
                            //           ? const ScreenChooseGoalMentalStrength()
                            //           : const SizedBox(),
                            //       mentalStrengthEditProvider.openAddGoal
                            //           ? const AddGoalsDreamsBottomSheet()
                            //           : const SizedBox(),
                            //       mentalStrengthEditProvider.openGoalViewSheet
                            //           ? mentalStrengthEditProvider
                            //           .goalDetailModel ==
                            //           null
                            //           ? Container(
                            //         decoration: BoxDecoration(
                            //           color: appTheme.gray50,
                            //           borderRadius:
                            //           const BorderRadius.only(
                            //             topRight: Radius.circular(
                            //               25,
                            //             ),
                            //             topLeft: Radius.circular(
                            //               25,
                            //             ),
                            //           ),
                            //         ),
                            //         margin: EdgeInsets.only(
                            //           top: size.height * 0.15,
                            //         ),
                            //         child: shimmerList(
                            //           height: size.height * 0.8,
                            //           list: 10,
                            //         ),
                            //       )
                            //           : GoalAndDreamFullViewBottomSheet(
                            //         goalDetailModel:
                            //         mentalStrengthEditProvider
                            //             .goalDetailModel!,
                            //       )
                            //           : const SizedBox(),
                            //       mentalStrengthEditProvider.openChooseAction
                            //           ? ChooseActionMentalHelth(
                            //         goal: mentalStrengthEditProvider
                            //             .goalsValue,
                            //       )
                            //           : const SizedBox(),
                            //       mentalStrengthEditProvider.openAddAction
                            //           ? AddActionMentalStrengthBottomSheet(
                            //         goalId: mentalStrengthEditProvider
                            //             .goalsValue.id
                            //             .toString(),
                            //       )
                            //           : const SizedBox(),
                            //       mentalStrengthEditProvider.openActionFullView
                            //           ? const ActionFullViewJournalCreateBottomSheet()
                            //           : const SizedBox()
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              )
            : const TokenExpireScreen());
  }

  /// ✅ First Tab - Kept as per your design
  Widget _buildFirstTab(
      BuildContext context,
      MentalStrengthEditProvider mentalStrengthEditProvider,
      Size size,
      ) {
    final isLoading = mentalStrengthEditProvider.saveJournalLoading;
    return IgnorePointer(
      ignoring: isLoading, // disables touch events
      child: Opacity(
        opacity: isLoading ? 0.5 : 1.0, // fades out UI when loading
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          color: mentalStrengthEditProvider.openChooseGoal
              ? ColorsContent.newThemeColor
              : null,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: size.height * 0.02,
              bottom: size.height * 0.12, // ✅ Adds space for floating buttons
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleEditText(context, mentalStrengthEditProvider),
                SizedBox(height: size.height * 0.02),
                _buildDescriptionEditText(context, mentalStrengthEditProvider,homeProvider),
                SizedBox(height: size.height * 0.02),
                _buildAddMediaColumn(context, size),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSecondTab(BuildContext context, Size size) {
    Size size = MediaQuery.of(context).size;
    final isLoading = mentalStrengthEditProvider.saveJournalLoading;

    return IgnorePointer(
      ignoring: isLoading, // disables touch events
      child: Opacity(
        opacity: isLoading ? 0.5 : 1.0, // fades out UI when loading
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Rate How You Are Feeling Now ?",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: size.height * 0.05),
              SvgPicture.asset(
                ImageConstant.feelingDummyNumuNew, // Button icon
              ),
              SizedBox(height: size.height * 0.02),
              CustomRatingBar(
                initialRating: mentalStrengthEditProvider.emotionalValueStar,
                itemSize: 60,
                color: ColorsContent.newThemeColor,
                unselectedColor: Colors.grey,
                onRatingUpdate: (value) {
                  final previousRating =
                      mentalStrengthEditProvider.emotionalValueStar ?? 0;
                  final wasLow = isLowRange(previousRating);
                  final isNowLow = isLowRange(value);

                  // Switch between low <-> high range
                  if (wasLow != isNowLow) {
                    final currentDropdown =
                        mentalStrengthEditProvider.emotionValue;

                    // Store current value before clearing
                    if (wasLow && currentDropdown != null) {
                      _lowRangeEmotion = currentDropdown;
                    } else if (!wasLow && currentDropdown != null) {
                      _highRangeEmotion = currentDropdown;
                    }

                    // Clear dropdown
                    mentalStrengthEditProvider.addEmotionValue(null);
                  }

                  // Restore previous emotion if returning to same range
                  if (wasLow != isNowLow) {
                    if (isNowLow && _lowRangeEmotion != null) {
                      Future.delayed(Duration(milliseconds: 100), () {
                        mentalStrengthEditProvider
                            .addEmotionValue(_lowRangeEmotion!);
                      });
                    } else if (!isNowLow && _highRangeEmotion != null) {
                      Future.delayed(Duration(milliseconds: 100), () {
                        mentalStrengthEditProvider
                            .addEmotionValue(_highRangeEmotion!);
                      });
                    }
                  }

                  // Existing logic (keep as-is)
                  int mappedValue = ((value - 1) * 4 / (5 - 1) - 2).round();
                  mentalStrengthEditProvider.fetchEmotionsEdit(
                    emotion: "$mappedValue",
                    emotionId: mentalStrengthEditProvider.emotionValue?.id?.toString(),
                    context: context,
                  );
                  mentalStrengthEditProvider.changeEmotionalValueStar(value);
                  _isTokenExpired();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThirdTab(BuildContext context, Size size) {
    size = MediaQuery.of(context).size;
    final TextEditingController searchController = TextEditingController();
    final emotions =
        mentalStrengthEditProvider.getEmotionsModel?.emotions ?? [];
    final isLoading = mentalStrengthEditProvider.saveJournalLoading;


    return IgnorePointer(
      ignoring: isLoading, // disables touch events
      child: Opacity(
        opacity: isLoading ? 0.5 : 1.0, // fades out UI when loading
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "What Is Your Emotional State?",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: size.height * 0.08),
              if (emotions.isNotEmpty)
                Container(
                  width: size.width * 0.80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: DropdownButtonHideUnderline(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: DropdownButton2<Emotion>(
                          isExpanded: true,
                          value: emotions.any((e) =>
                                  e.id ==
                                  mentalStrengthEditProvider.emotionValue?.id)
                              ? emotions.firstWhere((e) =>
                                  e.id ==
                                  mentalStrengthEditProvider.emotionValue?.id)
                              : null,
                          hint: const Text("Select Emotion"),
                          items: emotions.map((Emotion item) {
                            return DropdownMenuItem<Emotion>(
                              value: item,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  item.title ?? "",
                                  style: TextStyle(
                                    color: ColorsContent.newThemeColor,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (Emotion? newValue) {
                            final matched = emotions.firstWhere(
                              (e) => e.id == newValue?.id,
                              orElse: () => newValue!,
                            );
                            mentalStrengthEditProvider.addEmotionValue(matched);
                            _isTokenExpired();
                          },
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 350,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            padding: EdgeInsets.all(8),
                          ),
                          dropdownSearchData: DropdownSearchData(
                            searchController: searchController,
                            searchInnerWidgetHeight: 60,
                            searchInnerWidget: Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextFormField(
                                controller: searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Search Emotion...',
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            searchMatchFn: (item, searchValue) {
                              return (item.value?.title ?? '')
                                  .toLowerCase()
                                  .contains(searchValue.toLowerCase());
                            },
                          ),
                          iconStyleData: IconStyleData(
                            icon: Icon(
                              Icons.arrow_drop_down,
                              size: 30,
                              color: ColorsContent
                                  .newThemeColor, // Change the color of the dropdown icon here
                            ),
                          ),
                        ),
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

  Widget _buildFourthTab(BuildContext context, Size size) {
    final isLoading = mentalStrengthEditProvider.saveJournalLoading;
    Size size = MediaQuery.of(context).size;
    return IgnorePointer(
      ignoring: isLoading, // disables touch events
      child: Opacity(
        opacity: isLoading ? 0.5 : 1.0, // fades out UI when loading
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Do You Like Your Reaction To",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                "The situation?",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              SizedBox(height: size.height * 0.03),
              SizedBox(height: size.height * 0.01),
              CustomRatingBar(
                initialRating: mentalStrengthEditProvider.driveValueStar,
                itemSize: 60,
                color: ColorsContent.newThemeColor,
                onRatingUpdate: (value) {
                  mentalStrengthEditProvider.changeDriveValueStar(value);

                  _isTokenExpired();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFifthTab(BuildContext context, Size size) {
    Size size = MediaQuery.of(context).size;
    final isLoading = mentalStrengthEditProvider.saveJournalLoading;
    return IgnorePointer(
      ignoring: isLoading, // disables touch events
      child: Opacity(
        opacity: isLoading ? 0.5 : 1.0, // fades out UI when loading
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Which Goal Is Affected By ",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                " Your Reaction ?",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: size.width * 0.80,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _isTokenExpired();
                    mentalStrengthEditProvider.openChooseGoalFunction();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Goal",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Icon(
                        size: 30,
                        Icons.arrow_drop_down,
                        color: ColorsContent.newThemeColor,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.015,
              ),
              mentalStrengthEditProvider.goalsValue.id == null
                  ? const SizedBox()
                  : Container(
                      height: size.height * 0.06,
                      width: size.width * 0.80,
                      padding: const EdgeInsets.only(
                        bottom: 5,
                        top: 5,
                        left: 5,
                        right: 5,
                      ),
                      decoration: BoxDecoration(
                        color: ColorsContent.newThemeColor,
                        borderRadius: BorderRadius.circular(8), // Makes it circular
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                customPopup(
                                  context: context,
                                  onPressedDelete: () async {
                                    mentalStrengthEditProvider.cleaGoalValue();
                                    Navigator.of(context).pop();
                                  },
                                  yes: "Yes",
                                  title: 'Do you Need Delete ?',
                                  content: 'Are you sure you want to delete ?',
                                );
                              },
                              child: CircleAvatar(
                                radius: size.width * 0.04,
                                backgroundColor: Colors.deepPurple,
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: size.width * 0.05,
                                ),
                              ),
                            ),
                            SizedBox(
                              // color: Colors.red,
                              width: size.width * 0.45,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                // Enable horizontal scrolling
                                child: Text(
                                  mentalStrengthEditProvider.goalsValue.title
                                      .toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines:
                                      1, // Set the maximum number of lines to 3
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                mentalStrengthEditProvider
                                    .openGoalViewSheetFunction();
                                mentalStrengthEditProvider.fetchGoalDetails(
                                    goalId: mentalStrengthEditProvider.goalsValue.id
                                        .toString(),
                                    context: context);
                              },
                              child: CircleAvatar(
                                radius: size.width * 0.04,
                                backgroundColor: Colors.deepPurple,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: size.width * 0.05,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSixthTab(BuildContext context, Size size) {
    final isLoading = mentalStrengthEditProvider.saveJournalLoading;
    return IgnorePointer(
      ignoring: isLoading, // disables touch events
      child: Opacity(
        opacity: isLoading ? 0.5 : 1.0, // fades out UI when loading
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Select an action",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: size.width * 0.80,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (mentalStrengthEditProvider.goalsValue.id == null) {
                      showCustomSnackBar(
                        context: context,
                        message: "Please choose your goal",
                      );
                    } else {
                      _isTokenExpired();
                      mentalStrengthEditProvider.openChooseActionFunction();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16), // left padding
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Action",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Icon(
                        size: 30,
                        Icons.arrow_drop_down,
                        color: ColorsContent.newThemeColor,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.015,
              ),
              SizedBox(
                height: mentalStrengthEditProvider.actionList.length *
                    size.height *
                    0.070,
                width: size.width * 0.80,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mentalStrengthEditProvider.actionList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      height: size.height * 0.06,
                      width: size.width * 0.80,
                      padding: const EdgeInsets.only(
                        bottom: 5,
                        top: 5,
                        left: 5,
                        right: 5,
                      ),
                      margin: const EdgeInsets.only(
                        bottom: 4,
                      ),
                      decoration: BoxDecoration(
                        color: ColorsContent.newThemeColor,
                        borderRadius: BorderRadius.circular(8), // Makes it circular
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                customPopup(
                                  context: context,
                                  onPressedDelete: () async {
                                    mentalStrengthEditProvider
                                        .clearActionListSelected(
                                      index: index,
                                    );
                                    Navigator.of(context).pop();

                                    // Close the bottom sheet after deleting
                                    //  Navigator.of(context).pop();  // This will close the galleryBottomSheet as well
                                  },
                                  yes: "Yes",
                                  title: 'Do you Need Delete ?',
                                  content: 'Are you sure you want to delete ?',
                                );
                              },
                              child: CircleAvatar(
                                radius: size.width * 0.04,
                                backgroundColor: Colors.deepPurple,
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: size.width * 0.04,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: size.width * 0.45,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                // Enable horizontal scrolling
                                child: Text(
                                  mentalStrengthEditProvider.actionList[index].title
                                      .toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  // Add this line if you want to truncate long text
                                  maxLines:
                                      1, // Limit to 1 line for horizontal scrolling
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                mentalStrengthEditProvider
                                    .openActionFullViewFunction();
                                await mentalStrengthEditProvider.fetchActionDetails(
                                    actionId: mentalStrengthEditProvider
                                        .actionList[index].id
                                        .toString(),
                                    context: context);
                              },
                              child: CircleAvatar(
                                radius: size.width * 0.04,
                                backgroundColor: Colors.deepPurple,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: size.width * 0.04,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildTitleEditText(BuildContext context,
      MentalStrengthEditProvider mentalStrengthEditProvider) {
    return Consumer<MentalStrengthEditProvider>(
      builder: (context, mentalStrengthEditProvider, _) {
        // Decode the text before setting it to the controller
        String decodedText = HtmlUnescape()
            .convert(mentalStrengthEditProvider.titleEditTextController.text);
        mentalStrengthEditProvider.titleEditTextController.text = decodedText;

        return CustomTextFormFieldNumuFirstShow(
          controller: mentalStrengthEditProvider.titleEditTextController,
          hintText: "Title",
          hintStyle: CustomTextStyles.bodySmallGray700,
          textInputAction: TextInputAction.done,
          maxLines: 1,
          focusNode: _titleFocusNode,
          onTap: () => setState(() {}),
          // Rebuild when tapped
          onEditingComplete: () {
            _titleFocusNode.unfocus(); // Ensure focus is removed when done
            setState(() {});
          },
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[\u0000-\uFFFF]'), // allows nearly all Unicode characters, including emojis
              ),
            ],
          onChanged: (text) {
            // Ensure space is allowed only if at least one letter is typed
            if (text.isNotEmpty &&
                !text.trim().isEmpty &&
                text.trim().length == 1 &&
                text.contains(' ')) {
              // Remove space if there's no letter typed yet
              mentalStrengthEditProvider.titleEditTextController.text =
                  text.trim();
              mentalStrengthEditProvider.titleEditTextController.selection =
                  TextSelection.collapsed(offset: text.length);
            } else if (text.trim().isEmpty) {
              // Prevent space if text is empty or contains only spaces
              mentalStrengthEditProvider.titleEditTextController.text =
                  text.trim();
              mentalStrengthEditProvider.titleEditTextController.selection =
                  TextSelection.collapsed(offset: text.length);
            }
          },
        );
      },
    );
  }

  Widget _buildDescriptionEditText(
      BuildContext context,
      MentalStrengthEditProvider provider,
      HomeProvider homeProvider,
      )
  {
    final journal = homeProvider.journalDetails?.journals;
    final previewLink = journal?.preview_link?.trim() ?? "";

    // ✅ Initialize backend link ONLY on first load
    if (previewLink.isNotEmpty &&
        provider.editDetectedLinks.isEmpty &&
        !provider.hasUserClearedLink) {
      provider.editDetectedLinks = [previewLink];
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📝 Text field — always visible
              CustomTextFormFieldNumuFirstShow(
                controller: provider.descriptionEditTextController,
                hintText: "Start writing...",
                hintStyle: CustomTextStyles.bodySmallGray700,
                textInputAction: TextInputAction.newline,
                textInputType: TextInputType.multiline,
                maxLines: 4,
                focusNode: _descriptionFocusNode,
              //  borderDecoration: InputBorder.none,
                textAlign: TextAlign.start,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\u0000-\uFFFF]')),
                ],
                onChanged: (value) {
                  final regex = provider.editUrlRegex;
                  final matches = regex.allMatches(value).map((m) => m.group(0)!).toList();


                  if (matches.isNotEmpty) {
                    final firstLink = matches.first;

                    if (firstLink.length < 8) return; // prevent `..` or short junk

                    // 🚫 Condition: SAME link already exists → show toast
                    if (provider.editDetectedLinks.isNotEmpty &&
                        provider.editDetectedLinks.first == firstLink) {
                      showToastTOP(
                        context: context,
                        message: "Only one link at a time",
                      );

                      // Remove the pasted link text from the field
                      final updatedText = value.replaceAll(regex, '').trimRight();
                      provider.descriptionEditTextController.text = updatedText;
                      provider.descriptionEditTextController.selection =
                          TextSelection.fromPosition(
                            TextPosition(offset: updatedText.length),
                          );
                      return;
                    }

                    // 🚫 Condition: Another different link already exists → show toast
                    if (provider.editDetectedLinks.isNotEmpty &&
                        provider.editDetectedLinks.first != firstLink) {
                      showToastTOP(
                        context: context,
                        message: "Only one link at a time",
                      );

                      // Remove pasted link text
                      final updatedText = value.replaceAll(regex, '').trimRight();
                      provider.descriptionEditTextController.text = updatedText;
                      provider.descriptionEditTextController.selection =
                          TextSelection.fromPosition(
                            TextPosition(offset: updatedText.length),
                          );
                      return;
                    }

                    // ✅ A new link is detected (first time)
                    final updatedText = value.replaceAll(regex, '').trimRight();

                    setState(() {
                      provider.editDetectedLinks.clear();
                      provider.editDetectedLinks = [firstLink];

                      provider.descriptionEditTextController.text = updatedText;
                      provider.descriptionEditTextController.selection =
                          TextSelection.fromPosition(
                            TextPosition(offset: updatedText.length),
                          );

                      provider.hasUserClearedLink = false;
                    });
                  }
                },

                onTap: () => setState(() {}),
                onEditingComplete: () {
                  _descriptionFocusNode.unfocus();
                  setState(() {});
                },
              ),

              // 🔗 Link preview (ONLY ONE - no multiple links)
              if (provider.editDetectedLinks.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinkPreviewGenerator(
                            link: provider.editDetectedLinks.first,
                            linkPreviewStyle: LinkPreviewStyle.large,
                            showDomain: true,
                            showBody: true,
                            showTitle: true,
                            bodyMaxLines: 3,
                            borderRadius: 10,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Container(
                      //   decoration: BoxDecoration(
                      //     border: Border.all(
                      //       color: Colors.grey.shade300,
                      //       width: 1.2,
                      //     ),
                      //     borderRadius: BorderRadius.circular(10),
                      //   ),
                      //   child: ClipRRect(
                      //     borderRadius: BorderRadius.circular(10),
                      //     child: LinkPreviewGenerator(
                      //       link: provider.editDetectedLinks.first,
                      //       linkPreviewStyle: LinkPreviewStyle.small,
                      //       showDomain: true,
                      //       showTitle: true,
                      //       bodyMaxLines: 1,
                      //       borderRadius: 10,
                      //       boxShadow: const [
                      //         BoxShadow(
                      //           color: Colors.black12,
                      //           blurRadius: 4,
                      //           offset: Offset(0, 2),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      // ❌ Close button (removes the link)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () {

                            customPopup(
                              context: context,
                              onPressedDelete: () {
                                setState(() {
                                  provider.editDetectedLinks.clear();
                                  provider.hasUserClearedLink = true;
                                });
                                Navigator.of(context).pop();
                              },
                              title: 'Confirm Delete',
                              content:
                              'Are you sure you want to delete this link?',
                            );


                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }





  Widget _buildAddMediaColumn(BuildContext context, Size size) {
    return Consumer<MentalStrengthEditProvider>(
        builder: (context, mentalStrengthEditProvider, _) {
      var logger = Logger();
      logger.w(
          "pickedImages${mentalStrengthEditProvider.pickedImages.length + mentalStrengthEditProvider.alreadyPickedImages.length}");
      return Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add Media",
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(
              height: 11,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: size.height * 0.09,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _isTokenExpired();
                          if (await requestGalleryPermission() &&
                              Platform.isAndroid) {
                            mentalStrengthEditProvider.selectedMedia(1);
                            await galleryBottomSheet(
                              context: context,
                              title: 'Gallery',
                            );
                          } else if (Platform.isIOS) {
                            mentalStrengthEditProvider.selectedMedia(1);
                            await galleryBottomSheet(
                              context: context,
                              title: 'Gallery',
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Gallery permission is required.")),
                            );
                          }
                        },
                        child: SvgPicture.asset(
                          ImageConstant
                              .galleryAddMediaNumu, // Replace with your SVG asset path
                        ),
                      ),
                      Positioned(
                        bottom: Platform.isIOS ? 50 : 45,
                        // Adjust this value as needed
                        right: 0,
                        // Move to the right
                        left: 40,
                        child: Consumer<MentalStrengthEditProvider>(
                          builder: (context, mentalStrengthEditProvider, _) {
                            if (mentalStrengthEditProvider
                                    .alreadyPickedImages.isEmpty &&
                                mentalStrengthEditProvider
                                    .pickedImages.isEmpty) {
                              return const SizedBox();
                            } else {
                              return Container(
                                width: size.height * 0.04,
                                // Set width
                                height: size.height * 0.04,
                                // Set height same as width to make it a circle
                                decoration: BoxDecoration(
                                  color: ColorsContent.galleryCountColor,
                                  shape: BoxShape.circle,
                                  // Ensures the container is circular
                                  image: DecorationImage(
                                    image: AssetImage(ImageConstant.imgMenu),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "${mentalStrengthEditProvider.pickedImages.length + mentalStrengthEditProvider.alreadyPickedImages.length}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      )
                      // Positioned(
                      //   bottom: 0,
                      //   left: 10,
                      //   right: 10,
                      //   child: Consumer<MentalStrengthEditProvider>(
                      //       builder: (context, mentalStrengthEditProvider, _) {
                      //         if (mentalStrengthEditProvider
                      //             .alreadyPickedImages.isEmpty &&
                      //             mentalStrengthEditProvider.pickedImages.isEmpty) {
                      //           return const SizedBox();
                      //         } else {
                      //           return Container(
                      //             width: size.height * 0.04,
                      //             decoration: BoxDecoration(
                      //               color: Colors.white,
                      //               image: DecorationImage(
                      //                 image: AssetImage(ImageConstant.imgMenu),
                      //                 fit: BoxFit.cover,
                      //               ),
                      //               borderRadius: const BorderRadius.all(
                      //                 Radius.circular(
                      //                   50.0,
                      //                 ),
                      //               ),
                      //               border: Border.all(
                      //                 color: appTheme.blue300,
                      //                 width: 2.0,
                      //               ),
                      //             ),
                      //             child: Center(
                      //               child: Text(
                      //                 "${mentalStrengthEditProvider.pickedImages.length + mentalStrengthEditProvider.alreadyPickedImages.length}",
                      //                 style: const TextStyle(
                      //                   color: Colors.blue,
                      //                   fontWeight: FontWeight.bold,
                      //                 ),
                      //               ),
                      //             ),
                      //           );
                      //         }
                      //       }),
                      // )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.09,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _isTokenExpired();
                          if (await requestCameraPermission() &&
                              Platform.isAndroid) {
                            mentalStrengthEditProvider.selectedMedia(2);
                            cameraBottomSheet(
                              context: context,
                              title: "Camera",
                            );
                          } else if (Platform.isIOS) {
                            mentalStrengthEditProvider.selectedMedia(2);
                            cameraBottomSheet(
                              context: context,
                              title: "Camera",
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Camera permission is required.")),
                            );
                          }
                        },
                        child: SvgPicture.asset(
                          ImageConstant
                              .cameraAddMediaNumu, // Replace with your SVG asset path
                        ),
                      ),
                      Positioned(
                        bottom: Platform.isIOS ? 50 : 45,
                        // Adjust this value as needed
                        right: 0,
                        // Move to the right
                        left: 40,
                        child: Consumer<MentalStrengthEditProvider>(
                          builder: (context, mentalStrengthEditProvider, _) {
                            if (mentalStrengthEditProvider
                                .takedImages.isEmpty) {
                              return const SizedBox();
                            } else {
                              return Container(
                                width: size.height * 0.04,
                                // Ensure width
                                height: size.height * 0.04,
                                // Ensure height matches width for a circle
                                decoration: BoxDecoration(
                                  color: ColorsContent.cameraCountColor,
                                  shape: BoxShape.circle,
                                  // This makes it perfectly round
                                  image: DecorationImage(
                                    image: AssetImage(ImageConstant.imgMenu),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "${mentalStrengthEditProvider.takedImages.length}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      )
                      // Positioned(
                      //   bottom: 0,
                      //   left: 10,
                      //   right: 10,
                      //   child: Consumer<MentalStrengthEditProvider>(
                      //       builder: (context, mentalStrengthEditProvider, _) {
                      //         if (mentalStrengthEditProvider.takedImages.isEmpty) {
                      //           return const SizedBox();
                      //         } else {
                      //           return Container(
                      //             width: size.height * 0.04,
                      //             decoration: BoxDecoration(
                      //               color: Colors.white,
                      //               image: DecorationImage(
                      //                 image: AssetImage(ImageConstant.imgMenu),
                      //                 fit: BoxFit.cover,
                      //               ),
                      //               borderRadius: const BorderRadius.all(
                      //                 Radius.circular(
                      //                   50.0,
                      //                 ),
                      //               ),
                      //               border: Border.all(
                      //                 color: appTheme.blue300,
                      //                 width: 2.0,
                      //               ),
                      //             ),
                      //             child: Center(
                      //               child: Text(
                      //                 "${mentalStrengthEditProvider.takedImages.length}",
                      //                 style: const TextStyle(
                      //                   color: Colors.blue,
                      //                   fontWeight: FontWeight.bold,
                      //                 ),
                      //               ),
                      //             ),
                      //           );
                      //         }
                      //       }),
                      // )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.09,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _isTokenExpired();
                          mentalStrengthEditProvider.selectedMedia(0);
                          // if (mentalStrengthEditProvider.mediaSelected == 1) {
                          await audioBottomSheet(
                            context: context,
                            title: 'Record Audio',
                          );
                          // }
                        },
                        child: SvgPicture.asset(
                          ImageConstant
                              .recordAddMediaNumu, // Replace with your SVG asset path
                        ),
                      ),

                      Positioned(
                        bottom: Platform.isIOS ? 50 : 45,
                        // Adjust this value as needed
                        right: 0,
                        // Move to the right
                        left: 40,
                        child: Consumer<MentalStrengthEditProvider>(
                          builder: (context, mentalStrengthEditProvider, _) {
                            if (mentalStrengthEditProvider
                                    .alreadyRecordedFilePath.isEmpty &&
                                mentalStrengthEditProvider
                                    .recordedFilePath.isEmpty) {
                              return const SizedBox();
                            } else {
                              return Container(
                                width: size.height * 0.04,
                                // Ensuring width
                                height: size.height * 0.04,
                                // Ensuring height for a circle
                                decoration: BoxDecoration(
                                  color: ColorsContent.recordCountColor,
                                  shape: BoxShape.circle,
                                  // Ensuring a perfect circle
                                  image: DecorationImage(
                                    image: AssetImage(ImageConstant.imgMenu),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    "${mentalStrengthEditProvider.recordedFilePath.length + mentalStrengthEditProvider.alreadyRecordedFilePath.length}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      )
                      // Positioned(
                      //   bottom: 0,
                      //   left: 10,
                      //   right: 10,
                      //   child: Consumer<MentalStrengthEditProvider>(
                      //       builder: (context, mentalStrengthEditProvider, _) {
                      //         if (mentalStrengthEditProvider
                      //             .alreadyRecordedFilePath.isEmpty &&
                      //             mentalStrengthEditProvider
                      //                 .recordedFilePath.isEmpty) {
                      //           return const SizedBox();
                      //         } else {
                      //           return Container(
                      //             width: size.height * 0.04,
                      //             decoration: BoxDecoration(
                      //               color: Colors.white,
                      //               image: DecorationImage(
                      //                 image: AssetImage(ImageConstant.imgMenu),
                      //                 fit: BoxFit.cover,
                      //               ),
                      //               borderRadius: const BorderRadius.all(
                      //                 Radius.circular(
                      //                   50.0,
                      //                 ),
                      //               ),
                      //               border: Border.all(
                      //                 color: appTheme.blue300,
                      //                 width: 2.0,
                      //               ),
                      //             ),
                      //             child: Center(
                      //               child: Text(
                      //                 "${mentalStrengthEditProvider.recordedFilePath.length + mentalStrengthEditProvider.alreadyRecordedFilePath.length}",
                      //                 style: const TextStyle(
                      //                   color: Colors.blue,
                      //                   fontWeight: FontWeight.bold,
                      //                 ),
                      //               ),
                      //             ),
                      //           );
                      //         }
                      //       }),
                      // )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.09,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          mentalStrengthEditProvider.selectedMedia(
                            3,
                          );

                          final status =
                              await Permission.locationWhenInUse.status;

                          print("Permission status is ${status}");
                          if (status.isDenied || status.isPermanentlyDenied) {
                            final result =
                                await Permission.locationWhenInUse.request();

                            if (result.isDenied || result.isPermanentlyDenied) {
                              if (mounted) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                        'Location Permission Required'),
                                    content: const Text(
                                        'Location permission is needed to add your current location to the mental strength entry. Please enable it in settings.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await openAppSettings();
                                        },
                                        child: const Text('Open Settings'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return;
                            }
                          }
                          if (await Permission.locationWhenInUse.isGranted) {
                            if (mounted) {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                // <== Helps with full height layout
                                backgroundColor: Colors.transparent,
                                // Optional for rounded corners
                                builder: (BuildContext context) {
                                  return SafeArea(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context)
                                            .viewInsets
                                            .bottom, // Avoid overlap with keyboard or bottom inset
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20)),
                                        ),
                                        child: const MentalGoogleMap(
                                          edit: true,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          }

                          // mentalStrengthEditProvider.mediaSelected == 3
                          //     ? const MentalGoogleMap()
                          //     : const SizedBox(),
                        },
                        child: SvgPicture.asset(
                          ImageConstant
                              .locationAddMediaNumu, // Replace with your SVG asset path
                        ),
                      ),
                      Positioned(
                        bottom: Platform.isIOS ? 50 : 45,
                        // Adjust this value as needed
                        right: 0,
                        // Move to the right
                        left: 40,
                        child: Consumer<MentalStrengthEditProvider>(
                          builder: (context, mentalStrengthEditProvider, _) {
                            if (mentalStrengthEditProvider
                                .selectedLocationName.isEmpty) {
                              return const SizedBox();
                            } else {
                              return Container(
                                width: size.height * 0.04,
                                height: size.height * 0.04,
                                decoration: BoxDecoration(
                                  color: ColorsContent.locationCountColor,
                                  shape: BoxShape.circle,
                                  // Ensuring a perfect circle
                                  image: DecorationImage(
                                    image: AssetImage(ImageConstant.imgMenu),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.0,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "1",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      // Positioned(
                      //   bottom: 0,
                      //   left: 10,
                      //   right: 10,
                      //   child: Consumer<MentalStrengthEditProvider>(
                      //       builder: (context, mentalStrengthEditProvider, _) {
                      //         if (mentalStrengthEditProvider
                      //             .selectedLocationName.isEmpty) {
                      //           return const SizedBox();
                      //         } else {
                      //           return Container(
                      //             width: size.height * 0.04,
                      //             decoration: BoxDecoration(
                      //               color: Colors.white,
                      //               image: DecorationImage(
                      //                 image: AssetImage(ImageConstant.imgMenu),
                      //                 fit: BoxFit.cover,
                      //               ),
                      //               borderRadius: const BorderRadius.all(
                      //                 Radius.circular(
                      //                   50.0,
                      //                 ),
                      //               ),
                      //               border: Border.all(
                      //                 color: appTheme.blue300,
                      //                 width: 2.0,
                      //               ),
                      //             ),
                      //             child: const Center(
                      //               child: Text(
                      //                 "1",
                      //                 style: TextStyle(
                      //                   color: Colors.blue,
                      //                   fontWeight: FontWeight.bold,
                      //                 ),
                      //               ),
                      //             ),
                      //           );
                      //         }
                      //       }),
                      // )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

Widget buildAvatarImage(
    {required String imagePath,
    required Size size,
    Widget? widget,
    bool isSelected = false}) {
  return Container(
    height: size.height * 0.08,
    width: size.height * 0.08,
    decoration: BoxDecoration(
      color: isSelected ? ColorsContent.newThemeColor : Colors.transparent,
      image: DecorationImage(
        image: AssetImage(
          imagePath,
        ),
        fit: BoxFit.cover,
      ),
      borderRadius: const BorderRadius.all(
        Radius.circular(
          50.0,
        ),
      ),
      border: Border.all(
        color: appTheme.blue300,
        width: 1.0,
      ),
    ),
    child: widget ??
        CustomIconButton(
          height: size.height * 0.08,
          width: size.height * 0.08,
          padding: const EdgeInsets.all(18),
          child: CustomImageView(
            imagePath: imagePath,
            color: isSelected ? Colors.white : ColorsContent.newThemeColor,
          ),
        ),
  );
}
