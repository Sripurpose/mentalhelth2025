// import 'package:flutter/material.dart';
// import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
// import 'package:mentalhelth/screens/journal_list_screen/provider/journal_list_provider.dart';
// import 'package:mentalhelth/screens/journal_list_screen/widgets/chart_view_list.dart';
// import 'package:mentalhelth/screens/journal_list_screen/widgets/userprofilelist1_item_widget.dart';
// import 'package:mentalhelth/screens/journal_view_screen/journal_view_screen.dart';
// import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
// import 'package:provider/provider.dart';
//
// import '../../utils/core/image_constant.dart';
// import '../../utils/theme/app_decoration.dart';
// import '../../utils/theme/theme_helper.dart';
//
// // ignore_for_file: must_be_immutable
// class JournalListPage extends StatefulWidget {
//   const JournalListPage({Key? key})
//       : super(
//           key: key,
//         );
//
//   @override
//   JournalListPageState createState() => JournalListPageState();
// }
//
// class JournalListPageState extends State<JournalListPage>
//     with AutomaticKeepAliveClientMixin<JournalListPage> {
//   final ScrollController _scrollController = ScrollController();
//   @override
//   void initState() {
//     HomeProvider homeProvider = Provider.of<HomeProvider>(
//       context,
//       listen: false,
//     );
//     JournalListProvider journalListProvider =
//         Provider.of<JournalListProvider>(context, listen: false);
//     // homeProvider.journalsModelList = [];
//     homeProvider.fetchJournals();
//     _loadMoreData();
//     journalListProvider.fetchJournalChartView();
//     _scrollController.addListener(_loadMoreData);
//     super.initState();
//   }
//
//   void _loadMoreData() {
//     HomeProvider homeProvider =
//         Provider.of<HomeProvider>(context, listen: false);
//     if (_scrollController.hasClients) {
//       final double maxScroll = _scrollController.position.maxScrollExtent;
//       final double currentScroll = _scrollController.position.pixels;
//       final double scrollPercentage = currentScroll / maxScroll;
//       // Adjust the threshold percentage as needed
//       if (scrollPercentage >= 0.5) {
//         // Trigger an action when scroll reaches 80% of the total scrollable area
//         print("Reached 80% of scroll");
//         // Call your function to fetch journals
//         homeProvider.fetchJournals();
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return SafeArea(
//       child: Container(
//         width: size.width,
//         height: size.height,
//         decoration: BoxDecoration(
//           color: theme.colorScheme.onSecondaryContainer.withOpacity(1),
//           image: DecorationImage(
//             image: AssetImage(
//               ImageConstant.imgGroup193,
//             ),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Container(
//           width: double.maxFinite,
//           decoration: AppDecoration.fillOnSecondaryContainer.copyWith(
//             image: DecorationImage(
//               image: AssetImage(
//                 ImageConstant.imgGroup193,
//               ),
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: Consumer2<JournalListProvider, HomeProvider>(
//               builder: (context, journalListProvider, homeProvider, _) {
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 0),
//               child: Column(
//                 children: [
//                   buildAppBar(
//                     context,
//                     size,
//                     heading: "My Journals",
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 28),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             journalListProvider.changeListViewBar(true);
//                           },
//                           child: Container(
//                             width: size.width * 0.42,
//                             padding: EdgeInsets.only(
//                               left: size.width * 0.1,
//                               right: size.width * 0.1,
//                               top: size.width * 0.03,
//                               bottom: size.width * 0.03,
//                             ),
//                             decoration: BoxDecoration(
//                               color: journalListProvider.listViewBool
//                                   ? Colors.blue
//                                   : Colors.blue[100],
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(20),
//                               ),
//                             ),
//                             child: const Center(
//                               child: Text(
//                                 "List View",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             journalListProvider.changeListViewBar(false);
//                           },
//                           child: Container(
//                             width: size.width * 0.42,
//                             padding: EdgeInsets.only(
//                               left: size.width * 0.1,
//                               right: size.width * 0.1,
//                               top: size.width * 0.03,
//                               bottom: size.width * 0.03,
//                             ),
//                             decoration: BoxDecoration(
//                               color: journalListProvider.listViewBool
//                                   ? Colors.blue[100]
//                                   : Colors.blue,
//                               borderRadius: const BorderRadius.only(
//                                 topRight: Radius.circular(20),
//                               ),
//                             ),
//                             child: const Center(
//                               child: Text(
//                                 "Chart View",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     height: size.height * 0.031,
//                   ),
//                   journalListProvider.listViewBool
//                       ? homeProvider.journalsModelList == null
//                           ? const SizedBox()
//                           : Expanded(
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 28),
//                                 child: ListView.separated(
//                                   controller: _scrollController,
//                                   separatorBuilder: (
//                                     context,
//                                     index,
//                                   ) {
//                                     return const SizedBox(
//                                       height: 3,
//                                     );
//                                   },
//                                   itemCount:
//                                       homeProvider.journalsModelList!.length,
//                                   itemBuilder: (context, index) {
//                                     if (index ==
//                                         homeProvider.journalsModelList.length) {
//                                       return const Center(
//                                         child: CircularProgressIndicator(),
//                                       );
//                                     } else {
//                                       return GestureDetector(
//                                         onTap: () {
//                                           Navigator.of(context).push(
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   JournalViewScreen(
//                                                 journalsModelList: homeProvider
//                                                     .journalsModelList![index],
//                                                 indexs: index,
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                         child: UserProfileList1ItemWidget(
//                                           journalsModelList: homeProvider
//                                               .journalsModelList![index],
//                                           index: index,
//                                         ),
//                                       );
//                                     }
//                                   },
//                                 ),
//                               ),
//                             )
//                       : const ChartViewList(),
//                 ],
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }
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

    // Keep provider in sync
    homeProvider.pageLoad = pageNo;

    await homeProvider.fetchJournals(
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
    await homeProvider.fetchJournals(
        initial: true, context: context, fullList: true);
    await homeProvider.fetchJournalsGridView(initial: true, context: context);
    await editProfileProvider.fetchUserProfile(context);
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
                  return Stack(
                    children: [
                      Column(
                        children: [
                          // const SizedBox(height: 20),
                          buildAppBar(
                            context,
                            size,
                            heading: "My Journals",
                            onTap: () {
                              dashBoardProvider.changePage(index: 0);
                            },
                          ),
                          const SizedBox(height: 10),
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
                                    journalListProvider
                                        .changeListViewBar(false);
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
                          if (journalListProvider.listViewBool)
                            buildSearchAndDateBar(context, homeProvider),
                          // 🔍 Add this here
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
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
                                    child: currentPage > 1
                                        ? SvgPicture.asset(ImageConstant
                                            .previousScrollIconActive)
                                        : const SizedBox(),
                                    //   SvgPicture.asset(ImageConstant.previousScrollIconActive),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: Consumer<HomeProvider>(
                              builder: (context, homeProvider, _) {
                                return Stack(
                                  children: [
                                    journalListProvider.listViewBool
                                        ? const JournalListViewWidget()
                                        : const ChartViewList(),
                                    journalListProvider.listViewBool &&
                                        homeProvider.journalsModelList.isNotEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 30.0, vertical: 70),
                                            child: Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Container(
                                                // ⭐ DECORATION ADDED
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),

                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 4),
                                                  child: Text(
                                                    () {
                                                      // Parse values safely
                                                      final totalCount =
                                                          int.tryParse(homeProvider
                                                                      .journalsModel
                                                                      ?.totalCount
                                                                      .toString() ??
                                                                  '0') ??
                                                              0;
                                                      final currentPage =
                                                          int.tryParse(homeProvider
                                                                      .journalsModel
                                                                      ?.currentPage
                                                                      .toString() ??
                                                                  '1') ??
                                                              1;
                                                      const pageCount =
                                                          10; // fixed items per page

                                                      // Calculate start and end items
                                                      final startItem =
                                                          ((currentPage - 1) *
                                                                  pageCount) +
                                                              1;
                                                      final endItem =
                                                          (currentPage *
                                                                      pageCount) >
                                                                  totalCount
                                                              ? totalCount
                                                              : currentPage *
                                                                  pageCount;

                                                      return "$endItem of $totalCount";
                                                    }(),
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontFamily: 'Poppins',
                                                      color: ColorsContent
                                                          .blackText,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                    journalListProvider.listViewBool
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 25.0),
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 0),
                                                // Adjust the position
                                                child: SizedBox(
                                                  width: 150, // Increase width
                                                  height: 70, // Increase height
                                                  child: FloatingActionButton(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    elevation: 0,
                                                    // removes shadow
                                                    highlightElevation: 0,
                                                    focusElevation: 0,
                                                    hoverElevation: 0,
                                                    splashColor:
                                                        Colors.transparent,
                                                    // disables ripple effect
                                                    foregroundColor:
                                                        Colors.transparent,
                                                    shape: const CircleBorder(),
                                                    // Ensures circular shape
                                                    onPressed: () {
                                                      dashBoardProvider
                                                          .changePage(index: 1);
                                                      mentalStrengthEditProvider
                                                          .fetchEmotions(
                                                              context: context);
                                                    },
                                                    child:
                                                    addGoalButton(
                                                      onTap: () {
                                                        dashBoardProvider
                                                            .changePage(index: 1);
                                                        mentalStrengthEditProvider
                                                            .fetchEmotions(
                                                            context: context);
                                                      },
                                                    ),

                                                    // Image.asset(
                                                    //   ImageConstant.addGoalPng,
                                                    // ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                    journalListProvider.listViewBool
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15.0),
                                            child: Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Load More Button
                                                  GestureDetector(
                                                    onTap: (homeProvider.journalsModel
                                                                        ?.pageCount ??
                                                                    1) >
                                                                currentPage &&
                                                            !isLoading
                                                        ? () async {
                                                            final next =
                                                                currentPage + 1;
                                                            await loadPage(
                                                                next);
                                                          }
                                                        : null,
                                                    child: (homeProvider
                                                                    .journalsModel
                                                                    ?.pageCount ??
                                                                1) >
                                                            currentPage
                                                        ? SvgPicture.asset(
                                                            ImageConstant
                                                                .loadMoreScrollIconActive)
                                                        : const SizedBox(),
                                                    //    SvgPicture.asset(ImageConstant.loadMoreScrollIconActive),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),

                                                  /// --------- "10 of 50" text below ---------

                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : const SizedBox()
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          )
        : const TokenExpireScreen();
  }

  // 🔍 Search + Date Filter Bar
  Widget buildSearchAndDateBar(
    BuildContext context,
    HomeProvider homeProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
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

                  // ❌ CLEAR ICON
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

          // 📅 DATE PICKER ICON OUTSIDE BOX
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF7C63F7), // Same purple color
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 6),
            const Text(
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
