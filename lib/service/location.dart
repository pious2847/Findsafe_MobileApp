import 'package:dio/dio.dart';
import 'package:findsafe/models/location_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:findsafe/.env.dart';
import 'package:findsafe/models/devices.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationApiService {
  Future<List<Device>> fetchDevices(String userId) async {
    final dio = Dio();
    try {
      final response =
          await dio.get('${Uri.parse(APIURL)}/mobiledevices/$userId');
      print('Response of devices: ${response.data}');
      if (response.statusCode == 200) {
        List jsonResponse = response.data['mobileDevices'];
        print(jsonResponse);
        return jsonResponse.map((device) => Device.fromJson(device)).toList();
      } else {
        throw Exception('Failed to load devices');
      }
    } catch (error) {
      print('Error fetching devices: $error');
      throw Exception('Failed to load devices');
    }
  }

// Function for location
Future<LatLng?> fetchLatestLocation(String deviceId) async {
  final dio = Dio();
  final apiUrl = '$APIURL/mobiledevices/$deviceId/locations';

  try {
    final response = await dio.get(apiUrl);

    if (response.statusCode == 200 && response.data.isNotEmpty) {
      final latestLocation = response.data[0];
      return LatLng(latestLocation['latitude'], latestLocation['longitude']);
    } else {
      print('No data found for the device: $deviceId');
      return null;
    }
  } catch (e) {
    print('Failed to fetch latest location: $e');
    return null;
  }
}

  Future<List<Location>> fetchLocationHistory(String deviceId) async {
    final dio = Dio();

    try {
      
      final response =
          await dio.get('$APIURL/mobiledevices/$deviceId/locations');
      print('Resloc: $response');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to fetch location history');
      }
    } catch (e) {
      throw Exception('Failed to make API call: $e');
    }
  }

  Future<LatLng?> registerCurrentLocation(
      String deviceId, Position currentlocation) async {
    final dio = Dio();
    final apiUrl = '$APIURL/register-location/$deviceId';

    final data = {
      'latitude': '${currentlocation.latitude}',
      'longitude': '${currentlocation.longitude}'
    };
    try {
      final response = await dio.post(apiUrl, data: data);

      if (response.statusCode == 200 && response.data.isNotEmpty) {
        print(
            '============================================= Registed Currect Location completed ============================');
      } else {
      print('Failed to adding  location: $response');
        
      }
    } catch (e) {
      print('Failed to adding  location: $e');
      return null;
    }
    return null;
  }


}
