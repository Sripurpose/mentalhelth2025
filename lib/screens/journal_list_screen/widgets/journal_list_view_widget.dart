import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/screens/journal_list_screen/provider/journal_list_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
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
      _scrollController.addListener(_loadMoreData);
      homeProvider.fetchJournals(initial: true); // Fetch initial journals
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  void _loadMoreData() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      homeProvider.fetchJournals();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer2<JournalListProvider, HomeProvider>(
      builder: (context, journalListProvider, homeProvider, _) {
        return RefreshIndicator(
          onRefresh: () async {
            homeProvider.fetchJournals(initial: true);
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: size.height * 0.67,
                  color: homeProvider.journalsModelList.isEmpty && !homeProvider.journalsModelLoading
                      ? Colors.white
                      : null,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: isLoading
                      ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                      : homeProvider.journalsModelList.isEmpty && !homeProvider.journalsModelLoading
                      ? Center(
                    child: Image.asset(
                      ImageConstant.noData,
                    ),
                  )
                      : ListView.separated(
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 3);
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
                                  journalId: homeProvider.journalsModelList[index].journalId.toString(),
                                  index: index,
                                ),
                              ),
                            );
                          },
                          child: UserProfileList1ItemWidget(
                            journalsModelList: homeProvider.journalsModelList[index],
                            index: index,
                          ),
                        );
                      } else if (homeProvider.journalsModelLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
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
                // Pagination Row
                Padding(
                  padding: const EdgeInsets.only(bottom: 0.0),
                  child: GestureDetector(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(homeProvider.journalsModel?.pageCount ?? 0, (index) {
                        return GestureDetector(
                          onTap: () {
                            // Update the current page and fetch new data
                            setState(() {
                              homeProvider.journalsModelList.clear();
                              currentPage = index + 1;
                            });
                            homeProvider.fetchJournals(pageNo: currentPage.toString());
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
                                  homeProvider.journalsModelList.clear();
                                  currentPage = index + 1;
                                });
                                homeProvider.fetchJournals(pageNo: currentPage.toString());
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
            
            
              ],
            ),
          ),
        );
      },
    );
  }
}
