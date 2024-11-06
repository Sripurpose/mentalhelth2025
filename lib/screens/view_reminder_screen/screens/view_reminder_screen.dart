import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/addgoals_dreams_screen.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/provider/goals_dreams_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/provider/goals_dreams_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/screens/goals_and_dreams_full_view/goals_and_dreams_full_view_screen.dart';
import 'package:mentalhelth/screens/view_reminder_screen/widgets/reminder_list_widget.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/background_image/background_imager.dart';
import 'package:mentalhelth/widgets/widget/shimmer.dart';
import 'package:provider/provider.dart';

import '../../dash_borad_screen/dash_board_screen.dart';
import '../../edit_add_profile_screen/provider/edit_provider.dart';
import '../../goals_dreams_page/widgets/weightlosscomponentlist_item_widget.dart';
import '../../home_screen/provider/home_provider.dart';
import '../../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../../token_expiry/tocken_expiry_warning_screen.dart';
import '../../token_expiry/token_expiry.dart';
import 'add_new_reminder_screen.dart';
import 'edit_reminder_screen.dart';

class ViewReminderScreen extends StatefulWidget {
  const ViewReminderScreen({Key? key})
      : super(
    key: key,
  );

  @override
  State<ViewReminderScreen> createState() => _ViewReminderScreenState();
}

class _ViewReminderScreenState extends State<ViewReminderScreen> {
  late HomeProvider homeProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late EditProfileProvider editProfileProvider;
  late DashBoardProvider dashBoardProvider;
  late GoalsDreamsProvider goalsDreamsProvider;
  bool tokenStatus = false;
  var logger = Logger();
  bool completed = false;
  final ScrollController _scrollController = ScrollController();

  Future<void> _isTokenExpired() async {
    await homeProvider.fetchChartView(context);
    await homeProvider.fetchJournals(initial: true);
    await homeProvider.fetchRemindersDetails();
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
    //homeProvider.remindersDetails?.reminders?.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      goalsDreamsProvider.goalsanddreams = [];
      goalsDreamsProvider.goalsanddreams.clear();
      goalsDreamsProvider.fetchGoalsAndDreams(initial: true);
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return tokenStatus == false ?
    SafeArea(
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
                    heading: "My Reminders",
                  );
                }),
            SizedBox(
              height: size.height * 0.025,
            ),
            Expanded(
              child: Consumer<HomeProvider>(
                  builder: (context, homeProvider, _) {
                    return Stack(
                      children: [
                        homeProvider.remindersDetailsLoading ?
                        shimmerList(
                              height: size.height,
                              list: 10,
                              shimmerHeight: size.height * 0.1,
                            ):
                            homeProvider.reminderStatusCode == 404?
                            Center(
                                  child: Image.asset(
                                    ImageConstant.noData,
                                  ),
                                ):
                        Container(
                          color: homeProvider.remindersDetails?.reminders == null
                              ? Colors.white
                              : null,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                          ),
                          child: ListView.builder(
                        //    controller: _scrollController,
                            itemCount: homeProvider.remindersDetails?.reminders?.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                       EditReminderScreenScreen(
                                        title: homeProvider.remindersDetails?.reminders![index].reminderTitle ?? "",
                                         description: homeProvider.remindersDetails?.reminders![index].reminderDesc ?? "",
                                         startDate: homeProvider.remindersDetails?.reminders![index].reminderStartdate ?? "",
                                         endDate: homeProvider.remindersDetails?.reminders![index].reminderEnddate ?? "",
                                         startTime: homeProvider.remindersDetails?.reminders![index].fromTime ?? "",
                                         endTime: homeProvider.remindersDetails?.reminders![index].toTime ?? "",
                                         reminderBefore: homeProvider.remindersDetails?.reminders![index].reminderBefore ?? "",
                                         repeat: homeProvider.remindersDetails?.reminders![index].reminderRepeat ?? "",
                                         goalId: homeProvider.remindersDetails?.reminders![index].goalId ?? "",
                                         actionId: homeProvider.remindersDetails?.reminders![index].actionId ?? "",
                                         reminderId: homeProvider.remindersDetails?.reminders![index].reminderId ?? "",
                                      ),
                                    ),
                                  );
                                },
                                child: ReminderListItemWidget(
                                  headding: homeProvider.remindersDetails?.reminders![index].reminderTitle ?? "",
                                  content: homeProvider.remindersDetails?.reminders![index].reminderDesc ?? "",
                                  startDate: homeProvider.remindersDetails?.reminders![index].reminderStartdate ?? "",
                                  endDate: homeProvider.remindersDetails?.reminders![index].reminderEnddate ?? "",
                                  imagePath: homeProvider.remindersDetails?.reminders![index].imageUrl ?? "",
                                ),
                              );

                            }
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
    ):
    const TokenExpireScreen();
  }


}