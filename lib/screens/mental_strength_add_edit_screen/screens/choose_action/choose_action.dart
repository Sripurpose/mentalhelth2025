import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/get_goals_model.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/list_goal_actions.dart'
    as action;
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:provider/provider.dart';

import '../../../../utils/core/date_time_utils.dart';
import '../../../../utils/core/image_constant.dart';
import '../../../../utils/theme/colors.dart';
import '../../../../utils/theme/theme_helper.dart';
import '../../../../widgets/custom_image_view.dart';
import '../../../dash_borad_screen/provider/dash_board_provider.dart';
import '../../../edit_add_profile_screen/provider/edit_provider.dart';
import '../../../home_screen/provider/home_provider.dart';
import '../../../no_internet/duplicate_screen.dart';
import '../../../token_expiry/tocken_expiry_warning_screen.dart';
import '../../../token_expiry/token_expiry.dart';

class ChooseActionMentalHelth extends StatefulWidget {
  const ChooseActionMentalHelth({super.key, required this.goal});

  final Goal goal;

  @override
  State<ChooseActionMentalHelth> createState() =>
      _ChooseActionMentalHelthState();
}

class _ChooseActionMentalHelthState extends State<ChooseActionMentalHelth> {
  late HomeProvider homeProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late EditProfileProvider editProfileProvider;
  late DashBoardProvider dashBoardProvider;
  bool tokenStatus = false;
  var logger = Logger();

  Future<void> _isTokenExpired() async {
 //   await homeProvider.fetchChartView(context);
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
     mentalStrengthEditProvider =
        Provider.of<MentalStrengthEditProvider>(context, listen: false);

     WidgetsBinding.instance.addPostFrameCallback((_) {
       mentalStrengthEditProvider.fetchGoalActions(
         goalId: widget.goal.id.toString(),
       );
       _isTokenExpired();
     });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return tokenStatus == false
        ? Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: size.height * 0.04),
          decoration: BoxDecoration(
            color: ColorsContent.homeBackGroundColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(25),
              topLeft: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100), // add padding for the button
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 8),
                      Consumer<MentalStrengthEditProvider>(
                          builder: (context, mentalStrengthEditProvider, _) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(width: size.width * 0.2),
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
                                      mentalStrengthEditProvider.openChooseActionFunction();
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
                      Padding(
                        padding: EdgeInsets.all(size.width * 0.02),
                        child: Consumer<MentalStrengthEditProvider>(
                            builder: (context, mentalStrengthEditProvider, _) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (mentalStrengthEditProvider.getListGoalActionsModel != null &&
                                          mentalStrengthEditProvider.getListGoalActionsModel!.actions != null &&
                                          mentalStrengthEditProvider
                                              .getListGoalActionsModel!.actions!.isNotEmpty)
                                        const Text(
                                          "Choose Actions",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      SizedBox(height: size.height * 0.003),
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
                                          SizedBox(
                                            width: size.width * 0.4,
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Text(
                                                widget.goal.title.toString(),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (mentalStrengthEditProvider
                                      .getListGoalActionsModel!.actions!.isNotEmpty)
                                    ElevatedButton(
                                      onPressed: () {
                                        mentalStrengthEditProvider.openChooseActionFunction();
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
                      const SizedBox(height: 10),
                      Consumer<MentalStrengthEditProvider>(
                        builder: (context, mentalStrengthEditProvider, _) {
                          final actionsList =
                              mentalStrengthEditProvider.getListGoalActionsModel?.actions;

                          if (actionsList == null) return const SizedBox();

                          if (actionsList.isEmpty) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(ImageConstant.noDataNumu),
                                const Text(
                                  "No data found",
                                  style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Check back later",
                                  style: TextStyle(fontSize: 18, color: Colors.black),
                                ),
                              ],
                            );
                          }

                          return SizedBox(
                            height: size.height * 0.44,
                            width: size.width * 0.8,
                            child: ListView.separated(
                              separatorBuilder: (context, index) => const SizedBox(height: 3),
                              itemCount: actionsList.length +
                                  (mentalStrengthEditProvider.getListGoalActionsModelLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index < actionsList.length) {
                                  return GestureDetector(
                                    onTap: () {},
                                    child: listActionList(
                                      size: size,
                                      action: actionsList,
                                      index: index,
                                    ),
                                  );
                                } else if (mentalStrengthEditProvider.getListGoalActionsModelLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Floating Create Action Button
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Consumer<MentalStrengthEditProvider>(
              builder: (context, mentalStrengthEditProvider, _) {
                return ElevatedButton(
                  onPressed: () {
                    mentalStrengthEditProvider.openAddActionFunction();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    backgroundColor: ColorsContent.newThemeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Create New Action",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    )
        : const TokenExpireScreen();
  }


  // @override
  // Widget build(BuildContext context) {
  //   Size size = MediaQuery.of(context).size;
  //   return tokenStatus == false ?
  //   Container(
  //   margin: EdgeInsets.only(
  //     top: size.height * 0.04,
  //   ),
  //   decoration: BoxDecoration(
  //     color: ColorsContent.homeBackGroundColor,
  //     borderRadius: const BorderRadius.only(
  //       topRight: Radius.circular(
  //         25,
  //       ),
  //       topLeft: Radius.circular(
  //         25,
  //       ),
  //     ),
  //     boxShadow: [
  //       BoxShadow(
  //         color: Colors.grey.withOpacity(0.5), // Shadow color
  //         spreadRadius: 5, // Spread radius
  //         blurRadius: 7, // Blur radius
  //         offset: const Offset(0, 3), // Offset
  //       ),
  //     ],
  //   ),
  //   child: Column(
  //     children: [
  //       SingleChildScrollView(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.max,
  //           children: [
  //             SizedBox(
  //               height: size.height * 0.01,
  //             ),
  //             Consumer<MentalStrengthEditProvider>(
  //                 builder: (context, mentalStrengthEditProvider, _) {
  //               return
  //
  //
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   SizedBox(
  //                     width: size.width * 0.2,
  //                   ),
  //                   SizedBox(
  //                     width: size.width * 0.2,
  //                     child: Column(
  //                       children: [
  //                         SvgPicture.asset(
  //                           ImageConstant.dotDot,
  //                           color: ColorsContent.greyColor,
  //                           height: 8,
  //                           width: 8,
  //                           fit: BoxFit.contain,
  //                         ),
  //                         SvgPicture.asset(
  //                           ImageConstant.dotDot,
  //                           color: ColorsContent.greyColor,
  //                           height: 8,
  //                           width: 8,
  //                           fit: BoxFit.contain,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(horizontal: 10.0),
  //                     child:                 GestureDetector(
  //                       onTap: () {
  //                         mentalStrengthEditProvider.openChooseActionFunction();
  //                       },
  //                       child: CustomImageView(
  //                         imagePath: ImageConstant.imgClosePrimaryNew,
  //                         height: 40,
  //                         width: 40,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               );
  //             }),
  //             // SizedBox(
  //             //   height: size.height * 0.01,
  //             // ),
  //             Padding(
  //               padding: EdgeInsets.all(
  //                 size.width * 0.02,
  //               ),
  //               child: Consumer<MentalStrengthEditProvider>(
  //                   builder: (context, mentalStrengthEditProvider, _) {
  //                 return Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   children: [
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         mentalStrengthEditProvider.getListGoalActionsModel != null &&
  //                             mentalStrengthEditProvider.getListGoalActionsModel!.actions != null &&
  //                             mentalStrengthEditProvider.getListGoalActionsModel!.actions!.isNotEmpty
  //                             ? const Text(
  //                           "Choose Actions",
  //                           style: TextStyle(
  //                             fontSize: 18,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ):
  //                             SizedBox(),
  //                         SizedBox(
  //                           height: size.height * 0.003,
  //                         ),
  //                         Row(
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           children: [
  //                             const Text(
  //                               "Goal: ",
  //                               style: TextStyle(
  //                                 fontSize: 18,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                             SizedBox(
  //                                 width:size.width * 0.40,
  //                                 child: SingleChildScrollView(
  //                                     scrollDirection: Axis.horizontal, // Enable horizontal scrolling
  //                                     child: Text(widget.goal.title.toString(),
  //                                       textAlign: TextAlign.center,
  //                                       overflow: TextOverflow.ellipsis, // Add this line if you want to truncate long text
  //                                       maxLines: 1, // Limit to 1 line for ho
  //                                     ),)),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                     mentalStrengthEditProvider
  //                         .getListGoalActionsModel!.actions!.isEmpty
  //                         ? const SizedBox()
  //                         : ElevatedButton(
  //                             onPressed: () {
  //                               mentalStrengthEditProvider
  //                                   .openChooseActionFunction();
  //                             },
  //                             style: ElevatedButton.styleFrom(
  //                               backgroundColor: Colors.black,
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(10),
  //                               ),
  //                             ),
  //                             child: const Text(
  //                               "Proceed",
  //                               style: TextStyle(
  //                                 color: Colors.white,
  //                                 fontWeight: FontWeight.bold,
  //                               ),
  //                             ),
  //                           ),
  //                   ],
  //                 );
  //               }),
  //             ),
  //             SizedBox(
  //               height: size.height * 0.01,
  //             ),
  //             Consumer<MentalStrengthEditProvider>(
  //               builder: (context, mentalStrengthEditProvider, _) {
  //                 final actionsList = mentalStrengthEditProvider.getListGoalActionsModel?.actions;
  //
  //                 if (actionsList == null) {
  //                   return const SizedBox(); // If the data model is null, return nothing
  //                 }
  //
  //                 if (actionsList.isEmpty) {
  //                   return Column(
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       SvgPicture.asset(
  //                         ImageConstant.noDataNumu,
  //                       ),
  //                       const Text("No data found",
  //                           style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
  //                       const SizedBox(height: 10),
  //                       const Text("Check back later",
  //                           style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.normal)),
  //                     ],
  //                   );
  //                 }
  //
  //                 return SizedBox(
  //                   height: size.height * 0.44,
  //                   width: size.width * 0.8,
  //                   child: ListView.separated(
  //                     separatorBuilder: (context, index) => const SizedBox(height: 3),
  //                     itemCount: actionsList.length +
  //                         (mentalStrengthEditProvider.getListGoalActionsModelLoading ? 1 : 0),
  //                     itemBuilder: (context, index) {
  //                       if (index < actionsList.length) {
  //                         return GestureDetector(
  //                           onTap: () {},
  //                           child: listActionList(
  //                             size: size,
  //                             action: actionsList,
  //                             index: index,
  //                           ),
  //                         );
  //                       } else if (mentalStrengthEditProvider.getListGoalActionsModelLoading) {
  //                         return const Center(
  //                           child: CircularProgressIndicator(), // Show loading indicator
  //                         );
  //                       }
  //                       return null; // Ensures all cases are handled
  //                     },
  //                   ),
  //                 );
  //               },
  //             ),
  //
  //             SizedBox(
  //               height: size.height * 0.05,
  //             ),
  //             Consumer<MentalStrengthEditProvider>(
  //                 builder: (context, mentalStrengthEditProvider, _) {
  //               return ElevatedButton(
  //                 onPressed: () {
  //                   mentalStrengthEditProvider.openAddActionFunction();
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: ColorsContent.newThemeColor,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(20),
  //                   ),
  //                 ),
  //                 child: const Text(
  //                   "Create New Action",
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //               );
  //             }),
  //           ],
  //         ),
  //       ),
  //     ],
  //   ),
  //       ):
  //   const TokenExpireScreen();
  // }

  Widget listActionList({
    required Size size,
    required List<action.Action> action,
    required int index,
  }) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.03),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: ColorsContent.chooseGoalActionColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: size.width * 0.1,
            child: Consumer<MentalStrengthEditProvider>(
              builder: (context, mentalStrengthEditProvider, _) {
                return Checkbox(
                  value: mentalStrengthEditProvider.actionList.contains(action[index]),
                  onChanged: (value) {
                    mentalStrengthEditProvider.addActionFunction(value: action[index]);
                  },
                );
              },
            ),
          ),
          SizedBox(
            width: size.width * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: size.width * 0.55,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      action[index].title.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.005),
                Text(
                  formatDate(int.parse(action[index].actionDate.toString())),
                  style: theme.textTheme.bodySmall,
                ),
                SizedBox(height: size.height * 0.01),
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
                  // mentalStrengthEditProvider.actionsDetailsModelLoading
                  //     ?
                  // Colors.blue[50]
                  //     :
                  ColorsContent.newThemeColor,
                  child:
                  // mentalStrengthEditProvider.actionsDetailsModelLoading
                  //     ?
                  // const CircularProgressIndicator()
                  //     :
                  Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: size.width * 0.04,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

}
