import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/home_screen/provider/home_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/all_model.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/emotions_model.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/get_goals_model.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/goal_details_model.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/list_goal_actions.dart'
    as action;
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/model/list_goal_actions.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:mentalhelth/widgets/widget/video_compessor.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart';

import '../../goals_dreams_page/model/actions_details_model.dart';
import '../../token_expiry/token_expiry.dart';

class MentalStrengthEditProvider extends ChangeNotifier {
  var logger = Logger();

  void editJournalAddValues({
    required String descriptionText,
    required List<String> recordedFile,
    required List<String> pickedImagesList,
    required String selectedLocationNames,
    required String selectedLocationAddresss,
    required String selectedLatitudes,
    required String locationLongitudes,
    required double emotionalValueStars,
    required Emotion emotion,
    required double driveValueStars,
    required Goal goals,
    required List<action.Action> actionLists,
  }) {
    descriptionEditTextController.text = descriptionText;
    recordedFilePath.addAll(recordedFile);
    pickedImages.addAll(pickedImagesList);
    selectedLocationName = selectedLocationNames;
    selectedLocationAddress = selectedLocationAddresss;
    selectedLatitude = selectedLatitudes;
    locationLongitude = locationLongitudes;
    emotionalValueStar = emotionalValueStars;
    emotionValue = emotion;
    driveValueStar = driveValueStars;
    goalsValue = goals;
    actionList = actionLists;
  }

  //audio sections
  // selected location
  String selectedLocationName = '';
  String selectedLocationAddress = '';
  String selectedLatitude = '';
  String locationLongitude = '';
  bool isVideoUploading = false;
  List<String> addMediaUploadResponseList = [];

  void addLocationSection(
      {required String selectedAddress,
      required Placemark placemark,
      required LatLng location}) {
    selectedLocationName =
        selectedLocationAddress = placemark.locality.toString();
    selectedAddress.toString();
    selectedLatitude = location.latitude.toString();
    locationLongitude = location.longitude.toString();
    notifyListeners();
  }

  void openAllCloser() {
    openChooseGoal = false;
    openAddGoal = false;
    openGoalViewSheet = false;
    openChooseAction = false;
    openAddAction = false;
    openActionFullView = false;
  }

  bool openChooseGoal = false;

  void openChooseGoalFunction() {
    if (openChooseGoal) {
      openChooseGoal = false;
    } else {
      openChooseGoal = true;
    }
    notifyListeners();
  }

  bool openAddGoal = false;

  void openAddGoalFunction() {
    if (openAddGoal) {
      openAddGoal = false;
    } else {
      openAddGoal = true;
    }
    print(openAddGoal.toString());
    notifyListeners();
  }

  bool openGoalViewSheet = false;

  void openGoalViewSheetFunction() {
    if (openGoalViewSheet) {
      openGoalViewSheet = false;
    } else {
      openGoalViewSheet = true;
    }
    notifyListeners();
  }

  bool openChooseAction = false;

  void openChooseActionFunction() {
    if (openChooseAction) {
      openChooseAction = false;
    } else {
      openChooseAction = true;
    }
    notifyListeners();
  }

  bool openAddAction = false;

  void openAddActionFunction() {
    if (openAddAction) {
      openAddAction = false;
    } else {
      openAddAction = true;
    }
    notifyListeners();
  }

  bool openActionFullView = false;

  void openActionFullViewFunction() {
    if (openActionFullView) {
      openActionFullView = false;
    } else {
      openActionFullView = true;
    }
    notifyListeners();
  }

  void addMediaUploadResponseListFunction(List<String> value) {
    addMediaUploadResponseList.addAll(value);
    notifyListeners();
  }

  TextEditingController descriptionEditTextController = TextEditingController();
  double? emotionalValueStar; // Use nullable type


  void changeEmotionalValueStar(double value) {
    emotionalValueStar = value;
    notifyListeners();
  }

  double? driveValueStar;

  void changeDriveValueStar(double value) {
    driveValueStar = value;
    notifyListeners();
  }

  ///record files
  ///
  ///
  ///
  ///
  List<AllModel> alreadyRecordedFilePath = [];

  void alreadyRecorderValuesAddFunction(List<AllModel> paths) {
    alreadyRecordedFilePath.addAll(paths);
    notifyListeners();
  }

  void alreadyRecorderValuesRemove(index) {
    alreadyRecordedFilePath.removeAt(index);
    notifyListeners();
  }

  List<String> recordedFilePath = [];

  void recorderValuesAddFunction(List<String> paths) {
    recordedFilePath.addAll(paths);
    notifyListeners();
  }

  void recorderValuesRemove(index) {
    recordedFilePath.removeAt(index);
    notifyListeners();
  }

  int mediaSelected = 0;

  void selectedMedia(int index) {
    mediaSelected = index;
    notifyListeners();
  }

  //image picker section

  Future<void> pickImageFunction() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    // if (pickedImagesMain != null) {
    // imageFile = File(pickedImage.path);

    // XFile? pickedImage = await compressImage(
    //   File(
    //     pickedImagesMain.path,
    //   ),
    // );
    //
    // final image = File(pickedImagesMain.path);
    // final bytes = await image.readAsBytes();
    // final imageSize = bytes.lengthInBytes;
    // final image1 = File(pickedImagesMain.path);
    // final bytes1 = await image1.readAsBytes();
    // final imageSize1 = bytes1.lengthInBytes;
    // print('Image size: $imageSize bytes');
    // print('Image size: $imageSize1 bytes1');
    if (pickedImage != null) {
      String fileExtension = pickedImage.path..split('.').last;
      String lastThreeChars = fileExtension.substring(fileExtension.length - 3);

      List<String> imagePaths = [];
      imagePaths.add(
        pickedImage.path,
      );
      pickedImagesAddFunction(
        imagePaths,
      );
      await saveMediaUploadMental(
        file: pickedImage.path,
        type: "journal",
        fileType: lastThreeChars,
      );
      notifyListeners();
    }
    // }
  }

  Future<void> pickVideoFunction(BuildContext context) async {
    try {
      // Pick video from gallery
      final pickedVideoPath = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedVideoPath == null) {
        showCustomSnackBar(
          context: context,
          message: "No video selected.",
        );
        return;
      }

      // Check if a video is currently being uploaded
      if (!isVideoUploading) {
        isVideoUploading = true;
        notifyListeners();

        String fileExtension = pickedVideoPath.path.split('.').last.toLowerCase();
        String lastThreeChars = fileExtension.substring(fileExtension.length - 3);

        List<String> videoPaths = [pickedVideoPath.path];
        pickedImagesAddFunction(videoPaths);

        final String outputPath = '${pickedVideoPath.path}_compressed.mp4';

        // Compress video using FFmpegKit with logging enabled
        final session = await FFmpegKit.execute(
            '-y -i ${pickedVideoPath.path} -vcodec libx264 -preset veryfast -crf 30 -movflags +faststart -vf "scale=320:240" -r 12 -b:v 200k -acodec aac -b:a 32k -ac 1 $outputPath'
        );

        final returnCode = await session.getReturnCode();

        if (returnCode != null && returnCode.isValueSuccess()) {
          // Video compression successful, generate thumbnail and upload
          File thumbNailFile = await generateThumbnail(File(outputPath));
          logger.w("outputPath${outputPath}");
          logger.w("lastThreeChars${lastThreeChars}");
          logger.w("thumbNailFile.path${thumbNailFile.path}");
          await saveMediaUploadMental(
            file: outputPath,
            type: "journal",
            fileType: "mp4",
            thumbNail: thumbNailFile.path,
          );
        } else {
          // Log and show error message if compression fails
          final logs = await session.getAllLogs();
          for (final log in logs) {
            debugPrint("FFmpeg Log: ${log.getMessage()}");
          }
          final sessionError = await session.getFailStackTrace();
          debugPrint("FFmpeg Error: $sessionError");

          showCustomSnackBar(
            context: context,
            message: "Video compression failed. Please try again.",
          );
        }
      } else {
        showCustomSnackBar(
          context: context,
          message: "Please Wait, Video is Uploading",
        );
      }
    } catch (e) {
      showCustomSnackBar(
        context: context,
        message: "An error occurred: $e",
      );
    } finally {
      isVideoUploading = false;
      notifyListeners();
    }
  }

  List<AllModel> alreadyPickedImages = [];

  void alreadyPickedImagesAddFunction(List<AllModel> images) {
    alreadyPickedImages.addAll(images);
    notifyListeners();
  }

  void alreadyPickedImagesRemove(index) {
    alreadyPickedImages.removeAt(index);
    notifyListeners();
  }

  List<String> pickedImages = [];

  void pickedImagesAddFunction(List<String> images) {
    pickedImages.addAll(images);
    notifyListeners();
  }

  void pickedImagesRemove(int index) {
    if (index >= 0 && index < pickedImages.length) {
      print('Removing image at index: $index');
      print('Current images: $pickedImages');
      pickedImages.removeAt(index);
      print('Updated images: $pickedImages');
      notifyListeners();
    } else {
      print('Index out of range: $index');
    }
  }



  List<AllModel> alreadyTakedImages = [];

  void alreadyTakedImagesAddFunction(List<AllModel> images) {
    alreadyTakedImages.addAll(images);
    notifyListeners();
  }

  void alreadyTakedImagesRemove(index) {
    alreadyTakedImages.removeAt(index);
    notifyListeners();
  }

  List<String> takedImages = [];

  void takedImagesAddFunction(List<String> images) {
    takedImages.addAll(images);
    notifyListeners();
  }

  void takedImagesRemove(index) {
    takedImages.removeAt(index);
    notifyListeners();
  }

  //image take section
  // File? takeFile;

  Future<void> takeFileFunction(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      try {
        String fileExtension = pickedFile.path.split('.').last;
        String lastThreeChars = fileExtension.substring(fileExtension.length - 3);

        List<String> imagePaths = [];
        imagePaths.add(pickedFile.path);
        takedImagesAddFunction(imagePaths);

        // Check if the file is a video based on its extension
        if (lastThreeChars.toLowerCase() == 'mp4' ||
            lastThreeChars.toLowerCase() == 'mov' ||
            lastThreeChars.toLowerCase() == 'avi') {
          // Path for compressed video output
          final String outputPath = '${pickedFile.path}_compressed.mp4';

          // Compress the video using FFmpeg
          await FFmpegKit.execute(
              '-y -i ${pickedFile.path} -vcodec libx264 -preset veryfast -crf 30 -movflags +faststart -vf "scale=320:240" -r 12 -b:v 200k -acodec aac -b:a 32k -ac 1 $outputPath'
          ).then((session) async {
            final returnCode = await session.getReturnCode();

            if (returnCode!.isValueSuccess()) {
              // Compression successful, save the compressed video
              await saveMediaUploadMental(
                file: outputPath,
                type: "journal",
                fileType: lastThreeChars,
              );
            } else {
              // Handle compression failure
              showCustomSnackBar(
                context: context,
                message: "Video compression failed.",
              );
            }
          });
        } else {
          // Save the image without compression
          await saveMediaUploadMental(
            file: pickedFile.path,
            type: "journal",
            fileType: lastThreeChars,
          );
        }
      } catch (e) {
        // Handle errors during the process
        showCustomSnackBar(
          context: context,
          message: "An error occurred: $e",
        );
      } finally {
        // Notify listeners to update UI
        notifyListeners();
      }
    }
  }

  Future<void> takeVideoFunction(BuildContext context) async {
    final pickeVideo = await ImagePicker().pickVideo(
      source: ImageSource.camera,
    );

    if (!isVideoUploading) {
      if (pickeVideo != null) {
        try {
          isVideoUploading = true;
          notifyListeners();

          // Extract the file extension
          String fileExtension = pickeVideo.path.split('.').last;
          String lastThreeChars = fileExtension.substring(fileExtension.length - 3);

          List<String> imagePaths = [];
          imagePaths.add(pickeVideo.path);
          takedImagesAddFunction(imagePaths);

          // Path for compressed video output
          final String outputPath = '${pickeVideo.path}_compressed.mp4';

          // Compress video using optimized settings
          await FFmpegKit.execute(
              '-y -i ${pickeVideo.path} -vcodec libx264 -preset veryfast -crf 30 -movflags +faststart -vf "scale=320:240" -r 12 -b:v 200k -acodec aac -b:a 32k -ac 1 $outputPath'
          ).then((session) async {
            final returnCode = await session.getReturnCode();

            if (returnCode!.isValueSuccess()) {
              // Video compression successful
              File thumbNailFile = await generateThumbnail(File(outputPath));

              await saveMediaUploadMental(
                file: outputPath,
                type: "journal",
                fileType: "mp4",
                thumbNail: thumbNailFile.path,
              );
            } else {
              showCustomSnackBar(
                context: context,
                message: "Video compression failed.",
              );
            }
          });
        } catch (e) {
          // Handle any errors that occur during the process
          showCustomSnackBar(
            context: context,
            message: "An error occurred: $e",
          );
        } finally {
          // Ensure this is always executed, regardless of success or failure
          isVideoUploading = false;
          notifyListeners();
        }
      }
    } else {
      showCustomSnackBar(
        context: context,
        message: "Please Wait, Video is Uploading",
      );
    }
  }



  // Future<XFile?> compressImage(File file) async {
  //   ImageFile input;
  //   Configuration config = Configuration(
  //     outputType: ImageOutputType.webpThenJpg,
  //     // can only be true for Android and iOS while using ImageOutputType.jpg or ImageOutputType.pngÏ
  //     useJpgPngNativeCompressor: false,
  //     // set quality between 0-100
  //     quality: 40,
  //   );
  //
  //   final param = ImageFileConfiguration(input: input, config: config);
  //   final output = await compressor.compress(param);
  //
  //   print("Input size : ${input.sizeInBytes}");
  //   print("Output size : ${output.sizeInBytes}");
  // }

  GetEmotionsModel? getEmotionsModel;
  bool getEmotionsModelLoading = false;
  Emotion emotionValue = Emotion();

  Future<void> fetchEmotions({bool editing = false, String? emotionId}) async {
    try {
      String? token = await getUserTokenSharePref();
      getEmotionsModelLoading = true;
      notifyListeners();
      final response = await http.get(
        Uri.parse(
          UrlConstant.emotionsUrl,
        ),
        headers: <String, String>{"authorization": "$token"},
      );

      if (response.statusCode == 200) {
        getEmotionsModel = getEmotionsModelFromJson(response.body);
        if (editing) {
          for (int i = 0; i < getEmotionsModel!.emotions!.length; i++) {
            if (getEmotionsModel!.emotions![i].id.toString() == emotionId) {
              emotionValue = getEmotionsModel!.emotions![i];
            }
          }
        } else {
          emotionValue = getEmotionsModel!.emotions![0];
        }
        notifyListeners();
      } else {}
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      getEmotionsModelLoading = false;
      notifyListeners();
    } catch (e) {
      getEmotionsModelLoading = false;
      notifyListeners();
    }
  }

  void addEmotionValue(Emotion emotion) {
    emotionValue = emotion;
    notifyListeners();
  }

  //fetch goals

  void addGoalValue({required Goal value}) {
    goalsValue = value;
    actionList.clear();
    actionListAll.clear();
    notifyListeners();
  }

  void cleaGoalValue() {
    goalsValue = Goal();
    actionList.clear();
    actionListAll.clear();
    Future.microtask(() {
      notifyListeners();
    });
  }

  GetGoalsModel? getGoalsModel;
  bool getGoalsModelLoading = false;
  Goal goalsValue = Goal();
  List<Goal> goalsList = [];
  int pageLoad = 1;

  Future<void> fetchGoals({bool initial = false}) async {
    try {
      String? token = await getUserTokenSharePref();
      getGoalsModelLoading = true;
      notifyListeners();
      if (initial) {
        pageLoad = 1;
        goalsList.clear();
        notifyListeners();
      } else {
        pageLoad += 1;
        notifyListeners();
      }
      final response = await http.get(
        Uri.parse(
          "${UrlConstant.goalsUrl}$pageLoad",
        ),
        headers: <String, String>{"authorization": "$token"},
      );
      if (response.statusCode == 200) {
        getGoalsModel = getGoalsModelFromJson(response.body);
        goalsList.addAll(
          getGoalsModel!.goals!,
        );
        notifyListeners();
      } else {}
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      getGoalsModelLoading = false;
      notifyListeners();
    } catch (e) {
      getGoalsModelLoading = false;
      notifyListeners();
    }
  }

  // void addActionValue({required action.Action value}) {
  //   actionValue = value;
  //   print(actionValue.id.toString());
  //   notifyListeners();
  // }
  //
  // void clearActionValue() {
  //   actionValue = action.Action();
  //   notifyListeners();
  // }

  // GoalActionListModel? goalActionListModel;
  // bool goalActionListModelLoading = false;
  // action.Action actionValue = action.Action();
  // List<action.Action> actionList = [];
  // int pageLoadAction = 1;
  // Future<void> fetchActionsList({bool initial = false}) async {
  //   try {
  //     String? token = await getUserTokenSharePref();
  //     goalActionListModelLoading = true;
  //     notifyListeners();
  //     if (initial) {
  //       pageLoadAction = 1;
  //       actionList.clear();
  //       notifyListeners();
  //     } else {
  //       pageLoadAction += 1;
  //       notifyListeners();
  //     }
  //     final response = await http.get(
  //       Uri.parse(
  //         "${UrlConstant.goalsUrl}$pageLoadAction",
  //       ),
  //       headers: <String, String>{"authorization": "${token}"},
  //     );
  //     log(response.statusCode.toString());
  //     if (response.statusCode == 200) {
  //       log(response.body.toString());
  //       goalActionListModel = goalActionListModelFromJson(response.body);
  //       log(goalActionListModel!.actions![0].title.toString(),
  //           name: "getGoalsModel");
  //       actionList!.addAll(
  //         goalActionListModel!.goals!,
  //       );
  //       notifyListeners();
  //     } else {
  //       log(response.statusCode.toString());
  //     }
  //     goalActionListModelLoading = false;
  //     notifyListeners();
  //   } catch (e) {
  //     goalActionListModelLoading = false;
  //     notifyListeners();
  //     log(e.toString());
  //   }
  // }

  //generate thumpanial
  Future<File> generateThumbnail(File file) async {
    final thumbNailBytes = await VideoCompress.getFileThumbnail(file.path);
    return thumbNailBytes;
  }

  Future<int> getVideoSize(File file) async {
    final size = await file.length();
    return size;
  }

  //fetch goal actions
  GetListGoalActionsModel? getListGoalActionsModel;
  bool getListGoalActionsModelLoading = false;

  Future<void> fetchGoalActions({required String goalId}) async {
    try {
      String? token = await getUserTokenSharePref();
      getListGoalActionsModelLoading = true;
      notifyListeners();
      final response = await http.get(
        Uri.parse(
          UrlConstant.goalActionsUrl(goalId: goalId.toString()),
        ),
        headers: <String, String>{"authorization": "$token"},
      );

      if (response.statusCode == 200) {
        getListGoalActionsModel =
            getListGoalActionsModelFromJson(response.body);

        notifyListeners();
      } else {}
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      getListGoalActionsModelLoading = false;
      notifyListeners();
    } catch (e) {
      getListGoalActionsModelLoading = false;
      notifyListeners();
    }
  }

  GoalDetailModel? goalDetailModel;
  bool goalDetailModelLoading = false;

  Future<void> fetchGoalDetails({required String goalId}) async {
    try {
      goalDetailModel = null;

      String? token = await getUserTokenSharePref();
      goalDetailModelLoading = true;
      notifyListeners();
      final response = await http.get(
        Uri.parse(
          UrlConstant.goalDetails(
            goalId: goalId.toString(),
          ),
        ),
        headers: <String, String>{"authorization": "$token"},
      );

      if (response.statusCode == 200) {
        goalDetailModel = goalDetailModelFromJson(response.body);
        notifyListeners();
      } else {}
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      goalDetailModelLoading = false;
      notifyListeners();
    } catch (e) {
      goalDetailModelLoading = false;
      notifyListeners();
    }
  }

  ActionsDetailsModel? actionsDetailsModel;
  bool actionsDetailsModelLoading = false;

  Future<void> fetchActionDetails({required String actionId}) async {
    try {
      actionsDetailsModel = null;

      String? token = await getUserTokenSharePref();
      actionsDetailsModelLoading = true;
      notifyListeners();
      final response = await http.get(
        Uri.parse(
          UrlConstant.actionDetailsPage(actionId: actionId.toString()),
        ),
        headers: <String, String>{"authorization": "$token"},
      );
      logger.w("response ${response.request}");
      print(response.body.toString() + " fetchActionDetails");
      log(token.toString() + "  $actionId", name: " tokentoken");
      if (response.statusCode == 200) {
        actionsDetailsModel = actionsDetailsModelFromJson(response.body);
        logger.w("locationLatitude${actionsDetailsModel?.actions?.location?.locationLatitude}");
        logger.w("locationLongitude${actionsDetailsModel?.actions?.location?.locationLongitude}");
        notifyListeners();
      } else {
        logger.w("actionsDetailsModelelse${actionsDetailsModel}");
      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      actionsDetailsModelLoading = false;
      notifyListeners();
    } catch (e) {
      logger.w("errorCatch${e}");
      actionsDetailsModelLoading = false;
      notifyListeners();
    }
  }

  bool saveJournalLoading = false;

  Future<bool> saveJournalsFunction(
    BuildContext context, {
    required String journalTitle,
    required String emotionId,
    required String emotionValue,
    required String journalDesc,
    required String driveValue,
    required String goalId,
    required locationName,
    required locationLatitude,
    required locationLongitude,
    required List<String> mediaName,
    required locationAddress,
    required List<String> actionIdList,
  }) async {
    try {
      saveJournalLoading = true;
      notifyListeners();
      String? token = await getUserTokenSharePref();
      var body = {
        'emotion_id': emotionId,
        'emotion_value': emotionValue,
        'journal_desc': journalDesc,
        'drive_value': driveValue,
        'goal_id': goalId,
        // 'action_id': actionId,
        // 'media_name[]': '926297553.jpeg',
        // 'media_name[]': '926297553.jpeg',
        'location_name': locationName,
        'location_address': locationAddress,
        'location_latitude': locationLatitude,
        'location_longitude': locationLongitude,
        'journal_title': journalTitle,
      };
      for (int i = 0; i < mediaName.length; i++) {
        body['media_name[$i]'] = mediaName[i];
      }
      for (int i = 0; i < actionIdList.length; i++) {
        body['action_id[$i]'] = actionIdList[i];
      }

      final response = await http.post(
        Uri.parse(
          UrlConstant.journalUrl,
        ),
        headers: <String, String>{
          "authorization": "$token",
        },
        body: body,
      );
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        clearAllValuesInSaveTime();

        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
        saveJournalLoading = false;
        notifyListeners();
        return true;
      } else {
        // Handle errors based on the status code
        showCustomSnackBar(
            context: context, message: json.decode(response.body)["text"]);
        saveJournalLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      saveJournalLoading = false;
      notifyListeners();
      return false;
    }
  }

//update journal
//   bool saveJournalLoading = false;
  Future<bool> updateJournalLoading(
    BuildContext context, {
    required String journalId,
    required String journalTitle,
    required String emotionId,
    required String emotionValue,
    required String journalDesc,
    required String driveValue,
    required String goalId,
    required locationName,
    required locationLatitude,
    required locationLongitude,
    required List<String> mediaName,
    required locationAddress,
    required List<String> actionIdList,
  }) async {
    try {
      saveJournalLoading = true;
      notifyListeners();
      String? token = await getUserTokenSharePref();
      var body = {
        'emotion_id': emotionId,
        'emotion_value': emotionValue,
        'journal_desc': journalDesc,
        'drive_value': driveValue,
        'goal_id': goalId,
        // 'action_id': actionId,
        // 'media_name[]': '926297553.jpeg',
        // 'media_name[]': '926297553.jpeg',
        'location_name': locationName,
        'location_address': locationAddress,
        'location_latitude': locationLatitude,
        'location_longitude': locationLongitude,
        'journal_title': journalTitle,
        'journal_id': journalId,
      };
      for (int i = 0; i < mediaName.length; i++) {
        body['media_name[$i]'] = mediaName[i];
      }
      for (int i = 0; i < actionIdList.length; i++) {
        body['action_id[$i]'] = actionIdList[i];
      }

      final response = await http.post(
        Uri.parse(
          "${UrlConstant.journalUrl}$journalId",
        ),
        headers: <String, String>{
          "authorization": "$token",
        },
        body: body,
      );
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        clearAllValuesInSaveTime();
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
        saveJournalLoading = false;
        notifyListeners();
        return true;
      } else {
        showCustomSnackBar(
            context: context, message: json.decode(response.body)["text"]);
        saveJournalLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      saveJournalLoading = false;
      notifyListeners();
      return false;
    }
  }

  //mediaUpload
  bool saveMediaUploadLoading = false;

  Future<void> saveMediaUploadMental({
    required String file,
    required String type,
    required String fileType,
    String? thumbNail,
    String? isCamera,
  }) async {
    try {
      String? token = await getUserTokenSharePref();
      saveMediaUploadLoading = true;
      notifyListeners();
      var headers = {
        "authorization": "$token",
      };
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          UrlConstant.mediauploadUrl,
        ),
      );

      request.fields.addAll(
        {
          'type': type,
          'file_type': fileType,
        },
      );

      logger.w("fileType${fileType}");

      // request.fields.addAll(
      //   {
      //     'file_type': fileType,
      //   },
      // );
      request.files.add(
        await http.MultipartFile.fromPath(
          'media_name',
          file,
        ),
      );
      if (thumbNail != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'media_thumb',
            thumbNail,
          ),
        );
      }

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      // print(await response.stream.bytesToString());
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        String? mediaName = jsonResponse['media_name'];
        List<String> mediaNameList = [];
        mediaNameList.add(mediaName!);
        addMediaUploadResponseListFunction(
          mediaNameList,
        );
        notifyListeners();
        // if (mediaName != null) {
        // } else {
        // }
      } else {}
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      saveMediaUploadLoading = false;
      notifyListeners();
    } catch (error) {
      saveMediaUploadLoading = false;
      notifyListeners();
    }
  }

  void clearAllValuesInSaveTime() {
    descriptionEditTextController.clear();
    // emotionValue = Emotion();
    emotionalValueStar = 0;
    driveValueStar = 0;
    // goalsValue = Goal();
    selectedLocationName = '';
    selectedLatitude = '';
    locationLongitude = '';
    addMediaUploadResponseList = [];
    selectedLocationAddress = '';
    recordedFilePath.clear();
    alreadyRecordedFilePath.clear();
    pickedImages.clear();
    takedImages.clear();
    alreadyPickedImages.clear();
    alreadyTakedImages.clear();
    actionList.clear();
    actionListAll.clear();
    cleaGoalValue();
    // notifyListeners();
  }

  //add action List
  List<action.Action> actionListAll = [];
  List<action.Action> actionList = [];

  void addActionFunction({required action.Action value}) {
    actionListAll.add(value);
    actionList.clear();
    actionList = actionListAll.toSet().toList();
    notifyListeners();
  }

  void clearActionListSelected({required int index}) {
    actionList.removeAt(index);
    for (var element in actionList) {
      actionListAll.remove(element);
    }
    notifyListeners();
  }

  //remove media
  bool removeMediaLoading = false;

  Future<void> removeMediaFunction({
    required BuildContext context,
    required String id,
    required String type,
  }) async {
    try {
      String? token = await getUserTokenSharePref();
      removeMediaLoading = true;
      notifyListeners();
      var body = {
        'id': id,
        'type': type,
      };
      final response = await http.post(
        Uri.parse(
          UrlConstant.removemediaUrl,
        ),
        headers: <String, String>{"authorization": "$token"},
        body: body,
      );

      if (response.statusCode == 200) {
      } else {
        showCustomSnackBar(context: context, message: 'media failed.');
      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      removeMediaLoading = false;
      notifyListeners();
    } catch (error) {
      removeMediaLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveButtonFunction(BuildContext context) async {
    if (!isVideoUploading) {
      if (descriptionEditTextController.text.isNotEmpty) {
        bool isSuccess = await saveJournalsFunction(
          context,
          journalTitle: descriptionEditTextController.text,
          journalDesc: descriptionEditTextController.text,
          emotionId: emotionValue.id.toString(),
          emotionValue: emotionalValueStar.toString(),
          driveValue: driveValueStar.toString(),
          goalId: goalsValue.id.toString(),
          locationName: selectedLocationName,
          locationLatitude: selectedLatitude,
          locationLongitude: locationLongitude,
          mediaName: addMediaUploadResponseList,
          locationAddress: selectedLocationAddress,
          actionIdList: actionList.map((e) => e.id ?? "").toList(),
        );
        if (isSuccess || !isSuccess ) {
          DashBoardProvider dashBoardProvider =
              Provider.of<DashBoardProvider>(context, listen: false);
          HomeProvider homeProvider =
              Provider.of<HomeProvider>(context, listen: false);
          await homeProvider.fetchJournals(initial: true);
          dashBoardProvider.changePage(index: 0);

        }
      } else {
        showCustomSnackBar(
          context: context,
          message: "Enter Fields",
        );
      }
    } else {
      showCustomSnackBar(
        context: context,
        message: "Please wait video upload",
      );
    }
  }
}
