import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addactions_screen/widget/popup/audio_popup.dart';
import 'package:mentalhelth/screens/addactions_screen/widget/popup/camera_popup.dart';
import 'package:mentalhelth/screens/addactions_screen/widget/popup/gallary_popup.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/logic/date_format.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:mentalhelth/utils/theme/custom_button_style.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_subtitle.dart';
import 'package:mentalhelth/widgets/app_bar/custom_app_bar.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/custom_text_form_field.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import '../dash_borad_screen/provider/dash_board_provider.dart';
import '../edit_add_profile_screen/provider/edit_provider.dart';
import '../home_screen/provider/home_provider.dart';
import '../home_screen/widgets/home_menu/home_menu.dart';
import '../mental_strength_add_edit_screen/mental_strength_add_edit_page.dart';
import '../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../token_expiry/tocken_expiry_warning_screen.dart';
import '../token_expiry/token_expiry.dart';
import 'provider/add_actions_provider.dart';
import 'widget/googlemap_widget/google_map_widget.dart';

class AddactionsScreen extends StatefulWidget {
  const AddactionsScreen({Key? key, required this.goalId})
      : super(
    key: key,
  );
  final String goalId;
  @override
  State<AddactionsScreen> createState() =>
      _AddactionsScreenState();
}
class _AddactionsScreenState extends State<AddactionsScreen> {
  late HomeProvider homeProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late EditProfileProvider editProfileProvider;
  late DashBoardProvider dashBoardProvider;
  late AddActionsProvider addActionsProvider;
  bool tokenStatus = false;
  var logger = Logger();
  PermissionStatus permissionStatus = PermissionStatus.denied;

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
    addActionsProvider = Provider.of<AddActionsProvider>(context, listen: false);
    addActionsProvider.titleEditTextController.text = "";
    addActionsProvider.descriptionEditTextController.text = "";
    addActionsProvider.reminderStartTime = null;
    addActionsProvider.reminderEndTime = null;
    addActionsProvider.reminderStartDate = "";
    addActionsProvider.reminderEndDate = "";
    addActionsProvider.repeat = "";
    addActionsProvider.recordedFilePath.clear();
    addActionsProvider.pickedImages.clear();
    addActionsProvider.takedImages.clear();
    addActionsProvider.selectedLocationName = "";
    addActionsProvider.mediaSelected = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      editProfileProvider.fetchCategory();
      _isTokenExpired();
    });
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
      await Permission.manageExternalStorage.request(); // For Android 11 and above
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
    return tokenStatus == false ?
      SafeArea(
      child: Scaffold(
        appBar: buildAppBarAction(
          context,
          size,
          heading: "Add Action",
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
            image: DecorationImage(
              image: AssetImage(
                ImageConstant.imgGroup22,
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 15,
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Consumer<AddActionsProvider>(
                      builder: (context, addActionsProvider, _) {
                    return Column(
                      children: [
                        _buildTitleEditText(context),
                        const SizedBox(height: 19),
                        _buildDescriptionEditText(context),
                        const SizedBox(height: 35),
                        _buildAddMediaColumn(
                          context,
                          size,
                        ),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: addActionsProvider.setRemainder,
                              onChanged: (value) async {
                                _isTokenExpired();
                                addActionsProvider.changeSetRemainder(value!);
                                addActionsProvider
                                    .requestExactAlarmPermission();
                              },
                            ),
                            SizedBox(
                              width: size.width * 0.01,
                            ),
                            const Text(
                              "Set a reminder for this action",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: size.height * 0.02,
                        ),
                        addActionsProvider.setRemainder
                            ? SizedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Date",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            addActionsProvider
                                                .reminderStartDateFunction(
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
                                              color: theme.colorScheme
                                                  .onSecondaryContainer
                                                  .withOpacity(1),
                                              border: Border.all(
                                                color: appTheme.gray700,
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadiusStyle
                                                  .roundedBorder4,
                                            ),
                                            child: SizedBox(
                                              width: size.width * 0.32,
                                              child: Row(
                                                children: [
                                                  CustomImageView(
                                                    imagePath: ImageConstant
                                                        .imgThumbsUpGray700,
                                                    height: 20,
                                                    width: 20,
                                                    margin:
                                                        const EdgeInsets.only(
                                                      bottom: 2,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 5,
                                                      top: 2,
                                                      bottom: 1,
                                                    ),
                                                    child: Text(
                                                      //importent
                                                      addActionsProvider
                                                              .reminderStartDate
                                                              .isNotEmpty
                                                          ? addActionsProvider
                                                              .reminderStartDate
                                                          : "Choose Date   ",
                                                      style: CustomTextStyles
                                                          .bodySmallGray700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          "To",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            addActionsProvider
                                                .reminderEndDateFunction(
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
                                              color: theme.colorScheme
                                                  .onSecondaryContainer
                                                  .withOpacity(1),
                                              border: Border.all(
                                                color: appTheme.gray700,
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadiusStyle
                                                  .roundedBorder4,
                                            ),
                                            child: SizedBox(
                                              width: size.width * 0.32,
                                              child: Row(
                                                children: [
                                                  CustomImageView(
                                                    imagePath: ImageConstant
                                                        .imgThumbsUpGray700,
                                                    height: 20,
                                                    width: 20,
                                                    margin:
                                                        const EdgeInsets.only(
                                                      bottom: 2,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 5,
                                                      top: 2,
                                                      bottom: 1,
                                                    ),
                                                    child: Text(
                                                      addActionsProvider
                                                              .reminderEndDate
                                                              .isNotEmpty
                                                          ? addActionsProvider
                                                              .reminderEndDate
                                                          : "Choose Date   ",
                                                      style: CustomTextStyles
                                                          .bodySmallGray700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    const Text(
                                      "Time",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            addActionsProvider
                                                .reminderStartTimeFunction(
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
                                              color: theme.colorScheme
                                                  .onSecondaryContainer
                                                  .withOpacity(1),
                                              border: Border.all(
                                                color: appTheme.gray700,
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadiusStyle
                                                  .roundedBorder4,
                                            ),
                                            child: SizedBox(
                                              width: size.width * 0.32,
                                              child: Row(
                                                children: [
                                                  CustomImageView(
                                                    imagePath: ImageConstant
                                                        .imgThumbsUpGray700,
                                                    height: 20,
                                                    width: 20,
                                                    margin:
                                                        const EdgeInsets.only(
                                                      bottom: 2,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 5,
                                                      top: 2,
                                                      bottom: 1,
                                                    ),
                                                    child: Text(
                                                      addActionsProvider
                                                                  .reminderStartTime !=
                                                              null
                                                          ? formatTimeOfDay(
                                                              addActionsProvider
                                                                  .reminderStartTime!)
                                                          : "Choose Time   ",
                                                      style: CustomTextStyles
                                                          .bodySmallGray700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          "To",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            addActionsProvider
                                                .reminderEndTimeFunction(
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
                                              color: theme.colorScheme
                                                  .onSecondaryContainer
                                                  .withOpacity(1),
                                              border: Border.all(
                                                color: appTheme.gray700,
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadiusStyle
                                                  .roundedBorder4,
                                            ),
                                            child: SizedBox(
                                              width: size.width * 0.32,
                                              child: Row(
                                                children: [
                                                  CustomImageView(
                                                    imagePath: ImageConstant
                                                        .imgThumbsUpGray700,
                                                    height: 20,
                                                    width: 20,
                                                    margin:
                                                        const EdgeInsets.only(
                                                      bottom: 2,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 5,
                                                      top: 2,
                                                      bottom: 1,
                                                    ),
                                                    child: Text(
                                                      addActionsProvider
                                                                  .reminderEndTime !=
                                                              null
                                                          ? formatTimeOfDay(
                                                              addActionsProvider
                                                                  .reminderEndTime!)
                                                          : "Choose Time   ",
                                                      style: CustomTextStyles
                                                          .bodySmallGray700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Column(
                                        //   crossAxisAlignment:
                                        //       CrossAxisAlignment.start,
                                        //   children: [
                                        //     const Text(
                                        //       "Remind before",
                                        //       style: TextStyle(
                                        //         fontWeight: FontWeight.bold,
                                        //         fontSize: 15,
                                        //       ),
                                        //     ),
                                        //     const SizedBox(
                                        //       height: 5,
                                        //     ),
                                        //     GestureDetector(
                                        //       onTap: () {
                                        //         addActionsProvider
                                        //             .remindTimeFunction(
                                        //           context,
                                        //         );
                                        //       },
                                        //       child: Container(
                                        //         margin: const EdgeInsets.only(
                                        //           left: 2,
                                        //         ),
                                        //         padding: const EdgeInsets.only(
                                        //           left: 11,
                                        //           right: 8,
                                        //           bottom: 6,
                                        //           top: 6,
                                        //         ),
                                        //         decoration: BoxDecoration(
                                        //           color: theme.colorScheme
                                        //               .onSecondaryContainer
                                        //               .withOpacity(
                                        //             1,
                                        //           ),
                                        //           border: Border.all(
                                        //             color: appTheme.gray700,
                                        //             width: 1,
                                        //           ),
                                        //           borderRadius:
                                        //               BorderRadiusStyle
                                        //                   .roundedBorder4,
                                        //         ),
                                        //         child: SizedBox(
                                        //           width: size.width * 0.32,
                                        //           child: Row(
                                        //             children: [
                                        //               Padding(
                                        //                 padding:
                                        //                     const EdgeInsets
                                        //                         .only(
                                        //                   left: 3,
                                        //                   top: 2,
                                        //                   bottom: 1,
                                        //                 ),
                                        //                 child: Text(
                                        //                   addActionsProvider
                                        //                               .remindTime !=
                                        //                           null
                                        //                       ?
                                        //                       // formatTimeOfDay(
                                        //                       //         addActionsProvider
                                        //                       //             .reminderEndTime!)
                                        //                       addActionsProvider
                                        //                                   .remindTime!
                                        //                                   .hour <=
                                        //                               0
                                        //                           ? '${addActionsProvider.remindTime!.minute} Minute'
                                        //                           : '${addActionsProvider.remindTime!.hour} Hour ${addActionsProvider.remindTime!.minute} Minut'
                                        //                       : "Choose Time   ",
                                        //                   style: CustomTextStyles
                                        //                       .bodySmallGray700,
                                        //                 ),
                                        //               ),
                                        //               const Spacer(),
                                        //               const Icon(
                                        //                 Icons
                                        //                     .keyboard_arrow_down_sharp,
                                        //                 color: Colors.blue,
                                        //               )
                                        //             ],
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Repeat",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                AlertDialog alert = AlertDialog(
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ListTile(
                                                        onTap: () {
                                                          addActionsProvider
                                                              .addRepeatValue(
                                                            "Never",
                                                          );
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        title: const Text(
                                                          "Never",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      ListTile(
                                                        onTap: () {
                                                          addActionsProvider
                                                              .addRepeatValue(
                                                                  "Daily");
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        title: const Text(
                                                          "Daily",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      ListTile(
                                                        onTap: () {
                                                          addActionsProvider
                                                              .addRepeatValue(
                                                                  "Weekly");
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        title: const Text(
                                                          "Weekly",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      ListTile(
                                                        onTap: () {
                                                          addActionsProvider
                                                              .addRepeatValue(
                                                                  "Monthly");
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        title: const Text(
                                                          "Monthly",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      ListTile(
                                                        onTap: () {
                                                          addActionsProvider
                                                              .addRepeatValue(
                                                                  "Yearly");
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        title: const Text(
                                                          "Yearly",
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return alert;
                                                  },
                                                );
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                  left: 2,
                                                ),
                                                padding: const EdgeInsets.only(
                                                  left: 11,
                                                  right: 8,
                                                  bottom: 6,
                                                  top: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme
                                                      .onSecondaryContainer
                                                      .withOpacity(1),
                                                  border: Border.all(
                                                    color: appTheme.gray700,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadiusStyle
                                                          .roundedBorder4,
                                                ),
                                                child: SizedBox(
                                                  width: size.width * 0.32,
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 10,
                                                          top: 2,
                                                          bottom: 1,
                                                        ),
                                                        child: Text(
                                                          addActionsProvider
                                                              .repeat,
                                                          style: CustomTextStyles
                                                              .bodySmallGray700,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      const Icon(
                                                        Icons
                                                            .keyboard_arrow_down_sharp,
                                                        color: Colors.blue,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                      ],
                    );
                  }),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildSaveButton(
                    context,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ):
    const TokenExpireScreen();
  }

  // Widget _addAudioStack(
  //     BuildContext context, Size size, AddActionsProvider addActionsProvider) {
  //   return Container(
  //     margin: const EdgeInsets.only(left: 2),
  //     child: Column(
  //       children: [
  //         Align(
  //           alignment: Alignment.topLeft,
  //           child: CustomImageView(
  //             imagePath: ImageConstant.imgPolygon4,
  //             height: 27,
  //             width: 23,
  //             margin: const EdgeInsets.only(left: 5),
  //           ),
  //         ),
  //         Align(
  //           alignment: Alignment.bottomCenter,
  //           child: Container(
  //             padding: const EdgeInsets.only(
  //               left: 10,
  //               right: 10,
  //               bottom: 10,
  //               top: 10,
  //             ),
  //             decoration: AppDecoration.fillBlue300.copyWith(
  //               borderRadius: BorderRadiusStyle.roundedBorder10,
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 const CircleAvatar(
  //                   backgroundColor: Colors.white,
  //                   child: Center(
  //                     child: Icon(
  //                       Icons.play_arrow,
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   width: size.width * 0.08,
  //                 ),
  //                 CustomImageView(
  //                   imagePath: ImageConstant.imgClosePrimary,
  //                   height: 30,
  //                   width: 30,
  //                 ),
  //               ],
  //             ),
  //
  //             // CustomImageView(
  //             //   imagePath: ImageConstant.imgClosePrimary,
  //             //   height: 30,
  //             //   width: double.infinity,
  //             // ),
  //           ),
  //         ),
  //         // Align(
  //         //   alignment: Alignment.topLeft,
  //         //   child: Padding(
  //         //     padding: const EdgeInsets.only(
  //         //       left: 17,
  //         //       right: 61,
  //         //     ),
  //         //     child: Column(
  //         //       mainAxisSize: MainAxisSize.min,
  //         //       crossAxisAlignment: CrossAxisAlignment.start,
  //         //       children: [
  //         //         const SizedBox(height: 1),
  //         //         Row(
  //         //           children: [
  //         //             Padding(
  //         //               padding: const EdgeInsets.only(top: 1),
  //         //               child: CustomIconButton(
  //         //                 height: 47,
  //         //                 width: 47,
  //         //                 padding: const EdgeInsets.all(15),
  //         //                 child: CustomImageView(
  //         //                   imagePath: ImageConstant
  //         //                       .imgOverflowMenuOnsecondarycontainer,
  //         //                 ),
  //         //               ),
  //         //             ),
  //         //             CustomImageView(
  //         //               imagePath: ImageConstant.imgVector,
  //         //               height: 44,
  //         //               width: 207,
  //         //               margin: const EdgeInsets.only(
  //         //                 left: 3,
  //         //                 bottom: 3,
  //         //               ),
  //         //             ),
  //         //           ],
  //         //         ),
  //         //       ],
  //         //     ),
  //         //   ),
  //         // ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _addAudioStack(BuildContext context) {
  //   return SizedBox(
  //     width: 336,
  //     child: Stack(
  //       alignment: Alignment.center,
  //       children: [
  //         Align(
  //           alignment: Alignment.bottomCenter,
  //           child: Container(
  //             decoration: BoxDecoration(
  //               color: appTheme.blue300,
  //               borderRadius: BorderRadius.circular(
  //                 10,
  //               ),
  //             ),
  //           ),
  //         ),
  //         Align(
  //           alignment: Alignment.center,
  //           child: SizedBox(
  //             // height: 252,
  //             // width: 335,
  //             child: Stack(
  //               alignment: Alignment.bottomCenter,
  //               children: [
  //                 // CustomImageView(
  //                 //   imagePath: ImageConstant.imgPolygon4,
  //                 //   height: 27,
  //                 //   width: 23,
  //                 //   alignment: Alignment.topLeft,
  //                 //   margin: const EdgeInsets.only(
  //                 //     left: 114,
  //                 //   ),
  //                 // ),
  //                 Align(
  //                   alignment: Alignment.bottomCenter,
  //                   child: SizedBox(
  //                     child: Stack(
  //                       alignment: Alignment.topRight,
  //                       children: [
  //                         CustomImageView(
  //                           imagePath: ImageConstant.imgImage6,
  //                           height: 236,
  //                           width: 335,
  //                           alignment: Alignment.center,
  //                         ),
  //                         CustomImageView(
  //                           imagePath: ImageConstant.imgClosePrimary,
  //                           height: 30,
  //                           width: 30,
  //                           alignment: Alignment.topRight,
  //                           margin: const EdgeInsets.only(
  //                             top: 30,
  //                             right: 26,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildAvatar({String? imagePath, required Size size, Widget? widget}) {
  //   return Container(
  //     height: size.height * 0.08,
  //     width: size.height * 0.08,
  //     decoration: BoxDecoration(
  //       color: Colors.transparent,
  //       image: imagePath == null
  //           ? null
  //           : DecorationImage(
  //               image: AssetImage(imagePath),
  //               fit: BoxFit.cover,
  //             ),
  //       borderRadius: const BorderRadius.all(
  //         Radius.circular(
  //           50.0,
  //         ),
  //       ),
  //       border: Border.all(
  //         color: appTheme.blue300,
  //         width: 1.0,
  //       ),
  //     ),
  //     child: imagePath == null
  //         ? widget
  //         : CustomIconButton(
  //             height: size.height * 0.08,
  //             width: size.height * 0.08,
  //             padding: const EdgeInsets.all(18),
  //             child: CustomImageView(
  //               imagePath: imagePath,
  //             ),
  //           ),
  //   );
  // }

  /// Section Widget
  Widget _buildTitleEditText(BuildContext context) {
    return Consumer<AddActionsProvider>(
        builder: (context, addActionsProvider, _) {
      return CustomTextFormField(
        controller: addActionsProvider.titleEditTextController,
        hintText: "Title",
        hintStyle: CustomTextStyles.bodySmallGray700,
      );
    });
  }

  /// Section Widget
  Widget _buildDescriptionEditText(BuildContext context) {
    return Consumer<AddActionsProvider>(
        builder: (context, addActionsProvider, _) {
      return CustomTextFormField(
        controller: addActionsProvider.descriptionEditTextController,
        hintText: "Description",
        hintStyle: CustomTextStyles.bodySmallGray700,
        textInputAction: TextInputAction.done,
        maxLines: 4,
      );
    });
  }

  /// Section Widget
  Widget _buildSaveButton(BuildContext context) {
    return Consumer2<AddActionsProvider, AdDreamsGoalsProvider>(
      builder: (context, addActionsProvider, adDreamsGoalsProvider, _) {
        return CustomElevatedButton(
          loading: addActionsProvider.saveAddActionsLoading,
          onPressed: () async {
            // Individual field validations
            if (addActionsProvider.titleEditTextController.text.isEmpty) {
              showCustomSnackBar(
                context: context,
                message: "Please fill in the title",
              );
            } else if (addActionsProvider.descriptionEditTextController.text.isEmpty) {
              showCustomSnackBar(
                context: context,
                message: "Please fill in the description",
              );
            } else {
              // Check if a reminder is set and validate date/time fields accordingly
              if (addActionsProvider.setRemainder) {
                if (addActionsProvider.reminderStartDate.isEmpty) {
                  showCustomSnackBar(
                    context: context,
                    message: "Please select a start date for the reminder",
                  );
                } else if (addActionsProvider.reminderEndDate.isEmpty) {
                  showCustomSnackBar(
                    context: context,
                    message: "Please select an end date for the reminder",
                  );
                } else if (addActionsProvider.reminderStartTime == null) {
                  showCustomSnackBar(
                    context: context,
                    message: "Please select a start time for the reminder",
                  );
                } else if (addActionsProvider.reminderEndTime == null) {
                  showCustomSnackBar(
                    context: context,
                    message: "Please select an end time for the reminder",
                  );
                }
                // else if (addActionsProvider.remindTime == null) {
                //   showCustomSnackBar(
                //     context: context,
                //     message: "Please select a reminder time",
                //   );
                // }
                else {
                  // All fields are validated, proceed to save
                  await addActionsProvider.saveGemFunction(
                    context,
                    title: addActionsProvider.titleEditTextController.text,
                    details: addActionsProvider.descriptionEditTextController.text,
                    mediaName: addActionsProvider.addMediaUploadResponseList,
                    locationName: addActionsProvider.selectedLocationName,
                    locationLatitude: addActionsProvider.selectedLatitude,
                    locationLongitude: addActionsProvider.locationLongitude,
                    locationAddress: addActionsProvider.selectedLocationAddress,
                    goalId: widget.goalId,
                    isReminder: "1",
                  );
                  adDreamsGoalsProvider.getAddActionIdAndName(
                    value: addActionsProvider.goalModelIdName!,
                  );
                  addActionsProvider.setRemainder = false;
                  // You can uncomment the line below if you want to close the screen after saving.
                  // Navigator.of(context).pop();
                }
              } else {
                // Reminder is not set, proceed with save without reminder-related fields
                await addActionsProvider.saveGemFunction(
                  context,
                  title: addActionsProvider.titleEditTextController.text,
                  details: addActionsProvider.descriptionEditTextController.text,
                  mediaName: addActionsProvider.addMediaUploadResponseList,
                  locationName: addActionsProvider.selectedLocationName,
                  locationLatitude: addActionsProvider.selectedLatitude,
                  locationLongitude: addActionsProvider.locationLongitude,
                  locationAddress: addActionsProvider.selectedLocationAddress,
                  goalId: widget.goalId,
                  isReminder: "0",
                );
                adDreamsGoalsProvider.getAddActionIdAndName(
                  value: addActionsProvider.goalModelIdName!,
                );

                addActionsProvider.setRemainder = false;
                // You can uncomment the line below if you want to close the screen after saving.
                 Navigator.of(context).pop();
              }
            }
          },
          height: 40,
          text: "Save",
          buttonStyle: CustomButtonStyles.outlinePrimaryTL5,
          buttonTextStyle: CustomTextStyles.titleSmallHelveticaOnSecondaryContainer,
        );
      },
    );
  }


  Widget _buildAddMediaColumn(BuildContext context, Size size) {
    return Consumer<AddActionsProvider>(
        builder: (context, addActionsProvider, _) {
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
                          addActionsProvider.selectedMedia(0);
                          await audioBottomSheetAction(
                            context: context,
                            title: 'Record Audio',
                          );
                          // }
                        },
                        child: Container(
                          height: size.height * 0.08,
                          width: size.height * 0.08,
                          decoration: BoxDecoration(
                            color: addActionsProvider.mediaSelected == 0
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
                            color: addActionsProvider.mediaSelected == 0
                                ? Colors.white
                                : Colors.blue,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 10,
                        right: 10,
                        child: Consumer<AddActionsProvider>(
                            builder: (context, addActionsProvider, _) {
                          if (addActionsProvider.recordedFilePath.isEmpty) {
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
                                  addActionsProvider.recordedFilePath.length
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
                          addActionsProvider.selectedMedia(1);
                          await galleryBottomSheetAction(
                            context: context,
                            title: 'Gallery',
                          );
                        },
                        child: buildAvatarImage(
                          widget: Icon(
                            Icons.image,
                            size: 30,
                            color: addActionsProvider.mediaSelected == 1
                                ? Colors.white
                                : Colors.blue,
                          ),
                          imagePath: ImageConstant.imgThumbsUp,
                          size: size,
                          isSelected: addActionsProvider.mediaSelected == 1
                              ? true
                              : false,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 10,
                        right: 10,
                        child: Consumer<AddActionsProvider>(
                            builder: (context, addActionsProvider, _) {
                          if (addActionsProvider.pickedImages.isEmpty) {
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
                                  addActionsProvider.pickedImages.length
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
                          addActionsProvider.selectedMedia(2);
                          cameraBottomSheetAction(
                            context: context,
                            title: "Camera",
                          );
                        },
                        child: buildAvatarImage(
                          widget: Icon(
                            Icons.camera_alt_outlined,
                            size: 30,
                            color: addActionsProvider.mediaSelected == 2
                                ? Colors.white
                                : Colors.blue,
                          ),
                          imagePath: ImageConstant.imgCamera,
                          size: size,
                          isSelected: addActionsProvider.mediaSelected == 2
                              ? true
                              : false,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 10,
                        right: 10,
                        child: Consumer<AddActionsProvider>(
                            builder: (context, addActionsProvider, _) {
                          if (addActionsProvider.takedImages.isEmpty) {
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
                                  addActionsProvider.takedImages.length
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
                          addActionsProvider.selectedMedia(
                            3,
                          );
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                child: const AddActionGoogleMap(),
                              );
                            },
                          );
                        },
                        child: buildAvatarImage(
                          widget: Icon(
                            Icons.location_on,
                            size: 30,
                            color: addActionsProvider.mediaSelected == 3
                                ? Colors.white
                                : Colors.blue,
                          ),
                          imagePath: ImageConstant.imgLinkedin,
                          size: size,
                          // wi
                          isSelected: addActionsProvider.mediaSelected == 3
                              ? true
                              : false,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 10,
                        right: 10,
                        child: Consumer<AddActionsProvider>(
                            builder: (context, addActionsProvider, _) {
                          if (addActionsProvider.selectedLocationName.isEmpty) {
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

PreferredSizeWidget buildAppBarAction(BuildContext context, Size size,
    {String? heading, Function? onTap}) {
  return CustomAppBar(
    leadingWidth: 36,
    leading: AppbarLeadingImage(
      onTap: onTap ??
          () {
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
      text: heading ?? "My profile",
      margin: const EdgeInsets.only(
        left: 11,
      ),
    ),
    actions: [
      GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => buildPopupDialog(
              context,
              size,
            ),
          );
        },
        child: Padding(
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
      ),
    ],
  );
}
