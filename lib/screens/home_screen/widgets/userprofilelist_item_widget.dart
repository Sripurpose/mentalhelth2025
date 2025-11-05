import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/utils/core/date_time_utils.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../utils/core/image_constant.dart';
import '../../../utils/theme/theme_helper.dart';
import '../../../widgets/video_player.dart';

import '../../journal_view_screen/widgets/journal_audio_player.dart';

class UserProfileListItemWidget extends StatefulWidget {
  const UserProfileListItemWidget({
    Key? key,
    required this.title,
    required this.date,
    required this.description,
    required this.journalMedia,
    this.locationName,
    this.locationLatitude,
    this.locationLongitude,
  }) : super(key: key);

  final String title;
  final String date;
  final String description;
  final List<dynamic> journalMedia;
  final String? locationName;
  final String? locationLatitude;
  final String? locationLongitude;

  @override
  State<UserProfileListItemWidget> createState() => _UserProfileListItemWidgetState();
}

class _UserProfileListItemWidgetState extends State<UserProfileListItemWidget> {
  final PageController pageController = PageController();
  int currentIndex = 0;
  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // 🧩 Merge image, video, and audio in order
    final List<Map<String, String>> mediaList = [];

    for (var media in widget.journalMedia) {
      try {
        // Handle model or map both
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
          // 🧠 Title
          Text(
            HtmlUnescape().convert(
              widget.title.length > 38
                  ? '${widget.title.substring(0, 38)}...'
                  : widget.title,
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Open Sans',
              color: ColorsContent.blackThemeColor,
            ),
          ),
          const SizedBox(height: 4),

          // 📅 Date
          Row(
            children: [
              // 🗓️ Date
              SvgPicture.asset(
                ImageConstant.dateIconGridNumu,
              ),
              const SizedBox(width: 6),
              Text(
                formatDateOnly(int.parse(widget.date)),
                style:  TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Regular',
                  color: ColorsContent.dateTimeColor,
                ),
              ),

              const SizedBox(width: 14),

              // ⏰ Time
              SvgPicture.asset(
                ImageConstant.timeIconGridNumu,
              ),
              const SizedBox(width: 6),
              Text(
                formatTimeOnly(int.parse(widget.date)),
                style:  TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Regular',
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
                      child: SvgPicture.asset(
                        ImageConstant.locationIconGridNumu, // Button icon
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.locationName!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ColorsContent.newThemeColor,
                          decoration: TextDecoration.underline,
                          decorationColor: ColorsContent.newThemeColor,
                          decorationThickness: 1.5,
                          fontFamily: 'Poppins',
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 5),

          // 🎞️ Unified Media Carousel
          if (mediaList.isNotEmpty)
          // 🎞️ Unified Media Carousel
            if (mediaList.isNotEmpty)
              SizedBox(
                height: size.height * 0.3,
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
                        } else {
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

                    // 🔘 Page indicators (bottom)
                    if (mediaList.length > 1)
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(mediaList.length, (index) {
                            final isActive = currentIndex == index;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: SvgPicture.asset(
                                isActive
                                    ? ImageConstant.toggleActiveNumu // active item icon
                                    : ImageConstant.toggleInActiveNumu, // inactive icon
                                height: isActive ? 18 : 14,
                                width: isActive ? 18 : 14,
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),


          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Description (only show if not empty)
              if (widget.description != null && widget.description!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Open Sans',
                      color: ColorsContent.blackThemeColor,
                    ),
                  ),
                ),

            ],
          ),


        ],
      ),
    );
  }



  String formatDateOnly(int millisecondsMain) {
    int milliseconds = int.parse("${millisecondsMain}000");
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return DateFormat('dd MMM yyyy').format(dateTime); // 🗓️ e.g. 05 Nov 2025
  }

  String formatTimeOnly(int millisecondsMain) {
    int milliseconds = int.parse("${millisecondsMain}000");
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return DateFormat('hh:mm a').format(dateTime); // ⏰ e.g. 11:33 AM
  }

}
