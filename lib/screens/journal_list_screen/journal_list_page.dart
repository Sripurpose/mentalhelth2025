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
import 'package:mentalhelth/screens/journal_list_screen/widgets/journal_list_view_widget.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:provider/provider.dart';

import '../../utils/core/image_constant.dart';
import '../edit_add_profile_screen/provider/edit_provider.dart';
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

  Future<void> _isTokenExpired() async {
   // await homeProvider.fetchChartView(context);
    await homeProvider.fetchJournals(initial: true,context: context);
    await homeProvider.fetchJournalsGridView(initial: true,context: context);
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
    mentalStrengthEditProvider = Provider.of<MentalStrengthEditProvider>(context, listen: false);
    scheduleMicrotask(() {
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
        child: Consumer4<MentalStrengthEditProvider,JournalListProvider, HomeProvider,
            DashBoardProvider>(
          builder: (context, mentalStrengthEditProvider,journalListProvider, homeProvider,
              dashBoardProvider, _) {
            return Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 20),
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
                              journalListProvider.changeListViewBar(false);
                              journalListProvider.fetchJournalChartView(context: context);
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
                    Expanded(
                      child: journalListProvider.listViewBool
                          ? const JournalListViewWidget()
                          : const ChartViewList(),
                    ),
                  ],
                ),

// Show Floating Button only in List View
                  if (journalListProvider.listViewBool)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10), // Adjust the position
                          child: SizedBox(
                            width: 80, // Increase width
                            height: 80, // Increase height
                            child: FloatingActionButton(
                              backgroundColor: Colors.transparent,
                              elevation: 0, // removes shadow
                              highlightElevation: 0,
                              focusElevation: 0,
                              hoverElevation: 0,
                              splashColor: Colors.transparent, // disables ripple effect
                              foregroundColor: Colors.transparent,
                              shape: const CircleBorder(), // Ensures circular shape
                              onPressed: () {
                                dashBoardProvider.changePage(index: 1);
                                mentalStrengthEditProvider.fetchEmotions(context: context);
                              },
                              child: Image.asset(
                                ImageConstant.createGoalsPng, // Make sure this points to your PNG file
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
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

}