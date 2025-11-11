import 'dart:async';
import 'dart:convert';
import 'dart:io';



import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/logic/date_format.dart';
import 'package:mentalhelth/utils/logic/shared_prefrence.dart';
import 'package:mentalhelth/widgets/functions/snack_bar.dart';
import 'package:mentalhelth/widgets/widget/video_compessor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

import '../../../utils/core/constent.dart';
import '../../../utils/theme/colors.dart';
import '../../maintenence_screen/maintenence_screen.dart';
import '../../mental_strength_add_edit_screen/model/all_model.dart';
import '../../token_expiry/token_expiry.dart';
import '../model/all_Goals_List_Link_Response_Model.dart';
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


  String? selectedOption;

  final List<String> goalOptions = [
    'Create New Goal',
    'Add to Existing Goal',
  ];

  String? selectedExistingGoal;


  AllGoalsListLinkResponseModel? getAllGoalsLinkModel;
  bool getAllGoalsLinkLoading = false;
  List<GoalListLink> goalListLink = [];

  Future<void> fetchAllGoalsForLink(
      BuildContext context)
  async {
    try {
      getAllGoalsLinkModel = null;

      String? token = await getUserTokenSharePref();
      getAllGoalsLinkLoading = true;
      logger.w("getAllGoalsLinkLoading $getAllGoalsLinkLoading");
      notifyListeners();

      Uri url = Uri.parse(UrlConstant.allGoalsUrl);
      logger.w("url $url");

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

      Map<String, String> headers = {
        'Device-Type': deviceType,
        'Version': versionCode.toString(),
        'authorization': token!, // Assuming token is not null
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 201) {
      //  statusDynamicMenu = response.statusCode;
        getAllGoalsLinkModel = allGoalsListLinkResponseModelFromJson(response.body);
        if (getAllGoalsLinkModel != null) {
          if (getAllGoalsLinkModel!.goalsListLink != null) {
            goalListLink.addAll(getAllGoalsLinkModel!.goalsListLink!);
            logger.w("goalListLink${jsonEncode(getAllGoalsLinkModel)}");
          }
        }
        getAllGoalsLinkLoading = false;
        notifyListeners();

        logger.w("getAllGoalsLinkLoading $getAllGoalsLinkLoading");
        logger.w("dynamicMenuResponseModel $getAllGoalsLinkModel");
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
        logger.i("getAllGoalsLinkModel${jsonEncode(getAllGoalsLinkModel?.status)}");
        if (response.statusCode == 401 || response.statusCode == 403) {
        //  statusDynamicMenu = response.statusCode;
          //   TokenManager.setTokenStatus(true);
          // CacheManager.setAccessToken(CacheManager.getUser().refreshToken);
        }
      }

      getAllGoalsLinkLoading = false;
      notifyListeners();
    } catch (e) {
      logger.e("Error fetching all goals list: $e");
      getAllGoalsLinkLoading = false;
      notifyListeners();
    }
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
  var logger = Logger();

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
      imageQuality: 100, // Will be overridden by manual compression logic
    );

    if (pickedImages != null && pickedImages.isNotEmpty) {
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
          backgroundColor: ColorsContent.newThemeColor,
          content: Row(
            children: [
              CupertinoActivityIndicator(color: ColorsContent.whiteText),
              const SizedBox(width: 16),
              const Text(
                "Uploading images...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Open Sans',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );

      List<String> imagePaths = [];

      for (var pickedImage in validImages) {
        try {
          final originalFile = File(pickedImage.path);
          final bytes = await originalFile.readAsBytes();
          final decodedImage = await decodeImageFromList(bytes);

          final int width = decodedImage.width;
          final int height = decodedImage.height;

          int minWidth;
          int minHeight;
          int quality;

          // --- Compression Settings ---
          if (width >= 6000 || height >= 4000) {
            minWidth = 6000;
            minHeight = 4000;
            quality = 18;
          } else if (width >= 4600 || height >= 3000) {
            minWidth = 4600;
            minHeight = 3000;
            quality = 22;
          } else if (width >= 3500 || height >= 2500) {
            minWidth = 3500;
            minHeight = 2500;
            quality = 50;
          } else if (width >= 2500 || height >= 1800) {
            minWidth = 2500;
            minHeight = 1800;
            quality = 75;
          } else {
            minWidth = 2300;
            minHeight = 1500;
            quality = 94;
          }

          String pathToUpload = pickedImage.path;
          String fileType = pickedImage.path.split('.').last.toLowerCase();

          final targetPath =
              "${originalFile.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

          final compressedFile = await FlutterImageCompress.compressAndGetFile(
            originalFile.absolute.path,
            targetPath,
            minWidth: minWidth,
            minHeight: minHeight,
            quality: quality,
          );

          if (compressedFile != null) {
            pathToUpload = compressedFile.path;
            fileType = 'jpg'; // Override since output is .jpg
          }

          debugPrint("Original Size: ${await originalFile.length()} bytes");
          if (compressedFile != null) {
            debugPrint("Compressed Size: ${await compressedFile.length()} bytes");
          }

          imagePaths.add(pathToUpload);

          await saveMediaUploadMental(
            file: pathToUpload,
            type: "goal",
            fileType: fileType,
            context: context,
          );
        } catch (e) {
          debugPrint("Error processing image: $e");
          continue;
        }
      }

      pickedImagesAddFunction(imagePaths);
      notifyListeners();

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close dialog
      }
    }
  }




  ///not used function for video pick and compression///
  Future<void> pickVideoFunctionWithoutMulti(BuildContext context) async {
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

        final MediaInfo? info = await VideoCompress.getMediaInfo(pickedVideoPath.path);
        final double durationInSeconds = (info?.duration ?? 0) / 1000;
        print("⏱ Video duration: ${durationInSeconds.toStringAsFixed(2)} seconds");

        if (fileSizeInMB > 300 || durationInSeconds > 300) {
          showCustomSnackBar(
            context: context,
            message: "Video must be ≤ 300MB and ≤ 5 minutes.",
          );
          isVideoUploading = false;
          notifyListeners();
          return;
        }

        File videoToUpload = originalFile;

        VideoQuality compressionQuality;
        if (fileSizeInMB <= 20) {
          compressionQuality = VideoQuality.HighestQuality;
          print('⚙️ Using HighestQuality for ≤ 20MB');
        } else if (fileSizeInMB <= 50) {
          compressionQuality = VideoQuality.MediumQuality;
          print('⚙️ Using MediumQuality for 21MB - 50MB');
        } else {
          compressionQuality = VideoQuality.LowQuality;
          print('⚙️ Using LowQuality for > 50MB');
        }


        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: ColorsContent.newThemeColor,
            content: Row(
              children: [
                CupertinoActivityIndicator(color: ColorsContent.whiteText),
                const SizedBox(width: 16),
                const Text("Compressing video...",
                  style:TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Open Sans',
                    color: Colors.white,
                  ),),
              ],
            ),
          ),
        );


        final MediaInfo? compressedVideoInfo = await VideoCompress.compressVideo(
          originalFile.path,
          quality: compressionQuality,
          deleteOrigin: false,
          includeAudio: true,
          frameRate: 30,
        );

        if (Navigator.canPop(context)) Navigator.pop(context); // Dismiss compression dialog

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

        // ✅ Copy to safe temporary path
        final safePath = await saveVideoToTemp(videoToUpload.path);
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: ColorsContent.newThemeColor,
            content: Row(
              children: [
                CupertinoActivityIndicator(color: ColorsContent.whiteText),
                const SizedBox(width: 16),
                const Text("Uploading video...",
                  style:TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Open Sans',
                    color: Colors.white,
                  ),),
              ],
            ),
          ),
        );

        pickedImagesAddFunction([safePath]);

        File thumbNailFile = await generateThumbnail(File(safePath));

        await saveMediaUploadMental(
          file: safePath,
          type: "goal",
          fileType: "mp4",
          thumbNail: thumbNailFile.path,
          context: context,
        );

        if (Navigator.canPop(context)) Navigator.pop(context); // Dismiss upload dialog

      } catch (e) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        showCustomSnackBar(
          context: context,
          message: "An error occurred: $e",
        );
      } finally {
        isVideoUploading = false;
        notifyListeners();
        VideoCompress.deleteAllCache();
      }
    } else if (isVideoUploading) {
      showCustomSnackBar(
        context: context,
        message: "Please wait, video is uploading.",
      );
    }
  }

  ///not used function for video pick and compression///
  Future<void> pickVideoFunctionSecondsCondition(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        showCustomSnackBar(context: context, message: "No video selected.");
        return;
      }

      for (final picked in result.files) {
        final originalFile = File(picked.path!);
        final fileSizeInMB = await originalFile.length() / (1024 * 1024);
        print("📦 Original video size: ${fileSizeInMB.toStringAsFixed(2)} MB");

        final MediaInfo? info = await VideoCompress.getMediaInfo(originalFile.path);
        final double durationInSeconds = (info?.duration ?? 0) / 1000;
        print("⏱ Video duration: ${durationInSeconds.toStringAsFixed(2)} seconds");

        // ✅ Validate size & duration before starting upload
        if (fileSizeInMB > 300 || durationInSeconds > 300) {
          showCustomSnackBar(
            context: context,
            message: "${picked.name} must be ≤ 300MB and ≤ 5 minutes.",
          );
          continue; // Skip to next file
        }

        // ✅ Block if already uploading a video
        if (isVideoUploading) {
          showCustomSnackBar(
            context: context,
            message: "Please wait, a video is already uploading.",
          );
          break; // Wait for current upload to finish before proceeding
        }

        isVideoUploading = true;
        notifyListeners();

        // Determine compression quality
        VideoQuality compressionQuality;
        if (fileSizeInMB <= 20) {
          compressionQuality = VideoQuality.MediumQuality;
          print('⚙️ Using HighestQuality for ≤ 20MB');
        } else if (fileSizeInMB <= 50) {
          compressionQuality = VideoQuality.MediumQuality;
          print('⚙️ Using MediumQuality for 21MB - 50MB');
        } else {
          compressionQuality = VideoQuality.MediumQuality;
          print('⚙️ Using LowQuality for > 50MB');
        }

        // Show compressing dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: ColorsContent.newThemeColor,
            content: Row(
              children: [
                CupertinoActivityIndicator(color: ColorsContent.whiteText),
                const SizedBox(width: 16),
                const Text(
                  "Compressing video...",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Open Sans',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );

        final MediaInfo? compressedVideoInfo = await VideoCompress.compressVideo(
          originalFile.path,
          quality: compressionQuality,
          deleteOrigin: false,
          includeAudio: true,
          frameRate: 30,
        );

        if (Navigator.canPop(context)) Navigator.pop(context); // Dismiss compress dialog

        if (compressedVideoInfo == null || compressedVideoInfo.file == null) {
          showCustomSnackBar(
            context: context,
            message: "Video compression failed.",
          );
          isVideoUploading = false;
          notifyListeners();
          continue;
        }

        final videoToUpload = compressedVideoInfo.file!;
        final compressedSize = await videoToUpload.length();
        print("📉 Compressed video size: ${(compressedSize / (1024 * 1024)).toStringAsFixed(2)} MB");

        final safePath = await saveVideoToTemp(videoToUpload.path);

        // Show uploading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            backgroundColor: ColorsContent.newThemeColor,
            content: Row(
              children: [
                CupertinoActivityIndicator(color: ColorsContent.whiteText),
                const SizedBox(width: 16),
                const Text(
                  "Uploading video...",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Open Sans',
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );

        pickedImagesAddFunction([safePath]);

        File thumbNailFile = await generateThumbnail(File(safePath));

        await saveMediaUploadMental(
          file: safePath,
          type: "goal",
          fileType: "mp4",
          thumbNail: thumbNailFile.path,
          context: context,
        );

        if (Navigator.canPop(context)) Navigator.pop(context); // Dismiss upload dialog

        isVideoUploading = false;
        notifyListeners();
        VideoCompress.deleteAllCache();
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      showCustomSnackBar(context: context, message: "An error occurred: $e");
      isVideoUploading = false;
      notifyListeners();
    }
  }

///used function for video pick and compression///
  Future<void> pickVideoFunction(BuildContext context) async {
    BuildContext? pleaseWaitContext;

    try {
      // ✅ Show "Please wait..." dialog first
      pleaseWaitContext = await showPleaseWaitDialog(context);

      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        if (pleaseWaitContext != null && Navigator.canPop(pleaseWaitContext)) {
          Navigator.pop(pleaseWaitContext);
        }
        showCustomSnackBar(context: context, message: "No video selected.");
        return;
      }

      for (final picked in result.files) {
        final originalFile = File(picked.path!);
        final fileSizeInMB = await originalFile.length() / (1024 * 1024);
        print("📦 Original video size: ${fileSizeInMB.toStringAsFixed(2)} MB");

        final MediaInfo? info = await VideoCompress.getMediaInfo(originalFile.path);
        final double durationInSeconds = (info?.duration ?? 0) / 1000;
        print("⏱ Video duration: ${durationInSeconds.toStringAsFixed(2)} seconds");

        // ❌ Too big or too long? Close and skip
        if (fileSizeInMB > 300 || durationInSeconds > 300) {
          if (pleaseWaitContext != null && Navigator.canPop(pleaseWaitContext)) {
            Navigator.pop(pleaseWaitContext);
            pleaseWaitContext = null;
          }
          showCustomSnackBar(
            context: context,
            message: "${picked.name} must be ≤ 300MB and ≤ 5 minutes.",
          );
          continue;
        }

        // ✅ Close "Please wait..." before compressing
        if (pleaseWaitContext != null && Navigator.canPop(pleaseWaitContext)) {
          Navigator.pop(pleaseWaitContext);
          pleaseWaitContext = null;
        }

        if (isVideoUploading) {
          showCustomSnackBar(
            context: context,
            message: "Please wait, a video is already uploading.",
          );
          break;
        }

        isVideoUploading = true;
        notifyListeners();

        // Determine compression quality
        VideoQuality compressionQuality;
        if (fileSizeInMB <= 20) {
          compressionQuality = VideoQuality.MediumQuality;
          print('⚙️ Using HighestQuality for ≤ 20MB');
        } else if (fileSizeInMB <= 50) {
          compressionQuality = VideoQuality.MediumQuality;
          print('⚙️ Using MediumQuality for 21MB - 50MB');
        } else {
          compressionQuality = VideoQuality.MediumQuality;
          print('⚙️ Using LowQuality for > 50MB');
        }

        // ✅ Show compressing dialog
        final compressContext = await showProgressDialog(context, "Compressing video...");

        final MediaInfo? compressedVideoInfo = await VideoCompress.compressVideo(
          originalFile.path,
          quality: compressionQuality,
          deleteOrigin: false,
          includeAudio: true,
          frameRate: 30,
        );

        if (Navigator.canPop(compressContext)) Navigator.pop(compressContext);

        if (compressedVideoInfo == null || compressedVideoInfo.file == null) {
          showCustomSnackBar(
            context: context,
            message: "Video compression failed.",
          );
          isVideoUploading = false;
          notifyListeners();
          continue;
        }

        final videoToUpload = compressedVideoInfo.file!;
        final compressedSize = await videoToUpload.length();
        print("📉 Compressed video size: ${(compressedSize / (1024 * 1024)).toStringAsFixed(2)} MB");

        final safePath = await saveVideoToTemp(videoToUpload.path);


        // ✅ Show uploading dialog
        final uploadContext = await showProgressDialog(context, "Uploading video...");

        pickedImagesAddFunction([safePath]);

        File thumbNailFile = await generateThumbnail(File(safePath));
        uploadedThumbPaths.add(thumbNailFile.path);

        await saveMediaUploadMental(
          file: safePath,
          type: "goal",
          fileType: "mp4",
          thumbNail: thumbNailFile.path,
          context: context,
        );

        if (Navigator.canPop(uploadContext)) Navigator.pop(uploadContext);

        isVideoUploading = false;
        notifyListeners();
        VideoCompress.deleteAllCache();
      }
    } catch (e) {
      if (pleaseWaitContext != null && Navigator.canPop(pleaseWaitContext)) {
        Navigator.pop(pleaseWaitContext);
      }
      showCustomSnackBar(
        context: context,
        message: "An error occurred: $e",
      );
      isVideoUploading = false;
      notifyListeners();
    }
  }

  Future<BuildContext> showPleaseWaitDialog(BuildContext context) async {
    final completer = Completer<BuildContext>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        completer.complete(ctx);
        return AlertDialog(
          backgroundColor: ColorsContent.newThemeColor,
          content: Row(
            children: [
              CupertinoActivityIndicator(color: ColorsContent.whiteText),
              const SizedBox(width: 16),
              const Text(
                "Please wait...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Open Sans',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
    return completer.future;
  }

  Future<BuildContext> showProgressDialog(BuildContext context, String message) async {
    final completer = Completer<BuildContext>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        completer.complete(ctx);
        return AlertDialog(
          backgroundColor: ColorsContent.newThemeColor,
          content: Row(
            children: [
              CupertinoActivityIndicator(color: ColorsContent.whiteText),
              const SizedBox(width: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Open Sans',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
    return completer.future;
  }

  Future<String> saveVideoToTemp(String originalPath) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final newPath = '${tempDir.path}/$fileName';
    final copiedFile = await File(originalPath).copy(newPath);
    return copiedFile.path;
  }
  /// end of function for video pick and compression///





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
  List<String> uploadedThumbPaths = [];
  Future<void> takeFileFunction(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    isVideoUploading = true;
    notifyListeners();

    BuildContext? dialogContext;

    try {
      // Show loading dialog and capture its context
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dContext) {
            dialogContext = dContext;
            return AlertDialog(
              content: Row(
                children: [
                  CupertinoActivityIndicator(
                    color: ColorsContent.newThemeColor,
                  ),
                  const SizedBox(width: 16),
                  const Text("Capturing image..."),
                ],
              ),
            );
          },
        );
      }

      // Extract file extension safely
      String fileExtension = pickedFile.path.split('.').last.toLowerCase();
      String lastThreeChars = fileExtension.length >= 3
          ? fileExtension.substring(fileExtension.length - 3)
          : fileExtension;

      List<String> imagePaths = [pickedFile.path];
      takedImagesAddFunction(imagePaths);

      // ✅ Generate thumbnail for image (optional but added for consistency)
      File thumbNailFile = File(pickedFile.path); // Can skip actual thumbnail creation for images
      uploadedThumbPaths.add(thumbNailFile.path);



      // Save picked image (no compression)
      await saveMediaUploadMental(
        file: pickedFile.path,
        type: "goal",
        fileType: lastThreeChars,
        thumbNail: thumbNailFile.path,
        context: context,
      );
    } catch (e, stackTrace) {
      logger.e("Error in takeFileFunctionGoal: $e\n$stackTrace");

      if (context.mounted) {
        showCustomSnackBar(
          context: context,
          message: "An error occurred: $e",
        );
      }
    } finally {
      isVideoUploading = false;

      if (dialogContext != null &&
          Navigator.of(dialogContext!, rootNavigator: true).canPop()) {
        Navigator.of(dialogContext!, rootNavigator: true).pop();
      }

      notifyListeners();
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

    if (pickeVideo == null) return;

    if (isVideoUploading) {
      if (context.mounted) {
        showCustomSnackBar(
          context: context,
          message: "Please wait, video is uploading.",
        );
      }
      return;
    }

    isVideoUploading = true;
    notifyListeners();

    BuildContext? dialogContext;

    try {
      // Show loading dialog and capture its context
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dContext) {
            dialogContext = dContext;
            return AlertDialog(
              content: Row(
                children: [
                  CupertinoActivityIndicator(
                    color: ColorsContent.newThemeColor,
                  ),
                  const SizedBox(width: 16),
                  const Text("Uploading video..."),
                ],
              ),
            );
          },
        );
      }

      // Extract file extension
      String fileExtension = pickeVideo.path.split('.').last;
      String lastThreeChars = fileExtension.length >= 3
          ? fileExtension.substring(fileExtension.length - 3).toLowerCase()
          : fileExtension.toLowerCase();

      List<String> imagePaths = [pickeVideo.path];
      takedImagesAddFunction(imagePaths);

      // ✅ Generate thumbnail
      File thumbNailFile = await generateThumbnail(File(pickeVideo.path));
      uploadedThumbPaths.add(thumbNailFile.path);
      logger.i("thumbNailFile.path: ${thumbNailFile.path}");

      // Save the video
      await saveMediaUploadMental(
        file: pickeVideo.path,
        type: "goal",
        fileType: "mp4", // or use lastThreeChars
        thumbNail: thumbNailFile.path,
        context: context,
      );
    } catch (e, stackTrace) {
      logger.e("Error in takeVideoFunctionGoal: $e\n$stackTrace");

      if (context.mounted) {
        showCustomSnackBar(
          context: context,
          message: "An error occurred: $e",
        );
      }
    } finally {
      isVideoUploading = false;

      if (dialogContext != null &&
          Navigator.of(dialogContext!, rootNavigator: true).canPop()) {
        Navigator.of(dialogContext!, rootNavigator: true).pop();
      }

      notifyListeners();
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

  Future<void> saveGemFunctionOld(
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
  })
  async {
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
        List<String>? mediaThumbs, // ✅ optional param
        required List<GoalModelIdName> actionId,
      }) async {
    try {
      // ✅ Keep only the last .mp3 file, keep all other files untouched
      int lastMp3Index =
      mediaName.lastIndexWhere((file) => file.toLowerCase().endsWith('.mp3'));
      if (lastMp3Index != -1) {
        String lastMp3File = mediaName[lastMp3Index];
        mediaName.removeWhere((file) => file.toLowerCase().endsWith('.mp3'));
        mediaName.add(lastMp3File);
      }

      saveAddActionsLoading = true;
      String deviceType = Platform.isAndroid ? 'android' : 'ios';
      String? versionCode = '';
      if (Platform.isAndroid) {
        versionCode = Constent.versionCodeAndroid.isNotEmpty
            ? Constent.versionCodeAndroid
            : await getVersionSharePref();
      } else if (Platform.isIOS) {
        versionCode = Constent.versionCodeIOS.isNotEmpty
            ? Constent.versionCodeIOS
            : await getVersionSharePref();
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

      // ✅ Add media files
      for (int i = 0; i < mediaName.length; i++) {
        body['media_name[$i]'] = mediaName[i];
      }

      if (mediaThumbs != null && mediaThumbs.isNotEmpty) {
        for (int i = 0; i < mediaThumbs.length; i++) {
          body['media_thumb[$i]'] = mediaThumbs[i];
        }
      }

      // ✅ Add action IDs
      for (int i = 0; i < actionId.length; i++) {
        body['action_id[$i]'] = actionId[i].id;
      }

      // ✅ Add link if exists in detectedLinks
      final linkList = detectedLinks; // ← from your provider
      if (linkList.isNotEmpty) {
        body['preview_link'] = linkList.first; // send only one link (as per backend)
      }

      logger.i("Final SaveGem Body => $body");

      final response = await http.post(
        Uri.parse(UrlConstant.savegemUrl),
        headers: <String, String>{
          'device-type': deviceType,
          'version': versionCode.toString(),
          "authorization": "$token",
        },
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
      } else if (response.statusCode == 503) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MaintenenceScreen(
                title:
                "App is in maintainance mode, Please be patient, we'll be back in a couple of hours!",
                message: "",
              ),
            ),
          );
        });
      } else {
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        TokenManager.setTokenStatus(true);
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
        List<String>? mediaThumbs, // ✅ optional param
        required List<GoalModelIdName> actionId,
        required String gemId,
        required List<String> editDetectedLinks, // ✅ now a list
      })
  async {
    try {
      updateGoalLoading = true;
      String deviceType = Platform.isAndroid ? 'android' : 'ios';
      String? versionCode = '';
      if (Platform.isAndroid) {
        versionCode = Constent.versionCodeAndroid.isNotEmpty
            ? Constent.versionCodeAndroid
            : await getVersionSharePref();
      } else if (Platform.isIOS) {
        versionCode = Constent.versionCodeIOS.isNotEmpty
            ? Constent.versionCodeIOS
            : await getVersionSharePref();
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

      // ✅ Add preview_link if the list is not empty
      if (editDetectedLinks.isNotEmpty) {
        // Option 1 (most common): send as comma-separated string
        body['preview_link'] = editDetectedLinks.join(',');

        // ✅ Option 2 (if backend expects array-style fields)
        // for (int i = 0; i < editDetectedLinks.length; i++) {
        //   body['preview_link[$i]'] = editDetectedLinks[i];
        // }
      }

      // ✅ Add media files
      for (int i = 0; i < mediaName.length; i++) {
        body['media_name[$i]'] = mediaName[i];
      }

      // ✅ Add media thumbs if available
      if (mediaThumbs != null && mediaThumbs.isNotEmpty) {
        for (int i = 0; i < mediaThumbs.length; i++) {
          body['media_thumb[$i]'] = mediaThumbs[i];
        }
      }

      logger.i("body $body");

      final response = await http.post(
        Uri.parse(UrlConstant.savegemUrl),
        headers: <String, String>{
          'device-type': deviceType,
          'version': versionCode.toString(),
          "authorization": "$token",
        },
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
      } else if (response.statusCode == 503) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MaintenenceScreen(
                title:
                "App is in maintainance mode, Please be patient, we'll be back in a couple of hours!",
                message: "",
              ),
            ),
          );
        });
      } else {
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        TokenManager.setTokenStatus(true);
      }

      updateGoalLoading = false;
      notifyListeners();
    } catch (error) {
      showCustomSnackBar(context: context, message: "Failed");
      updateGoalLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateGoalFunctionLink(
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
        List<String>? mediaThumbs, // ✅ optional param
        required List<GoalModelIdName> actionId,
        required String gemId,
        required List<String> editDetectedLinks, // ✅ now a list
      })
  async {
    try {
      updateGoalLoading = true;
      String deviceType = Platform.isAndroid ? 'android' : 'ios';
      String? versionCode = '';
      if (Platform.isAndroid) {
        versionCode = Constent.versionCodeAndroid.isNotEmpty
            ? Constent.versionCodeAndroid
            : await getVersionSharePref();
      } else if (Platform.isIOS) {
        versionCode = Constent.versionCodeIOS.isNotEmpty
            ? Constent.versionCodeIOS
            : await getVersionSharePref();
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

      // ✅ Add preview_link if the list is not empty
      if (editDetectedLinks.isNotEmpty) {
        // Option 1 (most common): send as comma-separated string
        body['preview_link'] = editDetectedLinks.join(',');

        // ✅ Option 2 (if backend expects array-style fields)
        // for (int i = 0; i < editDetectedLinks.length; i++) {
        //   body['preview_link[$i]'] = editDetectedLinks[i];
        // }
      }

      // ✅ Add media files
      for (int i = 0; i < mediaName.length; i++) {
        body['media_name[$i]'] = mediaName[i];
      }

      // ✅ Add media thumbs if available
      if (mediaThumbs != null && mediaThumbs.isNotEmpty) {
        for (int i = 0; i < mediaThumbs.length; i++) {
          body['media_thumb[$i]'] = mediaThumbs[i];
        }
      }

      logger.i("bodyupdateLink $body");

      final response = await http.post(
        Uri.parse(UrlConstant.savegemUrl),
        headers: <String, String>{
          'device-type': deviceType,
          'version': versionCode.toString(),
          "authorization": "$token",
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
        clearAction();
       // Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else if (response.statusCode == 503) {
        Future.delayed(Duration.zero, () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MaintenenceScreen(
                title:
                "App is in maintainance mode, Please be patient, we'll be back in a couple of hours!",
                message: "",
              ),
            ),
          );
        });
      } else {
        showCustomSnackBar(
          context: context,
          message: json.decode(response.body)["text"],
        );
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        TokenManager.setTokenStatus(true);
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
      String? versionCode = Platform.isAndroid
          ? (Constent.versionCodeAndroid.isNotEmpty
          ? Constent.versionCodeAndroid
          : await getVersionSharePref())
          : (Constent.versionCodeIOS.isNotEmpty
          ? Constent.versionCodeIOS
          : await getVersionSharePref());

      notifyListeners();

      var headers = {
        'device-type': deviceType,
        'version': versionCode.toString(),
        "authorization": "$token",
      };

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(UrlConstant.mediauploadUrl),
      );

      request.fields.addAll({
        'type': type,
        'file_type': fileType,
      });

      request.files.add(await http.MultipartFile.fromPath('media_name', file));

      if (thumbNail != null) {
        request.files.add(await http.MultipartFile.fromPath('media_thumb', thumbNail));
      }

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      logger.i("mediaUploadResponse: $responseBody");

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        String? mediaName = jsonResponse['media_name'];
        String? mediaThumb = jsonResponse['media_thumb'];

        if (mediaName != null) {
          addMediaUploadResponseListFunction([mediaName]);
        }

        if (mediaThumb != null) {
          addMediaThumbResponseListFunction([mediaThumb]);
        }

        notifyListeners();
      } else {
        showCustomSnackBar(
          context: context,
          message: response.reasonPhrase.toString(),
        );
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        TokenManager.setTokenStatus(true);
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

  List<String> mediaThumbList = [];

  void addMediaThumbResponseListFunction(List<String> thumbs) {
    mediaThumbList.clear();
    mediaThumbList.addAll(thumbs);
    notifyListeners();
  }

  //remove mediaNotUse
  bool removeMediaNotUseLoading = false;
  Future<void> removeMediaFunctionNotSave({
    required BuildContext context,
    required String file,
    required String type,
  }) async
  {
    try {
      String? token = await getUserTokenSharePref();
      removeMediaNotUseLoading = true;
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
      var body = {
        'file': file,
        'type': type,
      };
      final response = await http.post(
        Uri.parse(
          UrlConstant.removemediabeforesaveUrl,
        ),
        headers: <String, String>{
          'device-type': deviceType,
          'version': versionCode.toString(),
          "authorization": "$token"},
        body: body,
      );

      if (response.statusCode == 200) {
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
      removeMediaNotUseLoading = false;
      notifyListeners();
    } catch (error) {
      removeMediaNotUseLoading = false;
      notifyListeners();
    }
  }



  List<String> detectedLinks = [];
  RegExp urlRegex = RegExp(
    r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-&?=%.]+',
    caseSensitive: false,
  );

  List<String> editDetectedLinks = [];
  RegExp editUrlRegex = RegExp(
    r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-&?=%.]+',
    caseSensitive: false,
  );

  bool editBackendLinkAdded = false; // <- new flag
  bool hasUserClearedLink = false;

}
