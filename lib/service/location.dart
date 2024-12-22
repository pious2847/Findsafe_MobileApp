import 'package:dio/dio.dart';
import 'package:findsafe/models/location_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:findsafe/.env.dart';

class LocationApiService {
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
        final data = response.data;
        return data.map<Location>((json) => Location.fromJson(json)).toList();
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
      await dio.post(apiUrl, data: data);
    } catch (e) {
      print('Failed to adding  location: $e');
      return null;
    }
    return null;
  }

  Future<void> updateLocation(String deviceId, Position position) async {
    final dio = Dio();
    const url = '$APIURL/update-location';
    final data = {
      'deviceId': deviceId,
      'latitude': position.latitude,
      'longitude': position.longitude,
    };

    try {
      final response = await dio.post(url, data: data);
      print('Schedule task executed Response = $response');
    } catch (e) {
      print('Error updating location: $e');
    }
  }
}
