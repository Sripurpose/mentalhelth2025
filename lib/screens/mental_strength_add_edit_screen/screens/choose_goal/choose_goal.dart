import 'package:flutter/cupertino.dart';
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
import '../../../no_internet/duplicate_screen.dart';

class ScreenChooseGoalMentalStrength extends StatefulWidget {
  const ScreenChooseGoalMentalStrength({super.key});

  @override
  State<ScreenChooseGoalMentalStrength> createState() =>
      _ScreenChooseGoalMentalStrengthState();
}

class _ScreenChooseGoalMentalStrengthState
    extends State<ScreenChooseGoalMentalStrength> {
  final ScrollController _scrollController = ScrollController();
  late TextEditingController _searchController;


  @override
  void dispose() {
    _searchController.clear();  // Clear the search text when disposing the page
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    MentalStrengthEditProvider mentalStrengthEditProvider =
        Provider.of<MentalStrengthEditProvider>(context, listen: false);
    mentalStrengthEditProvider.fetchGoals(initial: true);
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchController.clear();  // Clear the search text when disposing the page
      mentalStrengthEditProvider.searchQuery = "";
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
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(
            top: size.height * 0.07,
          ),
          decoration: BoxDecoration(
            color: ColorsContent.homeBackGroundColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
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
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Consumer2<MentalStrengthEditProvider, AdDreamsGoalsProvider>(
                        builder: (context, mentalStrengthEditProvider, adDreamsGoalsProvider, _) {
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
                                      color: ColorsContent.newThemeColor,
                                      height: 8,
                                      width: 8,
                                      fit: BoxFit.contain,
                                    ),
                                    SvgPicture.asset(
                                      ImageConstant.dotDot,
                                      color: ColorsContent.newThemeColor,
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
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(size.width * 0.03),
                        child: Consumer<MentalStrengthEditProvider>(
                          builder: (context, mentalStrengthEditProvider, _) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                mentalStrengthEditProvider.goalsValue.id != null
                                    ? const Text(
                                  "Choose Goal",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                )
                                    : const SizedBox(),
                                mentalStrengthEditProvider.goalsValue.id == null
                                    ? const SizedBox()
                                    : ElevatedButton(
                                  onPressed: () {
                                    mentalStrengthEditProvider.openChooseGoalFunction();
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
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Consumer<MentalStrengthEditProvider>(
                        builder: (context, mentalStrengthEditProvider, _) {
                          final goalsList = mentalStrengthEditProvider.goalsList;

                          final filteredGoals = goalsList.where((goal) {
                            final query = mentalStrengthEditProvider.searchQuery?.toLowerCase() ?? '';
                            return goal.title.toString().toLowerCase().contains(query);
                          }).toList();

                          // Update search controller's text only if it's changed
                          if (_searchController.text != mentalStrengthEditProvider.searchQuery) {
                            _searchController.text = mentalStrengthEditProvider.searchQuery ?? '';
                            _searchController.selection = TextSelection.collapsed(offset: _searchController.text.length);
                          }

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10),
                                child: TextFormField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    mentalStrengthEditProvider.updateSearchQuery(value);
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Find Goal",
                                    prefixIcon: const Icon(Icons.search),
                                    filled: true,
                                    fillColor: Colors.white, // 🎨 Change as needed
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10), // 🎯 Curved all 4 sides
                                      borderSide: BorderSide.none, // ❌ Remove visible border
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),


                              if (!mentalStrengthEditProvider.getGoalsModelLoading && filteredGoals.isEmpty)
                                Column(
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
                                )
                              else
                                SizedBox(
                                  height: size.height * 0.45,
                                  width: size.width * 0.8,
                                  child: ListView.separated(
                                    controller: _scrollController,
                                    separatorBuilder: (context, index) => const SizedBox(height: 3),
                                    itemCount: filteredGoals.length + (mentalStrengthEditProvider.getGoalsModelLoading ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index < filteredGoals.length) {
                                        return GestureDetector(
                                          onTap: () {},
                                          child: listGoalWidget(
                                            size: size,
                                            goals: filteredGoals,
                                            index: index,
                                          ),
                                        );
                                      } else if (mentalStrengthEditProvider.getGoalsModelLoading) {
                                        return CupertinoActivityIndicator(
                                          color: ColorsContent.newThemeColor,
                                          radius: 15,
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Floating Create New Goal Button
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Consumer<MentalStrengthEditProvider>(
              builder: (context, mentalStrengthEditProvider, _) {
                return ElevatedButton(
                  onPressed: () {
                    mentalStrengthEditProvider.openAddGoalFunction();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    backgroundColor: ColorsContent.newThemeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Create New Goal",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
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
        color: ColorsContent.chooseGoalActionColor,
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
                activeColor: ColorsContent.newThemeColor,
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
                    context: context
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
                      style: theme.textTheme.labelMedium,
                    ),
                    Text(
                      "  to  ",
                      style: theme.textTheme.labelMedium,
                    ),
                    Text(
                      goals[index].goalEnddate == ""
                          ? ""
                          : formatDate1(
                              int.parse(goals[index].goalEnddate.toString())),
                      style: theme.textTheme.labelMedium,
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
                  context: context
                );
                mentalStrengthEditProvider.openGoalViewSheetFunction();
              },
              child: CircleAvatar(
                radius: size.width * 0.03,
                backgroundColor: ColorsContent.newThemeColor,
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: size.width * 0.04,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
