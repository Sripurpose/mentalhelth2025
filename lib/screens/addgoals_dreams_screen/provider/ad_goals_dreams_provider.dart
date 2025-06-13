import 'dart:convert';
import 'dart:io';



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/logic/date_format.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:mentalhelth/widgets/widget/video_compessor.dart';
import 'package:video_compress/video_compress.dart';

import '../../../utils/core/constent.dart';
import '../../../utils/theme/colors.dart';
import '../../maintenence_screen/maintenence_screen.dart';
import '../../mental_strength_add_edit_screen/model/all_model.dart';
import '../../token_expiry/token_expiry.dart';
import '../model/id_model.dart';

class AdDreamsGoalsProvider extends ChangeNotifier {

  void addLocationSection({
    required String selectedAddress,
    required Placemark placemark,
    required LatLng location,
  }) {
    selectedLocationName =
        selectedLocationAddress =
    "${placemark.name}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
    selectedLatitude = location.latitude.toString();
    selectedLongitude = location.longitude.toString();
    _selectedLocation = location;
    _selectedAddress = selectedAddress;
    notifyListeners();
  }

  void clearLocationSelection() {
    selectedLocationName = '';
    selectedLocationAddress = '';
    selectedLatitude = '';
    selectedLongitude = '';
    _selectedLocation = null;
    _selectedAddress = '';
    notifyListeners();
  }

  TextEditingController nameEditTextController = TextEditingController();

  TextEditingController commentEditTextController = TextEditingController();
  String formattedDate = '';
  String selectedDate = '';

  String selectedLocationName = '';
  String selectedLocationAddress = '';
  String selectedLatitude = '';
  String selectedLongitude = '';
  bool isVideoUploading = false;
  List<String> addMediaUploadResponseList = [];

  LatLng? _selectedLocation;
  String _selectedAddress = '';

  LatLng? get selectedLocation => _selectedLocation;
  String get selectedAddress => _selectedAddress;

  void addMediaUploadResponseListFunction(List<String> value) {
    addMediaUploadResponseList.addAll(value);
    notifyListeners();
  }

  void removeMediaUploadResponseListFunction(int index) {
    // Check if the index is valid before attempting to remove
    if (index >= 0 && index < addMediaUploadResponseList.length) {
      addMediaUploadResponseList.removeAt(index);  // Remove item at the given index

    } else {

    }
    notifyListeners();  // Notify listeners after modifying the list
  }

  TextEditingController descriptionEditTextController = TextEditingController();
  double emotionalValueStar = 0;

  void changeEmotionalValueStar(double value) {
    emotionalValueStar = value;
    notifyListeners();
  }

  double driveValueStar = 0;

  void changeDriveValueStar(double value) {
    driveValueStar = value;
    notifyListeners();
  }

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

  Future<void> pickImageFunctionOld(BuildContext context) async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );

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
          type: "goal",
          fileType: lastThreeChars,
          context: context);
      notifyListeners();
    }
    // }
  }

  Future<void> pickImageFunction(BuildContext context) async {
    final pickedImages = await ImagePicker().pickMultiImage(
      imageQuality: 100,
    );

    if (pickedImages != null && pickedImages.isNotEmpty) {
      // Filter out GIF files
      final validImages = pickedImages.where((image) {
        final extension = image.path.toLowerCase().split('.').last;
        return extension != 'gif';
      }).toList();

      if (validImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("GIF files are not supported.")),
        );
        return;
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: Row(
            children: [
              CupertinoActivityIndicator(color: ColorsContent.newThemeColor),
              const SizedBox(width: 16),
              const Text("Uploading images..."),
            ],
          ),
        ),
      );

      List<String> imagePaths = [];

      for (var pickedImage in validImages) {
        final originalFile = File(pickedImage.path);
        final fileSizeInBytes = await originalFile.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        String pathToUpload = pickedImage.path;
        String fileType = pickedImage.path.split('.').last.toLowerCase();

        // Compress if size > 5 MB
        if (fileSizeInMB > 5) {
          final targetPath =
              "${originalFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

          final compressedFile = await FlutterImageCompress.compressAndGetFile(
            originalFile.absolute.path,
            targetPath,
            quality: 70,
          );

          if (compressedFile != null) {
            pathToUpload = compressedFile.path;
            fileType = 'jpg'; // Compressed output is jpg
          }
        }

        imagePaths.add(pathToUpload);

        await saveMediaUploadMental(
          file: pathToUpload,
          type: "goal",
          fileType: fileType,
          context: context,
        );
      }

      pickedImagesAddFunction(imagePaths);
      notifyListeners();

      Navigator.of(context, rootNavigator: true).pop();
    }
  }



  Future<void> pickVideoFunction(BuildContext context) async {
    final pickedVideoPath = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );

    if (!isVideoUploading && pickedVideoPath != null) {
      try {
        isVideoUploading = true;
        notifyListeners();

        File originalFile = File(pickedVideoPath.path);
        final fileSizeInBytes = await originalFile.length();
        final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

        print("📦 Original video size: ${fileSizeInMB.toStringAsFixed(2)} MB");

        File videoToUpload = originalFile;

        // Compress if size > 100 MB
        if (fileSizeInMB > 100) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              content: Row(
                children: [
                  CupertinoActivityIndicator(color: ColorsContent.newThemeColor),
                  const SizedBox(width: 16),
                  const Text("Compressing video..."),
                ],
              ),
            ),
          );

          final compressedVideoInfo = await VideoCompress.compressVideo(
            pickedVideoPath.path,
            quality: VideoQuality.LowQuality,
            deleteOrigin: false,
          );

          Navigator.pop(context); // dismiss compression dialog

          if (compressedVideoInfo == null || compressedVideoInfo.file == null) {
            showCustomSnackBar(
              context: context,
              message: "Video compression failed.",
            );
            isVideoUploading = false;
            notifyListeners();
            return;
          }

          videoToUpload = compressedVideoInfo.file!;
          final compressedSize = await videoToUpload.length();
          print("📉 Compressed video size: ${(compressedSize / (1024 * 1024)).toStringAsFixed(2)} MB");
        }

        // Show loading dialog for upload
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            content: Row(
              children: [
                CupertinoActivityIndicator(color: ColorsContent.newThemeColor),
                const SizedBox(width: 16),
                const Text("Uploading video..."),
              ],
            ),
          ),
        );

        String fileExtension = videoToUpload.path.split('.').last;
        String lastThreeChars = fileExtension.substring(fileExtension.length - 3);

        List<String> videoPaths = [videoToUpload.path];
        pickedImagesAddFunction(videoPaths);

        File thumbNailFile = await generateThumbnail(videoToUpload);

        await saveMediaUploadMental(
          file: videoToUpload.path,
          type: "goal",
          fileType: "mp4",
          thumbNail: thumbNailFile.path,
          context: context,
        );

        Navigator.pop(context); // Dismiss upload dialog
      } catch (e) {
        Navigator.pop(context); // Ensure dialog is dismissed
        showCustomSnackBar(
          context: context,
          message: "An error occurred: $e",
        );
      } finally {
        isVideoUploading = false;
        notifyListeners();
      }
    } else if (isVideoUploading) {
      showCustomSnackBar(
        context: context,
        message: "Please Wait, Video is Uploading",
      );
    }
  }



  // Future<void> pickVideoFunction(BuildContext context) async {
  //   final pickedVideoPath = await ImagePicker().pickVideo(
  //     source: ImageSource.gallery,
  //   );
  //
  //   if (!isVideoUploading) {
  //     if (pickedVideoPath != null) {
  //       try {
  //         isVideoUploading = true;
  //         notifyListeners();
  //
  //         String fileExtension = pickedVideoPath.path.split('.').last;
  //         String lastThreeChars = fileExtension.substring(fileExtension.length - 3);
  //
  //         List<String> videoPaths = [];
  //         videoPaths.add(pickedVideoPath.path);
  //         pickedImagesAddFunction(videoPaths);
  //
  //         // Path for compressed video output
  //         final String outputPath = '${pickedVideoPath.path}_compressed.mp4';
  //
  //         // Compress video using optimized settings
  //         await FFmpegKit.execute(
  //             '-y -i ${pickedVideoPath.path} -vcodec libx264 -preset veryfast -crf 30 -movflags +faststart -vf "scale=320:240" -r 12 -b:v 200k -acodec aac -b:a 32k -ac 1 $outputPath'
  //         ).then((session) async {
  //           final returnCode = await session.getReturnCode();
  //
  //           if (returnCode!.isValueSuccess()) {
  //             // Video compression successful
  //             File thumbNailFile = await generateThumbnail(File(outputPath));
  //
  //             await saveMediaUploadMental(
  //               file: outputPath,
  //               type: "goal",
  //               fileType: "mp4",
  //               thumbNail: thumbNailFile.path,
  //               context: context,
  //             );
  //           } else {
  //             showCustomSnackBar(
  //               context: context,
  //               message: "Video compression failed.",
  //             );
  //           }
  //         });
  //       } catch (e) {
  //         // Handle any errors that occur during the process
  //         showCustomSnackBar(
  //           context: context,
  //           message: "An error occurred: $e",
  //         );
  //       } finally {
  //         // Ensure this is always executed, regardless of success or failure
  //         isVideoUploading = false;
  //         notifyListeners();
  //       }
  //     }
  //   } else {
  //     showCustomSnackBar(
  //       context: context,
  //       message: "Please Wait, Video is Uploading",
  //     );
  //   }
  // }


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

  void pickedImagesRemove(index) {
    pickedImages.removeAt(index);
    notifyListeners();
  }

  //image take section
  // File? takeFile;

  Future<void> takeFileFunction(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      try {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            content: Row(
              children: [
                CupertinoActivityIndicator(
                  color: ColorsContent.newThemeColor,
                ),
                const SizedBox(width: 16),
                const Text("Capturing images..."),
              ],
            ),
          ),
        );

        String fileExtension = pickedFile.path.split('.').last;
        String lastThreeChars = fileExtension.substring(fileExtension.length - 3);

        List<String> imagePaths = [];
        imagePaths.add(pickedFile.path);
        takedImagesAddFunction(imagePaths);

        // Directly save image or video without compression
        await saveMediaUploadMental(
          file: pickedFile.path,
          type: "goal",
          fileType: lastThreeChars,
          context: context,
        );
      } catch (e) {
        showCustomSnackBar(
          context: context,
          message: "An error occurred: $e",
        );
      } finally {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading dialog
        notifyListeners();
      }
    }
  }



  // Future<void> takeFileFunction(BuildContext context) async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
  //
  //   if (pickedFile != null) {
  //     try {
  //       String fileExtension = pickedFile.path.split('.').last;
  //       String lastThreeChars = fileExtension.substring(fileExtension.length - 3);
  //
  //       List<String> imagePaths = [];
  //       imagePaths.add(pickedFile.path);
  //       takedImagesAddFunction(imagePaths);
  //
  //       // Check if the file is a video based on its extension
  //       if (lastThreeChars.toLowerCase() == 'mp4' ||
  //           lastThreeChars.toLowerCase() == 'mov' ||
  //           lastThreeChars.toLowerCase() == 'avi') {
  //         // Path for compressed video output
  //         final String outputPath = '${pickedFile.path}_compressed.mp4';
  //
  //         // Compress the video using FFmpeg
  //         await FFmpegKit.execute(
  //             '-y -i ${pickedFile.path} -vcodec libx264 -preset veryfast -crf 30 -movflags +faststart -vf "scale=320:240" -r 12 -b:v 200k -acodec aac -b:a 32k -ac 1 $outputPath'
  //         ).then((session) async {
  //           final returnCode = await session.getReturnCode();
  //
  //           if (returnCode!.isValueSuccess()) {
  //             // Compression successful, save the compressed video
  //             await saveMediaUploadMental(
  //               file: outputPath,
  //               type: "goal",
  //               fileType: lastThreeChars,
  //               context: context,
  //             );
  //           } else {
  //             // Handle compression failure
  //             showCustomSnackBar(
  //               context: context,
  //               message: "Video compression failed.",
  //             );
  //           }
  //         });
  //       } else {
  //         // Save the image without compression
  //         await saveMediaUploadMental(
  //           file: pickedFile.path,
  //           type: "goal",
  //           fileType: lastThreeChars,
  //           context: context,
  //         );
  //       }
  //     } catch (e) {
  //       // Handle errors during the process
  //       showCustomSnackBar(
  //         context: context,
  //         message: "An error occurred: $e",
  //       );
  //     } finally {
  //       // Notify listeners to update UI
  //       notifyListeners();
  //     }
  //   }
  // }


  Future<void> takeVideoFunction(BuildContext context) async {
    final pickeVideo = await ImagePicker().pickVideo(
      source: ImageSource.camera,
    );

    if (!isVideoUploading) {
      if (pickeVideo != null) {
        try {
          isVideoUploading = true;
          notifyListeners();

          // Show loading dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              content: Row(
                children: [
                  CupertinoActivityIndicator(
                    color: ColorsContent.newThemeColor,
                  ),
                  const SizedBox(width: 16),
                  const Text("Uploading video..."),
                ],
              ),
            ),
          );

          String fileExtension = pickeVideo.path.split('.').last;
          String lastThreeChars = fileExtension.substring(fileExtension.length - 3);

          List<String> imagePaths = [pickeVideo.path];
          takedImagesAddFunction(imagePaths);

          // Generate thumbnail
          File thumbNailFile = await generateThumbnail(File(pickeVideo.path));

          // Save original video without compression
          await saveMediaUploadMental(
            file: pickeVideo.path,
            type: "goal",
            fileType: "mp4", // or use lastThreeChars if needed
            thumbNail: thumbNailFile.path,
            context: context,
          );
        } catch (e) {
          showCustomSnackBar(
            context: context,
            message: "An error occurred: $e",
          );
        } finally {
          isVideoUploading = false;
          Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading dialog
          notifyListeners();
        }
      }
    } else {
      showCustomSnackBar(
        context: context,
        message: "Please wait, video is uploading.",
      );
    }
  }



  // Future<void> takeVideoFunction(BuildContext context) async {
  //   final pickeVideo = await ImagePicker().pickVideo(
  //     source: ImageSource.camera,
  //   );
  //
  //   if (!isVideoUploading) {
  //     if (pickeVideo != null) {
  //       try {
  //         isVideoUploading = true;
  //         notifyListeners();
  //
  //         // Extract the file extension
  //         String fileExtension = pickeVideo.path.split('.').last;
  //         String lastThreeChars = fileExtension.substring(fileExtension.length - 3);
  //
  //         List<String> imagePaths = [];
  //         imagePaths.add(pickeVideo.path);
  //         takedImagesAddFunction(imagePaths);
  //
  //         // Path for compressed video output
  //         final String outputPath = '${pickeVideo.path}_compressed.mp4';
  //
  //         // Compress video using optimized settings
  //         await FFmpegKit.execute(
  //             '-y -i ${pickeVideo.path} -vcodec libx264 -preset veryfast -crf 30 -movflags +faststart -vf "scale=320:240" -r 12 -b:v 200k -acodec aac -b:a 32k -ac 1 $outputPath'
  //         ).then((session) async {
  //           final returnCode = await session.getReturnCode();
  //
  //           if (returnCode!.isValueSuccess()) {
  //             // Video compression successful
  //             File thumbNailFile = await generateThumbnail(File(outputPath));
  //
  //             await saveMediaUploadMental(
  //               file: outputPath,
  //               type: "goal",
  //               fileType: "mp4",
  //               thumbNail: thumbNailFile.path,
  //               context: context,
  //             );
  //           } else {
  //             showCustomSnackBar(
  //               context: context,
  //               message: "Video compression failed.",
  //             );
  //           }
  //         });
  //       } catch (e) {
  //         // Handle any errors that occur during the process
  //         showCustomSnackBar(
  //           context: context,
  //           message: "An error occurred: $e",
  //         );
  //       } finally {
  //         // Ensure this is always executed, regardless of success or failure
  //         isVideoUploading = false;
  //         notifyListeners();
  //       }
  //     }
  //   } else {
  //     showCustomSnackBar(
  //       context: context,
  //       message: "Please Wait, Video is Uploading",
  //     );
  //   }
  // }


  List<String> takedImages = [];

  void takedImagesAddFunction(List<String> images) {
    takedImages.addAll(images);
    notifyListeners();
  }

  void takedImagesRemove(index) {
    takedImages.removeAt(index);
    notifyListeners();
  }

  Future<int> getVideoSize(File file) async {
    final size = await file.length();
    return size;
  }

  bool saveAddActionsLoading = false;

  Future<void> saveGemFunction(
    BuildContext context, {
    bool isPop = true,
    required String title,
    required String details,
    required List<String> mediaName,
    required String locationName,
    required String locationLatitude,
    required String locationLongitude,
    required String locationAddress,
    required String categoryId,
    required String gemEndDate,
    required List<GoalModelIdName> actionId,
  }) async {
    try {
      saveAddActionsLoading = true;
      String deviceType = Platform.isAndroid ? 'android' : 'ios';
      String? versionCode = '';
      if (Platform.isAndroid) {
        versionCode = Constent.versionCodeAndroid.isNotEmpty
            ? Constent.versionCodeAndroid
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      } else if (Platform.isIOS) {
        versionCode = Constent.versionCodeIOS.isNotEmpty
            ? Constent.versionCodeIOS
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      }
      notifyListeners();
      String? token = await getUserTokenSharePref();
      var body = {
        'title': title,
        'gem_type': 'goal',
        'details': details,
        'gem_enddate': gemEndDate,
        'location_name': locationName,
        'location_latitude': locationLatitude,
        'location_longitude': locationLongitude,
        'category_id': categoryId,
        'location_address': locationAddress,
      };
      for (int i = 0; i < mediaName.length; i++) {
        body['media_name[$i]'] = mediaName[i];
      }
      for (int i = 0; i < actionId.length; i++) {
        body['action_id[$i]'] = actionId[i].id;
      }
      final response = await http.post(
        Uri.parse(
          UrlConstant.savegemUrl,
        ),
        headers: <String, String>{
          'device-type': deviceType,
          'version': versionCode.toString(),
          "authorization": "$token"},
        body: body,
      );
      print(response.statusCode.toString());
      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
        clearAction();
        if (isPop) {
          Navigator.of(context).pop();
        }
      }
      else if(response.statusCode == 503){
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MaintenenceScreen(
                title: "App is in maintainance mode, Please be patient, we'll be back in a couple of hours!",
                message: "",
              ),
            ),
          );
        });
      }
      else {
        // Handle errors based on the status code
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      saveAddActionsLoading = false;
      notifyListeners();
    } catch (error) {
      showCustomSnackBar(context: context, message: "Failed");
      saveAddActionsLoading = false;
      notifyListeners();
    }
  }

  bool updateGoalLoading = false;

  Future<void> updateGoalFunction(
    BuildContext context, {
    required String title,
    required String details,
    required List<String> mediaName,
    required String locationName,
    required String locationLatitude,
    required String locationLongitude,
    required String locationAddress,
    required String categoryId,
    required String gemEndDate,
    required List<GoalModelIdName> actionId,
    required String gemId,
  }) async {
    try {
      updateGoalLoading = true;
      String deviceType = Platform.isAndroid ? 'android' : 'ios';
      String? versionCode = '';
      if (Platform.isAndroid) {
        versionCode = Constent.versionCodeAndroid.isNotEmpty
            ? Constent.versionCodeAndroid
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      } else if (Platform.isIOS) {
        versionCode = Constent.versionCodeIOS.isNotEmpty
            ? Constent.versionCodeIOS
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      }
      notifyListeners();
      String? token = await getUserTokenSharePref();
      var body = {
        'title': title,
        'gem_type': 'goal',
        'details': details,
        'gem_enddate': gemEndDate,
        'location_name': locationName,
        'location_latitude': locationLatitude,
        'location_longitude': locationLongitude,
        'category_id': categoryId,
        'location_address': locationAddress,
        'gem_id': gemId,
      };
      for (int i = 0; i < mediaName.length; i++) {
        body['media_name[$i]'] = mediaName[i];
      }
      //comented sarath on 16-09-2024
      // for (int i = 0; i < actionId.length; i++) {
      //   body['action_id[$i]'] = actionId[i].id;
      // }
      final response = await http.post(
        Uri.parse(
          UrlConstant.savegemUrl,
        ),
        headers: <String, String>{
          'device-type': deviceType,
          'version': versionCode.toString(),
          "authorization": "$token"},
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
        clearAction();
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
      else if(response.statusCode == 503){
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MaintenenceScreen(
                title: "App is in maintainance mode, Please be patient, we'll be back in a couple of hours!",
                message: "",
              ),
            ),
          );
        });
      }
      else {
        // Handle errors based on the status code
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
      }
      if(response.statusCode == 401){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      if(response.statusCode == 403){
        TokenManager.setTokenStatus(true);
        //CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
      }
      updateGoalLoading = false;
      notifyListeners();
    } catch (error) {
      showCustomSnackBar(context: context, message: "Failed");
      updateGoalLoading = false;
      notifyListeners();
    }
  }

  // ad media upload
  bool saveMediaUploadLoading = false;

  Future<void> saveMediaUploadMental({
    required String file,
    required String type,
    required String fileType,
    String? thumbNail,
    required BuildContext context,
  }) async {
    try {
      String? token = await getUserTokenSharePref();
      saveMediaUploadLoading = true;
      String deviceType = Platform.isAndroid ? 'android' : 'ios';
      String? versionCode = '';
      if (Platform.isAndroid) {
        versionCode = Constent.versionCodeAndroid.isNotEmpty
            ? Constent.versionCodeAndroid
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      } else if (Platform.isIOS) {
        versionCode = Constent.versionCodeIOS.isNotEmpty
            ? Constent.versionCodeIOS
            : await getVersionSharePref(); // Fetch user ID if version code is empty
      }
      notifyListeners();
      var headers = {
        'device-type': deviceType,
        'version': versionCode.toString(),
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
      } else {
        showCustomSnackBar(
            context: context, message: response.reasonPhrase.toString());
      }
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
      showCustomSnackBar(context: context, message: error.toString());
    }
  }

  Future<void> clearAction() async {
    nameEditTextController.clear();
    commentEditTextController.clear();
    addMediaUploadResponseList = [];
    selectedLocationName = '';
    selectedLatitude = '';
    selectedLongitude = '';
    selectedLocationAddress = '';
    formattedDate = '';
    selectedDate = '';
    recordedFilePath.clear();
    alreadyRecordedFilePath.clear();
    pickedImages.clear();
    alreadyPickedImages.clear();
    takedImages.clear();
    goalModelIdName.clear();
    notifyListeners();
  }

  Future<File> generateThumbnail(File file) async {
    final thumbNailBytes = await VideoCompress.getFileThumbnail(file.path);
    return thumbNailBytes;
  }

  DateTime? date;

  Future<void> selectDate(BuildContext context) async {
    date = DateTime.now();
    selectedDate = dateFormatter(date: date.toString());
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != date) {
      int dateInMilliseconds = picked.millisecondsSinceEpoch;
      formattedDate = dateInMilliseconds.toString();
      date = picked;
      selectedDate = dateFormatter(date: picked.toString());

      notifyListeners();
    }
  }

  List<GoalModelIdName> goalModelIdName = [];

  void getAddActionIdAndName({required GoalModelIdName value}) {
    List<GoalModelIdName> valueAddHere = [];
    valueAddHere.add(value);
    goalModelIdName.addAll(valueAddHere);
    notifyListeners();
  }

  void getAddActionIdAndNameClear(int index) {
    goalModelIdName.removeAt(index);
    notifyListeners();
  }
}
