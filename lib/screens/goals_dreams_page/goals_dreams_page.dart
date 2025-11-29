import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/addgoals_dreams_screen.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/provider/goals_dreams_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/provider/goals_dreams_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/screens/goals_and_dreams_full_view/goals_and_dreams_full_view_screen.dart';
import 'package:mentalhelth/screens/goals_dreams_page/widgets/date_range_picker_screen_goals_and_dreams.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:mentalhelth/widgets/widget/shimmer.dart';
import 'package:provider/provider.dart';

import '../edit_add_profile_screen/provider/edit_provider.dart';
import '../goals_dreams_page/widgets/weightlosscomponentlist_item_widget.dart';
import '../home_screen/provider/home_provider.dart';
import '../home_screen/widgets/date_range_picker_screen.dart';
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

  int currentPage = 1;
  bool isLoading = false;

  Future<void> loadPage(int pageNo) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    // Keep provider in sync
    goalsDreamsProvider.pageLoad = pageNo;

    await goalsDreamsProvider.fetchGoalsAndDreams(
      pageNo: pageNo.toString(),
      context: context,
      initial: pageNo == 1, // reset only on first page
      fullList: true,
    );

    setState(() {
      currentPage = pageNo;
      isLoading = false;
    });
  }





  Future<void> _isTokenExpired() async {
    // await homeProvider.fetchChartView(context);
    await homeProvider.fetchJournals(initial: true, context: context);
    //await editProfileProvider.fetchUserProfile();
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int photoCurrentIndex = 0;
  List<String> imageList = [];

  @override
  void initState() {
    goalsDreamsProvider = Provider.of<GoalsDreamsProvider>(
      context,
      listen: false,
    );
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    mentalStrengthEditProvider =
        Provider.of<MentalStrengthEditProvider>(context, listen: false);
    dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
    editProfileProvider =
        Provider.of<EditProfileProvider>(context, listen: false);
    goalsDreamsProvider.goalsanddreams.clear();
    goalsDreamsProvider.goalsanddreams = [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentPage = 1;
      goalsDreamsProvider.goalsanddreams = [];
      goalsDreamsProvider.goalsanddreams.clear();
      goalsDreamsProvider.fetchGoalsAndDreams(
          pageNo: "1", context: context, initial: true, fullList: true);
      _isTokenExpired();
    });

    super.initState();
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
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    buildSearchAndDateBar(context, goalsDreamsProvider),
                    // 🔍 Add this here
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Previous Button
                            GestureDetector(
                              onTap: currentPage > 1 && !isLoading
                                  ? () async {
                                await loadPage(currentPage - 1);
                              }
                                  : null,
                              child:
                               currentPage > 1 ? SvgPicture.asset(ImageConstant.previousScrollIconActive): const SizedBox(),
                           //   SvgPicture.asset(ImageConstant.previousScrollIconActive),
                            ),


                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10,),
                    Expanded(
                      child: Consumer<GoalsDreamsProvider>(
                        builder: (context, goalsDreamsProvider, _) {
                          return Stack(
                            children: [
                              Container(
                                height: currentPage > 1 ? size.height * 0.50:size.height * 0.52,
                                color: goalsDreamsProvider.goalsanddreams.isEmpty
                                    ? ColorsContent.homeBackGroundColor
                                    : null,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 23),
                                child: goalsDreamsProvider
                                        .goalsAndDreamsModelLoading
                                    ? Center(
                                        child: CupertinoActivityIndicator(
                                        color: ColorsContent.newThemeColor,
                                        radius: 15,
                                      ))
                                    : goalsDreamsProvider.goalsanddreams.isEmpty
                                        ?
                                GestureDetector(
                                  onTap: () {},
                                  child: SvgPicture.asset(
                                    ImageConstant.homeSearchDataFoundGradient,
                                    width: size.width * 1.90,
                                    height: size.height * 0.50,
                                  ),
                                )
                                        : ListView.builder(
                                            itemCount: goalsDreamsProvider
                                                    .goalsanddreams.length +
                                                (goalsDreamsProvider
                                                        .goalsAndDreamsModelLoading
                                                    ? 1
                                                    : 0),
                                            itemBuilder: (context, index) {
                                              if (index <
                                                  goalsDreamsProvider
                                                      .goalsanddreams.length) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    goalsDreamsProvider
                                                        .openBoxFunction(
                                                            index: index);
                                                    Navigator.of(context)
                                                        .push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            GoalAndDreamFullViewScreen(
                                                          goalsanddream:
                                                              goalsDreamsProvider
                                                                      .goalsanddreams[
                                                                  index],
                                                          indexs: index,
                                                          goalStatus:
                                                              goalsDreamsProvider
                                                                      .goalsanddreams[
                                                                          index]
                                                                      .goalStatus ??
                                                                  "",
                                                        ),
                                                      ),
                                                    )
                                                        .then((_) {
                                                      // goalsDreamsProvider.fetchGoalsAndDreams(
                                                      //     pageNo: "1", context: context, initial: true, fullList: true);
                                                    });
                                                  },
                                                  child:
                                                      WeightLossComponentListItemWidget(
                                                    image: goalsDreamsProvider
                                                        .goalsanddreams[index]
                                                        .goalMedia
                                                        .toString(),
                                                    headding: goalsDreamsProvider
                                                        .goalsanddreams[index]
                                                        .goalTitle
                                                        .toString(),
                                                    status: goalsDreamsProvider
                                                                .goalsanddreams[
                                                                    index]
                                                                .goalStatus ==
                                                            "1"
                                                        ? true
                                                        : false,
                                                    startDate: goalsDreamsProvider
                                                        .goalsanddreams[index]
                                                        .goalStartdate
                                                        .toString(),
                                                    endDate: goalsDreamsProvider
                                                        .goalsanddreams[index]
                                                        .goalEnddate
                                                        .toString(),
                                                  ),
                                                );
                                              } else if (goalsDreamsProvider
                                                  .goalsAndDreamsModelLoading) {
                                                return shimmerList(
                                                  height: size.height,
                                                  list: 10,
                                                  shimmerHeight:
                                                      size.height * 0.1,
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
                              goalsDreamsProvider.goalsanddreams.isNotEmpty?
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 30.0,vertical: 70),
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child:  Container(
                                    // ⭐ DECORATION ADDED
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                    ),

                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 4),
                                      child: Text(
                                            () {
                                          // Parse values safely
                                          final totalCount = int.tryParse(
                                              goalsDreamsProvider.goalsAndDreamsModel?.totalCount.toString() ?? '0') ??
                                              0;
                                          final currentPage = int.tryParse(
                                              goalsDreamsProvider.goalsAndDreamsModel?.currentPage.toString() ?? '1') ??
                                              1;
                                          final pageCount = 10; // fixed items per page

                                          // Calculate start and end items
                                          final startItem = ((currentPage - 1) * pageCount) + 1;
                                          final endItem = (currentPage * pageCount) > totalCount
                                              ? totalCount
                                              : currentPage * pageCount;

                                          return "$endItem of $totalCount";
                                        }(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontFamily: 'Poppins',
                                          color: ColorsContent.blackText,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ):SizedBox(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 25.0),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 0),
                                    // Adjust the position
                                    child: SizedBox(
                                      width: 95, // Increase width
                                      height: 70, // Increase height
                                      child: FloatingActionButton(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        // removes shadow
                                        highlightElevation: 0,
                                        focusElevation: 0,
                                        hoverElevation: 0,
                                        splashColor: Colors.transparent,
                                        // disables ripple effect
                                        foregroundColor: Colors.transparent,
                                        shape: const CircleBorder(),
                                        // Ensures circular shape
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddGoalsDreamsScreen(
                                                pageNo: currentPage.toString(),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Image.asset(
                                          ImageConstant.addGoalPng,
                                          // Make sure this points to your PNG file
                                        //  fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Load More Button
                                      GestureDetector(
                                        onTap: (goalsDreamsProvider.goalsAndDreamsModel?.pageCount ?? 1) >
                                            currentPage && !isLoading
                                            ? () async {
                                          final next = currentPage + 1;
                                          await loadPage(next);
                                        }
                                            : null,
                                        child:
                                        (goalsDreamsProvider.goalsAndDreamsModel?.pageCount ?? 1) >
                                            currentPage
                                            ? SvgPicture.asset(ImageConstant.loadMoreScrollIconActive):const SizedBox(),
                                     //    SvgPicture.asset(ImageConstant.loadMoreScrollIconActive),

                                      ),
                                      const SizedBox(height: 10,),
                                      /// --------- "10 of 50" text below ---------



                                      const SizedBox(height: 15,),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
    )
        : const TokenExpireScreen();
  }

// 🔍 Search + Date Filter Bar
  Widget buildSearchAndDateBar(
      BuildContext context,
      GoalsDreamsProvider goalsDreamsProvider,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          // ⭐ SEARCH BOX
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SvgPicture.asset(ImageConstant.goalsAndDreamsSearchIcon),
                  const SizedBox(width: 10),

                  // 🔍 SEARCH FIELD
                  Expanded(
                    child: TextField(
                      controller: goalsDreamsProvider.searchController,
                      textInputAction: TextInputAction.search,
                      // readOnly: goalsDreamsProvider.selectedStartDate != null,

                      onSubmitted: (value) async {
                        goalsDreamsProvider.searchQuery = value;

                        await goalsDreamsProvider.fetchGoalsAndDreams(
                          initial: true,
                          context: context,
                          fullList: true,
                          keyword: value,
                          pageNo: "1",
                        );
                      },

                      decoration: InputDecoration(
                        hintText: "search goals",
                        hintStyle: TextStyle(
                          color: ColorsContent.searchHint,
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'Poppins',
                        ),
                        border: InputBorder.none,
                        isCollapsed: true,
                      ),
                    ),
                  ),

                  // ❌ CLEAR ICON
                  Consumer<GoalsDreamsProvider>(
                    builder: (context, provider, _) {
                      return provider.searchQuery.isNotEmpty
                          ? GestureDetector(
                        onTap: () async {
                          provider.searchController.clear();
                          provider.searchQuery = "";

                          await provider.fetchGoalsAndDreams(
                            initial: true,
                            context: context,
                            fullList: true,
                            keyword: "",
                            pageNo: "1",
                          );
                        },
                        child: Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            color: ColorsContent.newThemeColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.close_sharp,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                          : const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 📅 DATE PICKER ICON OUTSIDE BOX
          GestureDetector(
            onTap: () async {
              DateRangePickerGoalsAndDreamsScreen.show(
                context,
                onDateRangeSelected: (startDate, endDate) async {
                  goalsDreamsProvider.selectedStartDate = startDate;
                  goalsDreamsProvider.selectedEndDate = endDate;

                  goalsDreamsProvider.searchController.text =
                      goalsDreamsProvider.selectedDateRangeText;

                  await goalsDreamsProvider.fetchGoalsAndDreams(
                    initial: true,
                    context: context,
                    fromDateParam: startDate,
                    toDateParam: endDate,
                    fullList: false,
                  );
                },
              );

              // DateRangePickerGoalsAndDreamsScreen.show(
              //   context,
              //   onDateRangeSelected: (startDate, endDate) async {
              //     await goalsDreamsProvider.fetchGoalsAndDreams(
              //       initial: true,
              //       context: context,
              //       fromDateParam: startDate,
              //       toDateParam: endDate,
              //       fullList: false,
              //     );
              //
              //     goalsDreamsProvider.filterGoalsBySearch(
              //       goalsDreamsProvider.searchQuery,
              //     );
              //   },
              // );
            },
            child: SvgPicture.asset(ImageConstant.goalsAndDreamsDateIcon),
          ),
        ],
      ),
    );
  }

}
