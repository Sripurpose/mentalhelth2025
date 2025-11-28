import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/goals_dreams_page/model/goals_and_dreams_model.dart';
import 'package:mentalhelth/screens/goals_dreams_page/provider/goals_dreams_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/app_bar/appbar_subtitle.dart';
import '../../../../widgets/app_bar/custom_app_bar.dart';
import '../../../utils/logic/date_format.dart';
import '../../../utils/theme/app_decoration.dart';
import '../../../utils/theme/custom_button_style.dart';
import '../../../utils/theme/theme_helper.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_image_view.dart';
import '../../../widgets/custom_text_form_field.dart';
import '../../addactions_screen/provider/add_actions_provider.dart';
import '../../addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import '../../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../../no_internet/duplicate_screen.dart';

class AddNewReminderScreenScreen extends StatefulWidget {
  const AddNewReminderScreenScreen({
    Key? key,
  }) : super(
          key: key,
        );

  @override
  State<AddNewReminderScreenScreen> createState() =>
      _AddNewReminderScreenScreenState();
}

class _AddNewReminderScreenScreenState
    extends State<AddNewReminderScreenScreen> {
  bool isCompleted = false;
  bool isSingleActionCompleted = false;
  late GoalsDreamsProvider goalsDreamsProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late HomeProvider homeProvider;
  late AddActionsProvider addActionsProvider;

  @override
  void initState() {
    goalsDreamsProvider =
        Provider.of<GoalsDreamsProvider>(context, listen: false);
    mentalStrengthEditProvider =
        Provider.of<MentalStrengthEditProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    goalsDreamsProvider.fetchGoalsAndDreams(
        pageNo: "1", context: context, initial: true, fullList: true);
    addActionsProvider =
        Provider.of<AddActionsProvider>(context, listen: false);
    _loadGoalListDropDown();
    super.initState();
  }
  Future<void> _loadGoalListDropDown() async {
    final homeProvider =
    Provider.of<HomeProvider>(context, listen: false);
    await homeProvider.fetchGoals(context: context);
  }


  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: ConnectivityWidget(
        child: Scaffold(
          appBar:
              buildAppBarGoalView(context, size, heading: "New Reminder", id: ""),
          body: Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Consumer<HomeProvider>(builder: (context, homeProvider, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildTitleEditText(context),
                    const SizedBox(height: 20),
                    _buildDescriptionEditText(context),
                    const SizedBox(height: 50),
                    SizedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Date",
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  homeProvider.reminderStartDateFunction(
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
                                    color: theme.colorScheme.onSecondaryContainer
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
                                          imagePath:
                                              ImageConstant.imgThumbsUpGray700,
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
                                            homeProvider
                                                    .reminderStartDate.isNotEmpty
                                                ? homeProvider.reminderStartDate
                                                : "Choose Date   ",
                                            style:
                                                CustomTextStyles.bodySmallGray700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Text(
                                "To",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              GestureDetector(
                                onTap: () {
                                  homeProvider.reminderEndDateFunction(
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
                                    color: theme.colorScheme.onSecondaryContainer
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
                                          imagePath:
                                              ImageConstant.imgThumbsUpGray700,
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
                                            homeProvider
                                                    .reminderEndDate.isNotEmpty
                                                ? homeProvider.reminderEndDate
                                                : "Choose Date   ",
                                            style:
                                                CustomTextStyles.bodySmallGray700,
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
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  homeProvider.reminderStartTimeFunction(
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
                                    color: theme.colorScheme.onSecondaryContainer
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
                                          imagePath:
                                              ImageConstant.imgThumbsUpGray700,
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
                                            homeProvider.reminderStartTime != null
                                                ? formatTimeOfDay(homeProvider
                                                    .reminderStartTime!)
                                                : "Choose Time   ",
                                            style:
                                                CustomTextStyles.bodySmallGray700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Text(
                                "To",
                                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins',),
                              ),
                              GestureDetector(
                                onTap: () {
                                  homeProvider.reminderEndTimeFunction(
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
                                    color: theme.colorScheme.onSecondaryContainer
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
                                          imagePath:
                                              ImageConstant.imgThumbsUpGray700,
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
                                            homeProvider.reminderEndTime != null
                                                ? formatTimeOfDay(
                                                    homeProvider.reminderEndTime!)
                                                : "Choose Time   ",
                                            style:
                                                CustomTextStyles.bodySmallGray700,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Remind before",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      homeProvider.remindTimeFunction(
                                        context,
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
                                        color: theme
                                            .colorScheme.onSecondaryContainer
                                            .withOpacity(
                                          1,
                                        ),
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
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 3,
                                                top: 2,
                                                bottom: 1,
                                              ),
                                              child: Text(
                                                homeProvider.remindTime != null
                                                    ?
                                                    // formatTimeOfDay(
                                                    //         addActionsProvider
                                                    //             .reminderEndTime!)
                                                    homeProvider.remindTime!
                                                                .hour <=
                                                            0
                                                        ? '${homeProvider.remindTime!.minute} Minute'
                                                        : '${homeProvider.remindTime!.hour} Hour ${homeProvider.remindTime!.minute} Minut'
                                                    : "Choose Time   ",
                                                style: CustomTextStyles
                                                    .bodySmallGray700,
                                              ),
                                            ),
                                            const Spacer(),
                                             Icon(
                                              Icons.keyboard_arrow_down_sharp,
                                              color: ColorsContent.newThemeColor,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Repeat",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
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
                                                homeProvider.addRepeatValue(
                                                  "Never",
                                                );
                                                Navigator.of(context).pop();
                                              },
                                              title: const Text(
                                                "Never",
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              onTap: () {
                                                homeProvider
                                                    .addRepeatValue("Daily");
                                                Navigator.of(context).pop();
                                              },
                                              title: const Text(
                                                "Daily",
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              onTap: () {
                                                homeProvider
                                                    .addRepeatValue("Weekly");
                                                Navigator.of(context).pop();
                                              },
                                              title: const Text(
                                                "Weekly",
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              onTap: () {
                                                homeProvider
                                                    .addRepeatValue("Monthly");
                                                Navigator.of(context).pop();
                                              },
                                              title: const Text(
                                                "Monthly",
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            ListTile(
                                              onTap: () {
                                                homeProvider
                                                    .addRepeatValue("Yearly");
                                                Navigator.of(context).pop();
                                              },
                                              title: const Text(
                                                "Yearly",
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
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
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 10,
                                                top: 2,
                                                bottom: 1,
                                              ),
                                              child: Text(
                                                homeProvider.repeat,
                                                style: CustomTextStyles
                                                    .bodySmallGray700,
                                              ),
                                            ),
                                            const Spacer(),
                                             Icon(
                                              Icons.keyboard_arrow_down_sharp,
                                              color: ColorsContent.newThemeColor,
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
                    ),
                    const SizedBox(height: 50),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildSaveButton(
                        context,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleEditText(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, homeProvider, _) {
      return CustomTextFormField(
        controller: homeProvider.titleEditTextController,
        hintText: "Title",
        hintStyle: CustomTextStyles.bodySmallGray700,
      );
    });
  }

  /// Section Widget
  Widget _buildDescriptionEditText(BuildContext context) {
    return Consumer<HomeProvider>(builder: (context, homeProvider, _) {
      return CustomTextFormField(
        controller: homeProvider.descriptionEditTextController,
        hintText: "Description",
        hintStyle: CustomTextStyles.bodySmallGray700,
        textInputAction: TextInputAction.done,
        maxLines: 4,
      );
    });
  }

  Widget _buildSaveButton(BuildContext context) {
    return Consumer2<AddActionsProvider, AdDreamsGoalsProvider>(
        builder: (context, addActionsProvider, adDreamsGoalsProvider, _) {
      return CustomElevatedButton(
        loading: addActionsProvider.saveAddActionsLoading,
        onPressed: () async {},
        height: 40,
        text: "Set Reminder",
        buttonStyle: CustomButtonStyles.outlinePrimaryTL5,
        buttonTextStyle:
            CustomTextStyles.titleSmallHelveticaOnSecondaryContainer,
      );
    });
  }

  PreferredSizeWidget buildAppBarGoalView(
    BuildContext context,
    Size size, {
    String? heading,
    required String id,
  }) {
    return CustomAppBar(
      leadingWidth: 36,
      leading: AppbarLeadingImage(
        onTap: () {
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
        text: heading ?? "",
        margin: const EdgeInsets.only(
          left: 11,
        ),
      ),
      actions: [
        Consumer<GoalsDreamsProvider>(
          builder: (contexts, goalsDreamsProvider, _) {
            return PopupMenuButton<String>(
              onSelected: (value) {},
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    onTap: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => EditGoalsScreen(
                      //       goalsanddream: widget.goalsanddream,
                      //     ),
                      //   ),
                      // );
                    },
                    value: 'Edit',
                    child: Text(
                      'Edit',
                      style: CustomTextStyles.bodyMedium14,
                    ),
                  ),
                  PopupMenuItem<String>(
                    onTap: () {
                      // customPopup(
                      //   context: context,
                      //   onPressedDelete: () {
                      //     goalsDreamsProvider.deleteGoalsFunction(
                      //       deleteId: id,
                      //     );
                      //     Navigator.of(context).pop();
                      //     Navigator.of(context).pop();
                      //   },
                      //   title: 'Confirm Delete',
                      //   content: 'Are you sure You want to Delete this Goal ?',
                      // );
                    },
                    value: 'Delete',
                    child: Text(
                      'Delete',
                      style: CustomTextStyles.bodyMedium14,
                    ),
                  ),
                ];
              },
            );
          },
        ),
      ],
    );
  }
}
