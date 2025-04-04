import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

Future<bool> requestGalleryPermission() async {
  if (Platform.isIOS) {
    var status = await Permission.photos.status;
    if (status.isDenied || status.isRestricted || status.isLimited) {
      status = await Permission.photos.request();
    }
    return status.isGranted || status.isLimited;
  } else {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }
}



Future<bool> requestCameraPermission() async {
  var status = await Permission.camera.status;
  if (!status.isGranted) {
    status = await Permission.camera.request();
  }
  return status.isGranted;
}
