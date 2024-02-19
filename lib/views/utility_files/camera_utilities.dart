// ignore_for_file: avoid_print

import 'package:camera/camera.dart';

class CameraUtilities {
  static Future<CameraController> initializeCamera() async {
    final cameras = await availableCameras();
    final CameraController cameraController =
        CameraController(cameras[0], ResolutionPreset.medium);

    await cameraController.initialize();

    // Set auto exposure mode and flash mode here
    cameraController.setExposureMode(ExposureMode.auto);
    cameraController.setFlashMode(FlashMode.off);

    return cameraController;
  }

  static Future<void> captureImage(
      CameraController cameraController, Function(String) onCapture) async {
    try {
      final XFile capturedImage = await cameraController.takePicture();
      onCapture(capturedImage.path);
    } catch (e) {
      print('Error capturing image: $e');
    }
    cameraController.dispose();
  }
}
