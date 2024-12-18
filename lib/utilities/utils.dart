import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:async';

Future<void> saveUserDataToLocalStorage(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userId', userId);
  await prefs.setBool('isLoggedIn', true);
}

Future<Map<String, dynamic>> getUserDataFromLocalStorage() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  final isLoggedIn = prefs.getBool('isLoggedIn') ??
      false; // Default value is false if not found
  return {'userId': userId, 'isLoggedIn': isLoggedIn};
}

Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('userId');
  await prefs.setBool('isLoggedIn', false);
  await prefs.setBool('showHome', false);
  // await prefs.setBool('isRegisted', false);

  print("User Logged Out");
}


Future<Map<String, String>> getDeviceInfo() async {
  final deviceInfo = DeviceInfoPlugin();

  if (defaultTargetPlatform == TargetPlatform.android) {
    final androidInfo = await deviceInfo.androidInfo;
    return {
      'model': androidInfo.model,
      'manufacturer': androidInfo.manufacturer,
      'androidId': androidInfo.id, // Added for comprehensive data
      'version': androidInfo.version.release, // Added for comprehensive data
      'device': androidInfo.device //Added for comprehensive data
    };
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return {
      'model': iosInfo.name,
      'manufacturer': 'Apple', // Consistent data for iOS
      'device': iosInfo.modelName, // Added for comprehensive data
      'systemName': iosInfo.systemName,
      'version': iosInfo.systemVersion
    };
  } else {
    // Handle other platforms (e.g., web) if needed
    return {'model': 'Unknown', 'manufacturer': 'Unknown'};
  }
}