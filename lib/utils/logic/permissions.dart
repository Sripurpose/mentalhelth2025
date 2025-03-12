import 'package:permission_handler/permission_handler.dart';

Future<bool> requestGalleryPermission() async {
  var status = await Permission.photos.status;
  if (!status.isGranted) {
    status = await Permission.photos.request();
  }
  return status.isGranted;
}

Future<bool> requestCameraPermission() async {
  var status = await Permission.camera.status;
  if (!status.isGranted) {
    status = await Permission.camera.request();
  }
  return status.isGranted;
}
