import 'package:dio/dio.dart';
import 'package:findsafe/.env.dart';
import 'package:findsafe/service/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> addDeviceInfo(
  userId,
  devicename,
  modelNumer,
) async {
  final dio = Dio();
  final locatinService = LocationApiService();
  final currentPosition = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
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
