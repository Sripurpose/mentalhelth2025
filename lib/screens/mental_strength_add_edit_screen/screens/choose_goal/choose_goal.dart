import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/get_goals_model.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/widgets/widget/shimmer.dart';
import 'package:provider/provider.dart';

import '../../../../utils/core/date_time_utils.dart';
import '../../../../utils/core/image_constant.dart';
import '../../../../utils/theme/colors.dart';
import '../../../../utils/theme/theme_helper.dart';
import '../../../../widgets/custom_image_view.dart';

class ScreenChooseGoalMentalStrength extends StatefulWidget {
  const ScreenChooseGoalMentalStrength({super.key});

  @override
  State<ScreenChooseGoalMentalStrength> createState() =>
      _ScreenChooseGoalMentalStrengthState();
}

class _ScreenChooseGoalMentalStrengthState
    extends State<ScreenChooseGoalMentalStrength> {
  final ScrollController _scrollController = ScrollController();


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    MentalStrengthEditProvider mentalStrengthEditProvider =
        Provider.of<MentalStrengthEditProvider>(context, listen: false);
    mentalStrengthEditProvider.fetchGoals(initial: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_loadMoreData);
    });
    super.initState();
  }

  void _loadMoreData() {
    MentalStrengthEditProvider mentalStrengthEditProvider =
        Provider.of<MentalStrengthEditProvider>(context, listen: false);

    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      mentalStrengthEditProvider.fetchGoals();
    }
    // }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(
        top: size.height * 0.15,
      ),
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
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: size.height * 0.015,
                ),
                Consumer2<MentalStrengthEditProvider, AdDreamsGoalsProvider>(
                    builder: (context, mentalStrengthEditProvider,
                        adDreamsGoalsProvider, _) {
                  return
                  //   Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     GestureDetector(
                  //       onTap: () {
                  //         mentalStrengthEditProvider.openChooseGoalFunction();
                  //         adDreamsGoalsProvider.clearAction();
                  //       },
                  //       child: CustomImageView(
                  //         imagePath: ImageConstant.imgClosePrimaryNew,
                  //         height: 40,
                  //         width: 40,
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       width: size.width * 0.03,
                  //     )
                  //   ],
                  // );
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: size.width * 0.2,
                      ),
                      SizedBox(
                        width: size.width * 0.2,
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              ImageConstant.dotDot,
                              color: ColorsContent.greyColor,
                              height: 8,
                              width: 8,
                              fit: BoxFit.contain,
                            ),
                            SvgPicture.asset(
                              ImageConstant.dotDot,
                              color: ColorsContent.greyColor,
                              height: 8,
                              width: 8,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            mentalStrengthEditProvider.openChooseGoalFunction();
                            adDreamsGoalsProvider.clearAction();
                          },
                          child: CustomImageView(
                            imagePath: ImageConstant.imgClosePrimaryNew,
                            height: 40,
                            width: 40,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Padding(
                  padding: EdgeInsets.all(
                    size.width * 0.03,
                  ),
                  child: Consumer<MentalStrengthEditProvider>(
                      builder: (context, mentalStrengthEditProvider, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          "Choose Goal",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        mentalStrengthEditProvider.goalsValue.id == null
                            ? const SizedBox()
                            : ElevatedButton(
                                onPressed: () {
                                  mentalStrengthEditProvider
                                      .openChooseGoalFunction();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Proceed",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ],
                    );
                  }),
                ),
                // SizedBox(
                //   height: size.height * 0.01,
                // ),
                Consumer<MentalStrengthEditProvider>(
                  builder: (context, mentalStrengthEditProvider, _) {
                    return SizedBox(
                      height: size.height * 0.45,
                      width: size.width * 0.8,
                      child: ListView.separated(
                        controller: _scrollController,
                        separatorBuilder: (
                          context,
                          index,
                        ) {
                          return const SizedBox(
                            height: 3,
                          );
                        },
                        itemCount: mentalStrengthEditProvider.goalsList.length +
                            (mentalStrengthEditProvider.getGoalsModelLoading
                                ? 1
                                : 0),
                        itemBuilder: (context, index) {
                          if (index <
                              mentalStrengthEditProvider.goalsList.length) {
                            return GestureDetector(
                              onTap: () {
                                // log("${homeProvider.journalsModelList![index].journalId}",
                                //     name: "journals List");
                                // Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //     builder: (context) => JournalViewScreen(
                                //       journalsModelList: homeProvider
                                //           .journalsModelList![index],
                                //       indexs: index,
                                //     ),
                                //   ),
                                // );
                              },
                              child: listGoalWidget(
                                size: size,
                                goals: mentalStrengthEditProvider.goalsList,
                                index: index,
                              ),
                            );
                          } else if (mentalStrengthEditProvider
                              .getGoalsModelLoading) {
                            return shimmerList(
                              height: size.height,
                              list: 10,
                              shimmerHeight: size.height * 0.07,
                            );
                          } else if (mentalStrengthEditProvider
                              .goalsList.isEmpty) {
                            return const SizedBox(
                              child: Center(
                                child: Text("No Data"),
                              ),
                            );
                          } else {
                            return const SizedBox(
                              child: Center(
                                child: Text("No Data"),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Consumer<MentalStrengthEditProvider>(
                    builder: (context, mentalStrengthEditProvider, _) {
                  return ElevatedButton(
                    onPressed: () {
                      mentalStrengthEditProvider.openAddGoalFunction();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Create New Goal",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget listGoalWidget(
      {required Size size, required List<Goal> goals, required int index}) {
    return Container(
      padding: EdgeInsets.all(
        size.width * 0.03,
      ),
      margin: const EdgeInsets.only(
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            width: size.width * 0.05,
            child: Consumer<MentalStrengthEditProvider>(
                builder: (context, mentalStrengthEditProvider, _) {
              return Checkbox(
                value:
                    mentalStrengthEditProvider.goalsValue.id == goals[index].id
                        ? true
                        : false,
                onChanged: (value) {
                  mentalStrengthEditProvider.addGoalValue(
                    value: goals[index],
                  );

                  mentalStrengthEditProvider.fetchGoalDetails(
                    goalId: goals[index].id.toString(),
                  );
                },
              );
            }),
          ),
          SizedBox(
            width: size.width * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: size.width * 0.5,
                  child: Text(
                    goals[index].title.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Row(
                  children: [
                    Text(
                      formatDate(
                          int.parse(goals[index].goalStartdate.toString())),
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      "  to  ",
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      goals[index].goalEnddate == ""
                          ? ""
                          : formatDate(
                              int.parse(goals[index].goalEnddate.toString())),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
              ],
            ),
          ),
          Consumer<MentalStrengthEditProvider>(
              builder: (context, mentalStrengthEditProvider, _) {
            return GestureDetector(
              onTap: () async {
                await mentalStrengthEditProvider.fetchGoalDetails(
                  goalId: goals[index].id.toString(),
                );
                mentalStrengthEditProvider.openGoalViewSheetFunction();
              },
              child: CircleAvatar(
                radius: size.width * 0.03,
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.white,
                  size: size.width * 0.03,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
