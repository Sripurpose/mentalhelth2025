import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/screens/journal_list_screen/widgets/chart_view_list.dart';
import 'package:mentalhelth/screens/journal_list_screen/widgets/date_range_picker_screen_journal_list.dart';
import 'package:mentalhelth/screens/journal_list_screen/widgets/journal_list_view_widget.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:provider/provider.dart';

import '../../utils/core/image_constant.dart';
import '../../utils/core/url_constant.dart';
import '../edit_add_profile_screen/provider/edit_provider.dart';
import '../goals_dreams_page/provider/goals_dreams_provider.dart';
import '../goals_dreams_page/widgets/date_range_picker_screen_goals_and_dreams.dart';
import '../token_expiry/tocken_expiry_warning_screen.dart';
import '../token_expiry/token_expiry.dart';
import 'provider/journal_list_provider.dart';

class JournalListPage extends StatefulWidget {
  const JournalListPage({Key? key}) : super(key: key);

  @override
  _JournalListPageState createState() => _JournalListPageState();
}

class _JournalListPageState extends State<JournalListPage> {
  late HomeProvider homeProvider;
  late DashBoardProvider dashBoardProvider;
  late EditProfileProvider editProfileProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  bool tokenStatus = false;
  var logger = Logger();

  int currentPage = 1;
  bool isLoading = false;

  Future<void> loadPage(int pageNo) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    homeProvider.pageLoad = pageNo;

    await homeProvider.fetchJournals(
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

  Future<void> _isTokenExpired() async {
    await homeProvider.fetchJournals(
        initial: true, context: context, fullList: true);
    await homeProvider.fetchJournalsGridView(initial: true, context: context);
    await editProfileProvider.fetchUserProfile(context);
    tokenStatus = TokenManager.checkTokenExpiry();
    if (tokenStatus) {
      setState(() {
        logger.e("Token status changed: $tokenStatus");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
    editProfileProvider =
        Provider.of<EditProfileProvider>(context, listen: false);
    mentalStrengthEditProvider =
        Provider.of<MentalStrengthEditProvider>(context, listen: false);
    scheduleMicrotask(() {
      currentPage = 1;
      _isTokenExpired();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return tokenStatus == false
        ? SafeArea(
      child: backGroundImager(
        size: size,
        padding: EdgeInsets.zero,
        child: Consumer4<MentalStrengthEditProvider, JournalListProvider,
            HomeProvider, DashBoardProvider>(
          builder: (context, mentalStrengthEditProvider,
              journalListProvider, homeProvider, dashBoardProvider, _) {
            return Column(
              children: [
                buildAppBar(
                  context,
                  size,
                  heading: "My Journals",
                  onTap: () {
                    dashBoardProvider.changePage(index: 0);
                  },
                ),
                const SizedBox(height: 10),

                // TAB BUTTONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          journalListProvider.changeListViewBar(true);
                        },
                        child: Container(
                          width: size.width * 0.42,
                          padding: EdgeInsets.symmetric(
                            vertical: size.width * 0.03,
                          ),
                          decoration: BoxDecoration(
                            color: journalListProvider.listViewBool
                                ? ColorsContent.newThemeColor
                                : ColorsContent.goalNotCompletedColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "List View",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          journalListProvider.changeListViewBar(false);
                          journalListProvider.fetchJournalChartView(
                              context: context);
                        },
                        child: Container(
                          width: size.width * 0.42,
                          padding: EdgeInsets.symmetric(
                            vertical: size.width * 0.03,
                          ),
                          decoration: BoxDecoration(
                            color: journalListProvider.listViewBool
                                ? ColorsContent.goalNotCompletedColor
                                : ColorsContent.newThemeColor,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "Chart View",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.011),

                // SEARCH BAR (only in List View)
                if (journalListProvider.listViewBool)
                  buildSearchAndDateBar(context, homeProvider),

                const SizedBox(height: 15),

                // PREVIOUS BUTTON (only in List View)
                if (journalListProvider.listViewBool &&
                    homeProvider.journalsModelList.isNotEmpty &&
                    currentPage > 1)
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
                  child: Consumer<HomeProvider>(
                    builder: (context, homeProvider, _) {
                      return Stack(
                        children: [
                          // LIST OR CHART VIEW
                          Container(
                            //color: Colors.red,
                          //  height:size.height * 0.60,
                            margin: EdgeInsets.only(
                              bottom: journalListProvider.listViewBool &&
                                  homeProvider.journalsModelList.isNotEmpty
                                  ? 0
                                  : 0,
                            ),
                            child: journalListProvider.listViewBool
                                ? const JournalListViewWidget()
                                : const ChartViewList(),
                          ),

                          // PAGINATION COUNT - Bottom Left
                          if (journalListProvider.listViewBool &&
                              homeProvider.journalsModelList.isNotEmpty)
                            Positioned(
                              bottom: 30,
                              left: 30,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                child: Text(
                                      () {
                                    final totalCount = int.tryParse(
                                        homeProvider.journalsModel
                                            ?.totalCount
                                            .toString() ??
                                            '0') ??
                                        0;
                                    final currentPageNum = int.tryParse(
                                        homeProvider.journalsModel
                                            ?.currentPage
                                            .toString() ??
                                            '1') ??
                                        1;
                                    var pageCount =
                                        UrlConstant.paginationCount;
                                    final startItem =
                                        ((currentPageNum - 1) *
                                            pageCount) +
                                            1;
                                    final endItem =
                                    (currentPageNum * pageCount) >
                                        totalCount
                                        ? totalCount
                                        : currentPageNum * pageCount;
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

                          // LOAD MORE BUTTON - Bottom Center
                          if (journalListProvider.listViewBool &&
                              homeProvider.journalsModelList.isNotEmpty &&
                              (homeProvider.journalsModel?.pageCount ?? 1) >
                                  currentPage &&
                              !isLoading)
                            Positioned(
                              bottom: 20,
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

                          // ADD JOURNAL BUTTON - Bottom Right
                          if (journalListProvider.listViewBool)
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: SizedBox(
                                width: 150,
                                height: 70,
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
                                    dashBoardProvider.changePage(index: 1);
                                    mentalStrengthEditProvider
                                        .fetchEmotions(context: context);
                                  },
                                  child: addGoalButton(
                                    onTap: () {
                                      dashBoardProvider.changePage(index: 1);
                                      mentalStrengthEditProvider
                                          .fetchEmotions(context: context);
                                    },
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    )
        : const TokenExpireScreen();
  }

  Widget buildSearchAndDateBar(
      BuildContext context,
      HomeProvider homeProvider,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Row(
        children: [
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
                  Expanded(
                    child: TextField(
                      controller: homeProvider.searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) async {
                        homeProvider.searchQuery = value;
                        await homeProvider.fetchJournals(
                          initial: true,
                          context: context,
                          fullList: true,
                          keyword: value,
                          pageNo: "1",
                        );
                      },
                      decoration: InputDecoration(
                        hintText: "search journals",
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
                  Consumer<HomeProvider>(
                    builder: (context, provider, _) {
                      return provider.searchQuery.isNotEmpty
                          ? GestureDetector(
                        onTap: () async {
                          provider.searchController.clear();
                          provider.searchQuery = "";
                          await provider.fetchJournals(
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
                  homeProvider.selectedStartDate = startDate;
                  homeProvider.selectedEndDate = endDate;
                  homeProvider.searchController.text =
                      homeProvider.selectedDateRangeText;
                  await homeProvider.fetchJournals(
                    initial: true,
                    context: context,
                    fromDateParam: startDate,
                    toDateParam: endDate,
                    fullList: false,
                  );
                },
              );
            },
            child: SvgPicture.asset(ImageConstant.goalsAndDreamsDateIcon),
          ),
        ],
      ),
    );
  }

  Widget addGoalButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF7C63F7),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.add,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 6),
            Text(
              "Add Journal",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
              ),
            ),
          ],
        ),
      ),
    );
  }
}