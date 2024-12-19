import 'package:dio/dio.dart';
import 'package:findsafe/.env.dart';
import 'package:findsafe/models/devices.dart';
import 'package:findsafe/service/location.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceApiService {
  late LocationPermission permission;

  Future<List<Device>> fetchDevices(String userId) async {
    final dio = Dio();
    try {
      final response =
          await dio.get('${Uri.parse(APIURL)}/mobiledevices/$userId');

      if (response.statusCode == 200) {
        List jsonResponse = response.data['mobileDevices'];

        return jsonResponse.map((device) => Device.fromJson(device)).toList();
      } else {
        throw Exception('Failed to load devices');
      }
    } catch (error) {
      print('Error fetching devices: $error');
      throw Exception('Failed to load devices');
    }
  }

  Future<void> addDeviceInfo(
    context,
    userId,
    devicename,
    modelNumer,
  ) async {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      CustomToast.show(
          context: context,
          message:
              'Location permission denied. please check settings to enable',
          type: ToastType.warning,
          position: ToastPosition.top);
      return;
    }

    final dio = Dio();
    final locatinService = LocationApiService();
    final currentPosition = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    print(
        'Current Location position for new device: ${currentPosition.latitude}, ${currentPosition.longitude}');

    try {
      final response = await dio.post(
        "$APIURL/register-device/$userId/$devicename/$modelNumer",
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isRegisted', true);
        final deviceId = response.data['deviceId'] as String;
        await prefs.setString('deviceId', deviceId);

        await locatinService.registerCurrentLocation(deviceId, currentPosition);
        print('The responds for adding new device: $response');
        print("device info inserted successfull");
      } else {
        print("Invalid response ${response.statusCode}: ${response.data}");
      }
    } catch (e) {
      print("Error occurred: $e");
      // Handle error, show toast or snackbar
    }
  }
}
