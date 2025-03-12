import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/widget/googlemap_widget/google_map_widget.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/widget/popup/audio_popup_goals.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/widget/popup/camera_popup.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/widget/popup/gallary_popup_add_goals.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/model/get_category.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/mental_strength_add_edit_page.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/custom_text_form_field.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../utils/logic/permissions.dart';
import '../../utils/theme/custom_button_style.dart';
import '../addactions_screen/addactions_screen.dart';
import '../dash_borad_screen/provider/dash_board_provider.dart';
import '../goals_dreams_page/provider/goals_dreams_provider.dart';
import '../home_screen/provider/home_provider.dart';
import '../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../token_expiry/tocken_expiry_warning_screen.dart';
import '../token_expiry/token_expiry.dart';
import 'provider/ad_goals_dreams_provider.dart';

class AddGoalsDreamsScreen extends StatefulWidget {
  const AddGoalsDreamsScreen({Key? key})
      : super(
          key: key,
        );

  @override
  State<AddGoalsDreamsScreen> createState() => _AddGoalsDreamsScreenState();
}

class _AddGoalsDreamsScreenState extends State<AddGoalsDreamsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late HomeProvider homeProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late EditProfileProvider editProfileProvider;
  late DashBoardProvider dashBoardProvider;
  late AdDreamsGoalsProvider adDreamsGoalsProvider;
  bool tokenStatus = false;
  var logger = Logger();
  PermissionStatus permissionStatus = PermissionStatus.denied;

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
    adDreamsGoalsProvider.nameEditTextController.text = "";
    editProfileProvider.interestsValueController.text = "";
    adDreamsGoalsProvider.selectedDate = "";
    adDreamsGoalsProvider.commentEditTextController.text = "";
    adDreamsGoalsProvider.goalModelIdName.clear();
    adDreamsGoalsProvider.recordedFilePath.clear();
    adDreamsGoalsProvider.pickedImages.clear();
    adDreamsGoalsProvider.takedImages.clear();
    adDreamsGoalsProvider.selectedLocationName = "";
    adDreamsGoalsProvider.mediaSelected = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isTokenExpired();
      editProfileProvider.fetchCategory();
      adDreamsGoalsProvider.goalModelIdName.clear();
    });
    super.initState();
  }

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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return tokenStatus == false
        ? SafeArea(
            child: Scaffold(
              appBar: buildAppBar(
                context,
                size,
                heading: "Add Goals & Dreams",
              ),
              body: Stack(
                children: [
                  Container(
                    width: size.width,
                    height: size.height,
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.onSecondaryContainer.withOpacity(1),
                      image: DecorationImage(
                        image: AssetImage(
                          ImageConstant.imgGroup22,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 27,
                          vertical: 6,
                        ),
                        child: Consumer<AdDreamsGoalsProvider>(
                            builder: (context, adDreamsGoalsProvider, _) {
                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: size.height * 0.02,
                                ),
                                _buildNameEditText(context),
                                const SizedBox(height: 11),
                                Consumer<EditProfileProvider>(
                                    builder: (context, editProfileProvider, _) {
                                  return Container(
                                    height: size.height * 0.045,
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
                                    child: editProfileProvider
                                                .getCategoryModel ==
                                            null
                                        ? const SizedBox()
                                        : DropdownButton<Category>(
                                            items: editProfileProvider
                                                .getCategoryModel!.category!
                                                .map((Category value) {
                                              return DropdownMenuItem<Category>(
                                                value: value,
                                                child: Text(value.categoryName
                                                    .toString()),
                                              );
                                            }).toList(),
                                            hint: Text(
                                              editProfileProvider
                                                      .interestsValueController
                                                      .text
                                                      .isEmpty
                                                  ? 'Music, Badminton'
                                                  : editProfileProvider
                                                      .interestsValueController
                                                      .text,
                                              style: CustomTextStyles
                                                  .bodySmallGray700,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            underline: const SizedBox(),
                                            isExpanded: true,
                                            onChanged: (value) {
                                              if (value != null) {
                                                editProfileProvider
                                                    .selectCategory(
                                                  value: value.categoryName
                                                      .toString(),
                                                  mainCategory: value,
                                                );
                                                _isTokenExpired();
                                              }
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
                                // adDreamsGoalsProvider.mediaSelected == 3
                                //     ? const Center(child: AddGoalsGoogleMap())
                                //     : const SizedBox(),
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
                                      height: adDreamsGoalsProvider
                                              .goalModelIdName.length *
                                          size.height *
                                          0.06,
                                      child: ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: adDreamsGoalsProvider
                                            .goalModelIdName.length,
                                        itemBuilder: (context, index) {
                                          return Row(
                                            children: [
                                              // Checkbox(
                                              //     value: false,
                                              //     onChanged: (value) {}),
                                              GestureDetector(
                                                onTap: () {
                                                  // Navigator.of(context).push(
                                                  //   MaterialPageRoute(
                                                  //     builder: (context) =>
                                                  //         ActionsFullView(
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
                                                  width: size.width * 0.85,
                                                  margin: const EdgeInsets.only(
                                                    bottom: 4,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.only(
                                                    bottom: 5,
                                                    top: 5,
                                                    left: 0,
                                                    right: 5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      100,
                                                    ),
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
                                                          adDreamsGoalsProvider
                                                              .getAddActionIdAndNameClear(
                                                            index,
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
                                                      Text(
                                                        adDreamsGoalsProvider
                                                            .goalModelIdName[
                                                                index]
                                                            .name,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      CircleAvatar(
                                                        radius:
                                                            size.width * 0.04,
                                                        backgroundColor:
                                                            Colors.blue,
                                                        child: Icon(
                                                          Icons
                                                              .arrow_forward_ios_outlined,
                                                          color: Colors.white,
                                                          size:
                                                              size.width * 0.03,
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
                  ),
                ],
              ),
            ),
          )
        : const TokenExpireScreen();
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
            adDreamsGoalsProvider.selectDate(context);
          },
          child: Container(
            margin: const EdgeInsets.only(left: 2),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: const ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                    width: 0.8, style: BorderStyle.solid, color: Colors.grey),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
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
                  padding: const EdgeInsets.only(left: 5, top: 2, bottom: 1),
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
      },
    );
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
            builder: (context) => const AddactionsScreen(
              goalId: '',
            ),
          ),
        );
      },
      height: 40,
      text: "Add Action",
      margin: const EdgeInsets.only(left: 2),
      buttonStyle: CustomButtonStyles.outlinePrimary,
      buttonTextStyle: CustomTextStyles.titleSmallOnSecondaryContainer_1,
    );
  }

  /// Section Widget
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

  /// Section Widget
  Widget _buildSaveButton(BuildContext context) {
    return Consumer2<AdDreamsGoalsProvider, EditProfileProvider>(
      builder: (context, adDreamsGoalsProvider, editProfileProvider, _) {
        return CustomElevatedButton(
          loading: adDreamsGoalsProvider.saveAddActionsLoading,
          onPressed: () async {
            _isTokenExpired();
            if (!adDreamsGoalsProvider.isVideoUploading) {
              // Validate individual fields and show appropriate messages
              if (adDreamsGoalsProvider.nameEditTextController.text.isEmpty) {
                showCustomSnackBar(
                  context: context,
                  message: "Please fill Goal name",
                );
              } else if (editProfileProvider.categorys == null) {
                showCustomSnackBar(
                  context: context,
                  message: "Please fill Categories",
                );
              } else if (adDreamsGoalsProvider.selectedDate.isEmpty) {
                showCustomSnackBar(
                  context: context,
                  message: "Please fill Achievement date",
                );
              } else if (adDreamsGoalsProvider
                  .commentEditTextController.text.isEmpty) {
                showCustomSnackBar(
                  context: context,
                  message: "Please fill Goal Description",
                );
              } else if (adDreamsGoalsProvider.formattedDate == null) {
                showCustomSnackBar(
                  context: context,
                  message: "Please select a valid date",
                );
              } else {
                // All fields are validated, proceed with saving the data
                await adDreamsGoalsProvider.saveGemFunction(
                  context,
                  title: adDreamsGoalsProvider.nameEditTextController.text,
                  details: adDreamsGoalsProvider.commentEditTextController.text,
                  mediaName: adDreamsGoalsProvider.addMediaUploadResponseList,
                  locationName: adDreamsGoalsProvider.selectedLocationName,
                  locationLatitude: adDreamsGoalsProvider.selectedLatitude,
                  locationLongitude: adDreamsGoalsProvider.locationLongitude,
                  locationAddress:
                      adDreamsGoalsProvider.selectedLocationAddress,
                  categoryId: editProfileProvider.categorys!.id.toString(),
                  gemEndDate: adDreamsGoalsProvider.formattedDate,
                  actionId: adDreamsGoalsProvider.goalModelIdName,
                );
                GoalsDreamsProvider goalsDreamsProvider =
                    Provider.of<GoalsDreamsProvider>(
                  context,
                  listen: false,
                );
                goalsDreamsProvider.fetchGoalsAndDreams(initial: true);
              }
            } else {
              showCustomSnackBar(
                context: context,
                message: "Please wait, video is uploading",
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
      },
    );
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
                          if (await requestGalleryPermission()) {
                            mentalStrengthEditProvider.selectedMedia(1);
                            await galleryBottomSheetAddGoals(
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
                        onTap: () async {
                          _isTokenExpired();
                          if (await requestCameraPermission()) {
                            mentalStrengthEditProvider.selectedMedia(2);
                            cameraBottomSheetAdGoals(
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
                          _checkPermissionStatus();
                          _requestPermissions();
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
