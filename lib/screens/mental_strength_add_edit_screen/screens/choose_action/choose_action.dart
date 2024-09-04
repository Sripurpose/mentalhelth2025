import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/get_goals_model.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/list_goal_actions.dart'
    as action;
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:provider/provider.dart';

import '../../../../utils/core/date_time_utils.dart';
import '../../../../utils/theme/theme_helper.dart';

class ChooseActionMentalHelth extends StatefulWidget {
  const ChooseActionMentalHelth({super.key, required this.goal});

  final Goal goal;

  @override
  State<ChooseActionMentalHelth> createState() =>
      _ChooseActionMentalHelthState();
}

class _ChooseActionMentalHelthState extends State<ChooseActionMentalHelth> {
  @override
  void initState() {
    MentalStrengthEditProvider mentalStrengthEditProvider =
        Provider.of<MentalStrengthEditProvider>(context, listen: false);

    mentalStrengthEditProvider.fetchGoalActions(
      goalId: widget.goal.id.toString(),
    );
    super.initState();
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
                  height: size.height * 0.01,
                ),
                Consumer<MentalStrengthEditProvider>(
                    builder: (context, mentalStrengthEditProvider, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          mentalStrengthEditProvider.openChooseActionFunction();
                        },
                        child: const CircleAvatar(
                          radius: 13,
                          child: Icon(
                            Icons.close,
                            size: 17,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.03,
                      )
                    ],
                  );
                }),
                // SizedBox(
                //   height: size.height * 0.01,
                // ),
                Padding(
                  padding: EdgeInsets.all(
                    size.width * 0.02,
                  ),
                  child: Consumer<MentalStrengthEditProvider>(
                      builder: (context, mentalStrengthEditProvider, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Choose Actions",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.003,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text(
                                  "Goal: ",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(widget.goal.title.toString()),
                              ],
                            ),
                          ],
                        ),
                        mentalStrengthEditProvider.goalsValue.id == null
                            ? const SizedBox()
                            : ElevatedButton(
                                onPressed: () {
                                  mentalStrengthEditProvider
                                      .openChooseActionFunction();
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
                SizedBox(
                  height: size.height * 0.01,
                ),
                Consumer<MentalStrengthEditProvider>(
                  builder: (context, mentalStrengthEditProvider, _) {
                    return SizedBox(
                      height: size.height * 0.44,
                      width: size.width * 0.8,
                      child: mentalStrengthEditProvider
                                  .getListGoalActionsModel ==
                              null
                          ? const SizedBox()
                          : mentalStrengthEditProvider
                                      .getListGoalActionsModel!.actions ==
                                  null
                              ? const SizedBox()
                              : ListView.separated(
                                  separatorBuilder: (
                                    context,
                                    index,
                                  ) {
                                    return const SizedBox(
                                      height: 3,
                                    );
                                  },
                                  itemCount: mentalStrengthEditProvider
                                          .getListGoalActionsModel!
                                          .actions!
                                          .length +
                                      (mentalStrengthEditProvider
                                              .getListGoalActionsModelLoading
                                          ? 1
                                          : 0),
                                  itemBuilder: (context, index) {
                                    if (index <
                                        mentalStrengthEditProvider
                                            .getListGoalActionsModel!
                                            .actions!
                                            .length) {
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
                                        child: listActionList(
                                          size: size,
                                          action: mentalStrengthEditProvider
                                              .getListGoalActionsModel!
                                              .actions!,
                                          index: index,
                                        ),
                                      );
                                    } else if (mentalStrengthEditProvider
                                        .getListGoalActionsModel!
                                        .actions!
                                        .isEmpty) {
                                      return const SizedBox(
                                        child: Center(
                                          child: Text("No Data"),
                                        ),
                                      );
                                    } else {
                                      return const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                          child: CircularProgressIndicator(),
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
                      mentalStrengthEditProvider.openAddActionFunction();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Create New Action",
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

  Widget listActionList(
      {required Size size,
      required List<action.Action> action,
      required int index}) {
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: size.width * 0.1,
            child: Consumer<MentalStrengthEditProvider>(
                builder: (context, mentalStrengthEditProvider, _) {
              return Checkbox(
                value: mentalStrengthEditProvider.actionList.any(
                  (element) => element.id == action[index].id.toString(),
                ),
                onChanged: (value) {
                  mentalStrengthEditProvider.addActionFunction(
                    value: action[index],
                  );
                  // mentalStrengthEditProvider.fetchGoalDetails(
                  //   goalId: action[index].id.toString(),
                  // );
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
                Text(
                  action[index].title.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.005,
                ),
                Text(
                  formatDate(int.parse(action[index].actionDate.toString())),
                  style: theme.textTheme.bodySmall,
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
              ],
            ),
          ),
          const Spacer(),
          Consumer<MentalStrengthEditProvider>(
              builder: (context, mentalStrengthEditProvider, _) {
            return GestureDetector(
              onTap: () async {
                await mentalStrengthEditProvider.fetchActionDetails(
                  actionId: action[index].id.toString(),
                );
                mentalStrengthEditProvider.openActionFullViewFunction();
              },
              child: CircleAvatar(
                radius: size.width * 0.03,
                backgroundColor:
                    mentalStrengthEditProvider.actionsDetailsModelLoading
                        ? Colors.blue[50]
                        : Colors.blue,
                child: mentalStrengthEditProvider.actionsDetailsModelLoading
                    ? const CircularProgressIndicator()
                    : Icon(
                        (Icons.arrow_forward_ios_outlined),
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
