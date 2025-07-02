import 'dart:async';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/screens/add_action/add_action_mental_strength.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/screens/choose_action/choose_action.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/screens/choose_goal/choose_goal.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/widgets/googlemap_widget/google_map_widget.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/widgets/popup/audio_popup.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/widgets/popup/camera_popup.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/widgets/popup/gallary_popup.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:mentalhelth/widgets/custom_icon_button.dart';
import 'package:mentalhelth/widgets/custom_text_form_field.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:mentalhelth/widgets/widget/shimmer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../utils/core/image_constant.dart';
import '../../utils/logic/permissions.dart';
import '../../utils/theme/colors.dart';
import '../../utils/theme/theme_helper.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_rating_bar.dart';
import '../../widgets/functions/popup.dart';
import '../addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import '../home_screen/provider/home_provider.dart';
import '../home_screen/widgets/home_menu/home_menu.dart';
import '../token_expiry/tocken_expiry_warning_screen.dart';
import '../token_expiry/token_expiry.dart';
import 'model/emotions_model.dart';
import 'provider/mental_strenght_edit_provider.dart';
import 'screens/action_full_view_mental_helth/action_full_view_journal.dart';
import 'screens/add_goals_and_dreams_widget/add_goals_and_dreams_mental_strength.dart';
import 'screens/goals_and_dreams_full_view/goals_and_dreams_full_view_screen.dart';

class NumuMentalStrengthAddEditPage extends StatefulWidget {
  const NumuMentalStrengthAddEditPage({Key? key})
      : super(
          key: key,
        );

  @override
  _NumuMentalStrengthAddEditPageState createState() =>
      _NumuMentalStrengthAddEditPageState();
}

class _NumuMentalStrengthAddEditPageState
    extends State<NumuMentalStrengthAddEditPage>
    with SingleTickerProviderStateMixin {
  late HomeProvider homeProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late EditProfileProvider editProfileProvider;
  late DashBoardProvider dashBoardProvider;
  late AdDreamsGoalsProvider adDreamsGoalsProvider;
  bool tokenStatus = false;
  var logger = Logger();
  PermissionStatus permissionStatus = PermissionStatus.denied;
  late TabController _tabController;
  int currentTabIndex = 0;
  late FocusNode _descriptionFocusNode;
  late FocusNode _titleFocusNode;

  Future<void> _isTokenExpired() async {
    await homeProvider.fetchJournals(initial: true, context: context);
    //  await editProfileProvider.fetchUserProfile();
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

  Future<void> _checkPermissionStatus() async {
    // Check location permission status
    final status = await Permission.locationWhenInUse.status;
    setState(() {
      permissionStatus = status;
    });
  }

  Future<void> _requestPermissions() async {
    // Request location permission (Platform specific)
    if (Platform.isIOS) {
      await Permission.locationWhenInUse.request();
      await Permission.notification.request();
      await Permission.photos.request();
    } else if (Platform.isAndroid) {
      await Permission.locationWhenInUse.request();
      await Permission.notification.request();
      await Permission.storage.request(); // For storage permissions
      await Permission.manageExternalStorage
          .request(); // For Android 11 and above
    }

    // Check updated location permission status
    final locationStatus = await Permission.locationWhenInUse.status;
    setState(() {
      permissionStatus = locationStatus;
    });
  }

  @override
  void initState() {
    super.initState();
    _descriptionFocusNode = FocusNode();
    _titleFocusNode = FocusNode();
    // Ensure the focus is not automatically set when returning
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _descriptionFocusNode.unfocus();
      _titleFocusNode.unfocus(); // Ensure it does not get focus automatically
    });
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentTabIndex = _tabController.index;
      });
    });
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    mentalStrengthEditProvider =
        Provider.of<MentalStrengthEditProvider>(context, listen: false);
    editProfileProvider =
        Provider.of<EditProfileProvider>(context, listen: false);
    dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
    adDreamsGoalsProvider =
        Provider.of<AdDreamsGoalsProvider>(context, listen: false);
    logger.w(
        "mentalStrengthEditProvider.emotionalValueStar${mentalStrengthEditProvider.emotionalValueStar}");
    logger.w(
        "mentalStrengthEditProvider.driveValueStar${mentalStrengthEditProvider.driveValueStar}");
    scheduleMicrotask(() {
      mentalStrengthEditProvider.clearLocationSelection();
      mentalStrengthEditProvider.mediaSelected = -1;
      mentalStrengthEditProvider.descriptionEditTextController.text = "";
      mentalStrengthEditProvider.titleEditTextController.text = "";
      mentalStrengthEditProvider.emotionalValueStar = null;
      mentalStrengthEditProvider.driveValueStar = null;
      adDreamsGoalsProvider.selectedDate = "";
      mentalStrengthEditProvider.alreadyRecordedFilePath.clear();
      mentalStrengthEditProvider.recordedFilePath.clear();
      mentalStrengthEditProvider.alreadyPickedImages.clear();
      mentalStrengthEditProvider.pickedImages.clear();
      mentalStrengthEditProvider.alreadyTakedImages.clear();
      mentalStrengthEditProvider.takedImages.clear();
      mentalStrengthEditProvider.selectedLocationAddress = "";
      mentalStrengthEditProvider.selectedLatitude = "";
      mentalStrengthEditProvider.selectedLocationName = "";
      mentalStrengthEditProvider.goalsValue.title = "";
      mentalStrengthEditProvider.goalsValue.id = null;
      logger.i(
          "mentalStrengthEditProvider.goalsValue.id${mentalStrengthEditProvider.goalsValue.id}");

      _isTokenExpired();
    });
  }

  @override
  void dispose() {
    _descriptionFocusNode.dispose();
    _titleFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

    return tokenStatus == false
        ? WillPopScope(
            onWillPop: () {
              return Future.value(false); // Prevents back navigation
            },
            child: SafeArea(
              child: backGroundImagerOtherScreens(
                size: size,
                padding: EdgeInsets.zero,
                child: Consumer3<EditProfileProvider,
                    MentalStrengthEditProvider, DashBoardProvider>(
                  builder: (contexts, editProfileProvider,
                      mentalStrengthEditProvider, dashBoardProvider, _) {
                    return GestureDetector(
                      onTap: () {
                        mentalStrengthEditProvider.openAllCloser();
                        FocusScope.of(context).unfocus();
                      },
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        buildPopupDialog(context, size),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: size.width * 0.05,
                                  ),
                                  child: SvgPicture.asset(
                                    ImageConstant.menuBarSvg,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // const SizedBox(height: 10,),
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
                                          _tabController.animateTo(
                                              currentTabIndex -
                                                  1); // Go to previous tab

                                          mentalStrengthEditProvider
                                              .openAllCloser();
                                          // FocusScope.of(context).unfocus();
                                        },
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              ImageConstant
                                                  .numuMentalBackButton,
                                              // Replace with your SVG file path
                                              width:
                                                  30, // Adjust size if needed
                                              height: 30,
                                            ),
                                            const SizedBox(width: 10),
                                            // Spacing between icon and text
                                            Text(
                                              "Back",
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                                color: ColorsContent
                                                    .newThemeColor, // Adjust color as needed
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      GestureDetector(
                                        onTap: () {
                                          dashBoardProvider.changePage(
                                              index: 0);

                                          mentalStrengthEditProvider
                                              .openAllCloser();
                                          // FocusScope.of(context).unfocus();
                                        },
                                        child: Row(
                                          children: [
                                            SvgPicture.asset(
                                              ImageConstant
                                                  .numuMentalBackButton,
                                              // Replace with your SVG file path
                                              width:
                                                  30, // Adjust size if needed
                                              height: 30,
                                            ),
                                            const SizedBox(width: 10),
                                            // Spacing between icon and text
                                            Text(
                                              "Back",
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                                color: ColorsContent
                                                    .newThemeColor, // Adjust color as needed
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    // Placeholder to keep alignment when back button is hidden

                                    // Progress Text (e.g., "1/6", "2/6")
                                    Text(
                                      "${currentTabIndex + 1}/6",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
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
                                  physics: const NeverScrollableScrollPhysics(),
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
                                    bottom: size.height * 0.002,
                                    left: 0,
                                    right: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color:
                                              ColorsContent.homeBackGroundColor,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 3),
                                        child: Center(
                                          child: SizedBox(
                                            width: 85,
                                            height: 85,
                                            child: FloatingActionButton(
                                              backgroundColor:
                                                  Colors.transparent,
                                              elevation: 0,
                                              splashColor: Colors.transparent,
                                              foregroundColor:
                                                  Colors.transparent,
                                              onPressed: () {
                                                if (currentTabIndex == 0) {
                                                  final title =
                                                      mentalStrengthEditProvider
                                                          .titleEditTextController
                                                          .text
                                                          .trim();
                                                  final description =
                                                      mentalStrengthEditProvider
                                                          .descriptionEditTextController
                                                          .text
                                                          .trim();

                                                  if (title.isEmpty) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: const Text(
                                                            "Title is required."),
                                                        backgroundColor:
                                                            ColorsContent
                                                                .newThemeColor,
                                                      ),
                                                    );
                                                  } else if (description
                                                      .isEmpty) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: const Text(
                                                            "Description is required."),
                                                        backgroundColor:
                                                            ColorsContent
                                                                .newThemeColor,
                                                      ),
                                                    );
                                                  } else {
                                                    _tabController.animateTo(
                                                        currentTabIndex + 1);
                                                  }
                                                } else if (currentTabIndex ==
                                                    1) {
                                                  if (mentalStrengthEditProvider
                                                          .emotionalValueStar !=
                                                      null) {
                                                    _tabController.animateTo(
                                                        currentTabIndex + 1);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: const Text(
                                                            "This field is mandatory."),
                                                        backgroundColor:
                                                            ColorsContent
                                                                .newThemeColor,
                                                      ),
                                                    );
                                                  }
                                                } else if (currentTabIndex ==
                                                    2) {
                                                  if (mentalStrengthEditProvider
                                                          .emotionValue !=
                                                      null) {
                                                    _tabController.animateTo(
                                                        currentTabIndex + 1);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: const Text(
                                                            "Emotion selection is required."),
                                                        backgroundColor:
                                                            ColorsContent
                                                                .newThemeColor,
                                                      ),
                                                    );
                                                  }
                                                } else if (currentTabIndex ==
                                                    3) {
                                                  if (mentalStrengthEditProvider
                                                          .driveValueStar !=
                                                      null) {
                                                    _tabController.animateTo(
                                                        currentTabIndex + 1);
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: const Text(
                                                            "This field is mandatory."),
                                                        backgroundColor:
                                                            ColorsContent
                                                                .newThemeColor,
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  _tabController.animateTo(
                                                      currentTabIndex + 1);
                                                }
                                              },
                                              child: Image.asset(
                                                ImageConstant.numuNextIcon,
                                                width: 85,
                                                height: 85,
                                              ),
                                              shape: const CircleBorder(),
                                              heroTag: "next_button",
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else if (currentTabIndex == 4 &&
                                    mentalStrengthEditProvider.goalsValue.id ==
                                        null) ...[
                                  // Submit button on 4th tab when goal is not selected
                                  Positioned(
                                    bottom: size.height * 0.002,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      width: double.infinity,
                                      color: ColorsContent.homeBackGroundColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () async {
                                            String? validationMessage;

                                            if (mentalStrengthEditProvider
                                                .descriptionEditTextController
                                                .text
                                                .isEmpty) {
                                              validationMessage =
                                                  "Description missing";
                                            } else if (mentalStrengthEditProvider
                                                .emotionValue!.id
                                                .toString()
                                                .isEmpty) {
                                              validationMessage =
                                                  "Please select an emotion";
                                            } else if (mentalStrengthEditProvider
                                                    .emotionalValueStar ==
                                                null) {
                                              validationMessage =
                                                  "Please select Feeling Now emotional Rate";
                                            } else if (mentalStrengthEditProvider
                                                    .driveValueStar ==
                                                null) {
                                              validationMessage =
                                                  "Please select Situation Rate";
                                            }

                                            if (validationMessage != null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content:
                                                      Text(validationMessage),
                                                  backgroundColor: ColorsContent
                                                      .newThemeColor,
                                                ),
                                              );
                                            } else {
                                              await mentalStrengthEditProvider
                                                  .saveButtonFunction(context);
                                              _isTokenExpired();
                                            }
                                          },
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SvgPicture.asset(ImageConstant
                                                  .submitButtonNumuBuild),
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
                                  ),
                                ] else ...[
                                  // Final Submit button (default for last tab)
                                  Positioned(
                                    bottom: size.height * 0.002,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      width: double.infinity,
                                      color: ColorsContent.homeBackGroundColor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () async {
                                            String? validationMessage;

                                            if (mentalStrengthEditProvider
                                                .descriptionEditTextController
                                                .text
                                                .isEmpty) {
                                              validationMessage =
                                                  "Description missing";
                                            } else if (mentalStrengthEditProvider
                                                .emotionValue!.id
                                                .toString()
                                                .isEmpty) {
                                              validationMessage =
                                                  "Please select an emotion";
                                            } else if (mentalStrengthEditProvider
                                                    .emotionalValueStar ==
                                                null) {
                                              validationMessage =
                                                  "Please select Feeling Now emotional Rate";
                                            } else if (mentalStrengthEditProvider
                                                    .driveValueStar ==
                                                null) {
                                              validationMessage =
                                                  "Please select Situation Rate";
                                            }

                                            if (validationMessage != null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content:
                                                      Text(validationMessage),
                                                  backgroundColor: ColorsContent
                                                      .newThemeColor,
                                                ),
                                              );
                                            } else {
                                              await mentalStrengthEditProvider
                                                  .saveButtonFunction(context);
                                              _isTokenExpired();
                                            }
                                          },
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              SvgPicture.asset(ImageConstant
                                                  .numuSubmitEditAdd),
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
                                  ),
                                ],

                                // Newly Added Widgets
                                if (mentalStrengthEditProvider.openChooseGoal)
                                  const ScreenChooseGoalMentalStrength(),

                                if (mentalStrengthEditProvider.openAddGoal)
                                  const AddGoalsDreamsBottomSheet(),

                                if (mentalStrengthEditProvider
                                    .openGoalViewSheet)
                                  mentalStrengthEditProvider.goalDetailModel ==
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

                                if (mentalStrengthEditProvider.openChooseAction)
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
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        : const TokenExpireScreen();
  }

  /// ✅ First Tab - Kept as per your design
  Widget _buildFirstTab(BuildContext context,
      MentalStrengthEditProvider mentalStrengthEditProvider, Size size) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          color: mentalStrengthEditProvider.openChooseGoal
              ? ColorsContent.newThemeColor
              : null,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.01),
                _buildTitleEditText(context, mentalStrengthEditProvider),
                SizedBox(height: size.height * 0.015),
                _buildDescriptionEditText(context, mentalStrengthEditProvider),
                SizedBox(height: size.height * 0.015),
                _buildAddMediaColumn(context, size),
                SizedBox(height: size.height * 0.05),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                //   child: Container(
                //     width: double.infinity,
                //     height: 65,
                //     color: ColorsContent.numuAddColor,
                //     child: Center(
                //       child: Text(
                //         'Numu App',
                //         style: TextStyle(
                //           color: ColorsContent.newThemeColor, // or any color that fits your background
                //           fontSize: 15,         // adjust as needed
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ),
                //   ),
                // )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecondTab(BuildContext context, Size size) {
    Size size = MediaQuery.of(context).size;
    return Center(
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
              fontFamily: 'OpenSans',
            ),
          ),
          SizedBox(height: size.height * 0.05),
          SvgPicture.asset(
            ImageConstant.feelingDummyNumu, // Button icon
          ),
          SizedBox(height: size.height * 0.03),
          SvgPicture.asset(
            ImageConstant.lineNumu, // Button icon
          ),
          SizedBox(height: size.height * 0.03),
          CustomRatingBar(
            initialRating: mentalStrengthEditProvider.emotionalValueStar,
            itemSize: 60,
            color: ColorsContent.newThemeColor,
            unselectedColor: Colors.grey,
            onRatingUpdate: (value) {
              logger.w("Updated emotional value star: $value");

              // Map the value from 1-5 to -2 to 2 as an integer
              int mappedValue = ((value - 1) * 4 / (5 - 1) - 2).round();

              mentalStrengthEditProvider.fetchEmotions(
                  emotion: "$mappedValue", context: context);

              mentalStrengthEditProvider.changeEmotionalValueStar(value);
              _isTokenExpired(); // Call your method after rating update.
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThirdTab(BuildContext context, Size size) {
    Size size = MediaQuery.of(context).size;
    final TextEditingController searchController = TextEditingController();

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "What Is Your Emotional State?",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'OpenSans',
            ),
          ),
          SizedBox(height: size.height * 0.06),
          (mentalStrengthEditProvider.getEmotionsModel == null)
              ? const SizedBox()
              : Container(
                  width: size.width * 0.80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: DropdownButtonHideUnderline(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: DropdownButton2<Emotion>(
                        isExpanded: true,
                        value: mentalStrengthEditProvider.emotionValue,
                        hint: const Text("Select Emotion"),
                        items: mentalStrengthEditProvider
                            .getEmotionsModel?.emotions
                            ?.map((Emotion items) {
                          return DropdownMenuItem<Emotion>(
                            value: items,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                items.title.toString(),
                                style: TextStyle(
                                  color: ColorsContent.newThemeColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (Emotion? newValue) {
                          final matched = mentalStrengthEditProvider
                              .getEmotionsModel?.emotions
                              ?.firstWhere((e) => e.id == newValue?.id,
                                  orElse: () => newValue!);
                          mentalStrengthEditProvider.addEmotionValue(matched!);
                          _isTokenExpired();
                        },
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 350,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          padding: EdgeInsets.all(8),
                        ),
                        dropdownSearchData: DropdownSearchData(
                          searchController: searchController,
                          searchInnerWidgetHeight: 60, // <- Required
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
                                .startsWith(searchValue.toLowerCase());
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
                    )),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFourthTab(BuildContext context, Size size) {
    Size size = MediaQuery.of(context).size;
    return Center(
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
              fontFamily: 'OpenSans',
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
              fontFamily: 'OpenSans',
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
    );
  }

  Widget _buildFifthTab(BuildContext context, Size size) {
    Size size = MediaQuery.of(context).size;
    return Center(
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
              fontFamily: 'OpenSans',
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
              fontFamily: 'OpenSans',
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
            height: size.height * 0.02,
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
                            radius: size.width * 0.035,
                            backgroundColor: Colors.deepPurple,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: size.width * 0.04,
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
                                fontFamily: 'OpenSans',
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
                            radius: size.width * 0.035,
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
                ),
        ],
      ),
    );
  }

  Widget _buildSixthTab(BuildContext context, Size size) {
    return Center(
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
              fontFamily: 'OpenSans',
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
            height: size.height * 0.02,
          ),
          SizedBox(
            height: size.height * 0.40,
            width: size.width * 0.80,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              // Or ScrollPhysics() for default
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
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: ColorsContent.newThemeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Delete Button
                        GestureDetector(
                          onTap: () {
                            customPopup(
                              context: context,
                              onPressedDelete: () async {
                                mentalStrengthEditProvider
                                    .clearActionListSelected(index: index);
                                Navigator.of(context).pop();
                              },
                              yes: "Yes",
                              title: 'Do you Need Delete ?',
                              content: 'Are you sure you want to delete ?',
                            );
                          },
                          child: CircleAvatar(
                            radius: size.width * 0.035,
                            backgroundColor: Colors.deepPurple,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: size.width * 0.04,
                            ),
                          ),
                        ),
                        // Title
                        SizedBox(
                          width: size.width * 0.45,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              mentalStrengthEditProvider.actionList[index].title
                                  .toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'OpenSans',
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        // Play Button
                        GestureDetector(
                          onTap: () async {
                            await mentalStrengthEditProvider.fetchActionDetails(
                                actionId: mentalStrengthEditProvider
                                    .actionList[index].id
                                    .toString(),
                                context: context);
                            mentalStrengthEditProvider
                                .openActionFullViewFunction();
                          },
                          child: CircleAvatar(
                            radius: size.width * 0.035,
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
          )
        ],
      ),
    );
  }

  Widget _buildDescriptionEditText(BuildContext context,
      MentalStrengthEditProvider mentalStrengthEditProvider) {
    //FocusNode focusNode = FocusNode();

    return StatefulBuilder(
      builder: (context, setState) {
        return CustomTextFormFieldNumu(
          textAlign: TextAlign.start,
          controller: mentalStrengthEditProvider.descriptionEditTextController,
          hintText: _descriptionFocusNode.hasFocus ? '' : "Start writing...",
          hintStyle: TextStyle(
            color: ColorsContent.hintColor,
            fontSize: 16,
            fontWeight: FontWeight.w400, // Font weight 600
            fontFamily: 'OpenSans', // Font family Open Sans
          ),
          textInputAction: TextInputAction.done,
          maxLines: 4,
          focusNode: _descriptionFocusNode,
          onTap: () => setState(() {}),
          // Rebuild when tapped
          onEditingComplete: () {
            _descriptionFocusNode
                .unfocus(); // Ensure focus is removed when done
            setState(() {});
          }, // Rebuild when focus is lost
        );
      },
    );
  }

  Widget _buildTitleEditText(BuildContext context,
      MentalStrengthEditProvider mentalStrengthEditProvider) {
    //FocusNode focusNode = FocusNode();

    return StatefulBuilder(
      builder: (context, setState) {
        return CustomTextFormFieldNumu(
          textAlign: TextAlign.start,
          controller: mentalStrengthEditProvider.titleEditTextController,
          hintText: _titleFocusNode.hasFocus ? '' : "Whats on your mind ?",
          hintStyle: TextStyle(
            color: ColorsContent.hintColor,
            fontSize: 16,
            fontWeight: FontWeight.w400, // Font weight 600
            fontFamily: 'OpenSans', // Font family Open Sans
          ),
          textInputAction: TextInputAction.done,
          maxLines: 1,
          focusNode: _titleFocusNode,
          onTap: () => setState(() {}),
          // Rebuild when tapped
          onEditingComplete: () {
            _titleFocusNode.unfocus(); // Ensure focus is removed when done
            setState(() {});
          }, // Rebuild when focus is lost
        );
      },
    );
  }

  Widget _buildAddMediaColumn(BuildContext context, Size size) {
    return Consumer<MentalStrengthEditProvider>(
        builder: (context, mentalStrengthEditProvider, _) {
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
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: size.height * 0.10,
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
                        bottom: Platform.isIOS ? 60 : 50,
                        // Adjust this value as needed
                        right: 0,
                        // Move to the right
                        left: 40,
                        child: Consumer<MentalStrengthEditProvider>(
                          builder: (context, mentalStrengthEditProvider, _) {
                            if (mentalStrengthEditProvider
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
                                    mentalStrengthEditProvider
                                        .pickedImages.length
                                        .toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.10,
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
                        bottom: Platform.isIOS ? 60 : 50,
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
                                    mentalStrengthEditProvider
                                        .takedImages.length
                                        .toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.10,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _isTokenExpired();
                          mentalStrengthEditProvider.selectedMedia(0);
                          await audioBottomSheet(
                            context: context,
                            title: 'Record Audio',
                          );
                        },
                        child: SvgPicture.asset(
                          ImageConstant
                              .recordAddMediaNumu, // Replace with your SVG asset path
                        ),
                      ),
                      Positioned(
                        bottom: Platform.isIOS ? 60 : 50,
                        // Adjust this value as needed
                        right: 0,
                        // Move to the right
                        left: 40,
                        child: Consumer<MentalStrengthEditProvider>(
                          builder: (context, mentalStrengthEditProvider, _) {
                            if (mentalStrengthEditProvider
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
                                    mentalStrengthEditProvider
                                        .recordedFilePath.length
                                        .toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.10,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _isTokenExpired();
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
                                          edit: false,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          }
                        },
                        child: SvgPicture.asset(
                          ImageConstant
                              .locationAddMediaNumu, // Replace with your SVG asset path
                        ),
                      ),
                      Positioned(
                        bottom: Platform.isIOS ? 60 : 50,
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
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
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
      color: isSelected
          ? ColorsContent.newThemeColor
          : ColorsContent.newThemeColor,
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
        color: ColorsContent.newThemeColor,
        width: 1.8,
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
