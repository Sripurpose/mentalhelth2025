import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/utils/core/date_time_utils.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/core/image_constant.dart';
import '../../../utils/theme/theme_helper.dart';
import '../../../widgets/functions/popup.dart';
import '../../../widgets/video_player.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/list_goal_actions.dart'
as action;

import '../../edit_add_profile_screen/provider/edit_provider.dart';
import '../../journal_list_screen/provider/journal_list_provider.dart';
import '../../journal_list_screen/screens/edit_journal/numu_edit_journal_screen.dart';
import '../../journal_view_screen/widgets/journal_audio_player.dart';
import '../../mental_strength_add_edit_screen/model/all_model.dart';
import '../../mental_strength_add_edit_screen/model/get_goals_model.dart';
import '../../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../provider/home_provider.dart';

class UserProfileListItemWidget extends StatefulWidget {
  const UserProfileListItemWidget({
    Key? key,
    required this.title,
    required this.date,
    required this.description,
    required this.journalMedia,
    required this.journalId, // Add this for menu operations
    this.locationName,
    this.locationLatitude,
    this.locationLongitude,
    this.viewDefImage,
  }) : super(key: key);

  final String title;
  final String date;
  final String description;
  final List<dynamic> journalMedia;
  final String journalId; // Add this
  final String? locationName;
  final String? locationLatitude;
  final String? locationLongitude;
  final String? viewDefImage;

  @override
  State<UserProfileListItemWidget> createState() => _UserProfileListItemWidgetState();
}

class _UserProfileListItemWidgetState extends State<UserProfileListItemWidget> {
  final PageController pageController = PageController();
  int currentIndex = 0;
  final logger = Logger();
  bool isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // 🧩 Merge image, video, and audio in order
    final List<Map<String, String>> mediaList = [];

    for (var media in widget.journalMedia) {
      try {
        final type = (media.mediaType ?? media['mediaType'] ?? '').toString();
        final url = (media.gemMedia ?? media['gem_media'] ?? media['mediaUrl'] ?? '').toString();

        if (url.isNotEmpty) {
          mediaList.add({'type': type, 'url': url});
        }
      } catch (e) {
        logger.e('Error parsing media: $e');
      }
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: AppDecoration.outlineGray.copyWith(
        borderRadius: BorderRadiusStyle.roundedBorder10,
        border: Border.all(
          color: ColorsContent.allBorderColor,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🧠 Title + 3-Dot Menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  capitalizeFirstLetter(
                    HtmlUnescape().convert(
                      widget.title.length > 38
                          ? '${widget.title.substring(0, 38)}...'
                          : widget.title,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: ColorsContent.blackThemeColor,
                  ),
                ),
              ),

              // 🎯 3-Dot Menu Button
              _buildThreeDotMenu(context),
            ],
          ),
          //const SizedBox(height: 2),

          // 📅 Date
          Row(
            children: [
              SvgPicture.asset(ImageConstant.dateIconGridNumu),
              const SizedBox(width: 6),
              Text(
                formatDateOnly(int.parse(widget.date)),
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  color: ColorsContent.dateTimeColor,
                ),
              ),
              const SizedBox(width: 14),
              SvgPicture.asset(ImageConstant.timeIconGridNumu),
              const SizedBox(width: 6),
              Text(
                formatTimeOnly(int.parse(widget.date)),
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  color: ColorsContent.dateTimeColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),
          // ✅ Location
          if (widget.locationName != null &&
              widget.locationLatitude != null &&
              widget.locationLongitude != null)
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: GestureDetector(
                onTap: () async {
                  final lat = widget.locationLatitude!;
                  final lon = widget.locationLongitude!;
                  final googleMapsUrl =
                      'https://www.google.com/maps/search/?api=1&query=$lat,$lon';
                  if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
                    await launchUrl(
                      Uri.parse(googleMapsUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: SvgPicture.asset(ImageConstant.locationIconGridNumu),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.locationName!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationColor: ColorsContent.newThemeColor,
                          decorationThickness: 1.5,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          color: ColorsContent.newThemeColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 5),

          // 🎞️ Unified Media Carousel
          // 🎞️ Unified Media Carousel or Display Image
          if (mediaList.isNotEmpty)
            Column(
              children: [
                SizedBox(
                  height: size.height * 0.38,
                  child: Stack(
                    children: [
                      PageView.builder(
                        controller: pageController,
                        itemCount: mediaList.length,
                        onPageChanged: (index) {
                          setState(() => currentIndex = index);
                        },
                        itemBuilder: (context, index) {
                          final media = mediaList[index];
                          final type = media['type'];
                          final url = media['url'] ?? '';

                          if (type == 'image') {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(0),
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (c, e, s) => const Center(
                                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                ),
                              ),
                            );
                          } else if (type == 'video') {
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (_) => Dialog(
                                    insetPadding: EdgeInsets.zero,
                                    backgroundColor: Colors.black,
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: VideoPlayerWidgetViewAndAlreadyBuildMentalProgressBar(
                                            videoUrl: url,
                                          ),
                                        ),
                                        Positioned(
                                          top: 40,
                                          right: 20,
                                          child: IconButton(
                                            icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                            onPressed: () => Navigator.of(context).pop(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0),
                                child: VideoPlayerWidgetViewAndAlreadyBuildMental(
                                  videoUrl: url,
                                ),
                              ),
                            );
                          } else if (type == 'audio') {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                                child: GridAudioPlayer(url: url),
                              ),
                            );
                          }
                          else if (type == 'chart') {
                            final controller = WebViewController()
                              ..setJavaScriptMode(JavaScriptMode.unrestricted)
                              ..loadRequest(Uri.parse(url));

                            return SizedBox(
                              height: 250,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(0),
                                child: WebViewWidget(
                                  controller: controller,
                                ),
                              ),
                            );
                          }

                          else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),

                      // 🔢 Top-right media counter
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${currentIndex + 1}/${mediaList.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔘 Page indicators
                if (mediaList.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(mediaList.length, (index) {
                        final isActive = currentIndex == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: SvgPicture.asset(
                            isActive
                                ? ImageConstant.toggleActiveNumu
                                : ImageConstant.toggleInActiveNumu,
                            height: isActive ? 18 : 14,
                            width: isActive ? 18 : 14,
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            )
          else if (widget.viewDefImage != null && widget.viewDefImage!.isNotEmpty)
          // 🖼️ Fallback Display Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.viewDefImage!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: size.height * 0.25,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),


          ExpandableDescription(description: widget.description),
        ],
      ),
    );
  }


  // 🎯 3-Dot Menu Widget
  Widget _buildThreeDotMenu(BuildContext context) {
    return Consumer4<JournalListProvider, HomeProvider,
        MentalStrengthEditProvider, EditProfileProvider>(
      builder: (contexts, journalListProvider, homeProvider,
          mentalStrengthEditProvider, editProfileProvider, _) {
        return PopupMenuButton<String>(
          color: Colors.white,
          icon: Icon(Icons.more_horiz, color: ColorsContent.blackText),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 100, maxWidth: 100),
          onSelected: (value) {},
          itemBuilder: (BuildContext context) {
            return [
              // Edit Option
              PopupMenuItem<String>(
                onTap: () async {
                  await homeProvider.fetchJournalDetails(
                      journalId: widget.journalId,
                      context: context
                  );

                  mentalStrengthEditProvider.openAllCloser();
                  editProfileProvider.fetchUserProfile(context);

                  if (homeProvider.journalDetails != null) {
                    mentalStrengthEditProvider.descriptionEditTextController.text =
                        homeProvider.journalDetails!.journals!.journalDesc.toString();
                    mentalStrengthEditProvider.titleEditTextController.text =
                        homeProvider.journalDetails!.journals!.journalTitle.toString();

                    // Load audio
                    for (int i = 0;
                    i < homeProvider.journalDetails!.journals!.journalMedia!.length;
                    i++) {
                      if (homeProvider.journalDetails!.journals!
                          .journalMedia![i].mediaType == 'audio') {
                        mentalStrengthEditProvider.alreadyRecordedFilePath.add(
                          AllModel(
                            id: homeProvider.journalDetails!.journals!
                                .journalMedia![i].mediaId.toString(),
                            value: homeProvider.journalDetails!.journals!
                                .journalMedia![i].gemMedia!,
                          ),
                        );
                      }
                    }

                    // Load images
                    for (int i = 0;
                    i < homeProvider.journalDetails!.journals!.journalMedia!.length;
                    i++) {
                      if (homeProvider.journalDetails!.journals!
                          .journalMedia![i].mediaType == 'image') {
                        mentalStrengthEditProvider.alreadyPickedImages.add(
                          AllModel(
                            id: homeProvider.journalDetails!.journals!
                                .journalMedia![i].mediaId.toString(),
                            value: homeProvider.journalDetails!.journals!
                                .journalMedia![i].gemMedia!,
                          ),
                        );
                      }
                    }

                    // Load videos
                    for (int i = 0;
                    i < homeProvider.journalDetails!.journals!.journalMedia!.length;
                    i++) {
                      if (homeProvider.journalDetails!.journals!
                          .journalMedia![i].mediaType == 'video') {
                        mentalStrengthEditProvider.alreadyPickedImages.add(
                          AllModel(
                            id: homeProvider.journalDetails!.journals!
                                .journalMedia![i].mediaId.toString(),
                            value: homeProvider.journalDetails!.journals!
                                .journalMedia![i].gemMedia!,
                          ),
                        );
                      }
                    }

                    // Load location
                    if (homeProvider.journalDetails!.journals!.location != null) {
                      mentalStrengthEditProvider.selectedLocationName =
                          homeProvider.journalDetails!.journals!.location!.locationName!.toString();
                      mentalStrengthEditProvider.selectedLocationAddress =
                          homeProvider.journalDetails!.journals!.location!.locationAddress!.toString();
                      mentalStrengthEditProvider.selectedLatitude =
                          homeProvider.journalDetails!.journals!.location!.locationLatitude!.toString();
                      mentalStrengthEditProvider.selectedLongitude =
                          homeProvider.journalDetails!.journals!.location!.locationLongitude!.toString();
                    }

                    // Load emotions and other data
                    mentalStrengthEditProvider.emotionalValueStar =
                        double.parse(homeProvider.journalDetails!.journals!.emotionValue.toString());
                    mentalStrengthEditProvider.fetchEmotions(
                        editing: true,
                        emotionId: homeProvider.journalDetails!.journals!.emotionId.toString(),
                        context: context
                    );

                    mentalStrengthEditProvider.driveValueStar =
                        double.parse(homeProvider.journalDetails!.journals!.driveValue.toString());

                    if (homeProvider.journalDetails!.journals!.goal != null) {
                      mentalStrengthEditProvider.goalsValue = Goal(
                        id: homeProvider.journalDetails!.journals!.goal!.goalId.toString(),
                        title: homeProvider.journalDetails!.journals!.goal!.goalTitle.toString(),
                      );
                    }

                    for (int i = 0;
                    i < homeProvider.journalDetails!.journals!.action!.length;
                    i++) {
                      mentalStrengthEditProvider.actionList.add(action.Action(
                        title: homeProvider.journalDetails!.journals!.action![i].actionTitle,
                        id: homeProvider.journalDetails!.journals!.action![i].actionId,
                      ));
                    }
                  }

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NumuEditJournalScreen(),
                    ),
                  );
                },
                value: 'Edit',
                height: 20,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mode_edit_outline_outlined, color: ColorsContent.newThemeColor),
                      const SizedBox(width: 5),
                      const Padding(
                        padding: EdgeInsets.only(right: 12.0),
                        child: Text('Edit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto',
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const PopupMenuDivider(),

              // Delete Option
              PopupMenuItem<String>(
                onTap: () async {
                  if (isDeleting) return;
                  isDeleting = true;

                  await Future.delayed(Duration.zero);
                  customPopup(
                    context: context,
                    onPressedDelete: () async {
                      await journalListProvider.deleteJournalsFunction(
                        journalId: widget.journalId,
                      ).then((value) async {
                        if (Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Journal deleted successfully")),
                          );
                        }

                        await homeProvider.fetchJournalsGridView(initial: true,context: context,fullList: true);

                        if (homeProvider.journalStatus == 404) {
                          await homeProvider.fetchJournalsGridView(initial: true,context: context,fullList: true);
                        }

                        isDeleting = false;
                      });
                    },
                    title: 'Confirm Delete',
                    content: 'Are you sure you want to delete this journal?',
                  );
                },
                height: 20,
                value: 'Delete',
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, color: ColorsContent.newThemeColor),
                      const SizedBox(width: 5),
                      const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
        );
      },
    );
  }

  String formatDateOnly(int millisecondsMain) {
    int milliseconds = int.parse("${millisecondsMain}000");
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  String formatTimeOnly(int millisecondsMain) {
    int milliseconds = int.parse("${millisecondsMain}000");
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return DateFormat('hh:mm a').format(dateTime);
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

}




class ExpandableDescription extends StatefulWidget {
  final String? description;

  const ExpandableDescription({Key? key, this.description}) : super(key: key);

  @override
  _ExpandableDescriptionState createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String? text = widget.description;
    if (text == null || text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    // Limit text length to 30 chars initially
    final bool isLongText = text.length > 70;
    final String displayText = !_isExpanded && isLongText
        ? '${text.substring(0, 70)}...'
        : text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: ColorsContent.blackText,
            ),
          ),
        ),
        if (isLongText)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                _isExpanded ? 'less' : 'more',
                style:  TextStyle(
                  color: ColorsContent.moreColor,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  decorationThickness: 1.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
