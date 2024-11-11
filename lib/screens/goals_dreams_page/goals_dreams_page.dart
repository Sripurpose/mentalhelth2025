import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/addgoals_dreams_screen.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/provider/goals_dreams_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/provider/goals_dreams_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/screens/goals_and_dreams_full_view/goals_and_dreams_full_view_screen.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:mentalhelth/widgets/widget/shimmer.dart';
import 'package:provider/provider.dart';

import '../edit_add_profile_screen/provider/edit_provider.dart';
import '../goals_dreams_page/widgets/weightlosscomponentlist_item_widget.dart';
import '../home_screen/provider/home_provider.dart';
import '../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../token_expiry/tocken_expiry_warning_screen.dart';
import '../token_expiry/token_expiry.dart';

class GoalsDreamsPage extends StatefulWidget {
  const GoalsDreamsPage({Key? key})
      : super(
          key: key,
        );

  @override
  State<GoalsDreamsPage> createState() => _GoalsDreamsPageState();
}

class _GoalsDreamsPageState extends State<GoalsDreamsPage> {
  late HomeProvider homeProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late EditProfileProvider editProfileProvider;
  late DashBoardProvider dashBoardProvider;
  late GoalsDreamsProvider goalsDreamsProvider;
  bool tokenStatus = false;
  var logger = Logger();
  bool completed = false;
  final ScrollController _scrollController = ScrollController();
  int currentPage = 1; // State to track the current page
  void _onPageChanged(int newPage) {
    setState(() {
      currentPage = newPage;
    });

    goalsDreamsProvider.fetchGoalsAndDreams(pageNo: currentPage.toString()); // Fetch new data for the updated page
  }

  Future<void> _isTokenExpired() async {
    await homeProvider.fetchChartView(context);
    await homeProvider.fetchJournals(initial: true);
    //await editProfileProvider.fetchUserProfile();
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int photoCurrentIndex = 0;
  List<String> imageList = [];

  @override
  void initState() {
     goalsDreamsProvider = Provider.of<GoalsDreamsProvider>(context, listen: false,);
     homeProvider = Provider.of<HomeProvider>(context, listen: false);
     mentalStrengthEditProvider = Provider.of<MentalStrengthEditProvider>(context, listen: false);
     dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
     editProfileProvider = Provider.of<EditProfileProvider>(context, listen: false);
     goalsDreamsProvider.goalsanddreams.clear();
     goalsDreamsProvider.goalsanddreams = [];

     WidgetsBinding.instance.addPostFrameCallback((_) {
       goalsDreamsProvider.goalsanddreams = [];
       goalsDreamsProvider.goalsanddreams.clear();
       goalsDreamsProvider.fetchGoalsAndDreams(pageNo: currentPage.toString());
      // mentalStrengthEditProvider.fetchGoalActions(goalId: widget.goalsanddream.goalId.toString(),);
       _isTokenExpired();
     });

    _scrollController.addListener(_loadMoreData);
    super.initState();
  }

  void _loadMoreData() {
    GoalsDreamsProvider goalsDreamsProvider = Provider.of<GoalsDreamsProvider>(
      context,
      listen: false,
    );

    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      goalsDreamsProvider.fetchGoalsAndDreams();
    }

    if (_scrollController.position.pixels !=
            _scrollController.position.minScrollExtent &&
        _scrollController.position.pixels !=
            _scrollController.position.maxScrollExtent) {
      goalsDreamsProvider.scrollTrue(value: true);
    } else {
      goalsDreamsProvider.scrollTrue(value: false);
    }
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return tokenStatus == false
        ? SafeArea(
      child: backGroundImager(
        size: size,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Consumer<DashBoardProvider>(
                builder: (context, dashBoardProvider, _) {
                  return buildAppBar(
                    context,
                    size,
                    heading: "My Goals & Dreams",
                    onTap: () {
                      dashBoardProvider.changePage(index: 0);
                    },
                  );
                }),
            Expanded(
              child: Consumer<GoalsDreamsProvider>(
                  builder: (context, goalsDreamsProvider, _) {
                    return Stack(
                      children: [
                        Container(
                          color: goalsDreamsProvider.goalsanddreams.isEmpty
                              ? Colors.white
                              : null,
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: goalsDreamsProvider.goalsAndDreamsModelLoading
                              ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue),
                            ),
                          )
                              : goalsDreamsProvider.goalsanddreams.isEmpty
                              ? Center(
                            child: Image.asset(
                              ImageConstant.noData,
                            ),
                          )
                              : ListView.builder(
                            itemCount: goalsDreamsProvider.goalsanddreams.length +
                                (goalsDreamsProvider.goalsAndDreamsModelLoading ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < goalsDreamsProvider.goalsanddreams.length) {
                                return GestureDetector(
                                  onTap: () {
                                    goalsDreamsProvider.openBoxFunction(index: index);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => GoalAndDreamFullViewScreen(
                                          goalsanddream: goalsDreamsProvider.goalsanddreams[index],
                                          indexs: index,
                                          goalStatus: goalsDreamsProvider.goalsanddreams[index].goalStatus ?? "",
                                        )
                                      ),
                                    ).then((_) {
                                      // Fetch the correct page's data when coming back
                                      goalsDreamsProvider.fetchGoalsAndDreams(pageNo: currentPage.toString());
                                    });
                                   // currentPage = 1;
                                  },
                                  child: WeightLossComponentListItemWidget(
                                    image: goalsDreamsProvider.goalsanddreams[index].goalMedia.toString(),
                                    headding: goalsDreamsProvider.goalsanddreams[index].goalTitle.toString(),
                                    status: goalsDreamsProvider.goalsanddreams[index].goalStatus == "1" ? true : false,
                                    startDate: goalsDreamsProvider.goalsanddreams[index].goalStartdate.toString(),
                                    endDate: goalsDreamsProvider.goalsanddreams[index].goalEnddate.toString(),
                                  ),
                                );
                              } else if (goalsDreamsProvider.goalsAndDreamsModelLoading) {
                                return shimmerList(
                                  height: size.height,
                                  list: 10,
                                  shimmerHeight: size.height * 0.1,
                                );
                              } else {
                                return Center(
                                  child: Image.asset(
                                    ImageConstant.noData,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        goalsDreamsProvider.isScrolling
                            ? const SizedBox()
                            : Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Pagination Row
                              Padding(
                                padding: const EdgeInsets.only(bottom: 0.0),
                                child: GestureDetector(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(goalsDreamsProvider.goalsAndDreamsModel?.pageCount ?? 0, (index) {
                                      return GestureDetector(
                                        onTap: () {
                                          // Update the current page and fetch new data
                                          setState(() {
                                          goalsDreamsProvider.goalsanddreams.clear();
                                          _onPageChanged(index + 1);
                                          //  currentPage = index + 1;
                                          });
                                          goalsDreamsProvider.fetchGoalsAndDreams(pageNo: currentPage.toString());
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.all(4.0),
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: currentPage == index + 1 ? Colors.blue : Colors.grey, // Change color based on current page
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              // Update the current page and fetch new data
                                              setState(() {
                                                goalsDreamsProvider.goalsanddreams.clear();
                                                _onPageChanged(index + 1);
                                              // currentPage = index + 1;
                                              });
                                              goalsDreamsProvider.fetchGoalsAndDreams(pageNo: currentPage.toString());
                                            },
                                            child: Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),

                              // Create New Goals Button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorsContent.primaryColor,
                                ),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const AddGoalsDreamsScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Create New Goals",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
    )
        : const TokenExpireScreen();
  }


// /// Section Widget
// Widget _buildWeightLossComponentList(BuildContext context) {
//   return ListView.separated(
//     physics: const NeverScrollableScrollPhysics(),
//     shrinkWrap: true,
//     separatorBuilder: (
//       context,
//       index,
//     ) {
//       return const SizedBox(
//         height: 2,
//       );
//     },
//     itemCount: 1,
//     itemBuilder: (context, index) {
//       return const WeightLossComponentListItemWidget(
//         image: '',
//         headding: '',
//       );
//     },
//   );
// }
}

//////
