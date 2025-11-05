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
      _scrollController.addListener(_loadMoreData);
      homeProvider.fetchJournals(initial: true,context: context); // Fetch initial journals
      homeProvider.fetchJournalsGridView(initial: true,context: context); // Fetch initial journals
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  void _loadMoreData() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      homeProvider.fetchJournals(context: context);
      homeProvider.fetchJournalsGridView(initial: true,context: context); // Fetch initial journals
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer2<JournalListProvider, HomeProvider>(
      builder: (context, journalListProvider, homeProvider, _) {
        return RefreshIndicator(
          onRefresh: () async {
            homeProvider.fetchJournals(initial: true,context: context);
            homeProvider.fetchJournalsGridView(initial: true,context: context); // Fetch initial journals
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
                      padding: const EdgeInsets.symmetric(horizontal: 28,vertical: 10),
                      child: isLoading
                          ?   Center(child: CupertinoActivityIndicator(
                        color: ColorsContent.newThemeColor,
                        radius: 15,
                      ))
                          : homeProvider.journalsModelList.isEmpty &&
                          !homeProvider.journalsModelLoading
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                                            ImageConstant.noDataNumu,
                                                    ),
                              const Text("No data found",
                                  style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              const Text("Check back later",
                                  style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.normal)),
                            ],
                          )
                          : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // Prevent ListView from scrolling separately
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 10);
                        },
                        itemCount: homeProvider.journalsModelList.length +
                            (homeProvider.journalsModelLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < homeProvider.journalsModelList.length) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => JournalViewScreen(
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
                                journalsModelList:
                                homeProvider.journalsModelList[index],
                                index: index,
                              ),
                            );
                          } else if (homeProvider.journalsModelLoading) {
                            return Center(child: CupertinoActivityIndicator(
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

              // Pagination Row - Always Visible
              if (homeProvider.journalsModelList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: Visibility(
                    visible: (homeProvider.journalsModel?.pageCount ?? 0) > 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        homeProvider.journalsModel?.pageCount ?? 0,
                            (index) {
                          return GestureDetector(
                            onTap: () {
                              homeProvider.setCurrentPage(index + 1);
                              homeProvider.journalsModelList.clear();
                              print("currentPagenews ${homeProvider.currentPage}");
                              homeProvider.fetchJournals(
                                  pageNo: homeProvider.currentPage.toString(),context: context);
                              homeProvider.fetchJournalsGridView(
                                  pageNo: homeProvider.currentPage.toString(),context: context);
                            },
                            child: Container(
                              margin: const EdgeInsets.all(4.0),
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: homeProvider.currentPage == index + 1
                                    ? ColorsContent.newThemeColor
                                    : Colors.grey,
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
