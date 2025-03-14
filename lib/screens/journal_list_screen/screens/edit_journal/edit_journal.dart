import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
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

class EditJournalMentalStrength extends StatefulWidget {
  const EditJournalMentalStrength({Key? key, this.valueBool = false})
      : super(
          key: key,
        );
  final bool valueBool;

  @override
  State<EditJournalMentalStrength> createState() =>
      _EditJournalMentalStrengthState();
}

class _EditJournalMentalStrengthState extends State<EditJournalMentalStrength> {
  late HomeProvider homeProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late EditProfileProvider editProfileProvider;
  late DashBoardProvider dashBoardProvider;
  late AdDreamsGoalsProvider adDreamsGoalsProvider;
  bool tokenStatus = false;
  var logger = Logger();

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    mentalStrengthEditProvider =
        Provider.of<MentalStrengthEditProvider>(context, listen: false);
    dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
    editProfileProvider =
        Provider.of<EditProfileProvider>(context, listen: false);
    adDreamsGoalsProvider =
        Provider.of<AdDreamsGoalsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mentalStrengthEditProvider.mediaSelected = -1;
      _isTokenExpired();
    });
    super.initState();
  }

  Future<void> _isTokenExpired() async {
    await homeProvider.fetchChartView(context);
    await homeProvider.fetchJournals(initial: true);
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
          mentalStrengthEditProvider.openActionFullView =false;
          mentalStrengthEditProvider.openAddAction = false;
        },
        child: tokenStatus == false
            ? Scaffold(
                body: SafeArea(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          ImageConstant.imgGroup22,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
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
                                mentalStrengthEditProvider.openGoalViewSheet = false;
                                mentalStrengthEditProvider.goalDetailModel = null;
                                mentalStrengthEditProvider.openActionFullView =false;
                                mentalStrengthEditProvider.openAddAction = false;
                                // Proper condition check before popping the screen
                                // if (mentalStrengthEditProvider.openGoalViewSheet) {
                                //   if (mentalStrengthEditProvider.goalDetailModel != null) {
                                //     Navigator.of(context).pop();
                                //   }
                                // } else {
                                //   Navigator.of(context).pop();
                                // }
                                Navigator.of(context).pop();
                              },
                            ),
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                      left: size.width * 0.05,
                                      right: size.width * 0.05,
                                    ),
                                    color: mentalStrengthEditProvider
                                            .openChooseGoal
                                        ? Colors.blue[50]
                                        : null,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            // width: size.width * 0.1,
                                            // height: size.height * 0.1,
                                            child: GestureDetector(
                                              onTap: () {
                                                // editProfileProvider.getImageFromGallery(
                                                //   context: context,
                                                // );
                                              },
                                              child: editProfileProvider
                                                          .images !=
                                                      null
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              60),
                                                      child: Image.file(
                                                        editProfileProvider
                                                            .images!,
                                                        height:
                                                            size.height * 0.1,
                                                        width:
                                                            size.height * 0.1,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                  : CustomImageView(
                                                      imagePath:
                                                          editProfileProvider
                                                              .profileUrl
                                                              .toString(),
                                                      height: size.height * 0.1,
                                                      width: size.height * 0.1,
                                                      radius:
                                                          BorderRadius.circular(
                                                              54),
                                                      alignment:
                                                          Alignment.center,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                          editProfileProvider.getProfileModel ==
                                                  null
                                              ? const SizedBox()
                                              : SizedBox(
                                                  width: size.width * 0.6,
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    child: Center(
                                                      child: Text(
                                                        editProfileProvider
                                                            .getProfileModel!
                                                            .firstname
                                                            .toString(),
                                                        style: CustomTextStyles
                                                            .bodyLarge18,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines:
                                                            10, // Set the maximum number of lines
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                          editProfileProvider.getProfileModel ==
                                                  null
                                              ? const SizedBox()
                                              : Text(
                                                  homeProvider.journalDetails ==
                                                          null
                                                      ? ""
                                                      : dateTimeFormatter(
                                                          date: homeProvider
                                                              .journalDetails!
                                                              .journals!
                                                              .journalDatetime
                                                              .toString(),
                                                        ),
                                                  style: CustomTextStyles
                                                      .bodyMediumGray700,
                                                ),
                                          SizedBox(
                                            height: size.height * 0.02,
                                          ),
                                          Text(
                                            "Whats on your mind?",
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                          SizedBox(
                                            height: size.height * 0.03,
                                          ),
                                          _buildDescriptionEditText(context),
                                          // const Slider1ItemWidget(),
                                          SizedBox(height: size.height * 0.03),
                                          CustomImageView(
                                            imagePath: ImageConstant.imgGroup27,
                                            height: 33,
                                            width: 5,
                                          ),
                                          _buildAddMediaColumn(
                                            context,
                                            size,
                                          ),
                                          SizedBox(height: size.height * 0.03),

                                          // mentalStrengthEditProvider.mediaSelected == 3
                                          //     ? const MentalGoogleMap()
                                          //     : const SizedBox(),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          CustomIconButton(
                                            height: size.height * 0.08,
                                            width: size.height * 0.08,
                                            padding: const EdgeInsets.all(
                                              11,
                                            ),
                                            decoration:
                                                IconButtonStyleHelper.fillBlue,
                                            child: CustomImageView(
                                              imagePath:
                                                  ImageConstant.imgLightBulb,
                                            ),
                                          ),
                                          SizedBox(
                                            height: size.height * 0.03,
                                          ),
                                          CustomImageView(
                                            imagePath: ImageConstant.imgGroup28,
                                            height: 19,
                                            width: 5,
                                          ),
                                          SizedBox(height: size.height * 0.03),
                                          Text(
                                            "Rate how you are feeling now?",
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          CustomRatingBar(
                                            initialRating:
                                                mentalStrengthEditProvider
                                                    .emotionalValueStar,
                                            itemSize: 34,
                                            color: Colors.blue,
                                            onRatingUpdate: (value) {
                                              mentalStrengthEditProvider
                                                  .changeEmotionalValueStar(
                                                      value);
                                            },
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          CustomImageView(
                                            imagePath: ImageConstant.imgGroup29,
                                            height: 33,
                                            width: 5,
                                          ),
                                          SizedBox(
                                            height: size.height * 0.03,
                                          ),
                                          Text(
                                            "What is your emotional state?",
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                          SizedBox(height: size.height * 0.01),
                                          mentalStrengthEditProvider
                                                      .getEmotionsModel ==
                                                  null
                                              ? const SizedBox()
                                              : Container(
                                                  width: size.width * 0.60,
                                                  // This controls the button width
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.grey,
                                                      // Border color
                                                      width:
                                                          1.0, // Border width
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                    // Border radius for rounded corners
                                                    color: Colors
                                                        .white, // Background color (optional)
                                                  ),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child: DropdownButton2(
                                                      isExpanded: true,
                                                      // buttonWidth: size.width * 0.60, // Adjust the width of the button
                                                      // buttonDecoration: BoxDecoration(
                                                      //   borderRadius: BorderRadius.circular(15.0),
                                                      //   border: Border.all(color: Colors.grey, width: 1.0),
                                                      //   color: Colors.white,
                                                      // ),
                                                      // dropdownWidth: 190, // Set the desired width for the dropdown menu
                                                      // dropdownDecoration: BoxDecoration(
                                                      //   borderRadius: BorderRadius.circular(15.0),
                                                      //   color: Colors.white,
                                                      // ),
                                                      value:
                                                          mentalStrengthEditProvider
                                                              .emotionValue,
                                                      //icon: const Icon(Icons.keyboard_arrow_down),
                                                      dropdownStyleData:
                                                          DropdownStyleData(
                                                        maxHeight: 300,
                                                        width: 250,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(14),
                                                          color: Colors.white,
                                                        ),
                                                        offset:
                                                            const Offset(0, 0),
                                                        scrollbarTheme:
                                                            ScrollbarThemeData(
                                                          radius: const Radius
                                                              .circular(40),
                                                          thickness:
                                                              MaterialStateProperty
                                                                  .all(6),
                                                          thumbVisibility:
                                                              MaterialStateProperty
                                                                  .all(true),
                                                        ),
                                                      ),
                                                      items:
                                                          mentalStrengthEditProvider
                                                              .getEmotionsModel!
                                                              .emotions!
                                                              .map((Emotion
                                                                  items) {
                                                        return DropdownMenuItem(
                                                          value: items,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                            child: Text(
                                                              items.title
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black, // Change to your desired color
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged:
                                                          (Emotion? newValue) {
                                                        setState(() {
                                                          mentalStrengthEditProvider
                                                                  .emotionValue =
                                                              newValue!;
                                                        });
                                                        _isTokenExpired();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                          SizedBox(height: size.height * 0.03),
                                          CustomImageView(
                                            imagePath: ImageConstant.imgGroup29,
                                            height: 33,
                                            width: 5,
                                          ),
                                          SizedBox(height: size.height * 0.03),
                                          Text(
                                            "Do you like your reaction to the situation?",
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                          SizedBox(
                                            height: size.height * 0.01,
                                          ),
                                          CustomRatingBar(
                                            initialRating:
                                                mentalStrengthEditProvider
                                                    .driveValueStar,
                                            itemSize: 34,
                                            color: Colors.blue,
                                            onRatingUpdate: (value) {
                                              mentalStrengthEditProvider
                                                  .changeDriveValueStar(value);
                                            },
                                          ),
                                          SizedBox(height: size.height * 0.03),
                                          CustomImageView(
                                            imagePath: ImageConstant.imgGroup29,
                                            height: 33,
                                            width: 5,
                                          ),
                                          SizedBox(height: size.height * 0.03),
                                          Text(
                                            "Which goal is affected by your reaction?",
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                          SizedBox(
                                            height: size.height * 0.02,
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              mentalStrengthEditProvider
                                                  .openChooseGoalFunction();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            child: const Text(
                                              "Choose Goal",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: size.height * 0.01,
                                          ),
                                          mentalStrengthEditProvider
                                                      .goalsValue.id ==
                                                  null
                                              ? const SizedBox()
                                              : mentalStrengthEditProvider
                                                          .goalsValue.id ==
                                                      ""
                                                  ? const SizedBox()
                                                  : mentalStrengthEditProvider
                                                          .goalsValue
                                                          .id!
                                                          .isEmpty
                                                      ? const SizedBox()
                                                      : Container(
                                                          height: size.height *
                                                              0.04,
                                                          width:
                                                              size.width * 0.7,
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            bottom: 5,
                                                            top: 5,
                                                            left: 5,
                                                            right: 5,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100), // Makes it circular
                                                            border: Border.all(
                                                              color:
                                                                  Colors.grey,
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  customPopup(
                                                                    context:
                                                                        context,
                                                                    onPressedDelete:
                                                                        () async {
                                                                      mentalStrengthEditProvider
                                                                          .cleaGoalValue();
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                      // Close the bottom sheet after deleting
                                                                      //  Navigator.of(context).pop();  // This will close the galleryBottomSheet as well
                                                                    },
                                                                    yes: "Yes",
                                                                    title:
                                                                        'Do you Need Delete',
                                                                    content:
                                                                        'Are you sure do you need delete',
                                                                  );
                                                                },
                                                                child:
                                                                    CircleAvatar(
                                                                  radius:
                                                                      size.width *
                                                                          0.04,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .blue,
                                                                  child: Icon(
                                                                    Icons.close,
                                                                    color: Colors
                                                                        .white,
                                                                    size: size
                                                                            .width *
                                                                        0.03,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    size.width *
                                                                        0.45,
                                                                child:
                                                                    SingleChildScrollView(
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  // Enable horizontal scrolling
                                                                  child: Text(
                                                                    mentalStrengthEditProvider
                                                                        .goalsValue
                                                                        .title
                                                                        .toString(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    // Add this line if you want to truncate long text
                                                                    maxLines:
                                                                        1, // Limit to 1 line for horizontal scrolling
                                                                  ),
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  mentalStrengthEditProvider
                                                                      .openGoalViewSheetFunction();
                                                                  mentalStrengthEditProvider
                                                                      .fetchGoalDetails(
                                                                    goalId: mentalStrengthEditProvider
                                                                        .goalsValue
                                                                        .id
                                                                        .toString(),
                                                                  );
                                                                },
                                                                child:
                                                                    CircleAvatar(
                                                                  radius:
                                                                      size.width *
                                                                          0.04,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .blue,
                                                                  child: Icon(
                                                                    Icons
                                                                        .arrow_forward_ios_outlined,
                                                                    color: Colors
                                                                        .white,
                                                                    size: size
                                                                            .width *
                                                                        0.03,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                          SizedBox(
                                            height: size.height * 0.03,
                                          ),
                                          CustomImageView(
                                            imagePath: ImageConstant.imgGroup29,
                                            height: 33,
                                            width: 5,
                                          ),
                                          SizedBox(height: size.height * 0.03),
                                          Text(
                                            "Select an action?",
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                          SizedBox(height: size.height * 0.03),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (mentalStrengthEditProvider
                                                  .goalsValue.id ==
                                                  null) {
                                                showCustomSnackBar(
                                                  context: context,
                                                  message: "Please choose your goal",
                                                );
                                              }else{
                                                mentalStrengthEditProvider
                                                    .openChooseActionFunction();
                                              }

                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            child: const Text(
                                              "Choose Action",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: size.height * 0.01,
                                          ),
                                          SizedBox(
                                            height: mentalStrengthEditProvider
                                                    .actionList.length *
                                                size.height *
                                                0.045,
                                            width: size.width * 0.7,
                                            child: ListView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  mentalStrengthEditProvider
                                                      .actionList.length,
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  height: size.height * 0.04,
                                                  width: size.width * 0.7,
                                                  padding:
                                                      const EdgeInsets.only(
                                                    bottom: 5,
                                                    top: 5,
                                                    left: 5,
                                                    right: 5,
                                                  ),
                                                  margin: const EdgeInsets.only(
                                                    bottom: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100), // Makes it circular
                                                    border: Border.all(
                                                      color: Colors.grey,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          customPopup(
                                                            context: context,
                                                            onPressedDelete:
                                                                () async {
                                                              mentalStrengthEditProvider
                                                                  .clearActionListSelected(
                                                                index: index,
                                                              );
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();

                                                              // Close the bottom sheet after deleting
                                                              //  Navigator.of(context).pop();  // This will close the galleryBottomSheet as well
                                                            },
                                                            yes: "Yes",
                                                            title:
                                                                'Do you Need Delete',
                                                            content:
                                                                'Are you sure do you need delete',
                                                          );
                                                        },
                                                        child: CircleAvatar(
                                                          radius:
                                                              size.width * 0.04,
                                                          backgroundColor:
                                                              Colors.blue,
                                                          child: Icon(
                                                            Icons.close,
                                                            color: Colors.white,
                                                            size: size.width *
                                                                0.03,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            size.width * 0.45,
                                                        // color:Colors.black,
                                                        child:
                                                            SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          // Enable horizontal scrolling
                                                          child: Text(
                                                            mentalStrengthEditProvider
                                                                .actionList[
                                                                    index]
                                                                .title
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
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
                                                          await mentalStrengthEditProvider
                                                              .fetchActionDetails(
                                                            actionId:
                                                                mentalStrengthEditProvider
                                                                    .actionList[
                                                                        index]
                                                                    .id
                                                                    .toString(),
                                                          );
                                                        },
                                                        child: CircleAvatar(
                                                          radius:
                                                              size.width * 0.04,
                                                          backgroundColor:
                                                              Colors.blue,
                                                          child: Icon(
                                                            Icons
                                                                .arrow_forward_ios_outlined,
                                                            color: Colors.white,
                                                            size: size.width *
                                                                0.03,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),

                                          SizedBox(
                                            height: size.height * 0.03,
                                          ),
                                          CustomElevatedButton(
                                            loading: mentalStrengthEditProvider
                                                .saveJournalLoading,
                                            onPressed: () async {
                                              _isTokenExpired();
                                              if (!mentalStrengthEditProvider
                                                  .isVideoUploading) {
                                                if (mentalStrengthEditProvider
                                                    .descriptionEditTextController
                                                    .text
                                                    .isNotEmpty) {
                                                  bool isSuccess =
                                                      await mentalStrengthEditProvider
                                                          .updateJournalLoading(
                                                    journalId: homeProvider
                                                        .journalDetails!
                                                        .journals!
                                                        .journalId
                                                        .toString(),
                                                    context,
                                                    journalTitle: mentalStrengthEditProvider
                                                                .descriptionEditTextController
                                                                .text
                                                                .length <=
                                                            6
                                                        ? mentalStrengthEditProvider
                                                            .descriptionEditTextController
                                                            .text
                                                        : mentalStrengthEditProvider
                                                            .descriptionEditTextController
                                                            .text
                                                            .substring(0, 6),
                                                    journalDesc:
                                                        mentalStrengthEditProvider
                                                            .descriptionEditTextController
                                                            .text,
                                                    emotionId:
                                                        mentalStrengthEditProvider
                                                            .emotionValue.id
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
                                                            .locationLongitude,
                                                    mediaName:
                                                        mentalStrengthEditProvider
                                                            .addMediaUploadResponseList,
                                                    locationAddress:
                                                        mentalStrengthEditProvider
                                                            .selectedLocationAddress,
                                                    actionIdList:
                                                        mentalStrengthEditProvider
                                                            .actionList
                                                            .map((e) =>
                                                                e.id ?? "")
                                                            .toList(),
                                                  );
                                                  if (isSuccess) {
                                                    Future.delayed(
                                                        const Duration(
                                                            seconds: 3),
                                                        () async {
                                                      await homeProvider
                                                          .fetchJournals(
                                                              initial: true);
                                                    });

                                                    DashBoardProvider
                                                        dashBoardProvider =
                                                        Provider.of<
                                                                DashBoardProvider>(
                                                            context,
                                                            listen: false);
                                                    dashBoardProvider
                                                        .changePage(index: 2);
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
                                                index: 2,
                                              );
                                            },
                                            height: 65,
                                            text: "Update",
                                            buttonStyle:
                                                CustomButtonStyles.fillBlueTL13,
                                            buttonTextStyle: CustomTextStyles
                                                .titleLargeGray50,
                                          ),
                                          SizedBox(
                                            height: size.height * 0.03,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  mentalStrengthEditProvider.openChooseGoal
                                      ? const ScreenChooseGoalMentalStrength()
                                      : const SizedBox(),
                                  mentalStrengthEditProvider.openAddGoal
                                      ? const AddGoalsDreamsBottomSheet()
                                      : const SizedBox(),
                                  mentalStrengthEditProvider.openGoalViewSheet
                                      ? mentalStrengthEditProvider
                                                  .goalDetailModel ==
                                              null
                                          ? Container(
                                              decoration: BoxDecoration(
                                                color: appTheme.gray50,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topRight: Radius.circular(
                                                    25,
                                                  ),
                                                  topLeft: Radius.circular(
                                                    25,
                                                  ),
                                                ),
                                              ),
                                              margin: EdgeInsets.only(
                                                top: size.height * 0.15,
                                              ),
                                              child: shimmerList(
                                                height: size.height * 0.8,
                                                list: 10,
                                              ),
                                            )
                                          : GoalAndDreamFullViewBottomSheet(
                                              goalDetailModel:
                                                  mentalStrengthEditProvider
                                                      .goalDetailModel!,
                                            )
                                      : const SizedBox(),
                                  mentalStrengthEditProvider.openChooseAction
                                      ? ChooseActionMentalHelth(
                                          goal: mentalStrengthEditProvider
                                              .goalsValue,
                                        )
                                      : const SizedBox(),
                                  mentalStrengthEditProvider.openAddAction
                                      ? AddActionMentalStrengthBottomSheet(
                                          goalId: mentalStrengthEditProvider
                                              .goalsValue.id
                                              .toString(),
                                        )
                                      : const SizedBox(),
                                  mentalStrengthEditProvider.openActionFullView
                                      ? const ActionFullViewJournalCreateBottomSheet()
                                      : const SizedBox()
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              )
            : const TokenExpireScreen());
  }

  /// Section Widget
  Widget _buildDescriptionEditText(BuildContext context) {
    return Consumer<MentalStrengthEditProvider>(
        builder: (context, mentalStrengthEditProvider, _) {
      // Decode the text before setting it to the controller
      String decodedText = HtmlUnescape().convert(
          mentalStrengthEditProvider.descriptionEditTextController.text);
      mentalStrengthEditProvider.descriptionEditTextController.text =
          decodedText;

      return CustomTextFormField(
        controller: mentalStrengthEditProvider.descriptionEditTextController,
        hintText: "Description",
        hintStyle: CustomTextStyles.bodySmallGray700,
        textInputAction: TextInputAction.done,
        maxLines: 4,
      );
    });
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
                          _isTokenExpired();
                          mentalStrengthEditProvider.selectedMedia(0);
                          // if (mentalStrengthEditProvider.mediaSelected == 1) {
                          await audioBottomSheet(
                            context: context,
                            title: 'Record Audio',
                          );
                          // }
                        },
                        child: Container(
                          height: size.height * 0.08,
                          width: size.height * 0.08,
                          decoration: BoxDecoration(
                            color: mentalStrengthEditProvider.mediaSelected == 0
                                ? Colors.blue
                                : Colors.transparent,
                            image: DecorationImage(
                              image: AssetImage(ImageConstant.imgMenu),
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
                          child: Icon(
                            Icons.mic,
                            size: 30,
                            color: mentalStrengthEditProvider.mediaSelected == 0
                                ? Colors.white
                                : Colors.blue,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 10,
                        right: 10,
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
                              decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                  image: AssetImage(ImageConstant.imgMenu),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(
                                    50.0,
                                  ),
                                ),
                                border: Border.all(
                                  color: appTheme.blue300,
                                  width: 2.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "${mentalStrengthEditProvider.recordedFilePath.length + mentalStrengthEditProvider.alreadyRecordedFilePath.length}",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                      )
                    ],
                  ),
                ),
                // const AudioRecorderMentalStrengthBuild(),
                SizedBox(
                  height: size.height * 0.09,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          _isTokenExpired();
                          if (await requestGalleryPermission() && Platform.isAndroid) {
                            mentalStrengthEditProvider.selectedMedia(1);
                            await galleryBottomSheet(
                              context: context,
                              title: 'Gallery',
                            );
                          } else if(Platform.isIOS){
                            mentalStrengthEditProvider.selectedMedia(1);
                            await galleryBottomSheet(
                              context: context,
                              title: 'Gallery',
                            );
                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                  Text("Gallery permission is required.")),
                            );
                          }
                        },
                        child: buildAvatarImage(
                          widget: Icon(
                            Icons.image,
                            size: 30,
                            color: mentalStrengthEditProvider.mediaSelected == 1
                                ? Colors.white
                                : Colors.blue,
                          ),
                          imagePath: ImageConstant.imgThumbsUp,
                          size: size,
                          isSelected:
                              mentalStrengthEditProvider.mediaSelected == 1
                                  ? true
                                  : false,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 10,
                        right: 10,
                        child: Consumer<MentalStrengthEditProvider>(
                            builder: (context, mentalStrengthEditProvider, _) {
                          if (mentalStrengthEditProvider
                                  .alreadyPickedImages.isEmpty &&
                              mentalStrengthEditProvider.pickedImages.isEmpty) {
                            return const SizedBox();
                          } else {
                            return Container(
                              width: size.height * 0.04,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                  image: AssetImage(ImageConstant.imgMenu),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(
                                    50.0,
                                  ),
                                ),
                                border: Border.all(
                                  color: appTheme.blue300,
                                  width: 2.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "${mentalStrengthEditProvider.pickedImages.length + mentalStrengthEditProvider.alreadyPickedImages.length}",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.09,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          _isTokenExpired();
                          if (await requestCameraPermission() && Platform.isAndroid) {
                            mentalStrengthEditProvider.selectedMedia(2);
                            cameraBottomSheet(
                              context: context,
                              title: "Camera",
                            );
                          } else if(Platform.isIOS){
                            mentalStrengthEditProvider.selectedMedia(2);
                            cameraBottomSheet(
                              context: context,
                              title: "Camera",
                            );

                          }else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                  Text("Camera permission is required.")),
                            );
                          }
                        },
                        child: buildAvatarImage(
                          widget: Icon(
                            Icons.camera_alt_outlined,
                            size: 30,
                            color: mentalStrengthEditProvider.mediaSelected == 2
                                ? Colors.white
                                : Colors.blue,
                          ),
                          imagePath: ImageConstant.imgCamera,
                          size: size,
                          isSelected:
                              mentalStrengthEditProvider.mediaSelected == 2
                                  ? true
                                  : false,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 10,
                        right: 10,
                        child: Consumer<MentalStrengthEditProvider>(
                            builder: (context, mentalStrengthEditProvider, _) {
                          if (mentalStrengthEditProvider.takedImages.isEmpty) {
                            return const SizedBox();
                          } else {
                            return Container(
                              width: size.height * 0.04,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                  image: AssetImage(ImageConstant.imgMenu),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(
                                    50.0,
                                  ),
                                ),
                                border: Border.all(
                                  color: appTheme.blue300,
                                  width: 2.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "${mentalStrengthEditProvider.takedImages.length}",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.09,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          mentalStrengthEditProvider.selectedMedia(
                            3,
                          );

                          final status = await Permission.locationWhenInUse.status;

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
                          if (await Permission.locationWhenInUse.isGranted){
                            if (mounted) {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(20),
                                      child: const MentalGoogleMap(
                                        edit: true,
                                      ));
                                },
                              );
                            }
                          }

                          // mentalStrengthEditProvider.mediaSelected == 3
                          //     ? const MentalGoogleMap()
                          //     : const SizedBox(),
                        },
                        child: buildAvatarImage(
                          widget: Icon(
                            Icons.location_on,
                            size: 30,
                            color: mentalStrengthEditProvider.mediaSelected == 3
                                ? Colors.white
                                : Colors.blue,
                          ),
                          imagePath: ImageConstant.imgLinkedin,
                          size: size,
                          // wi
                          isSelected:
                              mentalStrengthEditProvider.mediaSelected == 3
                                  ? true
                                  : false,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 10,
                        right: 10,
                        child: Consumer<MentalStrengthEditProvider>(
                            builder: (context, mentalStrengthEditProvider, _) {
                          if (mentalStrengthEditProvider
                              .selectedLocationName.isEmpty) {
                            return const SizedBox();
                          } else {
                            return Container(
                              width: size.height * 0.04,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                image: DecorationImage(
                                  image: AssetImage(ImageConstant.imgMenu),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(
                                    50.0,
                                  ),
                                ),
                                border: Border.all(
                                  color: appTheme.blue300,
                                  width: 2.0,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "1",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }
                        }),
                      )
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
      color: isSelected ? Colors.blue : Colors.transparent,
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
            color: isSelected ? Colors.white : Colors.blue,
          ),
        ),
  );
}
