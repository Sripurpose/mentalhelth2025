import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/addgoals_dreams_screen.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/provider/goals_dreams_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/screens/goals_and_dreams_full_view/goals_and_dreams_full_view_screen.dart';
import 'package:mentalhelth/screens/goals_dreams_page/widgets/date_range_picker_screen_goals_and_dreams.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:mentalhelth/widgets/widget/shimmer.dart';
import 'package:provider/provider.dart';
import '../../utils/core/url_constant.dart';
import '../edit_add_profile_screen/provider/edit_provider.dart';
import '../goals_dreams_page/widgets/weightlosscomponentlist_item_widget.dart';
import '../home_screen/provider/home_provider.dart';
import '../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../token_expiry/tocken_expiry_warning_screen.dart';
import '../token_expiry/token_expiry.dart';

class GoalsDreamsPage extends StatefulWidget {
  const GoalsDreamsPage({Key? key}) : super(key: key);

  @override
  State createState() => _GoalsDreamsPageState();
}

class _GoalsDreamsPageState extends State {
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

  Future loadPage(int pageNo) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    goalsDreamsProvider.pageLoad = pageNo;
    await goalsDreamsProvider.fetchGoalsAndDreams(
      pageNo: pageNo.toString(),
      context: context,
      initial: pageNo == 1,
      fullList: true,
    );

    setState(() {
      currentPage = pageNo;
      isLoading = false;
    });
  }

  Future _isTokenExpired() async {
    await homeProvider.fetchJournals(initial: true, context: context);
    tokenStatus = TokenManager.checkTokenExpiry();
    if (tokenStatus) {
      setState(() {
        logger.e("Token status changed: $tokenStatus");
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    goalsDreamsProvider = Provider.of(context, listen: false);
    homeProvider = Provider.of(context, listen: false);
    mentalStrengthEditProvider = Provider.of(context, listen: false);
    dashBoardProvider = Provider.of(context, listen: false);
    editProfileProvider = Provider.of(context, listen: false);

    goalsDreamsProvider.goalsanddreams.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentPage = 1;
      goalsDreamsProvider.goalsanddreams.clear();
      goalsDreamsProvider.fetchGoalsAndDreams(
          pageNo: "1",
          context: context,
          initial: true,
          fullList: true
      );
      _isTokenExpired();
    });
    super.initState();
  }

  @override
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
            const SizedBox(height: 20),
            buildSearchAndDateBar(context, goalsDreamsProvider),
            const SizedBox(height: 15),

            // PREVIOUS BUTTON - Fixed positioning
            if (goalsDreamsProvider.goalsanddreams.isNotEmpty && currentPage > 1)
              Padding(
                padding: const EdgeInsets.only(right: 25.0, bottom: 10),
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: !isLoading
                        ? () async {
                      await loadPage(currentPage - 1);
                    }
                        : null,
                    child: SvgPicture.asset(
                      ImageConstant.previousScrollIconActive,
                    ),
                  ),
                ),
              ),

            // MAIN CONTENT AREA
            Expanded(
              child: Consumer<GoalsDreamsProvider>(
                builder: (context, goalsDreamsProvider, _) {
                  return Stack(
                    children: [
                      // LIST VIEW
                      Container(
                        color: goalsDreamsProvider.goalsanddreams.isEmpty
                            ? ColorsContent.homeBackGroundColor
                            : null,
                        padding: const EdgeInsets.symmetric(horizontal: 23),
                        margin: EdgeInsets.only(
                          bottom: goalsDreamsProvider.goalsanddreams.isNotEmpty ? 70 : 70,
                        ),
                        child: goalsDreamsProvider.goalsAndDreamsModelLoading
                            ? Center(
                          child: CupertinoActivityIndicator(
                            color: ColorsContent.newThemeColor,
                            radius: 15,
                          ),
                        )
                            : goalsDreamsProvider.goalsanddreams.isEmpty
                            ? Center(
                          child: SvgPicture.asset(
                            ImageConstant.homeSearchDataFoundGradient,
                            width: size.width * 0.90,
                            height: size.height * 0.40,
                          ),
                        )
                            : ListView.builder(
                          controller: _scrollController,
                          itemCount: goalsDreamsProvider.goalsanddreams.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                goalsDreamsProvider.openBoxFunction(index: index);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => GoalAndDreamFullViewScreen(
                                      goalsanddream: goalsDreamsProvider.goalsanddreams[index],
                                      indexs: index,
                                      goalStatus: goalsDreamsProvider.goalsanddreams[index].goalStatus ?? "",
                                    ),
                                  ),
                                );
                              },
                              child: WeightLossComponentListItemWidget(
                                image: goalsDreamsProvider.goalsanddreams[index].goalMedia.toString(),
                                headding: goalsDreamsProvider.goalsanddreams[index].goalTitle.toString(),
                                status: goalsDreamsProvider.goalsanddreams[index].goalStatus == "1",
                                startDate: goalsDreamsProvider.goalsanddreams[index].goalStartdate.toString(),
                                endDate: goalsDreamsProvider.goalsanddreams[index].goalEnddate.toString(),
                              ),
                            );
                          },
                        ),
                      ),

                      // PAGINATION COUNT - Bottom Left
                      if (goalsDreamsProvider.goalsanddreams.isNotEmpty)
                        Positioned(
                          bottom: 15,
                          left: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Text(
                                  () {
                                final totalCount = int.tryParse(
                                    goalsDreamsProvider.goalsAndDreamsModel?.totalCount.toString() ?? '0'
                                ) ?? 0;
                                final currentPageNum = int.tryParse(
                                    goalsDreamsProvider.goalsAndDreamsModel?.currentPage.toString() ?? '1'
                                ) ?? 1;
                                final pageCount = UrlConstant.paginationCount;
                                final startItem = ((currentPageNum - 1) * pageCount) + 1;
                                final endItem = (currentPageNum * pageCount) > totalCount ? totalCount : currentPageNum * pageCount;
                                return "$endItem of $totalCount";
                              }(),
                              style: const TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                      // LOAD MORE BUTTON - Bottom Center
                      if (goalsDreamsProvider.goalsanddreams.isNotEmpty &&
                          (goalsDreamsProvider.goalsAndDreamsModel?.pageCount ?? 1) > currentPage &&
                          !isLoading)
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () async {
                                await loadPage(currentPage + 1);
                              },
                              child: SvgPicture.asset(
                                ImageConstant.loadMoreScrollIconActive,
                              ),
                            ),
                          ),
                        ),

                      // ADD GOAL BUTTON
                      Positioned(
                        bottom: -20,
                        right: 25,
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: FloatingActionButton(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            highlightElevation: 0,
                            focusElevation: 0,
                            hoverElevation: 0,
                            splashColor: Colors.transparent,
                            foregroundColor: Colors.transparent,
                            shape: const CircleBorder(),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AddGoalsDreamsScreen(
                                    pageNo: currentPage.toString(),
                                  ),
                                ),
                              );
                            },
                            child: Image.asset(ImageConstant.addGoalPng),
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

  Widget buildSearchAndDateBar(
      BuildContext context,
      GoalsDreamsProvider goalsDreamsProvider,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
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
                  Expanded(
                    child: TextField(
                      controller: goalsDreamsProvider.searchController,
                      textInputAction: TextInputAction.search,
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
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: SvgPicture.asset(ImageConstant.goalsAndDreamsDateIcon),
            ),
          ),
        ],
      ),
    );
  }
}