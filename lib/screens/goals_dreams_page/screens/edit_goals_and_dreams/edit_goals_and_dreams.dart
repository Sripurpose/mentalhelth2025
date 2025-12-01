import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
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
import 'package:mentalhelth/utils/theme/colors.dart';
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
import '../../../addactions_screen/add_edit_action_screen.dart';
import '../../../addactions_screen/addactions_screen.dart';
import '../../../addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import '../../../dash_borad_screen/provider/dash_board_provider.dart';
import '../../../home_screen/provider/home_provider.dart';
import '../../../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../../../no_internet/duplicate_screen.dart';
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
  late FocusNode _titleFocusNode;
  late FocusNode _descriptionFocusNode;

  @override
  void initState() {
    _descriptionFocusNode = FocusNode();
    _titleFocusNode = FocusNode();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    mentalStrengthEditProvider =
        Provider.of<MentalStrengthEditProvider>(context, listen: false);
    dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
    editProfileProvider =
        Provider.of<EditProfileProvider>(context, listen: false);
    adDreamsGoalsProvider =
        Provider.of<AdDreamsGoalsProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      adDreamsGoalsProvider.hasUserClearedLink = false;
      _descriptionFocusNode.unfocus();
      _titleFocusNode.unfocus();// Ensure it does not get focus automatically
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
    adDreamsGoalsProvider.editDetectedLinks.clear();

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
    //await homeProvider.fetchChartView(context);
    await homeProvider.fetchJournals(initial: true,context: context,fullList: true);
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
      adDreamsGoalsProvider.selectedLongitude =
          widget.goalsanddream.location == null
              ? ""
              : widget.goalsanddream.location!.locationLongitude.toString();
      adDreamsGoalsProvider.selectedLocationAddress =
          widget.goalsanddream.location == null
              ? ""
              : widget.goalsanddream.location!.locationAddress.toString();
      // editProfileProvider.categorys = Category(
      //   id: widget.goalsanddream.categoryId.toString(),
      //   categoryName: widget.goalsanddream.categoryName.toString(),
      //   categoryImg: "",
      // );

      final selectedCat = Category(
        id:widget.goalsanddream.categoryId.toString(),
        categoryName: widget.goalsanddream.categoryName.toString(),
        categoryImg: "",
      );

// ✅ Store selected category
      editProfileProvider.categorys = selectedCat;
      editProfileProvider.selectedCategory = selectedCat;

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
  void dispose() {
    _descriptionFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
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
                child: ConnectivityWidget(
                  child: Scaffold(
                    appBar: buildAppBarNumuEditGoals(context, size,
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
                            color: ColorsContent.homeBackGroundColor,
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
                                          final categoryList = editProfileProvider
                                              .getCategoryModel?.category ??
                                              [];

                                          // 🔹 Ensure the selected value actually exists in the dropdown list
                                          Category? selectedCategory =
                                              editProfileProvider.selectedCategory;

                                          if (selectedCategory != null &&
                                              categoryList.isNotEmpty) {
                                            final match = categoryList.firstWhere(
                                                  (cat) =>
                                              cat.id.toString() ==
                                                  selectedCategory?.id.toString(),
                                              orElse: () => Category(
                                                  id: '',
                                                  categoryName: '',
                                                  categoryImg: ''),
                                            );

                                            // If no valid match, reset to null
                                            if (match.id == '') {
                                              selectedCategory = null;
                                            } else {
                                              selectedCategory = match;
                                            }
                                          }

                                          return Container(
                                            height: size.height * 0.055,
                                            padding: const EdgeInsets.only(
                                                left: 10, right: 5),
                                            decoration: ShapeDecoration(
                                              color: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                side: const BorderSide(
                                                    width: 0.8,
                                                    color: Colors.transparent),
                                                borderRadius:
                                                BorderRadius.circular(8.0),
                                              ),
                                            ),
                                            child: categoryList.isEmpty
                                                ? const SizedBox()
                                                : DropdownButton<Category>(
                                              // ✅ Use verified selectedCategory
                                              value: selectedCategory,
                                              items: categoryList
                                                  .map((Category value) {
                                                return DropdownMenuItem<
                                                    Category>(
                                                  value: value,
                                                  child: Text(
                                                    value.categoryName ??
                                                        '',
                                                    style: CustomTextStyles
                                                        .bodySmallGray700,
                                                  ),
                                                );
                                              }).toList(),
                                              hint: Text(
                                                editProfileProvider
                                                    .interestsValueController
                                                    .text
                                                    .isEmpty
                                                    ? 'Select a category'
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
                                              iconEnabledColor:
                                              ColorsContent.newThemeColor,
                                              iconDisabledColor:
                                              ColorsContent.newThemeColor,
                                              onChanged: (value) {
                                                if (value != null) {
                                                  editProfileProvider
                                                      .selectedCategory =
                                                      value;
                                                  editProfileProvider
                                                      .selectCategory(
                                                    value: value.categoryName
                                                        .toString(),
                                                    mainCategory: value,
                                                  );
                                                  _isTokenExpired();
                                                  editProfileProvider
                                                      .notifyListeners();
                                                }
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                      // Consumer<EditProfileProvider>(builder:
                                      //     (context, editProfileProvider, _) {
                                      //   return Container(
                                      //     height: size.height * 0.050,
                                      //     padding: const EdgeInsets.only(
                                      //       left: 10,
                                      //       right: 10,
                                      //     ),
                                      //     decoration: const ShapeDecoration(
                                      //       color: Colors.white,
                                      //       shape: RoundedRectangleBorder(
                                      //         borderRadius: BorderRadius.all(
                                      //           Radius.circular(
                                      //             8.0,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //     child: editProfileProvider
                                      //                 .getCategoryModel ==
                                      //             null
                                      //         ? const SizedBox()
                                      //         : DropdownButton<Category>(
                                      //             items: editProfileProvider
                                      //                 .getCategoryModel!.category!
                                      //                 .map((Category value) {
                                      //               return DropdownMenuItem<
                                      //                   Category>(
                                      //                 value: value,
                                      //                 child: Text(value
                                      //                     .categoryName
                                      //                     .toString()),
                                      //               );
                                      //             }).toList(),
                                      //             hint: Text(
                                      //               editProfileProvider
                                      //                       .interestsValueController
                                      //                       .text
                                      //                       .isEmpty
                                      //                   ? 'Music, Badminton'
                                      //                   : editProfileProvider
                                      //                       .interestsValueController
                                      //                       .text,
                                      //               style: CustomTextStyles
                                      //                   .bodySmallGray700,
                                      //             ),
                                      //             borderRadius:
                                      //                 BorderRadius.circular(10),
                                      //             underline: const SizedBox(),
                                      //             isExpanded: true,
                                      //       iconEnabledColor: ColorsContent.newThemeColor, // 👈 Dropdown icon color
                                      //       iconDisabledColor: ColorsContent.newThemeColor,  // 👈 Optional: icon color when disabled
                                      //             onChanged: (value) {
                                      //               if (value != null) {
                                      //                 editProfileProvider
                                      //                     .selectCategory(
                                      //                   value: value.categoryName
                                      //                       .toString(),
                                      //                   mainCategory: value,
                                      //                 );
                                      //               }
                                      //               _isTokenExpired();
                                      //             },
                                      //           ),
                                      //   );
                                      // }),
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
                                                0.065,
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
                                                        // Navigator.of(context)
                                                        //     .push(
                                                        //   MaterialPageRoute(
                                                        //     builder: (context) =>
                                                        //         ActionsFullView(
                                                        //       id: widget
                                                        //               .goalsanddream
                                                        //               .action?[
                                                        //                   index]
                                                        //               .actionId
                                                        //               .toString() ??
                                                        //           "",
                                                        //       indexs: index,
                                                        //       action:
                                                        //           actionss.Action(
                                                        //         id: widget
                                                        //             .goalsanddream
                                                        //             .action![
                                                        //                 index]
                                                        //             .actionId,
                                                        //         title: widget
                                                        //             .goalsanddream
                                                        //             .action![
                                                        //                 index]
                                                        //             .actionTitle,
                                                        //         actionStatus: widget
                                                        //             .goalsanddream
                                                        //             .action![
                                                        //                 index]
                                                        //             .actionStatus,
                                                        //         actionDate: widget
                                                        //             .goalsanddream
                                                        //             .action![
                                                        //                 index]
                                                        //             .actionDatetime,
                                                        //       ),
                                                        //       goalId: widget
                                                        //           .goalsanddream
                                                        //           .goalId
                                                        //           .toString(),
                                                        //     ),
                                                        //   ),
                                                        // );
                                                      },
                                                      child: Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                                bottom: 10),
                                                        height:
                                                            size.height * 0.055,
                                                        width: size.width * 0.86,
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
                                                            5,
                                                          ),
                                                          border: Border.all(
                                                            color: Colors.grey,
                                                            width: 0.5,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
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
                                                                      context: context
                                                                    );
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  yes: "Yes",
                                                                  title:
                                                                      'Confirm Delete?',
                                                                  content:
                                                                      'Are you sure you want to delete this action?',
                                                                );
                                                              },
                                                              child: Padding(
                                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                                child: CircleAvatar(
                                                                  radius:
                                                                      size.width *
                                                                          0.04,
                                                                  backgroundColor:
                                                                      ColorsContent.newThemeColor,
                                                                  child: Icon(
                                                                    Icons.close_outlined,
                                                                    color: Colors
                                                                        .white,
                                                                    size:
                                                                        size.width *
                                                                            0.04,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                              child: SingleChildScrollView(
                                                                scrollDirection:
                                                                    Axis.horizontal,
                                                                // Enable horizontal scrolling
                                                                child: SizedBox(
                                                                  width: 250,
                                                                  child: Text(
                                                                    data.name,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 4,
                                                                    // Set the maximum number of lines to 3
                                                                    textAlign:
                                                                        TextAlign
                                                                            .start,
                                                                    style:  const TextStyle(
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w400,
                                                                      color: Colors.black,
                                                                      fontFamily: 'Poppins',
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            // GestureDetector(
                                                            //   onTap: () {
                                                            //     Navigator.of(
                                                            //             context)
                                                            //         .push(
                                                            //       MaterialPageRoute(
                                                            //         builder:
                                                            //             (context) =>
                                                            //                 ActionsFullView(
                                                            //           id: widget
                                                            //                   .goalsanddream
                                                            //                   .action?[index]
                                                            //                   .actionId
                                                            //                   .toString() ??
                                                            //               "",
                                                            //           indexs:
                                                            //               index,
                                                            //           action: actionss
                                                            //               .Action(
                                                            //             id: widget
                                                            //                 .goalsanddream
                                                            //                 .action![
                                                            //                     index]
                                                            //                 .actionId,
                                                            //             title: widget
                                                            //                 .goalsanddream
                                                            //                 .action![
                                                            //                     index]
                                                            //                 .actionTitle,
                                                            //             actionStatus: widget
                                                            //                 .goalsanddream
                                                            //                 .action![
                                                            //                     index]
                                                            //                 .actionStatus,
                                                            //             actionDate: widget
                                                            //                 .goalsanddream
                                                            //                 .action![
                                                            //                     index]
                                                            //                 .actionDatetime,
                                                            //           ),
                                                            //           goalId: widget
                                                            //               .goalsanddream
                                                            //               .goalId
                                                            //               .toString(),
                                                            //         ),
                                                            //       ),
                                                            //     );
                                                            //   },
                                                            //   child: CircleAvatar(
                                                            //     radius:
                                                            //         size.width *
                                                            //             0.04,
                                                            //     backgroundColor:
                                                            //     ColorsContent.newThemeColor,
                                                            //     child: Icon(
                                                            //       Icons
                                                            //           .arrow_forward_ios_outlined,
                                                            //       color: Colors
                                                            //           .white,
                                                            //       size:
                                                            //           size.width *
                                                            //               0.04,
                                                            //     ),
                                                            //   ),
                                                            // ),
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
        child: CustomTextFormFieldNumuFirstShow(
          controller: adDreamsGoalsProvider.nameEditTextController,
          hintText: _titleFocusNode.hasFocus ? '' : "Goal Name",
          hintStyle: CustomTextStyles.bodySmallGray700,
          focusNode: _titleFocusNode,
          textInputAction: TextInputAction.done,
          maxLines: 1,
          onTap: () => setState(() {}),
          // Rebuild when tapped
          onEditingComplete: () {
            _titleFocusNode.unfocus(); // Ensure focus is removed when done
            setState(() {});
          },
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
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
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
        final previewLink = widget.goalsanddream.preview_link?.toString().trim() ?? "";

        // ✅ Initialize backend link ONLY on first load
        if (previewLink.isNotEmpty &&
            adDreamsGoalsProvider.editDetectedLinks.isEmpty &&
            !adDreamsGoalsProvider.hasUserClearedLink) {
          adDreamsGoalsProvider.editDetectedLinks = [previewLink];
        }

        final hasLink = adDreamsGoalsProvider.editDetectedLinks.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📝 Always show text field
              CustomTextFormFieldNumuFirstShow(
                controller: adDreamsGoalsProvider.commentEditTextController,
                hintText: _descriptionFocusNode.hasFocus ? '' : "Goal Description",
                hintStyle: CustomTextStyles.bodySmallGray700,
                textInputAction: TextInputAction.done,
                textInputType: TextInputType.multiline,
                maxLines: 4,
                focusNode: _descriptionFocusNode,
          //     borderDecoration: InputBorder.none,
                textAlign: TextAlign.start,
                onTap: () => setState(() {}),
                onEditingComplete: () {
                  _descriptionFocusNode.unfocus();
                  setState(() {});
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\u0000-\uFFFF]')),
                ],
                onChanged: (text) {
                  // ✅ Detect new link dynamically
                  final matches = adDreamsGoalsProvider.editUrlRegex
                      .allMatches(text)
                      .map((m) => m.group(0)!)
                      .toList();

                  if (matches.isNotEmpty) {
                    // ✅ Check if user already has a link AND is trying to add another
                    if (adDreamsGoalsProvider.editDetectedLinks.isNotEmpty) {
                      // Show message for attempting to add multiple links
                      showToastTOP(
                        context: context,
                        message: "Only one link at a time",
                      );

                      // Remove the pasted link text, keep only normal text
                      final cleanedText = text.replaceAll(adDreamsGoalsProvider.editUrlRegex, '').trim();
                      adDreamsGoalsProvider.commentEditTextController.text = cleanedText;
                      adDreamsGoalsProvider.commentEditTextController.selection =
                          TextSelection.fromPosition(TextPosition(offset: cleanedText.length));
                      return;
                    }

                    final firstLink = matches.first;

                    // ✅ Store ONLY the first detected link (replace any previous)
                    adDreamsGoalsProvider.editDetectedLinks.clear();
                    adDreamsGoalsProvider.editDetectedLinks = [firstLink];
                    adDreamsGoalsProvider.hasUserClearedLink = false;

                    // ✅ Remove link text from the field
                    final cleanedText = text.replaceAll(adDreamsGoalsProvider.editUrlRegex, '').trim();
                    adDreamsGoalsProvider.commentEditTextController.text = cleanedText;
                    adDreamsGoalsProvider.commentEditTextController.selection =
                        TextSelection.fromPosition(TextPosition(offset: cleanedText.length));

                    setState(() {});
                  }
                },
              ),

              // 🔗 Link preview (ONLY ONE - no multiple links)
              if (hasLink)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [

                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinkPreviewGenerator(
                            link: adDreamsGoalsProvider.editDetectedLinks.first,
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

                      // ❌ Close icon - remove preview
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () {
                            customPopup(
                              context: context,
                              onPressedDelete: () {
                                setState(() {
                                  logger.i(
                                      "editDetectedLinks before clear: ${adDreamsGoalsProvider.editDetectedLinks}");
                                  adDreamsGoalsProvider.hasUserClearedLink = true;
                                  adDreamsGoalsProvider.editDetectedLinks.clear();
                                });
                                Navigator.of(context).pop();
                              },
                              title: 'Confirm Delete',
                              content:
                              'Are you sure you want to delete this link?',
                            );

                            setState(() {});
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




  /// Section Widget
  Widget _buildAddActionsButton(BuildContext context) {
    return CustomElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddEditActionScreen(
              goalId: widget.goalsanddream.goalId.toString(),
            ),
          ),
        );
      },
      height: 45,
      text: "Add Action",
      margin: const EdgeInsets.only(left: 2),
      buttonStyle: CustomButtonStyles.addActionButtonStyle,
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
            if (adDreamsGoalsProvider.nameEditTextController.text.isNotEmpty
                // &&
                // adDreamsGoalsProvider
                //     .commentEditTextController.text.isNotEmpty
                &&
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
                  locationLongitude: adDreamsGoalsProvider.selectedLongitude,
                  locationAddress:
                      adDreamsGoalsProvider.selectedLocationAddress,
                  categoryId: editProfileProvider.categorys!.id.toString(),
                  gemEndDate: adDreamsGoalsProvider.formattedDate,
                  mediaThumbs: adDreamsGoalsProvider.mediaThumbList, // ✅ pass here
                  actionId: adDreamsGoalsProvider.goalModelIdName,
                  gemId: widget.goalsanddream.goalId.toString(),
                  editDetectedLinks: adDreamsGoalsProvider.editDetectedLinks,
                );
                GoalsDreamsProvider goalsDreamsProvider =
                    Provider.of<GoalsDreamsProvider>(
                  context,
                  listen: false,
                );
                goalsDreamsProvider.fetchGoalsAndDreams(
                    pageNo: "1", context: context, initial: true, fullList: true);
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
                  locationLongitude: adDreamsGoalsProvider.selectedLongitude,
                  locationAddress:
                      adDreamsGoalsProvider.selectedLocationAddress,
                  categoryId: editProfileProvider.categorys!.id.toString(),
                  gemEndDate: unixTimestamp.toString(),
                  mediaThumbs: adDreamsGoalsProvider.mediaThumbList, // ✅ pass here
                  actionId: adDreamsGoalsProvider.goalModelIdName,
                  gemId: widget.goalsanddream.goalId.toString(),
                  editDetectedLinks: adDreamsGoalsProvider.editDetectedLinks,

                );
                GoalsDreamsProvider goalsDreamsProvider =
                    Provider.of<GoalsDreamsProvider>(
                  context,
                  listen: false,
                );

                goalsDreamsProvider.fetchGoalsAndDreams(
                    pageNo: "1", context: context, initial: true, fullList: true);
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
        height: 45,
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
                          FocusScope.of(context).requestFocus(FocusNode());
                          _isTokenExpired();
                          if (await requestGalleryPermission() && Platform.isAndroid) {
                            adDreamsGoalsProvider.selectedMedia(1);
                            await galleryBottomSheetAddGoals(
                              context: context,
                              title: 'Gallery',
                            );
                          } else if(Platform.isIOS){
                            adDreamsGoalsProvider.selectedMedia(1);
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
                          builder: (context, adDreamsGoalsProvider, _) {
                            if (adDreamsGoalsProvider
                                .alreadyPickedImages.isEmpty &&
                                adDreamsGoalsProvider.pickedImages.isEmpty) {
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
                                    "${adDreamsGoalsProvider.pickedImages.length + adDreamsGoalsProvider.alreadyPickedImages.length}",
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
                      ),
                      // Positioned(
                      //   bottom: 0,
                      //   left: 10,
                      //   right: 10,
                      //   child: Consumer<AdDreamsGoalsProvider>(
                      //       builder: (context, adDreamsGoalsProvider, _) {
                      //     if (adDreamsGoalsProvider
                      //             .alreadyPickedImages.isEmpty &&
                      //         adDreamsGoalsProvider.pickedImages.isEmpty) {
                      //       return const SizedBox();
                      //     } else {
                      //       return Container(
                      //         width: size.height * 0.04,
                      //         decoration: BoxDecoration(
                      //           color: Colors.white,
                      //           image: DecorationImage(
                      //             image: AssetImage(ImageConstant.imgMenu),
                      //             fit: BoxFit.cover,
                      //           ),
                      //           borderRadius: const BorderRadius.all(
                      //             Radius.circular(
                      //               50.0,
                      //             ),
                      //           ),
                      //           border: Border.all(
                      //             color: appTheme.blue300,
                      //             width: 2.0,
                      //           ),
                      //         ),
                      //         child: Center(
                      //           child: Text(
                      //             "${adDreamsGoalsProvider.pickedImages.length + adDreamsGoalsProvider.alreadyPickedImages.length}",
                      //             style: const TextStyle(
                      //               color: Colors.blue,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //         ),
                      //       );
                      //     }
                      //   }),
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
                          if (await requestCameraPermission() && Platform.isAndroid) {
                            adDreamsGoalsProvider.selectedMedia(2);
                            cameraBottomSheetAdGoals(
                              context: context,
                              title: "Camera",
                            );
                          } else if(Platform.isIOS){
                            adDreamsGoalsProvider.selectedMedia(2);
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
                          builder: (context, adDreamsGoalsProvider, _) {
                            if (adDreamsGoalsProvider.takedImages.isEmpty) {
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
                                    adDreamsGoalsProvider.takedImages.length
                                        .toString(),
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
                      //   child: Consumer<AdDreamsGoalsProvider>(
                      //       builder: (context, adDreamsGoalsProvider, _) {
                      //     if (adDreamsGoalsProvider.takedImages.isEmpty) {
                      //       return const SizedBox();
                      //     } else {
                      //       return Container(
                      //         width: size.height * 0.04,
                      //         decoration: BoxDecoration(
                      //           color: Colors.white,
                      //           image: DecorationImage(
                      //             image: AssetImage(ImageConstant.imgMenu),
                      //             fit: BoxFit.cover,
                      //           ),
                      //           borderRadius: const BorderRadius.all(
                      //             Radius.circular(
                      //               50.0,
                      //             ),
                      //           ),
                      //           border: Border.all(
                      //             color: appTheme.blue300,
                      //             width: 2.0,
                      //           ),
                      //         ),
                      //         child: Center(
                      //           child: Text(
                      //             adDreamsGoalsProvider.takedImages.length
                      //                 .toString(),
                      //             style: const TextStyle(
                      //               color: Colors.blue,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //         ),
                      //       );
                      //     }
                      //   }),
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
                          adDreamsGoalsProvider.selectedMedia(0);
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
                        bottom: Platform.isIOS ? 50: 45, // Adjust this value as needed
                        right: 0, // Move to the right
                        left: 40,
                        child: Consumer<AdDreamsGoalsProvider>(
                          builder: (context, adDreamsGoalsProvider, _) {
                            if (adDreamsGoalsProvider
                                .alreadyRecordedFilePath.isEmpty &&
                                adDreamsGoalsProvider.recordedFilePath.isEmpty) {
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
                                    "${adDreamsGoalsProvider.recordedFilePath.length + adDreamsGoalsProvider.alreadyRecordedFilePath.length}",
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
                      //   child: Consumer<AdDreamsGoalsProvider>(
                      //       builder: (context, adDreamsGoalsProvider, _) {
                      //         if (adDreamsGoalsProvider
                      //             .alreadyRecordedFilePath.isEmpty &&
                      //             adDreamsGoalsProvider.recordedFilePath.isEmpty) {
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
                      //                 "${adDreamsGoalsProvider.recordedFilePath.length + adDreamsGoalsProvider.alreadyRecordedFilePath.length}",
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
                                        child: AddGoalsGoogleMap(
                                            goalsanddream: widget.goalsanddream),
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
                        bottom: Platform.isIOS ? 50:45, // Adjust this value as needed
                        right: 0, // Move to the right
                        left: 40,
                        child: Consumer<AdDreamsGoalsProvider>(
                          builder: (context, adDreamsGoalsProvider, _) {
                            if (adDreamsGoalsProvider
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
                      //   child: Consumer<AdDreamsGoalsProvider>(
                      //       builder: (context, adDreamsGoalsProvider, _) {
                      //     if (adDreamsGoalsProvider
                      //         .selectedLocationName.isEmpty) {
                      //       return const SizedBox();
                      //     } else {
                      //       return Container(
                      //         width: size.height * 0.04,
                      //         decoration: BoxDecoration(
                      //           color: Colors.white,
                      //           image: DecorationImage(
                      //             image: AssetImage(ImageConstant.imgMenu),
                      //             fit: BoxFit.cover,
                      //           ),
                      //           borderRadius: const BorderRadius.all(
                      //             Radius.circular(
                      //               50.0,
                      //             ),
                      //           ),
                      //           border: Border.all(
                      //             color: appTheme.blue300,
                      //             width: 2.0,
                      //           ),
                      //         ),
                      //         child: const Center(
                      //           child: Text(
                      //             "1",
                      //             style: TextStyle(
                      //               color: Colors.blue,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //         ),
                      //       );
                      //     }
                      //   }),
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
