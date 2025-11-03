import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
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
import '../../utils/theme/colors.dart';
import '../../utils/theme/custom_button_style.dart';
import '../addactions_screen/addactions_screen.dart';
import '../dash_borad_screen/provider/dash_board_provider.dart';
import '../goals_dreams_page/provider/goals_dreams_provider.dart';
import '../home_screen/provider/home_provider.dart';
import '../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../no_internet/duplicate_screen.dart';
import '../token_expiry/tocken_expiry_warning_screen.dart';
import '../token_expiry/token_expiry.dart';
import 'provider/ad_goals_dreams_provider.dart';

class AddGoalsDreamsScreen extends StatefulWidget {
  const AddGoalsDreamsScreen({Key? key,required this.pageNo})
      : super(
          key: key,
        );

  final String pageNo;

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
  late FocusNode _goalNameFocusNode;
  late FocusNode _goalDescFocusNode;

  @override
  void initState() {
    _goalNameFocusNode = FocusNode();
    _goalDescFocusNode = FocusNode();
    // Ensure the focus is not automatically set when returning
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _goalNameFocusNode.unfocus(); // Ensure it does not get focus automatically
      _goalDescFocusNode.unfocus(); // Ensure it does not get focus automatically
    });
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
    adDreamsGoalsProvider.detectedLinks.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      adDreamsGoalsProvider.clearLocationSelection();
      _isTokenExpired();
      editProfileProvider.fetchCategory();
      adDreamsGoalsProvider.goalModelIdName.clear();
    });
    super.initState();
  }

  Future<void> _isTokenExpired() async {
    //await homeProvider.fetchChartView(context);
    await homeProvider.fetchJournals(initial: true,context: context);
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
  void dispose() {
    _goalNameFocusNode.dispose();
    _goalDescFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return tokenStatus == false
        ? ConnectivityWidget(
          child: SafeArea(
              child: Scaffold(
                appBar: buildAppBarNumuEditGoals(
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
                        color: ColorsContent.homeBackGroundColor,
                        //   fit: BoxFit.cover,
                        // ),
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
                                  const SizedBox(height: 15),
                                  Consumer<EditProfileProvider>(
                                    builder: (context, editProfileProvider, _) {
                                      return Container(
                                        height: size.height * 0.055,
                                        padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                        ),
                                        decoration: ShapeDecoration(
                                          color: Colors.white, // Set background color here
                                          shape: RoundedRectangleBorder(
                                            side: const BorderSide(
                                              width: 0.8,
                                              style: BorderStyle.solid,
                                              color: Colors.transparent,
                                            ),
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        child: editProfileProvider.getCategoryModel == null
                                            ? const SizedBox()
                                            : DropdownButton<Category>(
                                          items: editProfileProvider.getCategoryModel!.category!
                                              .map((Category value) {
                                            return DropdownMenuItem<Category>(
                                              value: value,
                                              child: Text(value.categoryName.toString()),
                                            );
                                          }).toList(),
                                          hint: Text(
                                            editProfileProvider.interestsValueController.text.isEmpty
                                                ? 'Select Category'
                                                : editProfileProvider.interestsValueController.text,
                                            style: CustomTextStyles.bodySmallGray700,
                                          ),
                                          borderRadius: BorderRadius.circular(10),
                                          underline: const SizedBox(),
                                          isExpanded: true,
                                          iconEnabledColor: ColorsContent.newThemeColor, // 👈 Dropdown icon color
                                          iconDisabledColor: ColorsContent.newThemeColor,  // 👈 Optional: icon color when disabled
                                          onChanged: (value) {
                                            if (value != null) {
                                              editProfileProvider.selectCategory(
                                                value: value.categoryName.toString(),
                                                mainCategory: value,
                                              );
                                              _isTokenExpired();
                                            }
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 15),
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
                                  const SizedBox(height: 25),


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
                                                        width: 0.5,
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
                                                            ColorsContent.newThemeColor,
                                                            child: Icon(
                                                              Icons.close,
                                                              color: Colors.white,
                                                              size: size.width *
                                                                  0.04,
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
                                                              ColorsContent.newThemeColor,
                                                          child: Icon(
                                                            Icons
                                                                .arrow_forward_ios_outlined,
                                                            color: Colors.white,
                                                            size:
                                                                size.width * 0.04,
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
                                    height: 30,
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
        child: CustomTextFormFieldGoalOrActionName(
          controller: adDreamsGoalsProvider.nameEditTextController,
          hintText: _goalNameFocusNode.hasFocus ? '' : "Goal Name",
          hintStyle: CustomTextStyles.bodySmallGray700,
          focusNode: _goalNameFocusNode,
          onTap: () => setState(() {}),
          // Rebuild when tapped
          onEditingComplete: () {
            _goalNameFocusNode.unfocus(); // Ensure focus is removed when done
            setState(() {});
          }, // Rebuild when focus is lost
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
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            decoration: ShapeDecoration(
              color: Colors.white, // Added background color
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  width: 0.8,
                  style: BorderStyle.solid,
                  color: Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Row(
              children: [
                CustomImageView(
                  imagePath: ImageConstant.actionDatePickerNumu,
                  height: 20,
                  width: 20,
                  margin: const EdgeInsets.only(bottom: 2),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 2, bottom: 1),
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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📝 Show text field only when no link is detected
                if (adDreamsGoalsProvider.detectedLinks.isEmpty)
                  CustomTextFormFieldGoalOrActionDesc(
                    controller: adDreamsGoalsProvider.commentEditTextController,
                    hintText: _goalDescFocusNode.hasFocus
                        ? ''
                        : "Goal Description",
                    hintStyle: CustomTextStyles.bodySmallGray700,
                    maxLines: 4,
                    focusNode: _goalDescFocusNode,
                    textInputAction: TextInputAction.newline,
                    textInputType: TextInputType.multiline,
                    borderDecoration: InputBorder.none,
                    onTap: () => setState(() {}),
                    onChanged: (value) {
                      // Detect URLs in text
                      final matches = adDreamsGoalsProvider.urlRegex
                          .allMatches(value)
                          .map((match) => match.group(0)!)
                          .toList();

                      // ✅ If contains a link, show preview instead of text
                      if (matches.isNotEmpty) {
                        setState(() {
                          adDreamsGoalsProvider.detectedLinks = matches;
                          adDreamsGoalsProvider.commentEditTextController.clear();
                        });
                      }
                    },
                    onEditingComplete: () {
                      _goalDescFocusNode.unfocus();
                      setState(() {});
                    },
                  ),

                // 🔗 Show link preview if a link is detected
                if (adDreamsGoalsProvider.detectedLinks.isNotEmpty)
                  ...adDreamsGoalsProvider.detectedLinks.map((link) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade300, // ✅ Border color
                                width: 1.5, // ✅ Border width
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinkPreviewGenerator(
                                link: link,
                                linkPreviewStyle: LinkPreviewStyle.small,
                                showDomain: true,
                                showTitle: true,
                                bodyMaxLines: 1,
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
                          // ❌ Close icon to clear preview
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  adDreamsGoalsProvider.detectedLinks.clear();
                                  adDreamsGoalsProvider
                                      .commentEditTextController
                                      .clear();
                                });
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
                                  //fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
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
      height: 45,
      text: "Add Action",
      margin: const EdgeInsets.only(left: 2),
      buttonStyle: CustomButtonStyles.addActionButtonStyle,
      buttonTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontFamily: 'Open Sans',
        color:  Colors.white,
      ),
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
              }
              else if (editProfileProvider.interestsValueController.text.isEmpty) {
                showCustomSnackBar(
                  context: context,
                  message: "Please select a category",
                );
              }
              else {
                // All fields are validated, proceed with saving the data
                await adDreamsGoalsProvider.saveGemFunction(
                  context,
                  title: adDreamsGoalsProvider.nameEditTextController.text,
                  details: adDreamsGoalsProvider.commentEditTextController.text,
                  mediaName: adDreamsGoalsProvider.addMediaUploadResponseList,
                  locationName: adDreamsGoalsProvider.selectedLocationName,
                  locationLatitude: adDreamsGoalsProvider.selectedLatitude,
                  locationLongitude: adDreamsGoalsProvider.selectedLongitude,
                  locationAddress:
                      adDreamsGoalsProvider.selectedLocationAddress,
                  categoryId: editProfileProvider.categorys!.id.toString(),
                  gemEndDate: adDreamsGoalsProvider.formattedDate,
                  mediaThumbs: adDreamsGoalsProvider.mediaThumbList, // ✅ pass here
                  actionId: adDreamsGoalsProvider.goalModelIdName,
                );
                GoalsDreamsProvider goalsDreamsProvider =
                    Provider.of<GoalsDreamsProvider>(
                  context,
                  listen: false,
                );
                goalsDreamsProvider.fetchGoalsAndDreams(pageNo: goalsDreamsProvider.currentPage.toString(),context: context);
                if(goalsDreamsProvider.fetchGoalsAndDreamsStatus == 404){
                  goalsDreamsProvider.fetchGoalsAndDreams(pageNo: 1.toString(),context: context);
                }

              }
            } else {
              showCustomSnackBar(
                context: context,
                message: "Please wait, video is uploading",
              );
            }
          },
          height: 45,
          text: "Save",
          margin: const EdgeInsets.only(left: 2),
          buttonStyle: CustomButtonStyles.outlinePrimaryTL5,
          buttonTextStyle:
          const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Open Sans',
            color: Colors.white,
          ),
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
              height: 20,
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
                          if (await requestGalleryPermission() && Platform.isAndroid) {
                            mentalStrengthEditProvider.selectedMedia(1);
                            await galleryBottomSheetAddGoals(
                              context: context,
                              title: 'Gallery',
                            );
                          } else if(Platform.isIOS){
                            mentalStrengthEditProvider.selectedMedia(1);
                            await galleryBottomSheetAddGoals(
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
                        child: SvgPicture.asset(
                          ImageConstant
                              .galleryAddMediaNumu, // Replace with your SVG asset path
                        ),
                      ),
                      Positioned(
                        bottom: Platform.isIOS ? 50 : 45, // Adjust this value as needed
                        right: 0, // Move to the right
                        left: 40,
                        child: Consumer<AdDreamsGoalsProvider>(
                            builder: (context, mentalStrengthEditProvider, _) {
                          if (mentalStrengthEditProvider.pickedImages.isEmpty) {
                            return const SizedBox();
                          } else {
                            // return Container(
                            //   width: size.height * 0.04,
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     image: DecorationImage(
                            //       image: AssetImage(ImageConstant.imgMenu),
                            //       fit: BoxFit.cover,
                            //     ),
                            //     borderRadius: const BorderRadius.all(
                            //       Radius.circular(
                            //         50.0,
                            //       ),
                            //     ),
                            //     border: Border.all(
                            //       color: appTheme.blue300,
                            //       width: 2.0,
                            //     ),
                            //   ),
                            //   child: Center(
                            //     child: Text(
                            //       mentalStrengthEditProvider.pickedImages.length
                            //           .toString(),
                            //       style: const TextStyle(
                            //         color: Colors.blue,
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     ),
                            //   ),
                            // );

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
                                  mentalStrengthEditProvider.pickedImages.length
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
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
                          FocusScope.of(context).requestFocus(FocusNode());
                          _isTokenExpired();
                          if (await requestCameraPermission() && Platform.isAndroid) {
                            mentalStrengthEditProvider.selectedMedia(2);
                            cameraBottomSheetAdGoals(
                              context: context,
                              title: "Camera",
                            );
                          } else if(Platform.isIOS){
                            mentalStrengthEditProvider.selectedMedia(2);
                            cameraBottomSheetAdGoals(
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
                        child: SvgPicture.asset(
                          ImageConstant
                              .cameraAddMediaNumu, // Replace with your SVG asset path
                        ),
                      ),
                      Positioned(
                        bottom: Platform.isIOS ? 50 : 45, // Adjust this value as needed
                        right: 0, // Move to the right
                        left: 40,
                        child: Consumer<AdDreamsGoalsProvider>(
                            builder: (context, mentalStrengthEditProvider, _) {
                          if (mentalStrengthEditProvider.takedImages.isEmpty) {
                            return const SizedBox();
                          } else {
                            // return Container(
                            //   width: size.height * 0.04,
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     image: DecorationImage(
                            //       image: AssetImage(ImageConstant.imgMenu),
                            //       fit: BoxFit.cover,
                            //     ),
                            //     borderRadius: const BorderRadius.all(
                            //       Radius.circular(
                            //         50.0,
                            //       ),
                            //     ),
                            //     border: Border.all(
                            //       color: appTheme.blue300,
                            //       width: 2.0,
                            //     ),
                            //   ),
                            //   child: Center(
                            //     child: Text(
                            //       mentalStrengthEditProvider.takedImages.length
                            //           .toString(),
                            //       style: const TextStyle(
                            //         color: Colors.blue,
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     ),
                            //   ),
                            // );

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
                                  mentalStrengthEditProvider.takedImages.length
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
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
                          FocusScope.of(context).requestFocus(FocusNode());
                          _isTokenExpired();
                          mentalStrengthEditProvider.selectedMedia(0);
                          await audioBottomSheetAddGoals(
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
                        bottom: Platform.isIOS ? 50 : 45, // Adjust this value as needed
                        right: 0, // Move to the right
                        left: 40,
                        child: Consumer<AdDreamsGoalsProvider>(
                            builder: (context, mentalStrengthEditProvider, _) {
                              if (mentalStrengthEditProvider
                                  .recordedFilePath.isEmpty) {
                                return const SizedBox();
                              } else {
                                // return Container(
                                //   width: size.height * 0.04,
                                //   decoration: BoxDecoration(
                                //     color: Colors.white,
                                //     image: DecorationImage(
                                //       image: AssetImage(ImageConstant.imgMenu),
                                //       fit: BoxFit.cover,
                                //     ),
                                //     borderRadius: const BorderRadius.all(
                                //       Radius.circular(
                                //         50.0,
                                //       ),
                                //     ),
                                //     border: Border.all(
                                //       color: appTheme.blue300,
                                //       width: 2.0,
                                //     ),
                                //   ),
                                //   child: Center(
                                //     child: Text(
                                //       mentalStrengthEditProvider
                                //           .recordedFilePath.length
                                //           .toString(),
                                //       style: const TextStyle(
                                //         color: Colors.blue,
                                //         fontWeight: FontWeight.bold,
                                //       ),
                                //     ),
                                //   ),
                                // );

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
                          FocusScope.of(context).requestFocus(FocusNode());
                          // _checkPermissionStatus();
                          // _requestPermissions();
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
                                isScrollControlled: true, // <== Helps with full height layout
                                backgroundColor: Colors.transparent, // Optional for rounded corners
                                builder: (BuildContext context) {
                                  return SafeArea(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        bottom: MediaQuery.of(context).viewInsets.bottom, // Avoid overlap with keyboard or bottom inset
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                        ),
                                        child: const AddGoalsGoogleMap(

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
                        bottom: Platform.isIOS ? 50 : 45, // Adjust this value as needed
                        right: 0, // Move to the right
                        left: 40,
                        child: Consumer<AdDreamsGoalsProvider>(
                            builder: (context, mentalStrengthEditProvider, _) {
                          if (mentalStrengthEditProvider
                              .selectedLocationName.isEmpty) {
                            return const SizedBox();
                          } else {
                            // return Container(
                            //   width: size.height * 0.04,
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     image: DecorationImage(
                            //       image: AssetImage(ImageConstant.imgMenu),
                            //       fit: BoxFit.cover,
                            //     ),
                            //     borderRadius: const BorderRadius.all(
                            //       Radius.circular(
                            //         50.0,
                            //       ),
                            //     ),
                            //     border: Border.all(
                            //       color: appTheme.blue300,
                            //       width: 2.0,
                            //     ),
                            //   ),
                            //   child: const Center(
                            //     child: Text(
                            //       "1",
                            //       style: TextStyle(
                            //         color: Colors.blue,
                            //         fontWeight: FontWeight.bold,
                            //       ),
                            //     ),
                            //   ),
                            // );

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
