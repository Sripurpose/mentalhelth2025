import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestGalleryPermission() async {
  if (Platform.isIOS) {
    var status = await Permission.photos.status;
    if (status.isDenied || status.isRestricted || status.isLimited) {
      status = await Permission.photos.request();
    }
    return status.isGranted || status.isLimited;
  } else {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        // Android 13 and above
        var photosPermission = await Permission.photos.status;
        if (!photosPermission.isGranted) {
          photosPermission = await Permission.photos.request();
        }
        return photosPermission.isGranted;
      } else if (sdkInt >= 30) {
        // Android 11 and 12
        var mediaPermission = await Permission.manageExternalStorage.status;
        if (!mediaPermission.isGranted) {
          mediaPermission = await Permission.manageExternalStorage.request();
        }
        return mediaPermission.isGranted;
      } else {
        // Below Android 11
        var storagePermission = await Permission.storage.status;
        if (!storagePermission.isGranted) {
          storagePermission = await Permission.storage.request();
        }
        return storagePermission.isGranted;
      }
    }
    return false;
  }
}




Future<bool> requestCameraPermission() async {
  var status = await Permission.camera.status;
  if (!status.isGranted) {
    status = await Permission.camera.request();
  }
  return status.isGranted;
}

Future<bool> requestMicrophonePermission() async {
  var status = await Permission.microphone.status;
  if (!status.isGranted) {
    status = await Permission.microphone.request();
  }
  return status.isGranted;
}


