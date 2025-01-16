import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/addactions_screen/provider/add_actions_provider.dart';
import 'package:mentalhelth/screens/addactions_screen/widget/googlemap_widget/google_map_widget.dart';
import 'package:mentalhelth/screens/addactions_screen/widget/popup/audio_popup.dart';
import 'package:mentalhelth/screens/addactions_screen/widget/popup/camera_popup.dart';
import 'package:mentalhelth/screens/addactions_screen/widget/popup/gallary_popup.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/logic/date_format.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:mentalhelth/utils/theme/custom_button_style.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/custom_text_form_field.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:provider/provider.dart';

import '../../mental_strength_add_edit_page.dart';

class AddActionMentalStrengthBottomSheet extends StatelessWidget {
  const AddActionMentalStrengthBottomSheet({Key? key, required this.goalId})
      : super(
          key: key,
        );

  final String goalId;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(
        top: size.height * 0.15,
      ),
      width: double.infinity,
      height: double.infinity,
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5), // Shadow color
            spreadRadius: 5, // Spread radius
            blurRadius: 7, // Blur radius
            offset: const Offset(0, 3), // Offset
          ),
        ],
        // color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
        image: DecorationImage(
          image: AssetImage(
            ImageConstant.imgGroup193,
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
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    Consumer<MentalStrengthEditProvider>(
                        builder: (context, mentalStrengthEditProvider, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              mentalStrengthEditProvider
                                  .openAddActionFunction();
                            },
                            child: CustomImageView(
                              imagePath: ImageConstant.imgClosePrimaryNew,
                              height: 40,
                              width: 40,
                            ),
                          ),
                          SizedBox(
                            width: size.width * 0.03,
                          )
                        ],
                      );
                    }),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    _buildTitleEditText(context),
                    const SizedBox(height: 19),
                    _buildDescriptionEditText(context),
                    const SizedBox(height: 35),
                    _buildAddMediaColumn(
                      context,
                      size,
                    ),
                    const SizedBox(height: 19),
                    Row(
                      children: [
                        Checkbox(
                          value: addActionsProvider.setRemainder,
                          onChanged: (value) {
                            addActionsProvider.changeSetRemainder(value!);
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
                                          color: theme
                                              .colorScheme.onSecondaryContainer
                                              .withOpacity(1),
                                          border: Border.all(
                                            color: appTheme.gray700,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadiusStyle.roundedBorder4,
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
                                                margin: const EdgeInsets.only(
                                                  bottom: 2,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
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
                                          color: theme
                                              .colorScheme.onSecondaryContainer
                                              .withOpacity(1),
                                          border: Border.all(
                                            color: appTheme.gray700,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadiusStyle.roundedBorder4,
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
                                                margin: const EdgeInsets.only(
                                                  bottom: 2,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
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
                                          color: theme
                                              .colorScheme.onSecondaryContainer
                                              .withOpacity(1),
                                          border: Border.all(
                                            color: appTheme.gray700,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadiusStyle.roundedBorder4,
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
                                                margin: const EdgeInsets.only(
                                                  bottom: 2,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
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
                                          color: theme
                                              .colorScheme.onSecondaryContainer
                                              .withOpacity(1),
                                          border: Border.all(
                                            color: appTheme.gray700,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadiusStyle.roundedBorder4,
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
                                                margin: const EdgeInsets.only(
                                                  bottom: 2,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
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
                                    //           left: 5,
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
                                    //           borderRadius: BorderRadiusStyle
                                    //               .roundedBorder4,
                                    //         ),
                                    //         child: SizedBox(
                                    //           width: size.width * 0.32,
                                    //           child: Row(
                                    //             children: [
                                    //               Padding(
                                    //                 padding:
                                    //                     const EdgeInsets.only(
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
                                                mainAxisSize: MainAxisSize.min,
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
                                              builder: (BuildContext context) {
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
                                              borderRadius: BorderRadiusStyle
                                                  .roundedBorder4,
                                            ),
                                            child: SizedBox(
                                              width: size.width * 0.32,
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      left: 10,
                                                      top: 2,
                                                      bottom: 1,
                                                    ),
                                                    child: Text(
                                                      addActionsProvider.repeat,
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
                    // addActionsProvider.mediaSelected == 3
                    //     ? const AddActionGoogleMap()
                    //     : const SizedBox(),
                    const SizedBox(height: 55),
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
    );
  }

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
        hintText: "Action Description",
        hintStyle: CustomTextStyles.bodySmallGray700,
        textInputAction: TextInputAction.done,
        maxLines: 4,
      );
    });
  }

  /// Section Widget
  Widget _buildSaveButton(BuildContext context) {
    return Consumer3<AddActionsProvider, AdDreamsGoalsProvider,
            MentalStrengthEditProvider>(
        builder: (context, addActionsProvider, adDreamsGoalsProvider,
            mentalStrengthEditProvider, _) {
      return CustomElevatedButton(
        loading: addActionsProvider.saveAddActionsLoading,
        onPressed: () async {
          // if (addActionsProvider.titleEditTextController.text.isNotEmpty &&
          //     addActionsProvider
          //         .descriptionEditTextController.text.isNotEmpty) {
          //   await addActionsProvider.saveGemFunction(
          //     context,
          //     title: addActionsProvider.titleEditTextController.text,
          //     details: addActionsProvider.descriptionEditTextController.text,
          //     mediaName: addActionsProvider.addMediaUploadResponseList,
          //     locationName: addActionsProvider.selectedLocationName,
          //     locationLatitude: addActionsProvider.selectedLatitude,
          //     locationLongitude: addActionsProvider.locationLongitude,
          //     locationAddress: addActionsProvider.selectedLocationAddress,
          //     goalId: goalId,
          //   );
          //   adDreamsGoalsProvider.getAddActionIdAndName(
          //     value: addActionsProvider.goalModelIdName!,
          //   );
          //   mentalStrengthEditProvider.fetchGoalActions(
          //     goalId: goalId,
          //   );
          //   mentalStrengthEditProvider.openAddActionFunction();
          // } else {
          //   showCustomSnackBar(
          //     context: context,
          //     message: "Please fill in all the fields",
          //   );
          // }
          if (addActionsProvider.titleEditTextController.text.isNotEmpty &&
              addActionsProvider
                  .descriptionEditTextController.text.isNotEmpty) {
            if (addActionsProvider.setRemainder) {
              if (addActionsProvider.reminderStartDate.isNotEmpty &&
                  addActionsProvider.reminderEndDate.isNotEmpty &&
                  addActionsProvider.reminderStartTime != null &&
                  addActionsProvider.reminderEndTime != null) {
              await addActionsProvider.saveGemFunction(
                  context,
                  title: addActionsProvider.titleEditTextController.text,
                  details:
                      addActionsProvider.descriptionEditTextController.text,
                  mediaName: addActionsProvider.addMediaUploadResponseList,
                  locationName: addActionsProvider.selectedLocationName,
                  locationLatitude: addActionsProvider.selectedLatitude,
                  locationLongitude: addActionsProvider.locationLongitude,
                  locationAddress: addActionsProvider.selectedLocationAddress,
                  goalId: goalId,
                    isReminder: "1"
                );
                // if (getGemStatus) {
                //   Navigator.of(context).pop();
                // }
                adDreamsGoalsProvider.getAddActionIdAndName(
                  value: addActionsProvider.goalModelIdName!,
                );
                mentalStrengthEditProvider.fetchGoalActions(
                  goalId: goalId,
                );
                mentalStrengthEditProvider.openAddActionFunction();
               //   Navigator.of(context).pop();
              } else {
                showCustomSnackBar(
                  context: context,
                  message: "Please Select Date and Time",
                );
              }
            } else {
              await addActionsProvider.saveGemFunction(
                context,
                title: addActionsProvider.titleEditTextController.text,
                details: addActionsProvider.descriptionEditTextController.text,
                mediaName: addActionsProvider.addMediaUploadResponseList,
                locationName: addActionsProvider.selectedLocationName,
                locationLatitude: addActionsProvider.selectedLatitude,
                locationLongitude: addActionsProvider.locationLongitude,
                locationAddress: addActionsProvider.selectedLocationAddress,
                goalId: goalId,
                  isReminder: "0"
              );
              adDreamsGoalsProvider.getAddActionIdAndName(
                value: addActionsProvider.goalModelIdName!,
              );
              mentalStrengthEditProvider.fetchGoalActions(
                goalId: goalId,
              );
              mentalStrengthEditProvider.openAddActionFunction();
              // Navigator.of(context).pop();
            }
          } else {
            showCustomSnackBar(
              context: context,
              message: "Please fill in all the fields",
            );
          }
        },
        height: 40,
        text: "Save",
        buttonStyle: CustomButtonStyles.outlinePrimaryTL5,
        buttonTextStyle:
            CustomTextStyles.titleSmallHelveticaOnSecondaryContainer,
      );
    });
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
