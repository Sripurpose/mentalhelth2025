import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addactions_screen/provider/add_actions_provider.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/model/id_model.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/widget/googlemap_widget/google_map_widget.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/widget/popup/audio_popup_goals.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/widget/popup/camera_popup.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/widget/popup/gallary_popup_add_goals.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/model/get_category.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/model/goals_and_dreams_model.dart';
import 'package:mentalhelth/screens/goals_dreams_page/provider/goals_dreams_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/screens/actions_full_view/actions_full_view.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/mental_strength_add_edit_page.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/all_model.dart';
import "package:mentalhelth/screens/mental_strength_add_edit_screen/model/list_goal_actions.dart"
    as actionss;
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:mentalhelth/utils/theme/custom_button_style.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_subtitle.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/custom_text_form_field.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../utils/core/date_time_utils.dart';
import '../../../../utils/logic/permissions.dart';
import '../../../../widgets/app_bar/custom_app_bar.dart';
import '../../../../widgets/functions/popup.dart';
import '../../../addactions_screen/addactions_screen.dart';
import '../../../addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import '../../../dash_borad_screen/provider/dash_board_provider.dart';
import '../../../home_screen/provider/home_provider.dart';
import '../../../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../../../token_expiry/tocken_expiry_warning_screen.dart';
import '../../../token_expiry/token_expiry.dart';

class EditGoalsScreen extends StatefulWidget {
  const EditGoalsScreen({Key? key, required this.goalsanddream})
      : super(
          key: key,
        );
  final Goalsanddream goalsanddream;

  @override
  State<EditGoalsScreen> createState() => _EditGoalsScreenState();
}

class _EditGoalsScreenState extends State<EditGoalsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late HomeProvider homeProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late EditProfileProvider editProfileProvider;
  late DashBoardProvider dashBoardProvider;
  late AdDreamsGoalsProvider adDreamsGoalsProvider;
  bool tokenStatus = false;
  var logger = Logger();
  int? unixTimestamp;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      logger.w(
          " adDreamsGoalsProvider.formattedDate${adDreamsGoalsProvider.formattedDate}");
      logger.w(
          " adDreamsGoalsProvider.selectedDate${adDreamsGoalsProvider.selectedDate}");
      unixTimestamp =
          convertToUnixTimestamp(adDreamsGoalsProvider.selectedDate);
      logger.w(" unixTimestamp--${unixTimestamp}");
      editProfileProvider.fetchCategory();
      adDreamsGoalsProvider.mediaSelected = -1;
      _isTokenExpired();
    });
    adDreamsGoalsProvider.goalModelIdName.clear();

    init();
    super.initState();
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

  int convertToUnixTimestamp(String dateString) {
    // Define the date format to match the external date string.
    DateFormat dateFormat = DateFormat("d MMM yyyy");

    // Parse the date string into a DateTime object.
    DateTime parsedDate = dateFormat.parse(dateString);

    // Convert to Unix timestamp in milliseconds (milliseconds since epoch).
    int timestamp = parsedDate.millisecondsSinceEpoch;

    return timestamp; // This will return the value in milliseconds.
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

  void init() {
    EditProfileProvider editProfileProvider =
        Provider.of(context, listen: false);
    AdDreamsGoalsProvider adDreamsGoalsProvider =
        Provider.of(context, listen: false);
    // Clear the lists to avoid duplicates
    adDreamsGoalsProvider.alreadyRecordedFilePath.clear();
    adDreamsGoalsProvider.alreadyPickedImages.clear();

    adDreamsGoalsProvider.nameEditTextController.text =
        widget.goalsanddream.goalTitle.toString();
    adDreamsGoalsProvider.commentEditTextController.text =
        widget.goalsanddream.goalDetails.toString();
    if (widget.goalsanddream.gemMedia != null) {
      for (int i = 0; i < widget.goalsanddream.gemMedia!.length; i++) {
        if (widget.goalsanddream.gemMedia![i].mediaType == 'audio') {
          adDreamsGoalsProvider.alreadyRecordedFilePath.add(AllModel(
              id: widget.goalsanddream.gemMedia![i].mediaId.toString(),
              value: widget.goalsanddream.gemMedia![i].gemMedia!.toString()));
        }
      }
      // if (audioList.isNotEmpty) {
      //   adDreamsGoalsProvider.alreadyRecordedFilePath
      //       .addAll(AllModel(id: id, value: value));
      //   log(adDreamsGoalsProvider.alreadyRecordedFilePath.length.toString(),
      //       name: "audiosall");
      // }

      for (int i = 0; i < widget.goalsanddream.gemMedia!.length; i++) {
        if (widget.goalsanddream.gemMedia![i].mediaType == 'image' ||
            widget.goalsanddream.gemMedia![i].mediaType == 'video') {
          adDreamsGoalsProvider.alreadyPickedImages.add(
            AllModel(
              id: widget.goalsanddream.gemMedia![i].mediaId.toString(),
              value: widget.goalsanddream.gemMedia![i].gemMedia!.toString(),
            ),
          );
        }
      }
      // if (imageList.isNotEmpty) {
      //   adDreamsGoalsProvider.alreadyPickedImages.add(imageList);
      //   log(adDreamsGoalsProvider.pickedImages.toString(), name: "imageLists");
      // }

      adDreamsGoalsProvider.selectedDate = formatDate2(
          widget.goalsanddream.goalEnddate == null ||
                  widget.goalsanddream.goalEnddate == ""
              ? DateTime.now().microsecondsSinceEpoch
              : int.parse(widget.goalsanddream.goalEnddate!));
      adDreamsGoalsProvider.selectedLocationName =
          widget.goalsanddream.location == null
              ? ""
              : widget.goalsanddream.location!.locationName.toString();
      adDreamsGoalsProvider.selectedLatitude =
          widget.goalsanddream.location == null
              ? ""
              : widget.goalsanddream.location!.locationLatitude.toString();
      adDreamsGoalsProvider.locationLongitude =
          widget.goalsanddream.location == null
              ? ""
              : widget.goalsanddream.location!.locationLongitude.toString();
      adDreamsGoalsProvider.selectedLocationAddress =
          widget.goalsanddream.location == null
              ? ""
              : widget.goalsanddream.location!.locationAddress.toString();
      editProfileProvider.categorys = Category(
        id: widget.goalsanddream.categoryId.toString(),
        categoryName: widget.goalsanddream.categoryName.toString(),
        categoryImg: "",
      );
      if (widget.goalsanddream.action != null) {
        for (int i = 0; i < widget.goalsanddream.action!.length; i++) {
          adDreamsGoalsProvider.getAddActionIdAndName(
            value: GoalModelIdName(
              id: widget.goalsanddream.action![i].actionId.toString(),
              name: widget.goalsanddream.action![i].actionTitle.toString(),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
        onPopInvoked: (value) async {
          AdDreamsGoalsProvider adDreamsGoalsProvider =
              Provider.of(context, listen: false);
          adDreamsGoalsProvider.clearAction();
        },
        child: tokenStatus == false
            ? SafeArea(
                child: Scaffold(
                  appBar: buildAppBar(context, size,
                      heading: "Edit Goals & Dreams", onTap: () {
                    Navigator.pop(context);
                  }),
                  // buildAppBarEditGoals(
                  //   context,
                  //   size,
                  //   heading: "Edit Goals & Dreams",
                  // ),
                  body: Stack(
                    children: [
                      Container(
                        width: size.width,
                        height: size.height,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSecondaryContainer
                              .withOpacity(1),
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
                                    Consumer<EditProfileProvider>(builder:
                                        (context, editProfileProvider, _) {
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
                                                  return DropdownMenuItem<
                                                      Category>(
                                                    value: value,
                                                    child: Text(value
                                                        .categoryName
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
                                                  }
                                                  _isTokenExpired();
                                                },
                                              ),
                                      );
                                    }),
                                    const SizedBox(height: 11),
                                    _buildAchievmentDateGoals(context),
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
                                    Consumer2<AdDreamsGoalsProvider,
                                        AddActionsProvider>(
                                      builder: (context, adDreamsGoalsProvider,
                                          addActionsProvider, _) {
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
                                              var data = adDreamsGoalsProvider
                                                  .goalModelIdName[index];
                                              // logger.w("actions ${adDreamsGoalsProvider
                                              //     .goalModelIdName.length}");
                                              // logger.w("message ${widget.goalsanddream
                                              //     .action?.length}");
                                              return Row(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              ActionsFullView(
                                                            id: widget
                                                                    .goalsanddream
                                                                    .action?[
                                                                        index]
                                                                    .actionId
                                                                    .toString() ??
                                                                "",
                                                            indexs: index,
                                                            action:
                                                                actionss.Action(
                                                              id: widget
                                                                  .goalsanddream
                                                                  .action![
                                                                      index]
                                                                  .actionId,
                                                              title: widget
                                                                  .goalsanddream
                                                                  .action![
                                                                      index]
                                                                  .actionTitle,
                                                              actionStatus: widget
                                                                  .goalsanddream
                                                                  .action![
                                                                      index]
                                                                  .actionStatus,
                                                              actionDate: widget
                                                                  .goalsanddream
                                                                  .action![
                                                                      index]
                                                                  .actionDatetime,
                                                            ),
                                                            goalId: widget
                                                                .goalsanddream
                                                                .goalId
                                                                .toString(),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 10),
                                                      height:
                                                          size.height * 0.04,
                                                      width: size.width * 0.85,
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
                                                            BorderRadius
                                                                .circular(
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
                                                            onTap: () async {
                                                              customPopup(
                                                                context:
                                                                    context,
                                                                onPressedDelete:
                                                                    () async {
                                                                  adDreamsGoalsProvider
                                                                      .getAddActionIdAndNameClear(
                                                                          index);
                                                                  await addActionsProvider
                                                                      .deleteActionFunction(
                                                                    deleteId:
                                                                        data.id,
                                                                  );
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
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
                                                                  size.width *
                                                                      0.04,
                                                              backgroundColor:
                                                                  Colors.blue,
                                                              child: Icon(
                                                                Icons.close,
                                                                color: Colors
                                                                    .white,
                                                                size:
                                                                    size.width *
                                                                        0.03,
                                                              ),
                                                            ),
                                                          ),
                                                          SingleChildScrollView(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            // Enable horizontal scrolling
                                                            child: Text(
                                                              data.name,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              // Set the maximum number of lines to 3
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .push(
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ActionsFullView(
                                                                    id: widget
                                                                            .goalsanddream
                                                                            .action?[index]
                                                                            .actionId
                                                                            .toString() ??
                                                                        "",
                                                                    indexs:
                                                                        index,
                                                                    action: actionss
                                                                        .Action(
                                                                      id: widget
                                                                          .goalsanddream
                                                                          .action![
                                                                              index]
                                                                          .actionId,
                                                                      title: widget
                                                                          .goalsanddream
                                                                          .action![
                                                                              index]
                                                                          .actionTitle,
                                                                      actionStatus: widget
                                                                          .goalsanddream
                                                                          .action![
                                                                              index]
                                                                          .actionStatus,
                                                                      actionDate: widget
                                                                          .goalsanddream
                                                                          .action![
                                                                              index]
                                                                          .actionDatetime,
                                                                    ),
                                                                    goalId: widget
                                                                        .goalsanddream
                                                                        .goalId
                                                                        .toString(),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: CircleAvatar(
                                                              radius:
                                                                  size.width *
                                                                      0.04,
                                                              backgroundColor:
                                                                  Colors.blue,
                                                              child: Icon(
                                                                Icons
                                                                    .arrow_forward_ios_outlined,
                                                                color: Colors
                                                                    .white,
                                                                size:
                                                                    size.width *
                                                                        0.03,
                                                              ),
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
                      // Align(
                      //   alignment: Alignment.bottomCenter,
                      //   child: Padding(
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 27,
                      //       vertical: 6,
                      //     ),
                      //     child: Column(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              )
            : const TokenExpireScreen());
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
  Widget _buildAchievmentDateGoals(BuildContext context) {
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
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(5),
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
            builder: (context) => AddactionsScreen(
              goalId: widget.goalsanddream.goalId.toString(),
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
            if (adDreamsGoalsProvider.nameEditTextController.text.isNotEmpty &&
                adDreamsGoalsProvider
                    .commentEditTextController.text.isNotEmpty &&
                editProfileProvider.categorys != null &&
                adDreamsGoalsProvider.formattedDate != null) {
              if (adDreamsGoalsProvider.formattedDate.isNotEmpty) {
                logger.w("formattedDate${adDreamsGoalsProvider.formattedDate}");
                logger.w("selectedDate${adDreamsGoalsProvider.selectedDate}");
                await adDreamsGoalsProvider.updateGoalFunction(
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
                  gemId: widget.goalsanddream.goalId.toString(),
                );
                GoalsDreamsProvider goalsDreamsProvider =
                    Provider.of<GoalsDreamsProvider>(
                  context,
                  listen: false,
                );
                goalsDreamsProvider.fetchGoalsAndDreams(initial: true);
              } else {
                logger.w("formattedDate${adDreamsGoalsProvider.formattedDate}");
                logger.w("selectedDate${adDreamsGoalsProvider.selectedDate}");
                await adDreamsGoalsProvider.updateGoalFunction(
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
                  gemEndDate: unixTimestamp.toString(),
                  actionId: adDreamsGoalsProvider.goalModelIdName,
                  gemId: widget.goalsanddream.goalId.toString(),
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
        text: "Update",
        margin: const EdgeInsets.only(left: 2),
        buttonStyle: CustomButtonStyles.outlinePrimaryTL5,
        buttonTextStyle:
            CustomTextStyles.titleSmallHelveticaOnSecondaryContainer,
      );
    });
  }

  Widget _buildAddMediaColumn(BuildContext context, Size size) {
    return Consumer<AdDreamsGoalsProvider>(
        builder: (context, adDreamsGoalsProvider, _) {
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
                          adDreamsGoalsProvider.selectedMedia(0);
                          await audioBottomSheetAddGoals(
                            context: context,
                            title: 'Record Audio',
                          );
                        },
                        child: Container(
                          height: size.height * 0.08,
                          width: size.height * 0.08,
                          decoration: BoxDecoration(
                            color: adDreamsGoalsProvider.mediaSelected == 0
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
                            color: adDreamsGoalsProvider.mediaSelected == 0
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
                            builder: (context, adDreamsGoalsProvider, _) {
                          if (adDreamsGoalsProvider
                                  .alreadyRecordedFilePath.isEmpty &&
                              adDreamsGoalsProvider.recordedFilePath.isEmpty) {
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
                                  "${adDreamsGoalsProvider.recordedFilePath.length + adDreamsGoalsProvider.alreadyRecordedFilePath.length}",
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
                            adDreamsGoalsProvider.selectedMedia(1);
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
                            color: adDreamsGoalsProvider.mediaSelected == 1
                                ? Colors.white
                                : Colors.blue,
                          ),
                          imagePath: ImageConstant.imgThumbsUp,
                          size: size,
                          isSelected: adDreamsGoalsProvider.mediaSelected == 1
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
                                  .alreadyPickedImages.isEmpty &&
                              adDreamsGoalsProvider.pickedImages.isEmpty) {
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
                                  "${adDreamsGoalsProvider.pickedImages.length + adDreamsGoalsProvider.alreadyPickedImages.length}",
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
                            adDreamsGoalsProvider.selectedMedia(2);
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
                            color: adDreamsGoalsProvider.mediaSelected == 2
                                ? Colors.white
                                : Colors.blue,
                          ),
                          imagePath: ImageConstant.imgCamera,
                          size: size,
                          isSelected: adDreamsGoalsProvider.mediaSelected == 2
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
                          if (adDreamsGoalsProvider.takedImages.isEmpty) {
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
                                  adDreamsGoalsProvider.takedImages.length
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
                          _checkPermissionStatus();
                          _requestPermissions();
                          adDreamsGoalsProvider.selectedMedia(
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
                                    child: AddGoalsGoogleMap(
                                        goalsanddream: widget.goalsanddream),
                                  );
                                },
                              );
                            }
                          }

                        },
                        child: buildAvatarImage(
                          widget: Icon(
                            Icons.location_on,
                            size: 30,
                            color: adDreamsGoalsProvider.mediaSelected == 3
                                ? Colors.white
                                : Colors.blue,
                          ),
                          imagePath: ImageConstant.imgLinkedin,
                          size: size,
                          // wi
                          isSelected: adDreamsGoalsProvider.mediaSelected == 3
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

  PreferredSizeWidget buildAppBarEditGoals(BuildContext context, Size size,
      {String? heading}) {
    return CustomAppBar(
      leadingWidth: 36,
      leading: Consumer<AdDreamsGoalsProvider>(
          builder: (context, adDreamsGoalsProvider, _) {
        return AppbarLeadingImage(
          onTap: () async {
            // AdDreamsGoalsProvider adDreamsGoalsProvider =
            //     Provider.of(context, listen: false);
            await adDreamsGoalsProvider.clearAction();
            Navigator.of(context).pop();
          },
          imagePath: ImageConstant.imgTelevision,
          margin: const EdgeInsets.only(
            left: 20,
            top: 19,
            bottom: 23,
          ),
        );
      }),
      title: AppbarSubtitle(
        text: heading ?? "My profile",
        margin: const EdgeInsets.only(
          left: 11,
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(
            right: size.width * 0.07,
          ),
          child: CircleAvatar(
            radius: size.width * 0.04,
            backgroundColor: PrimaryColors().blue300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: size.height * 0.003,
                  width: size.width * 0.03,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: size.height * 0.005,
                ),
                Container(
                  height: size.height * 0.003,
                  width: size.width * 0.03,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
