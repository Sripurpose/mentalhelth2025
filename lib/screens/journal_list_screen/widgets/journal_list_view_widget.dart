import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/screens/journal_list_screen/provider/journal_list_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/widgets/widget/shimmer.dart';
import 'package:provider/provider.dart';

import '../../journal_view_screen/journal_view_screen.dart';
import 'userprofilelist1_item_widget.dart';

class JournalListViewWidget extends StatefulWidget {
  const JournalListViewWidget({super.key});

  @override
  State<JournalListViewWidget> createState() => _JournalListViewWidgetState();
}

class _JournalListViewWidgetState extends State<JournalListViewWidget> {
  final ScrollController _scrollController = ScrollController();
  late HomeProvider homeProvider;
  bool isLoading = true;
  int currentPage = 1; // State to track the current page

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("currentPagnewse$currentPage");
      homeProvider.fetchJournals(
          initial: true, context: context, fullList: true);
      homeProvider.fetchJournalsGridView(
          initial: true, context: context); // Fetch initial journals
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer2<JournalListProvider, HomeProvider>(
      builder: (context, journalListProvider, homeProvider, _) {
        return RefreshIndicator(
          onRefresh: () async {
            homeProvider.fetchJournals(
                initial: true, context: context, fullList: true);
            homeProvider.fetchJournalsGridView(
                initial: true, context: context); // Fetch initial journals
          },
          child: Column(
            children: [
              // Wrap this part inside Expanded so it doesn't exceed available height
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      color: homeProvider.journalsModelList.isEmpty &&
                              !homeProvider.journalsModelLoading
                          ? Colors.transparent
                          : null,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 10),
                      child: isLoading
                          ? Center(
                              child: CupertinoActivityIndicator(
                              color: ColorsContent.newThemeColor,
                              radius: 15,
                            ))
                          :  homeProvider.journalStatus == 404
                          ?
                      GestureDetector(
                        onTap: () {},
                        child: SvgPicture.asset(
                          ImageConstant.homeSearchDataFoundGradient,
                          width: size.width * 0.95,
                          height: size.height * 0.50,
                        ),
                      )

                          : homeProvider.journalStatus == 204
                          ?
                      GestureDetector(
                        onTap: () {},
                        child: SvgPicture.asset(
                          ImageConstant.homeScreenNoData,
                          width: size.width * 0.95,
                          height: size.height * 0.50,
                        ),
                      )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  // Prevent ListView from scrolling separately
                                  separatorBuilder: (context, index) {
                                    return const SizedBox(height: 10);
                                  },
                                  itemCount:
                                      homeProvider.journalsModelList.length +
                                          (homeProvider.journalsModelLoading
                                              ? 1
                                              : 0),
                                  itemBuilder: (context, index) {
                                    if (index <
                                        homeProvider.journalsModelList.length) {
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  JournalViewScreen(
                                                journalId: homeProvider
                                                    .journalsModelList[index]
                                                    .journalId
                                                    .toString(),
                                                index: index,
                                              ),
                                            ),
                                          );
                                        },
                                        child: UserProfileList1ItemWidget(
                                          journalsModelList: homeProvider
                                              .journalsModelList[index],
                                          index: index,
                                        ),
                                      );
                                    } else if (homeProvider
                                        .journalsModelLoading) {
                                      return Center(
                                          child: CupertinoActivityIndicator(
                                        color: ColorsContent.newThemeColor,
                                        radius: 15,
                                      ));
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
