import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/widget/googlemap_widget/google_map_widget.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/widget/popup/audio_popup_goals.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/widget/popup/camera_popup.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/widget/popup/gallary_popup_add_goals.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/model/get_category.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/mental_strength_add_edit_page.dart';
import 'package:mentalhelth/utils/core/image_constant.dart';
import 'package:mentalhelth/utils/theme/app_decoration.dart';
import 'package:mentalhelth/utils/theme/custom_text_style.dart';
import 'package:mentalhelth/utils/theme/theme_helper.dart';
import 'package:mentalhelth/widgets/app_bar/appbar_leading_image.dart';
import 'package:mentalhelth/widgets/custom_elevated_button.dart';
import 'package:mentalhelth/widgets/custom_image_view.dart';
import 'package:mentalhelth/widgets/custom_text_form_field.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/core/date_time_utils.dart';
import '../../utils/logic/permissions.dart';
import '../../utils/theme/colors.dart';
import '../../utils/theme/custom_button_style.dart';
import '../../widgets/functions/popup.dart';
import '../SharePostView.dart';
import '../addactions_screen/addactions_screen.dart';
import '../addactions_screen/provider/add_actions_provider.dart';
import '../dash_borad_screen/provider/dash_board_provider.dart';
import '../goals_dreams_page/provider/goals_dreams_provider.dart';
import '../home_screen/provider/home_provider.dart';
import '../mental_strength_add_edit_screen/model/all_model.dart';
import '../mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import '../no_internet/duplicate_screen.dart';
import '../token_expiry/tocken_expiry_warning_screen.dart';
import '../token_expiry/token_expiry.dart';
import 'model/all_Goals_List_Link_Response_Model.dart';
import 'model/id_model.dart';
import 'provider/ad_goals_dreams_provider.dart';

const MethodChannel shareDataChannel = MethodChannel('com.numuapp.numuapp/shareData');

class AddGoalsLinkParScreen extends StatefulWidget {
  const AddGoalsLinkParScreen({
    Key? key,
    this.onClose,
    this.sharedUrl,
    this.sharedText,
    this.sharedImages,
  }) : super(key: key);

  final VoidCallback? onClose;
  final String? sharedUrl;
  final String? sharedText;
  final List<String>? sharedImages;

  @override
  State<AddGoalsLinkParScreen> createState() => _AddGoalsLinkParScreenState();
}

class _AddGoalsLinkParScreenState extends State<AddGoalsLinkParScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late HomeProvider homeProvider;
  late MentalStrengthEditProvider mentalStrengthEditProvider;
  late EditProfileProvider editProfileProvider;
  late DashBoardProvider dashBoardProvider;
  late AdDreamsGoalsProvider adDreamsGoalsProvider;
  bool tokenStatus = false;
  var logger = Logger();
  PermissionStatus permissionStatus = PermissionStatus.denied;
  late FocusNode _goalNameFocusNode;
  late FocusNode _goalDescFocusNode;
  SharedContentData? sharedData;
  bool isLoading = true;
  bool _isLoadingNew = false;
  String? unixTimestamp;
  bool isLoadingSomeTime = true;

  @override
  void initState() {
    debugPrint('🎯 AddGoalsLinkParScreen initState called');

    // Step 1: Initialize focus nodes FIRST
    _goalNameFocusNode = FocusNode();
    _goalDescFocusNode = FocusNode();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isLoadingSomeTime = false;
        });
      }
    });

    // Step 2: Load shared content SYNCHRONOUSLY first (check injected data only)
    _loadSharedContentSync();
    debugPrint('✅ Sync shared content load completed');

    // Step 3: Get provider instances (synchronous, safe)
    try {
      homeProvider = Provider.of<HomeProvider>(context, listen: false);
      mentalStrengthEditProvider = Provider.of<MentalStrengthEditProvider>(context, listen: false);
      dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
      editProfileProvider = Provider.of<EditProfileProvider>(context, listen: false);
      adDreamsGoalsProvider = Provider.of<AdDreamsGoalsProvider>(context, listen: false);
      debugPrint('✅ Providers initialized');
    } catch (e) {
      debugPrint('❌ Provider initialization error: $e');
      super.initState();
      return;
    }

    // Step 4: Clear all fields immediately (synchronous)
    try {
      adDreamsGoalsProvider.selectedOption = "";
      adDreamsGoalsProvider.selectedExistingGoal = null;
      adDreamsGoalsProvider.goalListLink = [];
      adDreamsGoalsProvider.selectedOption = "Create New Goal";
      _goalNameFocusNode.unfocus();
      _goalDescFocusNode.unfocus();

      adDreamsGoalsProvider.nameEditTextController.text = "";
      editProfileProvider.interestsValueController.text = "";
      adDreamsGoalsProvider.selectedDate = "";
      adDreamsGoalsProvider.commentEditTextController.text = "";
      adDreamsGoalsProvider.recordedFilePath.clear();
      adDreamsGoalsProvider.pickedImages.clear();
      adDreamsGoalsProvider.takedImages.clear();
      adDreamsGoalsProvider.selectedLocationName = "";
      adDreamsGoalsProvider.mediaSelected = 0;
      adDreamsGoalsProvider.detectedLinks.clear();

      debugPrint('✅ Fields cleared');
    } catch (e) {
      debugPrint('❌ Field clearing error: $e');
    }

    // Step 5: Handle shared data (NOW sharedData should be populated)
    if (sharedData != null && (sharedData!.url ?? '').isNotEmpty) {
      try {
        adDreamsGoalsProvider.detectedLinks.clear();
        adDreamsGoalsProvider.detectedLinks.add(sharedData!.url!);
        adDreamsGoalsProvider.editDetectedLinks.clear();
        adDreamsGoalsProvider.editDetectedLinks.add(sharedData!.url!);
        debugPrint('✅ Shared data loaded: ${sharedData!.url}');
      } catch (e) {
        debugPrint('❌ Shared data error: $e');
      }
    } else {
      debugPrint('⚠️ No shared data available');
    }

    // Step 6: Load async data in background (don't wait for it)
    _loadSharedContentAsync();

    // Step 7: Schedule async initialization LATER (give widget time to build first)
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        debugPrint('⏱️ 1 second delay passed, starting async initialization');
        _initializeAsyncData();
      }
    });

    super.initState();
    debugPrint('✅ AddGoalsLinkParScreen initState completed');
  }

  /// Load INJECTED shared content SYNCHRONOUSLY (no platform channel)
  void _loadSharedContentSync() {
    debugPrint('📍 Loading injected shared content synchronously');

    try {
      final hasInjected = (widget.sharedUrl != null && widget.sharedUrl!.isNotEmpty) ||
          (widget.sharedText != null && widget.sharedText!.isNotEmpty) ||
          ((widget.sharedImages?.isNotEmpty) ?? false);

      if (hasInjected) {
        debugPrint('✅ Injected content found');
        sharedData = SharedContentData(
          text: null,
          url: widget.sharedUrl,
          sharedText: widget.sharedText,
          imagePaths: List<String>.from(widget.sharedImages ?? const <String>[]),
          timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        );
        debugPrint('✅ Injected data set: url=${sharedData!.url}');
        isLoading = false;
        return;
      }

      debugPrint('⚠️ No injected content found');
      isLoading = false;
    } catch (e) {
      debugPrint('❌ Error in _loadSharedContentSync: $e');
      sharedData = null;
      isLoading = false;
    }
  }

  /// Load from platform channel ASYNCHRONOUSLY in background
  Future<void> _loadSharedContentAsync() async {
    debugPrint('📍 Loading platform channel data asynchronously in background');

    try {
      // Only load from platform if no injected data
      final hasInjected = (widget.sharedUrl != null && widget.sharedUrl!.isNotEmpty) ||
          (widget.sharedText != null && widget.sharedText!.isNotEmpty) ||
          ((widget.sharedImages?.isNotEmpty) ?? false);

      if (hasInjected) {
        debugPrint('⏭️ Skipping platform channel - using injected data');
        return;
      }

      final Map<dynamic, dynamic>? result =
      await shareDataChannel.invokeMethod<Map<dynamic, dynamic>>('getSharedData');

      if (result == null) {
        debugPrint('⚠️ No data from platform channel');
        sharedData = null;
        return;
      }

      final json = result.cast<String, dynamic>();
      final String? text = json['text'] as String?;
      final String? url = json['url'] as String?;
      final String? sharedText = json['sharedText'] as String?;
      final dynamic tVal = json['timestamp'];
      final int? timestamp = tVal is num ? tVal.toInt() : null;
      final int imageCount = json['imageCount'] as int? ?? 0;

      List<String> imagePaths = <String>[];
      if (Platform.isIOS && imageCount > 0) {
        imagePaths = await _getImagePathsFromAppGroup(imageCount);
      } else if (json['images'] is List) {
        imagePaths = List<String>.from((json['images'] as List).map((e) => e.toString()));
      }

      sharedData = SharedContentData(
        text: text,
        url: url,
        sharedText: sharedText,
        imagePaths: imagePaths,
        timestamp: timestamp ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      );

      debugPrint('✅ Platform channel data loaded: url=$url');

      // Clear after reading
      try {
        await shareDataChannel.invokeMethod('clearSharedData');
      } catch (_) {}
    } on PlatformException catch (e) {
      debugPrint('❌ Platform error: ${e.message}');
      sharedData = null;
    } catch (e) {
      debugPrint('❌ Failed to read shared content: $e');
      sharedData = null;
    }
  }

  /// Separate method for async initialization to handle cold start properly
  Future<void> _initializeAsyncData() async {
    debugPrint('🔄 Starting async initialization');

    try {
      // Safety check 1: Widget mounted?
      if (!mounted) {
        debugPrint('⚠️ Widget not mounted, skipping async init');
        return;
      }

      // Safety check 2: Context valid?
      if (context.mounted == false) {
        debugPrint('⚠️ Context not mounted, skipping async init');
        return;
      }

      debugPrint('📍 Step 1: Clearing location selection');
      try {
        adDreamsGoalsProvider.clearLocationSelection();
        debugPrint('✅ Step 1 completed');
      } catch (e) {
        debugPrint('⚠️ Step 1 error: $e');
      }

      // Check mounted
      if (!mounted) {
        debugPrint('⚠️ Widget unmounted after step 1');
        return;
      }

      debugPrint('📍 Step 2: Fetching all goals for link');
      try {
        await adDreamsGoalsProvider.fetchAllGoalsForLink(context);
        debugPrint('✅ Step 2 completed');
      } catch (e) {
        debugPrint('⚠️ Step 2 error: $e');
      }

      // Check mounted
      if (!mounted) {
        debugPrint('⚠️ Widget unmounted after step 2');
        return;
      }

      debugPrint('📍 Step 3: Checking token expiry');
      try {
        await _isTokenExpired();
        debugPrint('✅ Step 3 completed');
      } catch (e) {
        debugPrint('⚠️ Step 3 error: $e');
      }

      // Check mounted
      if (!mounted) {
        debugPrint('⚠️ Widget unmounted after step 3');
        return;
      }

      debugPrint('📍 Step 4: Fetching categories');
      try {
        await editProfileProvider.fetchCategory();
        debugPrint('✅ Step 4 completed');
      } catch (e) {
        debugPrint('⚠️ Step 4 error: $e');
      }

      // Check mounted
      if (!mounted) {
        debugPrint('⚠️ Widget unmounted after step 4');
        return;
      }

      debugPrint('📍 Step 5: Clearing goal model ID names');
      try {
        adDreamsGoalsProvider.goalModelIdName.clear();
        debugPrint('✅ Step 5 completed');
      } catch (e) {
        debugPrint('⚠️ Step 5 error: $e');
      }

      debugPrint('✅ All async initialization completed successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ FATAL Error in async initialization: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        try {
          showCustomSnackBar(
            context: context,
            message: 'Error loading data. Please refresh.',
          );
        } catch (_) {
          debugPrint('⚠️ Could not show snack bar');
        }
      }
    }
  }

  /// Updated _isTokenExpired to be async and safe
  Future<void> _isTokenExpired() async {
    try {
      if (!mounted) return;

      await homeProvider.fetchJournals(initial: true, context: context);

      if (!mounted) return;

      tokenStatus = TokenManager.checkTokenExpiry();

      if (tokenStatus && mounted) {
        setState(() {
          logger.e("Token status changed: $tokenStatus");
        });
      }
    } catch (e) {
      debugPrint('❌ Error in _isTokenExpired: $e');
    }
  }

  void applyRiskLogicInit() {
    try {
      EditProfileProvider editProfileProvider = Provider.of<EditProfileProvider>(context, listen: false);
      AdDreamsGoalsProvider adDreamsGoalsProvider = Provider.of<AdDreamsGoalsProvider>(context, listen: false);

      adDreamsGoalsProvider.alreadyRecordedFilePath.clear();
      adDreamsGoalsProvider.alreadyPickedImages.clear();
      adDreamsGoalsProvider.goalModelIdName.clear();

      final goal = mentalStrengthEditProvider.goalDetailModel;
      if (goal == null) return;

      adDreamsGoalsProvider.nameEditTextController.text = goal.goals?.goalTitle ?? '';
      adDreamsGoalsProvider.commentEditTextController.text = goal.goals?.goalDetails ?? '';

      if (goal.goals?.gemMedia != null) {
        for (var media in goal.goals!.gemMedia!) {
          if (media.mediaType == 'audio') {
            adDreamsGoalsProvider.alreadyRecordedFilePath.add(
              AllModel(id: media.mediaId.toString(), value: media.gemMedia.toString()),
            );
          } else if (media.mediaType == 'image' || media.mediaType == 'video') {
            adDreamsGoalsProvider.alreadyPickedImages.add(
              AllModel(id: media.mediaId.toString(), value: media.gemMedia.toString()),
            );
          }
        }
      }

      adDreamsGoalsProvider.selectedDate = formatDate2(
        goal.goals?.goalEnddate == null || goal.goals?.goalEnddate == ""
            ? DateTime.now().microsecondsSinceEpoch
            : int.parse(goal.goals!.goalEnddate!),
      );

      adDreamsGoalsProvider.selectedLocationName = goal.goals?.location?.locationName ?? '';
      adDreamsGoalsProvider.selectedLatitude = goal.goals?.location?.locationLatitude ?? '';
      adDreamsGoalsProvider.selectedLongitude = goal.goals?.location?.locationLongitude ?? '';
      adDreamsGoalsProvider.selectedLocationAddress = goal.goals?.location?.locationAddress ?? '';

      final selectedCat = Category(
        id: goal.goals?.categoryId?.toString(),
        categoryName: goal.goals?.categoryName?.toString(),
        categoryImg: "",
      );

      editProfileProvider.categorys = selectedCat;
      editProfileProvider.selectedCategory = selectedCat;
      unixTimestamp = goal.goals!.goalEnddate.toString();

      if (goal.goals?.action != null && goal.goals!.action!.isNotEmpty) {
        for (int i = 0; i < goal.goals!.action!.length; i++) {
          adDreamsGoalsProvider.getAddActionIdAndName(
            value: GoalModelIdName(
              id: goal.goals!.action![i].actionId.toString(),
              name: goal.goals!.action![i].actionTitle.toString(),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("⚠️ Risk logic failed: $e");
    }
  }


  Future<List<String>> _getImagePathsFromAppGroup(int imageCount) async {
    final List<String> paths = [];
    try {
      final Directory baseDir = Directory('/var/mobile/Containers/Shared/AppGroup');
      if (!baseDir.existsSync()) return paths;

      for (final entity in baseDir.listSync()) {
        if (entity is! Directory) continue;
        for (int i = 0; i < imageCount; i++) {
          final f = File('${entity.path}/sharedImage$i.jpg');
          if (f.existsSync()) paths.add(f.path);
        }
        if (paths.isNotEmpty) break;
      }
    } catch (e) {
      debugPrint('Error scanning app group images: $e');
    }
    return paths;
  }



  @override
  void dispose() {
    _goalNameFocusNode.dispose();
    _goalDescFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adDreamsGoalsProvider = Provider.of<AdDreamsGoalsProvider>(context, listen: false);
    Size size = MediaQuery.of(context).size;

    return tokenStatus == false
        ? SafeArea(
      child: Scaffold(
        appBar: buildAppBarNumuEditGoals(
          context,
          size,
          heading: adDreamsGoalsProvider.selectedOption == "Add to Existing Goal"
              ? "Share Goal & Dreams"
              : "Share Goal & Dreams",
        ),
        body: Stack(
          children: [
            Container(
              width: size.width,
              height: size.height,
              decoration: BoxDecoration(
                color: ColorsContent.homeBackGroundColor,
              ),
              child: Form(
                key: _formKey,
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 6),
                  child: Consumer2<AdDreamsGoalsProvider, MentalStrengthEditProvider>(
                    builder: (context, adDreamsGoalsProvider, mentalStrengthEditProvider, _) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ✅ FIRST DROPDOWN - ALWAYS ENABLED
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0.0),
                              child: Container(
                                decoration: ShapeDecoration(
                                  color: ColorsContent.linkDropDownBackGroundColor,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(width: 0.8, color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: DropdownButtonFormField<String>(
                                  hint: Text("Select Category", style: CustomTextStyles.bodySmallGray700),
                                  style: CustomTextStyles.bodySmallGray700,
                                  iconEnabledColor: ColorsContent.newThemeColor,
                                  iconDisabledColor: ColorsContent.newThemeColor,
                                  value: adDreamsGoalsProvider.goalOptions.contains(adDreamsGoalsProvider.selectedOption)
                                      ? adDreamsGoalsProvider.selectedOption
                                      : (adDreamsGoalsProvider.goalOptions.contains("Create New Goal") ? "Create New Goal" : null),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      adDreamsGoalsProvider.selectedOption = newValue;

                                      // ✅ When switching back to "Create New Goal", clear everything except shared link
                                      if (newValue == "Create New Goal") {
                                        adDreamsGoalsProvider.selectedExistingGoal = null;
                                        adDreamsGoalsProvider.nameEditTextController.text = "";
                                        adDreamsGoalsProvider.commentEditTextController.text = "";
                                        adDreamsGoalsProvider.selectedDate = "";

                                        // Clear all media
                                        adDreamsGoalsProvider.recordedFilePath.clear();
                                        adDreamsGoalsProvider.pickedImages.clear();
                                        adDreamsGoalsProvider.takedImages.clear();
                                        adDreamsGoalsProvider.alreadyRecordedFilePath.clear();
                                        adDreamsGoalsProvider.alreadyPickedImages.clear();

                                        // Clear location
                                        adDreamsGoalsProvider.selectedLocationName = "";
                                        adDreamsGoalsProvider.selectedLatitude = "";
                                        adDreamsGoalsProvider.selectedLongitude = "";
                                        adDreamsGoalsProvider.selectedLocationAddress = "";

                                        // Clear actions
                                        adDreamsGoalsProvider.goalModelIdName.clear();

                                        // Clear category
                                        editProfileProvider.categorys = null;
                                        editProfileProvider.selectedCategory = null;
                                        editProfileProvider.interestsValueController.text = "";

                                        adDreamsGoalsProvider.mediaSelected = 0;

                                        // ✅ Keep ONLY the shared link
                                        if (sharedData != null && (sharedData!.url ?? '').isNotEmpty) {
                                          if (!adDreamsGoalsProvider.detectedLinks.contains(sharedData!.url!)) {
                                            adDreamsGoalsProvider.detectedLinks.clear();
                                            adDreamsGoalsProvider.detectedLinks.add(sharedData!.url!);
                                          }
                                        }

                                        adDreamsGoalsProvider.editDetectedLinks.clear();
                                        unixTimestamp = null;
                                      }

                                      if (newValue != "Add to Existing Goal") {
                                        adDreamsGoalsProvider.selectedExistingGoal = null;
                                      }
                                    });
                                  },
                                  items: (adDreamsGoalsProvider.goalListLink.isEmpty
                                      ? ["Create New Goal"]
                                      : [
                                    if (!adDreamsGoalsProvider.goalOptions.contains("Create New Goal")) "Create New Goal",
                                    ...adDreamsGoalsProvider.goalOptions,
                                  ])
                                      .toSet()
                                      .map((String option) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(option),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),

                            const SizedBox(height: 5),

                            // SECOND DROPDOWN (only when needed)
                            if (adDreamsGoalsProvider.selectedOption == "Add to Existing Goal") ...[
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                                child: Container(
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(width: 0.8, color: Colors.transparent),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: IgnorePointer(
                                    ignoring: _isLoadingNew,
                                    child: DropdownButtonFormField<String>(
                                      hint: Text("Select Existing Goal", style: CustomTextStyles.bodySmallGray700),
                                      value: (() {
                                        final selected = adDreamsGoalsProvider.selectedExistingGoal;
                                        final list = adDreamsGoalsProvider.goalListLink;
                                        if (selected == null || list.isEmpty) return null;

                                        final exists = list.any((g) => g.id?.toString() == selected);
                                        if (exists) {
                                          return selected;
                                        } else {
                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                            if (mounted) {
                                              adDreamsGoalsProvider.selectedExistingGoal = null;
                                            }
                                          });
                                          return null;
                                        }
                                      })(),
                                      iconEnabledColor: ColorsContent.newThemeColor,
                                      iconDisabledColor: ColorsContent.newThemeColor,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                      ),
                                      items: (() {
                                        final list = adDreamsGoalsProvider.goalListLink;
                                        final Map<String, dynamic> uniqueGoals = {};
                                        for (var goalItem in list) {
                                          if (goalItem.id != null) {
                                            uniqueGoals[goalItem.id!.toString()] = goalItem;
                                          }
                                        }
                                        return uniqueGoals.entries.map((entry) {
                                          final goalItem = entry.value;
                                          return DropdownMenuItem<String>(
                                            value: entry.key,
                                            child: Text(
                                              goalItem.title ?? 'Unnamed Goal',
                                              style: CustomTextStyles.bodySmallGray700,
                                            ),
                                          );
                                        }).toList();
                                      })(),
                                      onChanged: (String? newValue) async {
                                        if (newValue == null || newValue.isEmpty) return;

                                        setState(() {
                                          adDreamsGoalsProvider.selectedExistingGoal = newValue;
                                          _isLoadingNew = true;
                                        });

                                        try {
                                          adDreamsGoalsProvider.goalModelIdName.clear();
                                          await mentalStrengthEditProvider.fetchGoalDetails(
                                            goalId: newValue,
                                            context: context,
                                          );
                                          applyRiskLogicInit();
                                        } catch (e) {
                                          debugPrint("⚠️ Error fetching goal details: $e");
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _isLoadingNew = false;
                                            });
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 15),
                            _buildNameEditText(context),
                            const SizedBox(height: 15),

                            Consumer<EditProfileProvider>(
                              builder: (context, editProfileProvider, _) {
                                final categoryList = editProfileProvider.getCategoryModel?.category ?? [];
                                Category? selectedCategory = editProfileProvider.selectedCategory;

                                if (selectedCategory != null && categoryList.isNotEmpty) {
                                  final match = categoryList.firstWhere(
                                        (cat) => cat.id.toString() == selectedCategory?.id.toString(),
                                    orElse: () => Category(id: '', categoryName: '', categoryImg: ''),
                                  );
                                  if (match.id == '') {
                                    selectedCategory = null;
                                  } else {
                                    selectedCategory = match;
                                  }
                                }

                                return Container(
                                  height: size.height * 0.055,
                                  padding: const EdgeInsets.only(left: 10, right: 5),
                                  decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(width: 0.8, color: Colors.transparent),
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  child: categoryList.isEmpty
                                      ? const SizedBox()
                                      : DropdownButton<Category>(
                                    value: selectedCategory,
                                    items: categoryList.map((Category value) {
                                      return DropdownMenuItem<Category>(
                                        value: value,
                                        child: Text(
                                          value.categoryName ?? '',
                                          style: CustomTextStyles.bodySmallGray700,
                                        ),
                                      );
                                    }).toList(),
                                    hint: Text(
                                      editProfileProvider.interestsValueController.text.isEmpty
                                          ? 'Select a category'
                                          : editProfileProvider.interestsValueController.text,
                                      style: CustomTextStyles.bodySmallGray700,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    underline: const SizedBox(),
                                    isExpanded: true,
                                    iconEnabledColor: ColorsContent.newThemeColor,
                                    iconDisabledColor: ColorsContent.newThemeColor,
                                    onChanged: (value) {
                                      if (value != null) {
                                        editProfileProvider.selectedCategory = value;
                                        editProfileProvider.selectCategory(
                                          value: value.categoryName.toString(),
                                          mainCategory: value,
                                        );
                                        _isTokenExpired();
                                        editProfileProvider.notifyListeners();
                                      }
                                    },
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 15),
                            _buildAchievementDate(context),
                            const SizedBox(height: 25),

                            adDreamsGoalsProvider.selectedOption == 'Add to Existing Goal'
                                ? _buildAddMediaColumnEdit(context, size)
                                : _buildAddMediaColumn(context, size),

                            const SizedBox(height: 11),
                            const SizedBox(height: 24),

                            adDreamsGoalsProvider.selectedOption == 'Add to Existing Goal'
                                ? _buildCommentEditTextEditLink(context)
                                : _buildCommentEditText(context),

                            const SizedBox(height: 25),
                            Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Text(
                                "Actions to achieve the goal",
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                            const SizedBox(height: 3),
                            _buildAddActionsButton(context),
                            const SizedBox(height: 15),

                            adDreamsGoalsProvider.selectedOption == 'Add to Existing Goal'
                                ? Consumer2<AdDreamsGoalsProvider, AddActionsProvider>(
                              builder: (context, adDreamsGoalsProvider, addActionsProvider, _) {
                                return SizedBox(
                                  height: adDreamsGoalsProvider.goalModelIdName.length * size.height * 0.065,
                                  child: ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: adDreamsGoalsProvider.goalModelIdName.length,
                                    itemBuilder: (context, index) {
                                      var data = adDreamsGoalsProvider.goalModelIdName[index];
                                      return Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              margin: const EdgeInsets.only(bottom: 10),
                                              height: size.height * 0.055,
                                              width: size.width * 0.86,
                                              padding: const EdgeInsets.only(bottom: 5, top: 5, left: 0, right: 5),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(5),
                                                border: Border.all(color: Colors.grey, width: 0.5),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () async {
                                                      customPopup(
                                                        context: context,
                                                        onPressedDelete: () async {
                                                          adDreamsGoalsProvider.getAddActionIdAndNameClear(index);
                                                          await addActionsProvider.deleteActionFunction(
                                                            deleteId: data.id,
                                                            context: context,
                                                          );
                                                          Navigator.of(context).pop();
                                                        },
                                                        yes: "Yes",
                                                        title: 'Do you Need Delete',
                                                        content: 'Are you sure do you need delete',
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                      child: CircleAvatar(
                                                        radius: size.width * 0.04,
                                                        backgroundColor: ColorsContent.newThemeColor,
                                                        child: Icon(
                                                          Icons.close_outlined,
                                                          color: Colors.white,
                                                          size: size.width * 0.04,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                    child: SingleChildScrollView(
                                                      scrollDirection: Axis.horizontal,
                                                      child: SizedBox(
                                                        width: 250,
                                                        child: Text(
                                                          data.name,
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 4,
                                                          textAlign: TextAlign.start,
                                                          style: const TextStyle(
                                                            fontFamily: 'Poppins',
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.w400,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              },
                            )
                                : Consumer<AdDreamsGoalsProvider>(
                              builder: (context, adDreamsGoalsProvider, _) {
                                return SizedBox(
                                  height: adDreamsGoalsProvider.goalModelIdName.length * size.height * 0.06,
                                  child: ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: adDreamsGoalsProvider.goalModelIdName.length,
                                    itemBuilder: (context, index) {
                                      return Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {},
                                            child: Container(
                                              height: size.height * 0.04,
                                              width: size.width * 0.85,
                                              margin: const EdgeInsets.only(bottom: 4),
                                              padding: const EdgeInsets.only(bottom: 5, top: 5, left: 0, right: 5),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(100),
                                                border: Border.all(color: Colors.grey, width: 0.5),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      adDreamsGoalsProvider.getAddActionIdAndNameClear(index);
                                                    },
                                                    child: CircleAvatar(
                                                      radius: size.width * 0.04,
                                                      backgroundColor: ColorsContent.newThemeColor,
                                                      child: Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                        size: size.width * 0.04,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    adDreamsGoalsProvider.goalModelIdName[index].name,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins',
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  CircleAvatar(
                                                    radius: size.width * 0.04,
                                                    backgroundColor: ColorsContent.newThemeColor,
                                                    child: Icon(
                                                      Icons.arrow_forward_ios_outlined,
                                                      color: Colors.white,
                                                      size: size.width * 0.04,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 30),

                            adDreamsGoalsProvider.selectedOption == 'Add to Existing Goal'
                                ? _buildUpdateButton(context)
                                : _buildSaveButton(context),

                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // 🔵 NEW LOADING (FIRST 5 SECONDS)
            if (isLoadingSomeTime)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.grey.withOpacity(0.5),
                  child: Center(
                    child: CupertinoActivityIndicator(
                      radius: 20,
                      color: ColorsContent.newThemeColor,
                    ),
                  ),
                ),
              ),

            if (_isLoadingNew)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.grey.withOpacity(0.5),
                  child: Center(
                    child: CupertinoActivityIndicator(
                      radius: 20,
                      color: ColorsContent.newThemeColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    )
        : const TokenExpireScreen();
  }

  Widget _buildNameEditText(BuildContext context) {
    return Consumer<AdDreamsGoalsProvider>(
      builder: (context, adDreamsGoalsProvider, _) {
        return Padding(
          padding: const EdgeInsets.only(left: 2),
          child: CustomTextFormFieldGoalOrActionName(
            controller: adDreamsGoalsProvider.nameEditTextController,
            hintText: _goalNameFocusNode.hasFocus ? '' : "Goal Name",
            hintStyle: CustomTextStyles.bodySmallGray700,
            focusNode: _goalNameFocusNode,
            onTap: () => setState(() {}),
            onEditingComplete: () {
              _goalNameFocusNode.unfocus();
              setState(() {});
            },
          ),
        );
      },
    );
  }

  Widget _buildAchievementDate(BuildContext context) {
    return Consumer<AdDreamsGoalsProvider>(
      builder: (context, adDreamsGoalsProvider, _) {
        return GestureDetector(
          onTap: () {
            adDreamsGoalsProvider.selectDate(context);
          },
          child: Container(
            margin: const EdgeInsets.only(left: 2),
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 0.8, style: BorderStyle.solid, color: Colors.transparent),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Row(
              children: [
                CustomImageView(
                  imagePath: ImageConstant.actionDatePickerNumu,
                  height: 20,
                  width: 20,
                  margin: const EdgeInsets.only(bottom: 2),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 2, bottom: 1),
                  child: Text(
                    adDreamsGoalsProvider.selectedDate.isNotEmpty
                        ? adDreamsGoalsProvider.selectedDate
                        : "Achievement Date",
                    style: CustomTextStyles.bodySmallGray700,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentEditText(BuildContext context) {
    return Consumer<AdDreamsGoalsProvider>(
      builder: (context, adDreamsGoalsProvider, _) {
        final hasLink = adDreamsGoalsProvider.detectedLinks.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextFormFieldGoalOrActionDesc(
                  controller: adDreamsGoalsProvider.commentEditTextController,
                  hintText: _goalDescFocusNode.hasFocus ? '' : "Goal Description",
                  hintStyle: CustomTextStyles.bodySmallGray700,
                  maxLines: 4,
                  focusNode: _goalDescFocusNode,
                  textInputAction: TextInputAction.done,
                  textInputType: TextInputType.multiline,
                  borderDecoration: InputBorder.none,
                  onTap: () {
                    if (adDreamsGoalsProvider.commentEditTextController.text.isEmpty &&
                        sharedData != null &&
                        (sharedData!.sharedText ?? '').isNotEmpty) {
                      adDreamsGoalsProvider.commentEditTextController.text = sharedData!.sharedText!;
                    }
                    setState(() {});
                  },
                  onChanged: (value) {
                    final matches = adDreamsGoalsProvider.urlRegex
                        .allMatches(value)
                        .map((match) => match.group(0)!)
                        .toList();

                    if (matches.isNotEmpty) {
                      final firstLink = matches.first;
                      setState(() {
                        adDreamsGoalsProvider.detectedLinks.clear();
                        adDreamsGoalsProvider.detectedLinks = [firstLink];
                      });

                      final cleanedText = value.replaceAll(adDreamsGoalsProvider.urlRegex, '').trim();
                      adDreamsGoalsProvider.commentEditTextController.text = cleanedText;
                      adDreamsGoalsProvider.commentEditTextController.selection =
                          TextSelection.fromPosition(TextPosition(offset: cleanedText.length));
                    }
                  },
                  onEditingComplete: () {
                    _goalDescFocusNode.unfocus();
                    setState(() {});
                  },
                ),

                if (hasLink)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300, width: 1.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinkPreviewGenerator(
                              link: adDreamsGoalsProvider.detectedLinks.isNotEmpty
                                  ? adDreamsGoalsProvider.detectedLinks.first
                                  : '',
                              linkPreviewStyle: LinkPreviewStyle.large,
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
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                adDreamsGoalsProvider.detectedLinks.clear();
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommentEditTextEditLink(BuildContext context) {
    return Consumer<AdDreamsGoalsProvider>(
      builder: (context, adDreamsGoalsProvider, _) {
        final hasLink = adDreamsGoalsProvider.editDetectedLinks.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextFormFieldGoalOrActionDesc(
                  controller: adDreamsGoalsProvider.commentEditTextController,
                  hintText: _goalDescFocusNode.hasFocus ? '' : "Goal Description",
                  hintStyle: CustomTextStyles.bodySmallGray700,
                  maxLines: 4,
                  focusNode: _goalDescFocusNode,
                  textInputAction: TextInputAction.newline,
                  textInputType: TextInputType.multiline,
                  borderDecoration: InputBorder.none,
                  onTap: () {
                    if (adDreamsGoalsProvider.commentEditTextController.text.isEmpty &&
                        sharedData != null &&
                        (sharedData!.sharedText ?? '').isNotEmpty) {
                      adDreamsGoalsProvider.commentEditTextController.text = sharedData!.sharedText!;
                    }
                    setState(() {});
                  },
                  onChanged: (value) {
                    final matches = adDreamsGoalsProvider.urlRegex
                        .allMatches(value)
                        .map((match) => match.group(0)!)
                        .toList();

                    if (matches.isNotEmpty) {
                      // Normalize the detected URL before saving
                      final firstRawLink = matches.first;
                      final normalizedLink = normalizeUrl(firstRawLink);

                      setState(() {
                        adDreamsGoalsProvider.editDetectedLinks.clear();
                        adDreamsGoalsProvider.editDetectedLinks = [normalizedLink];
                      });

                      // Remove only the raw link from text field
                      final cleanedText = value.replaceAll(adDreamsGoalsProvider.urlRegex, '').trim();

                      adDreamsGoalsProvider.commentEditTextController.text = cleanedText;
                      adDreamsGoalsProvider.commentEditTextController.selection =
                          TextSelection.fromPosition(
                            TextPosition(offset: cleanedText.length),
                          );
                    }
                  },

                  onEditingComplete: () {
                    _goalDescFocusNode.unfocus();
                    setState(() {});
                  },
                ),

                if (hasLink)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300, width: 1.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinkPreviewGenerator(
                              link: adDreamsGoalsProvider.editDetectedLinks.isNotEmpty
                                  ? adDreamsGoalsProvider.editDetectedLinks.first
                                  : '',
                              linkPreviewStyle: LinkPreviewStyle.large,
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
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                adDreamsGoalsProvider.editDetectedLinks.clear();
                              });
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddActionsButton(BuildContext context) {
    return CustomElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AddactionsScreen(goalId: ''),
          ),
        );
      },
      height: 45,
      text: "Add Action",
      margin: const EdgeInsets.only(left: 2),
      buttonStyle: CustomButtonStyles.addActionButtonStyle,
      buttonTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        fontFamily: 'Open Sans',
        color: Colors.white,
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Consumer2<AdDreamsGoalsProvider, EditProfileProvider>(
      builder: (context, adDreamsGoalsProvider, editProfileProvider, _) {
        return CustomElevatedButton(
          loading: adDreamsGoalsProvider.saveAddActionsLoading,
          onPressed: () async {
            _isTokenExpired();

            if (!adDreamsGoalsProvider.isVideoUploading) {
              if (adDreamsGoalsProvider.nameEditTextController.text.isEmpty) {
                showCustomSnackBar(context: context, message: "Please fill Goal name");
              } else if (editProfileProvider.categorys == null) {
                showCustomSnackBar(context: context, message: "Please fill Categories");
              } else if (adDreamsGoalsProvider.selectedDate.isEmpty) {
                showCustomSnackBar(context: context, message: "Please fill Achievement date");
              } else if (adDreamsGoalsProvider.formattedDate == null) {
                showCustomSnackBar(context: context, message: "Please select a valid date");
              } else if (editProfileProvider.interestsValueController.text.isEmpty) {
                showCustomSnackBar(context: context, message: "Please select a category");
              } else {
                await adDreamsGoalsProvider.saveGemFunctionLink(
                  context,
                  title: adDreamsGoalsProvider.nameEditTextController.text,
                  details: adDreamsGoalsProvider.commentEditTextController.text,
                  mediaName: adDreamsGoalsProvider.addMediaUploadResponseList,
                  locationName: adDreamsGoalsProvider.selectedLocationName,
                  locationLatitude: adDreamsGoalsProvider.selectedLatitude,
                  locationLongitude: adDreamsGoalsProvider.selectedLongitude,
                  locationAddress: adDreamsGoalsProvider.selectedLocationAddress,
                  categoryId: editProfileProvider.categorys!.id.toString(),
                  gemEndDate: adDreamsGoalsProvider.formattedDate,
                  mediaThumbs: adDreamsGoalsProvider.mediaThumbList,
                  actionId: adDreamsGoalsProvider.goalModelIdName,
                );

                GoalsDreamsProvider goalsDreamsProvider =
                Provider.of<GoalsDreamsProvider>(context, listen: false);
                goalsDreamsProvider.fetchGoalsAndDreams(
                  pageNo: goalsDreamsProvider.currentPage.toString(),
                  context: context,
                );

                if (goalsDreamsProvider.fetchGoalsAndDreamsStatus == 404) {
                  goalsDreamsProvider.fetchGoalsAndDreams(pageNo: 1.toString(), context: context);
                }
              }
            } else {
              showCustomSnackBar(context: context, message: "Please wait, video is uploading");
            }
          },
          height: 45,
          text: "Save",
          margin: const EdgeInsets.only(left: 2),
          buttonStyle: CustomButtonStyles.outlinePrimaryTL5,
          buttonTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Open Sans',
            color: Colors.white,
          ),
        );
      },
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    return Consumer2<AdDreamsGoalsProvider, EditProfileProvider>(
        builder: (context, adDreamsGoalsProvider, editProfileProvider, _) {
          return CustomElevatedButton(
            loading: adDreamsGoalsProvider.saveAddActionsLoading,
            onPressed: () async {
              _isTokenExpired();
              if (!adDreamsGoalsProvider.isVideoUploading) {
                if (adDreamsGoalsProvider.nameEditTextController.text.isNotEmpty &&
                    editProfileProvider.categorys != null &&
                    adDreamsGoalsProvider.formattedDate != null) {
                  if (adDreamsGoalsProvider.formattedDate.isNotEmpty) {
                    logger.w("formattedDate${adDreamsGoalsProvider.formattedDate}");
                    logger.w(
                        "adDreamsGoalsProvider.goalModelIdName${adDreamsGoalsProvider.goalModelIdName}");

                    // ✅ Call update function with all required parameters
                    await adDreamsGoalsProvider.updateGoalFunctionLink(
                      context,
                      title: adDreamsGoalsProvider.nameEditTextController.text,
                      details: adDreamsGoalsProvider.commentEditTextController.text,
                      mediaName: adDreamsGoalsProvider.addMediaUploadResponseList,
                      locationName: adDreamsGoalsProvider.selectedLocationName,
                      locationLatitude: adDreamsGoalsProvider.selectedLatitude,
                      locationLongitude: adDreamsGoalsProvider.selectedLongitude,
                      locationAddress:
                      adDreamsGoalsProvider.selectedLocationAddress,
                      categoryId: editProfileProvider.categorys!.id.toString(),
                      gemEndDate: adDreamsGoalsProvider.formattedDate,
                      mediaThumbs: adDreamsGoalsProvider.mediaThumbList,
                      actionId: adDreamsGoalsProvider.goalModelIdName,
                      gemId: adDreamsGoalsProvider.selectedExistingGoal.toString(),
                      editDetectedLinks: adDreamsGoalsProvider.editDetectedLinks,
                    );

                    GoalsDreamsProvider goalsDreamsProvider =
                    Provider.of<GoalsDreamsProvider>(context, listen: false);
                    // goalsDreamsProvider.fetchGoalsAndDreams(initial: true);

                    await goalsDreamsProvider.fetchGoalsAndDreams(
                        pageNo: goalsDreamsProvider.currentPage.toString(),
                        context: context);
                  } else {
                    logger.w("formattedDate${adDreamsGoalsProvider.formattedDate}");
                    logger.w("selectedDate${adDreamsGoalsProvider.selectedDate}");
                    logger.w(
                        "adDreamsGoalsProvider.goalModelIdName1${jsonEncode(adDreamsGoalsProvider.goalModelIdName)}");

                    // ✅ Call update function with all required parameters
                    await adDreamsGoalsProvider.updateGoalFunctionLink(
                      context,
                      title: adDreamsGoalsProvider.nameEditTextController.text,
                      details: adDreamsGoalsProvider.commentEditTextController.text,
                      mediaName: adDreamsGoalsProvider.addMediaUploadResponseList,
                      locationName: adDreamsGoalsProvider.selectedLocationName,
                      locationLatitude: adDreamsGoalsProvider.selectedLatitude,
                      locationLongitude: adDreamsGoalsProvider.selectedLongitude,
                      locationAddress:
                      adDreamsGoalsProvider.selectedLocationAddress,
                      categoryId: editProfileProvider.categorys!.id.toString(),
                      gemEndDate: unixTimestamp.toString(),
                      mediaThumbs: adDreamsGoalsProvider.mediaThumbList,
                      actionId: adDreamsGoalsProvider.goalModelIdName,
                      gemId: adDreamsGoalsProvider.selectedExistingGoal.toString(),
                      editDetectedLinks: adDreamsGoalsProvider.editDetectedLinks,
                    );

                    GoalsDreamsProvider goalsDreamsProvider =
                    Provider.of<GoalsDreamsProvider>(context, listen: false);
                    // goalsDreamsProvider.fetchGoalsAndDreams(initial: true);

                    await goalsDreamsProvider.fetchGoalsAndDreams(
                        pageNo: goalsDreamsProvider.currentPage.toString(),
                        context: context);
                  }
                } else {
                  showCustomSnackBar(
                    context: context,
                    message: "Please fill in all the fields",
                  );
                }
              } else {
                showCustomSnackBar(
                  context: context,
                  message: "Please Wait Video Uploading",
                );
              }
            },
            height: 45,
            text: "Update",
            margin: const EdgeInsets.only(left: 2),
            buttonStyle: CustomButtonStyles.outlinePrimaryTL5,
            buttonTextStyle:
            CustomTextStyles.titleSmallHelveticaOnSecondaryContainer,
          );
        });
  }

  Widget _buildAddMediaColumn(BuildContext context, Size size) {
    return Consumer<AdDreamsGoalsProvider>(
      builder: (context, mentalStrengthEditProvider, _) {
        return Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add Media", style: theme.textTheme.titleSmall),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Gallery
                  SizedBox(
                    height: size.height * 0.09,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _isTokenExpired();

                            if (await requestGalleryPermission() && Platform.isAndroid) {
                              mentalStrengthEditProvider.selectedMedia(1);
                              await galleryBottomSheetAddGoals(context: context, title: 'Gallery');
                            } else if (Platform.isIOS) {
                              mentalStrengthEditProvider.selectedMedia(1);
                              await galleryBottomSheetAddGoals(context: context, title: 'Gallery');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Gallery permission is required.")),
                              );
                            }
                          },
                          child: SvgPicture.asset(ImageConstant.galleryAddMediaNumu),
                        ),
                        Positioned(
                          bottom: Platform.isIOS ? 50 : 45,
                          right: 0,
                          left: 40,
                          child: Consumer<AdDreamsGoalsProvider>(
                            builder: (context, mentalStrengthEditProvider, _) {
                              if (mentalStrengthEditProvider.pickedImages.isEmpty) {
                                return const SizedBox();
                              }
                              return Container(
                                width: size.height * 0.04,
                                height: size.height * 0.04,
                                decoration: BoxDecoration(
                                  color: ColorsContent.galleryCountColor,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(ImageConstant.imgMenu),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(color: Colors.white, width: 1.0),
                                ),
                                child: Center(
                                  child: Text(
                                    mentalStrengthEditProvider.pickedImages.length.toString(),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Camera
                  SizedBox(
                    height: size.height * 0.09,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _isTokenExpired();

                            if (await requestCameraPermission() && Platform.isAndroid) {
                              mentalStrengthEditProvider.selectedMedia(2);
                              cameraBottomSheetAdGoals(context: context, title: "Camera");
                            } else if (Platform.isIOS) {
                              mentalStrengthEditProvider.selectedMedia(2);
                              cameraBottomSheetAdGoals(context: context, title: "Camera");
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Camera permission is required.")),
                              );
                            }
                          },
                          child: SvgPicture.asset(ImageConstant.cameraAddMediaNumu),
                        ),
                        Positioned(
                          bottom: Platform.isIOS ? 50 : 45,
                          right: 0,
                          left: 40,
                          child: Consumer<AdDreamsGoalsProvider>(
                            builder: (context, mentalStrengthEditProvider, _) {
                              if (mentalStrengthEditProvider.takedImages.isEmpty) {
                                return const SizedBox();
                              }
                              return Container(
                                width: size.height * 0.04,
                                height: size.height * 0.04,
                                decoration: BoxDecoration(
                                  color: ColorsContent.cameraCountColor,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(ImageConstant.imgMenu),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(color: Colors.white, width: 1.0),
                                ),
                                child: Center(
                                  child: Text(
                                    mentalStrengthEditProvider.takedImages.length.toString(),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Audio
                  SizedBox(
                    height: size.height * 0.09,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _isTokenExpired();
                            mentalStrengthEditProvider.selectedMedia(0);
                            await audioBottomSheetAddGoals(context: context, title: 'Record Audio');
                          },
                          child: SvgPicture.asset(ImageConstant.recordAddMediaNumu),
                        ),
                        Positioned(
                          bottom: Platform.isIOS ? 50 : 45,
                          right: 0,
                          left: 40,
                          child: Consumer<AdDreamsGoalsProvider>(
                            builder: (context, mentalStrengthEditProvider, _) {
                              if (mentalStrengthEditProvider.recordedFilePath.isEmpty) {
                                return const SizedBox();
                              }
                              return Container(
                                width: size.height * 0.04,
                                height: size.height * 0.04,
                                decoration: BoxDecoration(
                                  color: ColorsContent.recordCountColor,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(ImageConstant.imgMenu),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(color: Colors.white, width: 1.0),
                                ),
                                child: Center(
                                  child: Text(
                                    mentalStrengthEditProvider.recordedFilePath.length.toString(),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Location
                  SizedBox(
                    height: size.height * 0.09,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            mentalStrengthEditProvider.selectedMedia(3);

                            final status = await Permission.locationWhenInUse.status;
                            if (status.isDenied || status.isPermanentlyDenied) {
                              final result = await Permission.locationWhenInUse.request();
                              if (result.isDenied || result.isPermanentlyDenied) {
                                if (mounted) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Location Permission Required'),
                                      content: const Text(
                                        'Location permission is needed to add your current location to the mental strength entry. Please enable it in settings.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await openAppSettings();
                                          },
                                          child: const Text('Open Settings'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return;
                              }
                            }

                            if (await Permission.locationWhenInUse.isGranted) {
                              if (mounted) {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return SafeArea(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context).viewInsets.bottom,
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(20),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                          ),
                                          child: const AddGoalsGoogleMap(),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            }
                          },
                          child: SvgPicture.asset(ImageConstant.locationAddMediaNumu),
                        ),
                        Positioned(
                          bottom: Platform.isIOS ? 50 : 45,
                          right: 0,
                          left: 40,
                          child: Consumer<AdDreamsGoalsProvider>(
                            builder: (context, mentalStrengthEditProvider, _) {
                              if (mentalStrengthEditProvider.selectedLocationName.isEmpty) {
                                return const SizedBox();
                              }
                              return Container(
                                width: size.height * 0.04,
                                height: size.height * 0.04,
                                decoration: BoxDecoration(
                                  color: ColorsContent.locationCountColor,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(ImageConstant.imgMenu),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(color: Colors.white, width: 1.0),
                                ),
                                child: const Center(
                                  child: Text(
                                    "1",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddMediaColumnEdit(BuildContext context, Size size) {
    return Consumer<AdDreamsGoalsProvider>(
      builder: (context, adDreamsGoalsProvider, _) {
        return Align(
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add Media", style: theme.textTheme.titleSmall),
              const SizedBox(height: 11),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Gallery Edit
                  SizedBox(
                    height: size.height * 0.09,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _isTokenExpired();

                            if (await requestGalleryPermission() && Platform.isAndroid) {
                              adDreamsGoalsProvider.selectedMedia(1);
                              await galleryBottomSheetAddGoals(context: context, title: 'Gallery');
                            } else if (Platform.isIOS) {
                              adDreamsGoalsProvider.selectedMedia(1);
                              await galleryBottomSheetAddGoals(context: context, title: 'Gallery');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Gallery permission is required.")),
                              );
                            }
                          },
                          child: SvgPicture.asset(ImageConstant.galleryAddMediaNumu),
                        ),
                        Positioned(
                          bottom: Platform.isIOS ? 50 : 45,
                          right: 0,
                          left: 40,
                          child: Consumer<AdDreamsGoalsProvider>(
                            builder: (context, adDreamsGoalsProvider, _) {
                              if (adDreamsGoalsProvider.alreadyPickedImages.isEmpty &&
                                  adDreamsGoalsProvider.pickedImages.isEmpty) {
                                return const SizedBox();
                              }
                              return Container(
                                width: size.height * 0.04,
                                height: size.height * 0.04,
                                decoration: BoxDecoration(
                                  color: ColorsContent.galleryCountColor,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(ImageConstant.imgMenu),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(color: Colors.white, width: 1.0),
                                ),
                                child: Center(
                                  child: Text(
                                    "${adDreamsGoalsProvider.pickedImages.length + adDreamsGoalsProvider.alreadyPickedImages.length}",
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
                      ],
                    ),
                  ),

                  // Camera Edit
                  SizedBox(
                    height: size.height * 0.09,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _isTokenExpired();

                            if (await requestCameraPermission() && Platform.isAndroid) {
                              adDreamsGoalsProvider.selectedMedia(2);
                              cameraBottomSheetAdGoals(context: context, title: "Camera");
                            } else if (Platform.isIOS) {
                              adDreamsGoalsProvider.selectedMedia(2);
                              cameraBottomSheetAdGoals(context: context, title: "Camera");
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Camera permission is required.")),
                              );
                            }
                          },
                          child: SvgPicture.asset(ImageConstant.cameraAddMediaNumu),
                        ),
                        Positioned(
                          bottom: Platform.isIOS ? 50 : 45,
                          right: 0,
                          left: 40,
                          child: Consumer<AdDreamsGoalsProvider>(
                            builder: (context, adDreamsGoalsProvider, _) {
                              if (adDreamsGoalsProvider.takedImages.isEmpty) {
                                return const SizedBox();
                              }
                              return Container(
                                width: size.height * 0.04,
                                height: size.height * 0.04,
                                decoration: BoxDecoration(
                                  color: ColorsContent.cameraCountColor,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(ImageConstant.imgMenu),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(color: Colors.white, width: 1.0),
                                ),
                                child: Center(
                                  child: Text(
                                    adDreamsGoalsProvider.takedImages.length.toString(),
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
                      ],
                    ),
                  ),

                  // Audio Edit
                  SizedBox(
                    height: size.height * 0.09,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _isTokenExpired();
                            adDreamsGoalsProvider.selectedMedia(0);
                            await audioBottomSheetAddGoals(context: context, title: 'Record Audio');
                          },
                          child: SvgPicture.asset(ImageConstant.recordAddMediaNumu),
                        ),
                        Positioned(
                          bottom: Platform.isIOS ? 50 : 45,
                          right: 0,
                          left: 40,
                          child: Consumer<AdDreamsGoalsProvider>(
                            builder: (context, adDreamsGoalsProvider, _) {
                              if (adDreamsGoalsProvider.alreadyRecordedFilePath.isEmpty &&
                                  adDreamsGoalsProvider.recordedFilePath.isEmpty) {
                                return const SizedBox();
                              }
                              return Container(
                                width: size.height * 0.04,
                                height: size.height * 0.04,
                                decoration: BoxDecoration(
                                  color: ColorsContent.recordCountColor,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(ImageConstant.imgMenu),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(color: Colors.white, width: 1.0),
                                ),
                                child: Center(
                                  child: Text(
                                    "${adDreamsGoalsProvider.recordedFilePath.length + adDreamsGoalsProvider.alreadyRecordedFilePath.length}",
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
                      ],
                    ),
                  ),

                  // Location Edit
                  SizedBox(
                    height: size.height * 0.09,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            FocusScope.of(context).requestFocus(FocusNode());
                            adDreamsGoalsProvider.selectedMedia(3);

                            final status = await Permission.locationWhenInUse.status;
                            if (status.isDenied || status.isPermanentlyDenied) {
                              final result = await Permission.locationWhenInUse.request();
                              if (result.isDenied || result.isPermanentlyDenied) {
                                if (mounted) {
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Location Permission Required'),
                                      content: const Text(
                                        'Location permission is needed to add your current location to the mental strength entry. Please enable it in settings.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            await openAppSettings();
                                          },
                                          child: const Text('Open Settings'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return;
                              }
                            }

                            if (await Permission.locationWhenInUse.isGranted) {
                              if (mounted) {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return SafeArea(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context).viewInsets.bottom,
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(20),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                          ),
                                          child: const AddGoalsGoogleMap(isEdit: true),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            }
                          },
                          child: SvgPicture.asset(ImageConstant.locationAddMediaNumu),
                        ),
                        Positioned(
                          bottom: Platform.isIOS ? 50 : 45,
                          right: 0,
                          left: 40,
                          child: Consumer<AdDreamsGoalsProvider>(
                            builder: (context, adDreamsGoalsProvider, _) {
                              if (adDreamsGoalsProvider.selectedLocationName.isEmpty) {
                                return const SizedBox();
                              }
                              return Container(
                                width: size.height * 0.04,
                                height: size.height * 0.04,
                                decoration: BoxDecoration(
                                  color: ColorsContent.locationCountColor,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: AssetImage(ImageConstant.imgMenu),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(color: Colors.white, width: 1.0),
                                ),
                                child: Center(
                                  child: Text(
                                    adDreamsGoalsProvider.selectedLocationName.isEmpty ? "" : "1",
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
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

int convertToUnixTimestamp(String dateString) {
  DateFormat dateFormat = DateFormat("d MMM yyyy");
  DateTime parsedDate = dateFormat.parse(dateString);
  int timestamp = parsedDate.millisecondsSinceEpoch;
  return timestamp;
}

class SharedContentData {
  final String? text;
  final String? url;
  final String? sharedText;
  final List<String> imagePaths;
  final int? timestamp;

  SharedContentData({
    this.text,
    this.url,
    this.sharedText,
    required this.imagePaths,
    this.timestamp,
  });
}


String normalizeUrl(String url) {
  url = url.trim();

  if (url.startsWith("http://") || url.startsWith("https://")) {
    return url;
  }

  return "https://$url";  // Force a valid scheme
}
