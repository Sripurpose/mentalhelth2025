import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/goals_dreams_page/model/goals_and_dreams_model.dart';
import 'package:mentalhelth/screens/goals_dreams_page/screens/actions_full_view/actions_full_view.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/utils/logic/date_format.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/widgets/custom_checkbox_button.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/functions/popup.dart';
import 'package:provider/provider.dart';

import '../../../utils/theme/theme_helper.dart';
import '../../addactions_screen/provider/add_actions_provider.dart';
import '../provider/goals_dreams_provider.dart';

class GoalsListWidget extends StatefulWidget {
  const GoalsListWidget(
      {super.key, required this.goalsanddreams, required this.index});

  final List<Goalsanddream> goalsanddreams;
  final int index;

  @override
  State<GoalsListWidget> createState() => _GoalsListWidgetState();
}

class _GoalsListWidgetState extends State<GoalsListWidget> {
  int selectedIndexAction = -1;

  void changeSelectedIndexAction({required int index}) {
    setState(() {
      selectedIndexAction = index;
    });
  }

  @override
  void initState() {
    addImage();
    MentalStrengthEditProvider mentalStrengthEditProvider =
        Provider.of<MentalStrengthEditProvider>(
      context,
      listen: false,
    );
    mentalStrengthEditProvider.fetchGoalActions(
        goalId: widget.goalsanddreams[widget.index].goalId.toString());
    super.initState();
  }

  bool isCompleted = false;

  PageController photoController = PageController();
  int photoCurrentIndex = 0;
  List<String> imageList = [];

  void addImage() {
    for (int i = 0;
        i < widget.goalsanddreams[widget.index].gemMedia!.length;
        i++) {
      if (widget.goalsanddreams[widget.index].gemMedia![i].mediaType ==
          'image') {
        imageList.add(widget.goalsanddreams[widget.index].gemMedia![i].gemMedia
            .toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: AppDecoration.outlineGray100WithOpacity08.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.goalsanddreams[widget.index].goalTitle
                            .toString(),
                        style: CustomTextStyles.titleMedium16,
                      ),
                      Text(
                        "${dateFormatter(
                          date: widget.goalsanddreams[widget.index]
                                          .goalStartdate ==
                                      null ||
                                  widget.goalsanddreams[widget.index]
                                          .goalStartdate ==
                                      ""
                              ? DateTime.now().toString()
                              : widget
                                  .goalsanddreams[widget.index].goalStartdate
                                  .toString(),
                        )} to ${dateFormatter(
                          date: widget.goalsanddreams[widget.index]
                                          .goalEnddate ==
                                      null ||
                                  widget.goalsanddreams[widget.index]
                                          .goalEnddate ==
                                      ""
                              ? DateTime.now().toString()
                              : widget.goalsanddreams[widget.index].goalEnddate
                                  .toString(),
                        )}",
                        style: CustomTextStyles.bodySmallGray700_1,
                      ),
                    ],
                  ),
                ),
                // Consumer<GoalsDreamsProvider>(
                //   builder: (context, goalsDreamsProvider, _) {
                //     return PopupMenuButton<String>(
                //       onSelected: (value) {
                //         print('Selected: $value');
                //       },
                //       itemBuilder: (BuildContext context) {
                //         return [
                //           PopupMenuItem<String>(
                //             onTap: () {
                //               goalsDreamsProvider.deleteGoalsFunction(
                //                 deleteId: widget
                //                     .goalsanddreams![widget.index].goalId
                //                     .toString(),
                //               );
                //             },
                //             value: 'Delete',
                //             child: Text(
                //               'Delete',
                //               style: CustomTextStyles.bodyMedium14,
                //             ),
                //           ),
                //         ];
                //       },
                //     );
                //   },
                // ),
              ],
            ),
          ),
          SizedBox(
            height: size.height * 0.03,
          ),
          SizedBox(
            height: imageList.isNotEmpty ? size.height * 0.2 : 0,
            child: Stack(
              children: [
                PageView.builder(
                  controller: photoController,
                  itemCount: imageList.length,
                  itemBuilder: (context, index) {
                    return CustomImageView(
                      fit: BoxFit.cover,
                      imagePath: imageList[index],
                      height: size.height * 0.27,
                      width: size.width,
                      alignment: Alignment.center,
                    );
                  },
                  onPageChanged: (int pageIndex) {
                    setState(() {
                      photoCurrentIndex = pageIndex;
                    });
                  },
                ),
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    width: imageList.length * size.width * 0.1,
                    child: buildIndicators(
                      imageList.length,
                      photoCurrentIndex,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Consumer<MentalStrengthEditProvider>(
            builder: (context, mentalStrengthEditProvider, _) {
              return mentalStrengthEditProvider.getListGoalActionsModel == null
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.only(left: 9, top: 10),
                      child: Text(
                        "Related Actions",
                        style: theme.textTheme.titleSmall,
                      ),
                    );
            },
          ),
          const SizedBox(height: 6),
          Consumer3<MentalStrengthEditProvider, AddActionsProvider,
                  GoalsDreamsProvider>(
              builder: (context, mentalStrengthEditProvider, addActionsProvider,
                  goalsDreamsProvider, _) {
            return mentalStrengthEditProvider.getListGoalActionsModel == null
                ? const SizedBox()
                : SizedBox(
                    height: mentalStrengthEditProvider
                            .getListGoalActionsModel!.actions!.length *
                        size.height *
                        0.055,
                    width: size.width * 0.8,
                    child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: mentalStrengthEditProvider
                            .getListGoalActionsModel!.actions!.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              mentalStrengthEditProvider
                                          .getListGoalActionsModel!
                                          .actions![index]
                                          .actionStatus ==
                                      "1"
                                  ? Checkbox(value: true, onChanged: (value) {})
                                  : Checkbox(
                                      value: selectedIndexAction == index
                                          ? true
                                          : false,
                                      onChanged: (value) async {
                                        customPopup(
                                          context: context,
                                          onPressedDelete: () async {
                                            changeSelectedIndexAction(
                                              index: index,
                                            );
                                            await addActionsProvider
                                                .updateActionStatusFunction(
                                              context,
                                              goalId: mentalStrengthEditProvider
                                                  .getListGoalActionsModel!
                                                  .goalId
                                                  .toString(),
                                              actionId:
                                                  mentalStrengthEditProvider
                                                      .getListGoalActionsModel!
                                                      .actions![index]
                                                      .id
                                                      .toString(),
                                            );
                                            goalsDreamsProvider.fetchGoalsAndDreams(
                                                pageNo: "1", context: context, initial: true, fullList: true);
                                            Navigator.of(context).pop();
                                          },
                                          yes: "Yes",
                                          title: 'Action Completed',
                                          content:
                                              'Are you sure You want to mark this action as completed?',
                                        );
                                      },
                                    ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ActionsFullView(
                                        id: mentalStrengthEditProvider
                                            .getListGoalActionsModel!
                                            .actions![index]
                                            .id
                                            .toString(),
                                        indexs: index,
                                        action: mentalStrengthEditProvider
                                            .getListGoalActionsModel!
                                            .actions![index],
                                        goalId: widget
                                            .goalsanddreams[widget.index].goalId
                                            .toString(),
                                        actionStatus: mentalStrengthEditProvider
                                            .getListGoalActionsModel!
                                            .actions![index]
                                            .actionStatus
                                            .toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: size.height * 0.04,
                                  width: size.width * 0.6,
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
                                        mentalStrengthEditProvider
                                            .getListGoalActionsModel!
                                            .actions![index]
                                            .title
                                            .toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.grey,
                                        ),
                                      ),
                                      CircleAvatar(
                                        radius: size.width * 0.04,
                                        backgroundColor: ColorsContent.newThemeColor,
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
                        }),
                  );
          }),
          const SizedBox(height: 2),
          const SizedBox(height: 23),
          widget.goalsanddreams[widget.index].goalStatus == "1"
              ? const Padding(
                  padding: EdgeInsets.only(left: 13),
                  child: Text(
                    "Completed",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                    // style: theme.textTheme.titleSmall,
                  ),
                )
              : Consumer<GoalsDreamsProvider>(
                  builder: (context, goalsDreamsProvider, _) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 13),
                    child: CustomCheckboxButton(
                      text: "Mark this goal as Completed",
                      value: isCompleted,
                      onChange: (value) {
                        customPopup(
                          context: context,
                          onPressedDelete: () async {
                            await goalsDreamsProvider.updateGoalsStatus(
                              context,
                              goalId: widget.goalsanddreams[widget.index].goalId
                                  .toString(),
                              status: "1",
                            );
                            goalsDreamsProvider.fetchGoalsAndDreams(
                                pageNo: "1", context: context, initial: true, fullList: true);
                            Navigator.of(context).pop();
                          },
                          yes: "Yes",
                          title: 'Goal Completed',
                          content:
                              'Are you sure You want to mark this goal as completed?',
                        );
                        setState(() {
                          isCompleted = true;
                        });
                      },
                    ),
                  );
                }),
          const SizedBox(height: 13),
        ],
      ),
    );
  }

  Widget buildIndicators(int pageCount, int currentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        pageCount,
        (index) {
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == currentIndex ? ColorsContent.newThemeColor : Colors.grey,
            ),
          );
        },
      ),
    );
  }
}
