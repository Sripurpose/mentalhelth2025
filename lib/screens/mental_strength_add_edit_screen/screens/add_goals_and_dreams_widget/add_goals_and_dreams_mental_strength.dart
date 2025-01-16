import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addactions_screen/addactions_screen.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/widget/googlemap_widget/google_map_widget.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/widget/popup/audio_popup_goals.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/widget/popup/camera_popup.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/widget/popup/gallary_popup_add_goals.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/model/get_category.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/mental_strength_add_edit_page.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:mentalhelth/utils/theme/custom_button_style.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/custom_text_form_field.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:provider/provider.dart';

import '../../../auth/sign_in/provider/sign_in_provider.dart';
import '../../../dash_borad_screen/provider/dash_board_provider.dart';
import '../../../home_screen/provider/home_provider.dart';
import '../../../token_expiry/tocken_expiry_warning_screen.dart';
import '../../../token_expiry/token_expiry.dart';

class AddGoalsDreamsBottomSheet extends StatefulWidget {
  const AddGoalsDreamsBottomSheet({Key? key})
      : super(
          key: key,
        );

  @override
  State<AddGoalsDreamsBottomSheet> createState() =>
      _AddGoalsDreamsBottomSheetState();
}

class _AddGoalsDreamsBottomSheetState extends State<AddGoalsDreamsBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late HomeProvider homeProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late EditProfileProvider editProfileProvider;
  late DashBoardProvider dashBoardProvider;
  bool tokenStatus = false;
  var logger = Logger();


  Future<void> _isTokenExpired() async {
    await homeProvider.fetchChartView(context);
    await homeProvider.fetchJournals(initial: true);
   // await editProfileProvider.fetchUserProfile();
    tokenStatus = TokenManager.checkTokenExpiry();
    if (tokenStatus) {
      setState(() {
        logger.e("Token status changed: $tokenStatus");
      });
      logger.e("Token status changed: $tokenStatus");
    }else{
      logger.e("Token status changedElse: $tokenStatus");
    }

  }

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    mentalStrengthEditProvider = Provider.of<MentalStrengthEditProvider>(context, listen: false);
    dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
    editProfileProvider = Provider.of<EditProfileProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      editProfileProvider.fetchCategory();
      _isTokenExpired();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return  tokenStatus == false ?
      Container(
      margin: EdgeInsets.only(
        top: size.height * 0.15,
      ),
      width: size.width,
      height: size.height,
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
        // color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
        image: DecorationImage(
          image: AssetImage(
            ImageConstant.imgGroup22,
          ),
          fit: BoxFit.cover,
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
      child: Form(
        key: _formKey,
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(
            horizontal: 27,
            vertical: 6,
          ),
          child: Consumer2<AdDreamsGoalsProvider, MentalStrengthEditProvider>(
              builder: (context, adDreamsGoalsProvider,
                  mentalStrengthEditProvider, _) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          mentalStrengthEditProvider.openAddGoalFunction();
                          adDreamsGoalsProvider.clearAction();
                        },
                        child: CustomImageView(
                          imagePath: ImageConstant.imgClosePrimaryNew,
                          height: 40,
                          width: 40,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.005,
                  ),
                  const Center(
                    child: Text(
                      "Add Goals & dreams",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  _buildNameEditText(context),
                  const SizedBox(height: 11),
                  Consumer<EditProfileProvider>(
                      builder: (context, editProfileProvider, _) {
                    return Container(
                      height: size.height * 0.050,
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      decoration: const ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 0.8,
                            style: BorderStyle.solid,
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              5.0,
                            ),
                          ),
                        ),
                      ),
                      child: editProfileProvider.getCategoryModel == null
                          ? const SizedBox()
                          : DropdownButton<Category>(
                              items: editProfileProvider
                                  .getCategoryModel!.category!
                                  .map((Category value) {
                                return DropdownMenuItem<Category>(
                                  value: value,
                                  child: Text(value.categoryName.toString()),
                                );
                              }).toList(),
                              hint: Text(
                                editProfileProvider
                                        .interestsValueController.text.isEmpty
                                    ? 'Music, Badminton'
                                    : editProfileProvider
                                        .interestsValueController.text,
                                style: CustomTextStyles.bodySmallGray700,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              underline: const SizedBox(),
                              isExpanded: true,
                              onChanged: (value) {
                                if (value != null) {
                                  editProfileProvider.selectCategory(
                                    value: value.categoryName.toString(),
                                    mainCategory: value,
                                  );
                                }
                                _isTokenExpired();
                              },
                            ),
                    );
                  }),
                  const SizedBox(height: 11),
                  _buildAchievementDate(context),
                  const SizedBox(height: 25),
                  _buildAddMediaColumn(
                    context,
                    size,
                  ),
                  const SizedBox(height: 11),

                  const SizedBox(height: 24),
                  _buildCommentEditText(context),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 2,
                    ),
                    child: Text(
                      "Actions to achieve the goal",
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  _buildAddActionsButton(
                    context,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  // SizedBox(
                  //   height: size.height * 0.1,
                  //   child: Consumer<AdDreamsGoalsProvider>(
                  //       builder: (context, adDreamsGoalsProvider, _) {
                  //     return ListView.builder(
                  //       itemCount: adDreamsGoalsProvider
                  //           .goalModelIdName.length,
                  //       itemBuilder: (context, index) {
                  //         return _buildCloseEditText(
                  //           context,
                  //           content: adDreamsGoalsProvider
                  //               .goalModelIdName[index].name,
                  //           onTap: () {
                  //             adDreamsGoalsProvider
                  //                 .getAddActionIdAndNameClear(index);
                  //           },
                  //         );
                  //       },
                  //     );
                  //   }),
                  // ),
                  Consumer<AdDreamsGoalsProvider>(
                    builder: (context, adDreamsGoalsProvider, _) {
                      return SizedBox(
                        height: adDreamsGoalsProvider.goalModelIdName.length *
                            size.height *
                            0.06,
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              adDreamsGoalsProvider.goalModelIdName.length,
                          itemBuilder: (context, index) {
                            var data =
                                adDreamsGoalsProvider.goalModelIdName[index];
                            return Row(
                              children: [
                                GestureDetector(
                                  onTap: () async {
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
                                    print(data.id.toString());
                                    await mentalStrengthEditProvider
                                        .fetchActionDetails(
                                      actionId: data.id.toString(),
                                    );

                                    mentalStrengthEditProvider
                                        .openActionFullViewFunction();
                                  },
                                  child: Container(
                                    height: size.height * 0.04,
                                    width: size.width * 0.85,
                                    margin: const EdgeInsets.only(
                                      bottom: 5,
                                      top: 5,
                                      // left: 0,
                                      // right: 5,
                                    ),
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
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: size.width * 0.04,
                                        ),
                                        Text(
                                          adDreamsGoalsProvider
                                              .goalModelIdName[index].name,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        CircleAvatar(
                                          radius: size.width * 0.04,
                                          backgroundColor: Colors.blue,
                                          child: Icon(
                                            Icons.arrow_forward_ios_outlined,
                                            color: Colors.white,
                                            size: size.width * 0.03,
                                          ),
                                        ),
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
                      );
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _buildSaveButton(context),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    ):
    const TokenExpireScreen();
  }

  /// Section Widget
  Widget _buildNameEditText(BuildContext context) {
    return Consumer<AdDreamsGoalsProvider>(
        builder: (context, adDreamsGoalsProvider, _) {
      return Padding(
        padding: const EdgeInsets.only(left: 2),
        child: CustomTextFormField(
          controller: adDreamsGoalsProvider.nameEditTextController,
          hintText: "Goal Name",
          hintStyle: CustomTextStyles.bodySmallGray700,
        ),
      );
    });
  }

  /// Section Widget
  Widget _buildAchievementDate(BuildContext context) {
    return Consumer<AdDreamsGoalsProvider>(
        builder: (context, adDreamsGoalsProvider, _) {
      return GestureDetector(
        onTap: () {
          adDreamsGoalsProvider.selectDate(
            context,
          );
        },
        child: Container(
          margin: const EdgeInsets.only(
            left: 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 11,
            vertical: 8,
          ),
          decoration: const ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 0.8,
                style: BorderStyle.solid,
                color: Colors.grey,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(
                  5.0,
                ),
              ),
            ),
          ),
          child: Row(
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgThumbsUpGray700,
                height: 20,
                width: 20,
                margin: const EdgeInsets.only(bottom: 2),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 5,
                  top: 2,
                  bottom: 1,
                ),
                child: Text(
                  adDreamsGoalsProvider.selectedDate.isNotEmpty
                      ? adDreamsGoalsProvider.selectedDate
                      : "Achievement Date",
                  style: CustomTextStyles.bodySmallGray700,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCommentEditText(BuildContext context) {
    return Consumer<AdDreamsGoalsProvider>(
        builder: (context, adDreamsGoalsProvider, _) {
      return Padding(
        padding: const EdgeInsets.only(left: 2),
        child: CustomTextFormField(
          controller: adDreamsGoalsProvider.commentEditTextController,
          hintText: "Goal Description",
          hintStyle: CustomTextStyles.bodySmallGray700,
          maxLines: 4,
        ),
      );
    });
  }

  /// Section Widget
  Widget _buildAddActionsButton(BuildContext context) {
    return CustomElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AddactionsScreen(goalId: '',),
          ),
        );
      },
      height: 40,
      text: "Add Action",
      margin: const EdgeInsets.only(left: 2),
      buttonTextStyle: CustomTextStyles.titleSmallOnSecondaryContainer_1,
      buttonStyle: CustomButtonStyles.outlinePrimaryBlue,
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Consumer2<AdDreamsGoalsProvider, EditProfileProvider>(
        builder: (context, adDreamsGoalsProvider, editProfileProvider, _) {
      return CustomElevatedButton(
        loading: adDreamsGoalsProvider.saveAddActionsLoading,
        onPressed: () async {
          if (!adDreamsGoalsProvider.isVideoUploading) {
            if (adDreamsGoalsProvider.nameEditTextController.text.isNotEmpty &&
                adDreamsGoalsProvider
                    .commentEditTextController.text.isNotEmpty &&
                adDreamsGoalsProvider.selectedDate.isNotEmpty &&
                editProfileProvider.categorys != null &&
                adDreamsGoalsProvider.formattedDate != null) {
              await adDreamsGoalsProvider.saveGemFunction(
                isPop: false,
                context,
                title: adDreamsGoalsProvider.nameEditTextController.text,
                details: adDreamsGoalsProvider.commentEditTextController.text,
                mediaName: adDreamsGoalsProvider.addMediaUploadResponseList,
                locationName: adDreamsGoalsProvider.selectedLocationName,
                locationLatitude: adDreamsGoalsProvider.selectedLatitude,
                locationLongitude: adDreamsGoalsProvider.locationLongitude,
                locationAddress: adDreamsGoalsProvider.selectedLocationAddress,
                categoryId: editProfileProvider.categorys!.id.toString(),
                gemEndDate: adDreamsGoalsProvider.formattedDate,
                actionId: adDreamsGoalsProvider.goalModelIdName,
              );

              MentalStrengthEditProvider mentalStrengthEditProvider =
                  Provider.of<MentalStrengthEditProvider>(context,
                      listen: false);
              await mentalStrengthEditProvider.fetchGoals(
                initial: true,
              );
              mentalStrengthEditProvider.openAddGoalFunction();
              if (mentalStrengthEditProvider.goalsList.isNotEmpty) {
                mentalStrengthEditProvider.addGoalValue(
                  value: mentalStrengthEditProvider.goalsList[0],
                );
              }
            } else {
              showCustomSnackBar(
                context: context,
                message: "Please fill in all the fields",
              );
            }
          } else {
            showCustomSnackBar(
              context: context,
              message: "Please Wait Video Uploading",
            );
          }
        },
        height: 40,
        text: "Save",
        margin: const EdgeInsets.only(left: 2),
        buttonStyle: CustomButtonStyles.outlinePrimaryTL5,
        buttonTextStyle:
            CustomTextStyles.titleSmallHelveticaOnSecondaryContainer,
      );
    });
  }

  Widget _buildAddMediaColumn(BuildContext context, Size size) {
    return Consumer<AdDreamsGoalsProvider>(
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
                          await audioBottomSheetAddGoals(
                            context: context,
                            title: 'Record Audio',
                          );
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
                        child: Consumer<AdDreamsGoalsProvider>(
                            builder: (context, mentalStrengthEditProvider, _) {
                          if (mentalStrengthEditProvider
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
                                  mentalStrengthEditProvider
                                      .recordedFilePath.length
                                      .toString(),
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
                          mentalStrengthEditProvider.selectedMedia(1);
                          await galleryBottomSheetAddGoals(
                            context: context,
                            title: 'Gallery',
                          );
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
                        child: Consumer<AdDreamsGoalsProvider>(
                            builder: (context, mentalStrengthEditProvider, _) {
                          if (mentalStrengthEditProvider.pickedImages.isEmpty) {
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
                                  mentalStrengthEditProvider.pickedImages.length
                                      .toString(),
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
                        onTap: () {
                          _isTokenExpired();
                          mentalStrengthEditProvider.selectedMedia(2);
                          cameraBottomSheetAdGoals(
                            context: context,
                            title: "Camera",
                          );
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
                        child: Consumer<AdDreamsGoalsProvider>(
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
                                  mentalStrengthEditProvider.takedImages.length
                                      .toString(),
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
                        onTap: () {
                          mentalStrengthEditProvider.selectedMedia(
                            3,
                          );
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                child: const AddGoalsGoogleMap(),
                              );
                            },
                          );
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
                        child: Consumer<AdDreamsGoalsProvider>(
                            builder: (context, adDreamsGoalsProvider, _) {
                              if (adDreamsGoalsProvider
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
