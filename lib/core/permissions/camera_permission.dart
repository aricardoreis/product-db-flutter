import 'package:permission_handler/permission_handler.dart';

enum CameraPermissionResult { granted, denied, permanentlyDenied }

Future<CameraPermissionResult> requestCameraPermission() async {
  var status = await Permission.camera.status;
  if (status.isGranted || status.isLimited) {
    return CameraPermissionResult.granted;
  }
  if (status.isPermanentlyDenied || status.isRestricted) {
    return CameraPermissionResult.permanentlyDenied;
  }
  status = await Permission.camera.request();
  if (status.isGranted || status.isLimited) {
    return CameraPermissionResult.granted;
  }
  if (status.isPermanentlyDenied || status.isRestricted) {
    return CameraPermissionResult.permanentlyDenied;
  }
  return CameraPermissionResult.denied;
}
