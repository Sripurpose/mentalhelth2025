import 'package:flutter/material.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/home_screen/model/jounals_model.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/screens/journal_list_screen/provider/journal_list_provider.dart';
import 'package:mentalhelth/screens/journal_list_screen/screens/edit_journal/edit_journal.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/all_model.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/list_goal_actions.dart'
    as action;
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/utils/core/date_time_utils.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/widgets/functions/popup.dart';
import 'package:provider/provider.dart';
import 'package:html_unescape/html_unescape.dart';
import '../../../utils/theme/app_decoration.dart';
import '../../../utils/theme/colors.dart';
import '../../../utils/theme/theme_helper.dart';
import '../../mental_strength_add_edit_screen/model/get_goals_model.dart';
import '../screens/edit_journal/numu_edit_journal_screen.dart';

class UserProfileList1ItemWidget extends StatelessWidget {
  const UserProfileList1ItemWidget({
    Key? key,
    required this.journalsModelList,
    required this.index,
  }) : super(
          key: key,
        );
  final Journal journalsModelList;
  final int index;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 8,
      ),
      decoration: AppDecoration.outlineGray.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder10,
        border: Border.all(
          color: ColorsContent.goalNotCompletedColor, // Change to desired border color
          width: 0.5, // Border width
        ),
      ),

      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: size.width * 0.1, // Set the desired width
                height: size.width * 0.1, // Set the desired height
                decoration: BoxDecoration(
                  color: Colors.grey[100], // Background color
                  image: DecorationImage(
                    image: NetworkImage(journalsModelList.displayImage.toString()),
                    fit: BoxFit.cover, // Adjust image to fit container
                  ),
                  borderRadius: BorderRadius.circular(10), // Set curved edges
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 17,
                  top: 2,
                  bottom: 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      //color:Colors.red,
                      width: size.width * 0.50,
                      child: Text(
                        HtmlUnescape().convert(journalsModelList.journalTitle!),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Open Sans',
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      formatMilliseconds(
                          int.parse(journalsModelList.journalDatetime!)),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Consumer4<JournalListProvider, HomeProvider,
                      MentalStrengthEditProvider, EditProfileProvider>(
                  builder: (contexts, journalListProvider, homeProvider,
                      mentalStrengthEditProvider, editProfileProvider, _) {
                return PopupMenuButton<String>(
               //   color: ColorsContent.newThemeColor,
                  onSelected: (value) {},
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        onTap: () async {
                          await homeProvider.fetchJournalDetails(
                            journalId: journalsModelList.journalId.toString(),
                          );
                          // MentalStrengthEditProvider mentalStrengthEditProvider =
                          //     Provider.of<MentalStrengthEditProvider>(context,
                          //         listen: false);

                          mentalStrengthEditProvider.openAllCloser();
                          // EditProfileProvider editProfileProvider =
                          //     Provider.of<EditProfileProvider>(context,
                          //         listen: false);

                          editProfileProvider.fetchUserProfile();
                          if (homeProvider.journalDetails != null) {
                            mentalStrengthEditProvider
                                    .descriptionEditTextController.text =
                                homeProvider.journalDetails!.journals!.journalDesc
                                    .toString();
                            mentalStrengthEditProvider
                                .titleEditTextController.text =
                                homeProvider.journalDetails!.journals!.journalTitle
                                    .toString();
                            for (int i = 0;
                                i <
                                    homeProvider.journalDetails!.journals!
                                        .journalMedia!.length;
                                i++) {
                              if (homeProvider.journalDetails!.journals!
                                      .journalMedia![i].mediaType ==
                                  'audio') {
                                mentalStrengthEditProvider.alreadyRecordedFilePath
                                    .add(
                                  AllModel(
                                    id: homeProvider.journalDetails!.journals!
                                        .journalMedia![i].mediaId
                                        .toString(),
                                    value: homeProvider.journalDetails!.journals!
                                        .journalMedia![i].gemMedia!,
                                  ),
                                );
                              }
                            }
                            for (int i = 0;
                                i <
                                    homeProvider.journalDetails!.journals!
                                        .journalMedia!.length;
                                i++) {
                              if (homeProvider.journalDetails!.journals!
                                      .journalMedia![i].mediaType ==
                                  'image') {
                                mentalStrengthEditProvider.alreadyPickedImages.add(
                                  AllModel(
                                    id: homeProvider.journalDetails!.journals!
                                        .journalMedia![i].mediaId
                                        .toString(),
                                    value: homeProvider.journalDetails!.journals!
                                        .journalMedia![i].gemMedia!,
                                  ),
                                );
                              }
                            }
                            for (int i = 0;
                                i <
                                    homeProvider.journalDetails!.journals!
                                        .journalMedia!.length;
                                i++) {
                              if (homeProvider.journalDetails!.journals!
                                      .journalMedia![i].mediaType ==
                                  'video') {
                                mentalStrengthEditProvider.alreadyPickedImages.add(
                                  AllModel(
                                    id: homeProvider.journalDetails!.journals!
                                        .journalMedia![i].mediaId
                                        .toString(),
                                    value: homeProvider.journalDetails!.journals!
                                        .journalMedia![i].gemMedia!,
                                  ),
                                );
                              }
                            }

                            if (homeProvider.journalDetails!.journals!.location !=
                                null) {
                              mentalStrengthEditProvider.selectedLocationName =
                                  homeProvider.journalDetails!.journals!.location!
                                      .locationName!
                                      .toString();
                              mentalStrengthEditProvider.selectedLocationAddress =
                                  homeProvider.journalDetails!.journals!.location!
                                      .locationAddress!
                                      .toString();
                              mentalStrengthEditProvider.selectedLatitude =
                                  homeProvider.journalDetails!.journals!.location!
                                      .locationLatitude!
                                      .toString();

                              mentalStrengthEditProvider.locationLongitude =
                                  homeProvider.journalDetails!.journals!.location!
                                      .locationLongitude!
                                      .toString();
                            }
                            mentalStrengthEditProvider.emotionalValueStar =
                                double.parse(
                              homeProvider.journalDetails!.journals!.emotionValue
                                  .toString(),
                            );
                            mentalStrengthEditProvider.fetchEmotions(
                              editing: true,
                              emotionId: homeProvider
                                  .journalDetails!.journals!.emotionId
                                  .toString(),
                            );
                            // log(message)

                            mentalStrengthEditProvider.driveValueStar =
                                double.parse(homeProvider
                                    .journalDetails!.journals!.driveValue
                                    .toString());
                            if (homeProvider.journalDetails!.journals!.goal !=
                                null) {
                              mentalStrengthEditProvider.goalsValue = Goal(
                                id: homeProvider
                                    .journalDetails!.journals!.goal!.goalId
                                    .toString(),
                                title: homeProvider
                                    .journalDetails!.journals!.goal!.goalTitle
                                    .toString(),
                              );
                            }

                            for (int i = 0;
                                i <
                                    homeProvider
                                        .journalDetails!.journals!.action!.length;
                                i++) {
                              mentalStrengthEditProvider.actionList
                                  .add(action.Action(
                                title: homeProvider.journalDetails!.journals!
                                    .action![i].actionTitle,
                                id: homeProvider
                                    .journalDetails!.journals!.action![i].actionId,
                              ));
                            }
                          }
                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (context) =>
                          //         const EditJournalMentalStrength(),
                          //   ),
                          // );

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                              const NumuEditJournalScreen(),
                            ),
                          );
                        },
                        value: 'Edit',
                        child: ListTile(
                          leading: Icon(Icons.edit, color: ColorsContent.newThemeColor), // Edit Icon
                          title: Text(
                            'Edit',
                            style: CustomTextStyles.bodyMedium14,
                          ),
                        ),
                      ),
                      // PopupMenuItem<String>(
                      //   value: 'Share',
                      //   child: Text(
                      //     'Share',
                      //     style: CustomTextStyles.bodyMedium14,
                      //   ),
                      // ),
                      PopupMenuItem<String>(

                        onTap: () {
                          customPopup(
                            context: context,
                            onPressedDelete: () async {
                              await journalListProvider
                                  .deleteJournalsFunction(
                                journalId: journalsModelList.journalId.toString(),
                              )
                                  .then((value) async {
                                Navigator.of(context).pop();
                                await homeProvider.fetchJournals(pageNo:homeProvider.currentPage.toString());
                                if(homeProvider.journalStatus == 404){
                                  await homeProvider.fetchJournals(pageNo:1.toString());
                                }

                                List<int> indicesToRemove = [];
                                for (int i = 0;
                                    i < homeProvider.journalsModelList.length;
                                    i++) {
                                  var journals = homeProvider.journalsModelList[i];
                                  if (journals.journalId ==
                                      journalsModelList.journalId.toString()) {
                                    indicesToRemove.add(i);
                                  }
                                }
                                indicesToRemove.sort((a, b) => b.compareTo(a));
                                for (int index in indicesToRemove) {
                                  homeProvider.journalsModelList.removeAt(index);
                                }

                              });
                            },
                            title: 'Confirm Delete',
                            content:
                                'Are you sure You want to Delete this Journal?',
                          );
                        },
                        value: 'Delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: ColorsContent.newThemeColor), // Delete Icon
                          title: Text(
                            'Delete',
                            style: CustomTextStyles.bodyMedium14,
                          ),
                        ),
                      ),
                    ];
                  },
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
