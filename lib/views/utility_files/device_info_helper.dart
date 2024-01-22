// device_info_helper.dart
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoHelper {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<String> getAndroidDeviceInfo() async {
    try {
      AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
      String deviceName = androidInfo.model ?? 'Unknown Android Device';

      return deviceName;
    } catch (e) {
      print('Error getting Android device information: $e');
      return 'Unknown Android Device';
    }
  }
}
