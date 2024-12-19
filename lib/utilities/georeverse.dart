import 'package:dio/dio.dart';
import 'package:findsafe/.env.dart';


  Future<String> getPlaceName(double latitude, double longitude) async {
    final dio = Dio();
    final response = await dio.get(
      'https://maps.googleapis.com/maps/api/geocode/json',
      queryParameters: {
        'latlng': '$latitude,$longitude',
        'key': googleAPIKey,
      },
    );
        print('Then Set set results ${response}');

    if (response.statusCode == 200) {
      final results = response.data['results'];
      if (results.isNotEmpty) {
        print('Then Set set results ${results[0]['formatted_address']}');
        return results[0]['formatted_address'];
      } else {
        return 'No address found';
      }
    } else {
      throw Exception('Failed to get address');
    }
  }
