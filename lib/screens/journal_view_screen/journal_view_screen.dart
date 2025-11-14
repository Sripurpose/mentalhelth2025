import 'package:audio_session/audio_session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/home_screen/model/journal_details.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/screens/journal_list_screen/provider/journal_list_provider.dart';
import 'package:mentalhelth/screens/journal_list_screen/screens/edit_journal/edit_journal.dart';
import 'package:mentalhelth/screens/journal_view_screen/widgets/action_view_in_parellel_screen.dart';
import 'package:mentalhelth/screens/journal_view_screen/widgets/goal_view_in_parellel_screen.dart';
import 'package:mentalhelth/screens/journal_view_screen/widgets/jouranl_view_google_map.dart';
import 'package:mentalhelth/screens/journal_view_screen/widgets/journal_audio_player.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/all_model.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/get_goals_model.dart'
// ignore: library_prefixes
    as goalMain;
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/list_goal_actions.dart'
    as action;
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/logic/date_format.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/custom_rating_bar.dart';
import 'package:mentalhelth/widgets/functions/popup.dart';
import 'package:mentalhelth/widgets/indicatores_widgets.dart';
import 'package:mentalhelth/widgets/video_player.dart';
import 'package:mentalhelth/widgets/widget/shimmer.dart';
import 'package:provider/provider.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/logic/logic.dart';
import '../../utils/theme/app_decoration.dart';
import '../../widgets/background_image/background_imager.dart';
import '../addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import '../journal_list_screen/journal_list_page.dart';
import '../journal_list_screen/screens/edit_journal/numu_edit_journal_screen.dart';
import '../mental_strength_add_edit_screen/chat_gpt_screen.dart';
import '../mental_strength_add_edit_screen/screens/goals_and_dreams_full_view/goals_and_dreams_full_view_screen.dart';
import '../no_internet/duplicate_screen.dart';

class JournalViewScreen extends StatefulWidget {
  const JournalViewScreen(
      {Key? key, required this.journalId, required this.index})
      : super(
          key: key,
        );

  final String journalId;
  final int index;

  @override
  State<JournalViewScreen> createState() => _JournalViewScreenState();
}

class _JournalViewScreenState extends State<JournalViewScreen> {
  bool? _isConnected;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late HomeProvider homeProvider;
  var logger = Logger();
  late WebViewController _webViewController;


  @override
  void initState() {
    mentalStrengthEditProvider = Provider.of<MentalStrengthEditProvider>(context, listen: false,);
    mentalStrengthEditProvider.openGoalViewSheet = false;
    _pauseAllMedia(); // 👈 add this
    init();
    super.initState();
  }

  Future<void> _pauseAllMedia() async {
    final session = await AudioSession.instance;
    await session.setActive(false); // This tells all players to pause/stop
  }

  void _initializeWebView() {
    final linkUrl = homeProvider.journalDetails?.journals?.chartlink;

    if (linkUrl != null && linkUrl.isNotEmpty) {
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(linkUrl));
    }
  }

  void init() async {

    homeProvider = Provider.of<HomeProvider>(
      context,
      listen: false,
    );
    await homeProvider.fetchJournalDetails(
      journalId: widget.journalId,
      context: context
    );
    if (homeProvider.journalDetails != null) {
      addAudio(
        journalDetails: homeProvider.journalDetails!,
      );
      addImage(
        journalDetails: homeProvider.journalDetails!,
      );
      addVideo(
        journalDetails: homeProvider.journalDetails!,
      );
    }
    _initializeWebView();
  }

  int sliderIndex = 1;

  PageController photoController = PageController();

  int photoCurrentIndex = 0;
  PageController videoController = PageController();

  int videoCurrentIndex = 0;
  List<String> audioList = [];

  List<String> imageList = [];

  List<String> videoList = [];

  void addAudio({required JournalDetails journalDetails}) {
    for (int i = 0; i < journalDetails.journals!.journalMedia!.length; i++) {
      if (journalDetails.journals!.journalMedia![i].mediaType == 'audio') {
        // setState(() {
        audioList.add(journalDetails.journals!.journalMedia![i].gemMedia!);
        // });
      }
    }
  }

  void addImage({required JournalDetails journalDetails}) {
    for (int i = 0; i < journalDetails.journals!.journalMedia!.length; i++) {
      if (journalDetails.journals!.journalMedia![i].mediaType == 'image') {
        // setState(() {
        imageList.add(journalDetails.journals!.journalMedia![i].gemMedia!);
        // });
      }
    }
  }

  void addVideo({required JournalDetails journalDetails}) {
    for (int i = 0; i < journalDetails.journals!.journalMedia!.length; i++) {
      if (journalDetails.journals!.journalMedia![i].mediaType == 'video') {
        // setState(() {
        videoList.add(journalDetails.journals!.journalMedia![i].gemMedia!);
        // });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return PopScope(
      onPopInvoked: (value) async {
        mentalStrengthEditProvider.openGoalViewSheet = false;
        mentalStrengthEditProvider.goalDetailModel = null;
      },
      child: ConnectivityWidget(
        child: SafeArea(
          child: Consumer3<MentalStrengthEditProvider,DashBoardProvider,HomeProvider>(builder: (context,mentalStrengthEditProvider,dashBoardProvider,homeProvider, _) {
            return Scaffold(
              appBar: buildAppBarJournalViewScreenNew(context, size, heading: "View your journal",
                onTap: (){
                  mentalStrengthEditProvider.openGoalViewSheet = false;
                  mentalStrengthEditProvider.goalDetailModel = null;
                  Navigator.of(context).pop();
                }
              ),
              body: backGroundImagerViewJournal(
                size: size,
                child: Padding(
                  padding: const EdgeInsets.only(
                      ),
                  child:
                      Consumer<HomeProvider>(builder: (context, homeProvider, _) {
                        logger.w("audioList.length ${audioList.length}");
                    return SingleChildScrollView(
                      child: mentalStrengthEditProvider.openGoalViewSheet == false?
                      homeProvider.journalDetails == null
                          ? shimmerView(size: size)
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildUntitledOne(context, size),
                                const SizedBox(height: 15),
                                const Text(
                                  "In your mind",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                SizedBox(
                                  width: size.width * 0.70,
                                  child: Text(
                                    homeProvider.journalDetails == null
                                        ? ""
                                        : capitalizeFirstLetter(
                                      HtmlUnescape().convert(
                                        homeProvider.journalDetails!.journals!.journalTitle.toString(),
                                      ),
                                    ),
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.justify,
                                    style:  TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Poppins',
                                      color: ColorsContent.goalCompletedTextColor,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),
                                const Text(
                                  "Description",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                SizedBox(
                                  width: size.width * 0.90,
                                  child: Builder(
                                    builder: (context) {
                                      final journal = homeProvider.journalDetails?.journals;
                                      final journalDesc = journal?.journalDesc?.trim() ?? "";
                                      final previewLink = journal?.preview_link?.trim() ?? "";

                                      final hasDesc = journalDesc.isNotEmpty;
                                      final hasPreview = previewLink.isNotEmpty;

                                      // ❌ If both empty → show nothing
                                      if (!hasDesc && !hasPreview) {
                                        return const SizedBox.shrink();
                                      }

                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // 🧠 Show description text (if available)
                                          if (hasDesc)
                                            Text(
                                              HtmlUnescape().convert(journalDesc),
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: 'Poppins',
                                                color: ColorsContent.goalCompletedTextColor,
                                              ),
                                            ),


                                          // 🔗 Show preview link (if available)
                                          if (hasPreview)
                                            Padding(
                                              padding: EdgeInsets.only(top: hasDesc ? 6.0 : 0.0),
                                              child:
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 1.2,
                                                  ),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: LinkPreviewGenerator(
                                                    link: previewLink,
                                                    linkPreviewStyle: LinkPreviewStyle.large, // 👈 Forces column format
                                                    showDomain: true,
                                                    showBody: true,
                                                    showTitle: true,
                                                    bodyMaxLines: 3,
                                                    borderRadius: 10,
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Colors.black12,
                                                        blurRadius: 4,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),

                                        ],
                                      );
                                    },
                                  ),
                                ),


                                const SizedBox(height: 15),
                                audioList.isEmpty
                                    ? const SizedBox()
                                    :
                                const Padding(
                                        padding: EdgeInsets.only(left: 2),
                                        child: Text(
                                          "Audio",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                audioList.isEmpty
                                    ? const SizedBox()
                                    : const SizedBox(height: 2),
                                audioList.isEmpty
                                    ?
                                const SizedBox()
                                    :
                                SizedBox(
                                  height:  size.height * 0.12,  // Default height if more than 2 audios
                                  child: ListView.builder(
                                    itemCount: audioList.length,
                                    itemBuilder: (context, index) {
                                      return JournalAudioPlayer(
                                        url: audioList[index],
                                      );
                                    },
                                  ),
                                ),
        
                                imageList.isEmpty
                                    ? const SizedBox()
                                    : const SizedBox(
                                        height: 0,
                                      ),
                                // imageList.isEmpty
                                //     ? const SizedBox()
                                //     :
                                audioList.isEmpty?
                                    const SizedBox():
                                const SizedBox(height: 5),
                                imageList.isEmpty?
                                             const SizedBox():
                                const Padding(
                                        padding: EdgeInsets.only(left: 2),
                                        child: Text(
                                          "Photo",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                imageList.isEmpty
                                    ? const SizedBox()
                                    : const SizedBox(height: 4),
                                imageList.isEmpty
                                    ?  const SizedBox()
                                    : Container(
                                  decoration: AppDecoration.outlineGray.copyWith(
                                    borderRadius: BorderRadiusStyle.roundedBorder10,
                                    border: Border.all(
                                      color: ColorsContent.allBorderColor,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [

                                      SizedBox(
                                        height: size.height * 0.3,
                                        child: Stack(
                                          children: [
                                            PageView.builder(
                                              controller: photoController,
                                              itemCount: imageList.length,
                                              itemBuilder: (context, index) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: true,
                                                      builder: (_) => Dialog(
                                                        insetPadding: EdgeInsets.zero,
                                                        backgroundColor: Colors.black,
                                                        shape: const RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.zero,
                                                        ),
                                                        child: Stack(
                                                          children: [
                                                            InteractiveViewer(
                                                              child: Center(
                                                                child: Image.network(
                                                                  imageList[index],
                                                                  fit: BoxFit.contain,
                                                                  loadingBuilder: (context, child, loadingProgress) {
                                                                    if (loadingProgress == null) return child;
                                                                    return const Center(child: CupertinoActivityIndicator());
                                                                  },
                                                                  errorBuilder: (context, error, stackTrace) =>
                                                                  const Center(child: Icon(Icons.broken_image, color: Colors.white)),
                                                                ),
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
                                                    borderRadius: BorderRadius.circular(5),
                                                    child: CustomImageView(
                                                      fit: BoxFit.cover,
                                                      imagePath: imageList[index],
                                                      height: size.height * 0.30,
                                                      width: size.width,
                                                      alignment: Alignment.center,
                                                    ),
                                                  ),
                                                );
                                              },
                                              onPageChanged: (int pageIndex) {
                                                setState(() {
                                                  photoCurrentIndex = pageIndex;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      // 👇 moved indicator outside the Stack (now below the images)
                                      if (imageList.length > 1)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: SizedBox(
                                            width: imageList.length * size.width * 0.1,
                                            child: buildIndicators(
                                              imageList.length,
                                              photoCurrentIndex,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 10,),
                                    ],
                                  ),
                                ),

                                imageList.isEmpty?
                                const SizedBox():
                                const SizedBox(height: 28),

                                // ✅ WebView Container - Opens link automatically
                                if (homeProvider.journalDetails?.journals?.chartlink != null &&
                                    homeProvider.journalDetails!.journals!.chartlink!.isNotEmpty)
                                  Container(
                                    height: size.height * 0.35, // Adjust height as needed
                                    margin: const EdgeInsets.symmetric(horizontal: 0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: WebViewWidget(
                                          controller: _webViewController,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                videoList.isEmpty
                                    ? const SizedBox()
                                    : const SizedBox(
                                        height: 10,
                                      ),
                                videoList.isEmpty
                                    ? const SizedBox()
                                    :
                                const Padding(
                                        padding: EdgeInsets.only(left: 2),
                                        child: Text(
                                          "Video",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Poppins',
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                videoList.isEmpty
                                    ? const SizedBox()
                                    : const SizedBox(height: 4),
                                videoList.isEmpty
                                    ?  const SizedBox()
                                    : Container(
                                  decoration: AppDecoration.outlineGray.copyWith(
                                    borderRadius: BorderRadiusStyle.roundedBorder10,
                                    border: Border.all(
                                      color: ColorsContent.allBorderColor,
                                      width: 0.5,
                                    ),
                                  ),
                                  height: size.height * 0.3,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: PageView.builder(
                                          controller: videoController,
                                          itemCount: videoList.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: true,
                                                  builder: (_) => Dialog(
                                                    insetPadding: EdgeInsets.zero,
                                                    backgroundColor: Colors.black,
                                                    shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.zero,
                                                    ),
                                                    child: Stack(
                                                      children: [
                                                        Positioned.fill(
                                                          child: VideoPlayerWidgetViewAndAlreadyBuildMentalProgressBar(
                                                            videoUrl: videoList[index],
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
                                                borderRadius: BorderRadius.circular(5),
                                                child: VideoPlayerWidgetViewAndAlreadyBuildMental(
                                                  videoUrl: videoList[index],
                                                ),
                                              ),
                                            );
                                          },
                                          onPageChanged: (int pageIndex) {
                                            setState(() {
                                              videoCurrentIndex = pageIndex;
                                            });
                                          },
                                        ),
                                      ),
                                      if (videoList.length != 1)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0, bottom: 5.0),
                                          child: SizedBox(
                                            width: videoList.length * size.width * 0.1,
                                            child: buildIndicators(
                                              videoList.length,
                                              videoCurrentIndex,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 10,),
                                    ],
                                  ),
                                ),


                                videoList.isEmpty?
                                const SizedBox():
                                const SizedBox(height: 28),
                                homeProvider.journalDetails!.journals!.location == null ?
                                    const SizedBox():
                                const Padding(
                                  padding: EdgeInsets.only(left: 2),
                                  child: Text(
                                    "Your Location",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                homeProvider.journalDetails!.journals!.location == null
                                    ?
                             const SizedBox()
                                    :

                                Padding(
                                  padding: const EdgeInsets.only(top: 0),
                                  child: GestureDetector(
                                    onTap: () async {
                                      final lat =  homeProvider.journalDetails!.journals!.location?.locationLatitude;
                                      final lon = homeProvider.journalDetails!.journals!.location?.locationLatitude;
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
                                            homeProvider.journalDetails!.journals!.location?.locationName ?? "",
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
        
                                homeProvider.journalDetails!.journals!.location == null ?
                                const SizedBox():
                                const SizedBox(height: 19),
                                const Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text(
                                    "Rating as how you felt",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                homeProvider.journalDetails == null
                                    ? const SizedBox()
                                    : CustomRatingBar(
                                  color: ColorsContent.newThemeColor,
                                  initialRating: double.parse(
                                    homeProvider.journalDetails!.journals!.emotionValue?.toString() ?? '0',
                                  ),
                                        itemSize: 35,
                                  isRatingStatic: true, // Set to true to make rating unchangeable
                                      ),
                                const SizedBox(height: 22),
                                const Padding(
                                  padding: EdgeInsets.only(
                                    left: 6,
                                  ),
                                  child: Text(
                                    "Your emotional state ",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                homeProvider.journalDetails == null
                                    ? const SizedBox()
                                    : Padding(
                                        padding: const EdgeInsets.only(left: 6),
                                        child: Text(
                                          homeProvider.journalDetails!.journals!
                                              .emotionTitle
                                              .toString(),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Poppins',
                                              color:  ColorsContent.stressFullStateColor,
                                            ),
                                        ),
                                      ),
                                const SizedBox(height: 22),
                                const Padding(
                                  padding: EdgeInsets.only(left: 2),
                                  child: Text(
                                    "Like towards the reaction to the situation?",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                homeProvider.journalDetails == null
                                    ? const SizedBox()
                                    : CustomRatingBar(
                                        color: ColorsContent.newThemeColor,
                                        initialRating: double.parse(
                                          (homeProvider.journalDetails!.journals!.driveValue ?? 0).toString(),
                                        ),
                                        itemSize: 35,
                                  isRatingStatic: true, // Set to true to make rating unchangeable
                                      ),
                                const SizedBox(height: 29),
                                homeProvider.journalDetails?.journals?.goal == null?
                                const SizedBox():
                                const Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text(
                                    "Goal affected by your reaction",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                homeProvider.journalDetails?.journals?.goal == null
                                    ?   const SizedBox()
                                    : GestureDetector(
                                  onTap: (){
                                    mentalStrengthEditProvider
                                        .openGoalViewSheetFunction();
                                    mentalStrengthEditProvider
                                        .fetchGoalDetails(
                                      goalId:
                                      homeProvider.journalDetails!
                                          .journals!.goal!.goalId
                                          .toString(),
                                      context: context
                                    );
                                  },
                                      child:
                                      Container(
                                        height: size.height * 0.05,
                                        width: size.width * 0.88,
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: ColorsContent.newThemeColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                  child: Text(
                                                    homeProvider.journalDetails?.journals?.goal?.goalTitle ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: 'Poppins',
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                mentalStrengthEditProvider.openGoalViewSheetFunction();
                                                mentalStrengthEditProvider.fetchGoalDetails(
                                                  goalId: homeProvider.journalDetails!.journals!.goal!.goalId.toString(),
                                                  context: context,
                                                );
                                              },
                                              child: CircleAvatar(
                                                radius: size.width * 0.03,
                                                backgroundColor: ColorsContent.actionBackColor,
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Colors.white,
                                                  size: size.width * 0.04,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )

                                ),
                                homeProvider.journalDetails?.journals?.goal == null ?
                                    const SizedBox():
                                const SizedBox(height: 20),
                                homeProvider.journalDetails!.journals!.action!.isEmpty?
                                    const SizedBox():
                                const Padding(
                                  padding: EdgeInsets.only(left: 7),
                                  child: Text(
                                    "Your action",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                homeProvider.journalDetails?.journals?.action == null ||
                                    homeProvider.journalDetails!.journals!.action!.isEmpty
                                    ? const SizedBox()
                                    : SizedBox(
                                  height: (homeProvider.journalDetails?.journals?.action?.length ?? 0) * (size.height * 0.065),
                                  width: size.width * 0.88,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const BouncingScrollPhysics(), // Or ScrollPhysics() for default
                                    itemCount: homeProvider.journalDetails!.journals!.action!.length,
                                    itemBuilder: (context, index) {
                                      final action = homeProvider.journalDetails!.journals!.action![index];
                                      final actionId = action.actionId;

                                      return GestureDetector(
                                        onTap: () async {
                                          if (actionId != null) {
                                            await mentalStrengthEditProvider.fetchActionDetails(actionId: actionId,context: context);
                                            debugPrint("✅ Fetched action details for ID: $actionId");

                                            if (mentalStrengthEditProvider.actionDetailsStatus == 200) {
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (_, __, ___) => const ActionViewInParallelScreen(),
                                                  transitionDuration: const Duration(seconds: 0),
                                                ),
                                              );
                                            }
                                          } else {
                                            debugPrint("⚠️ No valid actionId found.");
                                          }
                                        },
                                        child: Container(
                                          height: size.height * 0.05, // slightly increased for better alignment
                                          margin: const EdgeInsets.only(bottom: 5),
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: ColorsContent.newThemeColor,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center, // ensure vertical alignment
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                  child: Text(
                                                    action.actionTitle ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: 'Poppins',
                                                      color: Colors.white,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              CircleAvatar(
                                                radius: size.width * 0.03,
                                                backgroundColor: ColorsContent.actionBackColor,
                                                child: Icon(
                                                  Icons.arrow_forward_ios,
                                                  color: Colors.white,
                                                  size: size.width * 0.04,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      );
                                    },
                                  ),
                                ),
                                homeProvider.journalDetails?.journals?.chatlink != null && homeProvider.journalDetails!.journals!.chatlink!.isNotEmpty ?
                                GestureDetector(
                                  onTap: () {
                                    final linkUrl = homeProvider.journalDetails?.journals?.chatlink;
                                    final chatTitle = homeProvider.journalDetails?.journals?.chatpage_title;

                                    if (linkUrl != null && linkUrl.isNotEmpty) {
                                      _launchInAppWithBrowserOptions(Uri.parse(linkUrl),chatTitle!, context);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('No chat link available'),
                                        ),
                                      );
                                    }
                                  },
                                  child: Center(
                                    child: SvgPicture.asset(
                                      height: 70,
                                      ImageConstant.summaryChatIcon,
                                    ),
                                  ),
                                ):SizedBox(),


                                const SizedBox(height: 10),
                              ],
                            ):
                      mentalStrengthEditProvider.goalDetailModel == null
                          ? Container(
                        decoration: BoxDecoration(
                          color: appTheme.gray50,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(25),
                            topLeft: Radius.circular(25),
                          ),
                        ),
                        margin: EdgeInsets.only(
                          top: size.height * 0.0,
                        ),
                        child: shimmerList(
                          height: size.height * 0.8,
                          list: 10,
                        ),
                      )
                          : Center(
                        child: GoalAndDreamFullViewBottomParellelSheet(
                          goalDetailModel: mentalStrengthEditProvider.goalDetailModel!,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildUntitledOne(BuildContext context, Size size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Consumer2<EditProfileProvider,HomeProvider>(builder: (context,editProfileProvider, homeProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width:372,
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                // decoration: BoxDecoration(
                //   color: ColorsContent.dateTimeBack,
                //   borderRadius: BorderRadius.circular(2),
                // ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                           Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                            color: ColorsContent.newThemeColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            homeProvider.journalDetails == null
                                ? ""
                                : dateFormatterViewJournal(
                              date: homeProvider
                                  .journalDetails!.journals!.journalDatetime
                                  .toString(),
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: ColorsContent.blackText,
                            ),
                          ),
                          const SizedBox(width: 30),
                          SvgPicture.asset(
                            ImageConstant.line, // Button icon
                          ),
                          const SizedBox(width: 30),
                           Icon(
                            Icons.access_time,
                            size: 20,
                            color: ColorsContent.newThemeColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            homeProvider.journalDetails == null
                                ? ""
                                : timeFormatter(
                              date: homeProvider
                                  .journalDetails!.journals!.journalDatetime
                                  .toString(),
                            ),
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: ColorsContent.blackText,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Consumer5<DashBoardProvider,JournalListProvider, HomeProvider, MentalStrengthEditProvider,
                        EditProfileProvider>(
                        builder: (contexts, dashBoardProvider,journalListProvider, homeProvider,
                            mentalStrengthEditProvider, editProfileProvider, _) {
                          return PopupMenuButton<String>(
                            color: Colors.white,
                            icon: Icon(Icons.more_vert, color: ColorsContent.newThemeColor), // 👈 Vertical dots icon
                            padding: EdgeInsets.zero, // Removes extra padding
                            constraints: const BoxConstraints(
                              minWidth: 100, // 👈 Reduce width here
                              maxWidth: 100,
                            ),
                            onSelected: (value) {},
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem<String>(
                                  onTap: () async {
                                    mentalStrengthEditProvider.openAllCloser();
                                    editProfileProvider.fetchUserProfile(context);
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
                                            'image' &&  homeProvider.journalDetails?.journals!.journalMedia![i].is_chart != '1') {
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

                                        mentalStrengthEditProvider.selectedLongitude =
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
                                          context: context
                                      );
                                      // log(message)

                                      mentalStrengthEditProvider.driveValueStar = double.parse(
                                          homeProvider.journalDetails!.journals!.driveValue
                                              .toString());
                                      if (homeProvider.journalDetails!.journals!.goal != null) {
                                        mentalStrengthEditProvider.goalsValue = goalMain.Goal(
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
                                        mentalStrengthEditProvider.actionList.add(action.Action(
                                          title: homeProvider
                                              .journalDetails!.journals!.action![i].actionTitle,
                                          id: homeProvider
                                              .journalDetails!.journals!.action![i].actionId,
                                        ));
                                      }
                                    }
                                    // Navigator.of(context).push(
                                    //   MaterialPageRoute(
                                    //     builder: (context) => const EditJournalMentalStrength(
                                    //       valueBool: true,
                                    //     ),
                                    //   ),
                                    // );

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => const NumuEditJournalScreen(
                                          valueBool: true,
                                        ),
                                      ),
                                    );

                                  },
                                  value: 'Edit',
                                  height: 20, // 👈 Reduce height here
                                  child:
                                  Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.mode_edit_outline_outlined, color: ColorsContent.newThemeColor),
                                        const SizedBox(width: 5),
                                        const Padding(
                                          padding: EdgeInsets.only(right: 12.0),
                                          child: Text('Edit', style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Roboto',
                                            color:  Colors.black,
                                          )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const PopupMenuDivider(), // 👈 This adds the divider
                                PopupMenuItem<String>(
                                  onTap: () {
                                    customPopup(
                                      context: context,
                                      onPressedDelete: () {
                                        journalListProvider
                                            .deleteJournalsFunction(
                                          journalId: homeProvider.journalDetails!.journals!.journalId.toString(),
                                        )
                                            .then((value) async {

                                          // Check if the journal exists in the list and remove it
                                          for (var journals in homeProvider.journalsModelList) {
                                            if (journals.journalId ==
                                                homeProvider.journalDetails!.journals!.journalId.toString()) {
                                              homeProvider.journalsModelList.removeAt(widget.index);
                                              break; // Stop the loop once item is removed
                                            }
                                          }
                                          await homeProvider.fetchJournals(pageNo:homeProvider.currentPage.toString(),context: context);
                                          await homeProvider.fetchJournalsGridView(initial: true,context: context,fullList: true);
                                          //   await homeProvider.fetchJournalsGridView(pageNo:homeProvider.currentPage.toString(),context: context);
                                          if(homeProvider.journalStatus == 404){
                                            await homeProvider.fetchJournals(pageNo:1.toString(),context: context);
                                            await homeProvider.fetchJournalsGridView(initial: true,context: context,fullList: true);
                                            //await homeProvider.fetchJournalsGridView(pageNo:1.toString(),context: context);
                                          }
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content:
                                                Text("Journals deleted successfully")),
                                          );
                                          // Close the dialog and then close the previous screen if needed
                                          await Future.delayed(const Duration(seconds: 0));
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        });
                                      },
                                      title: 'Confirm Delete',
                                      content: 'Are you sure you want to delete this journals?',
                                    );
                                  },
                                  height: 20, // 👈 Reduce height here
                                  value: 'Delete',
                                  child:
                                  Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.delete_outline, color: ColorsContent.newThemeColor),
                                        const SizedBox(width: 5),
                                        const Text('Delete',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Roboto',
                                              color:  Colors.black,
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                              ];
                            },
                          );
                        }),
                  ],
                ),
              ),

              homeProvider.journalDetails!.journals!.location != null ?
                  const SizedBox(height: 5,):const SizedBox(),
              homeProvider.journalDetails!.journals!.location == null ?
                  const SizedBox():
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 320,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons
                          .location_on_rounded,
                      color: ColorsContent.newThemeColor,
                      size: size.width *
                          0.06,
                    ),
                    Flexible(
                      child: Text(
                        homeProvider.journalDetails
                            ?.journals
                            ?.location
                            ?.locationName
                            ?.replaceAll(RegExp(r'[^a-zA-Z0-9, ]'), '') // Remove unwanted characters
                            .replaceAll(RegExp(r',\s*,+'), ',') // Replace multiple consecutive commas with a single comma
                            .replaceAll(RegExp(r'^,|,$'), '') // Remove leading and trailing commas
                            .trim() ?? "",
                        style: CustomTextStyles.bodyMediumGray700_1,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        const Spacer(),
      ],
    );
  }


// Updated launch function
  void _launchInAppWithBrowserOptions(Uri url, String title,BuildContext context) async {
    logger.i("Launching URL in custom bottom sheet: $url");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: ChatGptBottomSheet(initialUrl: url,chatTitle: title,),
      ),
    );
  }

  /// Section Widget
}
