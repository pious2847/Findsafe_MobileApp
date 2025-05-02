import 'package:dio/dio.dart';
import 'package:findsafe/.env.dart';
import 'package:findsafe/constants/custom_bottom_nav.dart';
import 'package:findsafe/models/User_model.dart';
import 'package:findsafe/screens/login.dart';
import 'package:findsafe/service/device.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:findsafe/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider {
  final dio = Dio();
  final deviceApiService = DeviceApiService();

  Future<void> signUp(BuildContext context, User user) async {
    try {
      final response = await dio.post(
        "$APIURL/signup",
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
        data: {
          'username': user.username,
          'email': user.email,
          'password': user.password,
        },
      );

      if (response.statusCode == 200) {
        // Successful signup
        final successMessage = response.data['message'];
        CustomToast.show(
            context: context,
            message: successMessage,
            type: ToastType.success,
            position: ToastPosition.top);

        Get.to(const Signin()); // Redirect to Signin page
      } else if (response.statusCode == 400) {
        //Check for specific 400 error
        CustomToast.show(
            context: context,
            message: 'Invalid Signup Data entered',
            type: ToastType.warning,
            position: ToastPosition.top);
      } else {
        // Handle other error codes (e.g., 409 for existing user)
        final errorMessage =
            response.data['message'] ?? 'Signup failed. Please try again.';
        CustomToast.show(
            context: context,
            message: errorMessage,
            type: ToastType.warning,
            position: ToastPosition.top);

        print(
            "Signup failed with status ${response.statusCode}: ${response.data}");
      }
    } catch (e) {
      // Network or other errors
      print("Error during signup: $e");
      CustomToast.show(
          context: context,
          message:
              'Signup failed. Please check your internet connection and try again.',
          type: ToastType.error,
          position: ToastPosition.top);
    }
  }

  Future<void> logIn(BuildContext context, User user) async {
    try {
      final response = await dio.post(
        "$APIURL/login",
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
        data: {
          'email': user.email,
          'password': user.password,
        },
      );
      print(user);

      if (response.statusCode == 200) {
        print(response);
        Map<String, dynamic> deviceInfo = await getDeviceInfo();
        print(deviceInfo);
        String deviceName = deviceInfo['model']; // Get the device name
        String deviceModel = deviceInfo['manufacturer']; // Get the device model

        final prefs = await SharedPreferences.getInstance();
        final isRegisted = prefs.getBool('isRegisted') ?? false;

        if (!isRegisted) {
          await deviceApiService.addDeviceInfo(
            context,
            response.data['userId'],
            deviceName,
            deviceModel,
          );
        }

        await saveUserDataToLocalStorage(response.data['userId']);

        // Save token if available
        if (response.data['token'] != null) {
          await prefs.setString('token', response.data['token']);
        }

        prefs.setBool('showHome', true);
        // Successful signup
        final successMessage = response.data['message'];
        CustomToast.show(
            context: context,
            message: successMessage,
            type: ToastType.success,
            position: ToastPosition.top);

        Get.to(const CustomBottomNav());
      } else if (response.statusCode == 400) {
        //Check for specific 400 error
        CustomToast.show(
            context: context,
            message: 'Invalid email or password. Please try again.',
            type: ToastType.warning,
            position: ToastPosition.top);
      } else {
        // Handle other error codes (e.g., 409 for existing user)
        final errorMessage =
            response.data['message'] ?? 'Login failed. Please try again';
        CustomToast.show(
            context: context,
            message: errorMessage,
            type: ToastType.error,
            position: ToastPosition.top);
      }
    } catch (e) {
      // Network or other errors
      CustomToast.show(
          context: context,
          message:
              'Login failed. Please check your internet connection and try again.',
          type: ToastType.error,
          position: ToastPosition.top);
    }
  }

  Future<void> updateUser(BuildContext context, user) async {
    try {
      final userData = await getUserDataFromLocalStorage();
      final userId = userData['userId'] as String?;

      print('User data for user update: $user.');

      // final url = '$APIURL/update/$userId';
      final dio = Dio();
      final response = await dio.put('$APIURL/update/$userId',
          options: Options(
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            },
          ),
          data: user);

      if (response.statusCode == 200) {
        final responseMsg = response.data['message'];
        CustomToast.show(
          context: context,
          message: responseMsg,
          type: ToastType.success,
          position: ToastPosition.top,
        );
      } else {
        const responseMsg = "Unknown error Occured";
        CustomToast.show(
          context: context,
          message: responseMsg,
          type: ToastType.error,
          position: ToastPosition.top,
        );
      }
    } catch (e) {
      CustomToast.show(
        context: context,
        message: 'Failed to update user profile ',
        type: ToastType.error,
        position: ToastPosition.top,
      );
    }
  }

  Future<dynamic> fetchUser(BuildContext context) async {
    try {
      // Get user data from local storage
      final userData = await getUserDataFromLocalStorage();
      final userId = userData['userId'];

      if (userId == null) {
        throw Exception('User ID is not available in local storage.');
      }

      final dio = Dio();
      final url = '$APIURL/get-user/$userId';

      // Send GET request to fetch user data
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        print("Success Retrieve User data: ${response.data['User']}");

        final userJson = response.data['User']; // Access the 'User' key
        var user = UserProfileModel.fromJson(userJson);
        return user;
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      // Handle errors
      CustomToast.show(
        context: context,
        message: 'An Error Occurred while fetching user data',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      print('An Error Occurred $e');
      return null; // Return null if an error occurs
    }
  }

  Future<dynamic> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('token'); // Clear the token
    await prefs.setBool('isLoggedIn', false);
    await prefs.setBool('showHome', false);
    // await prefs.setBool('isRegisted', false);
    CustomToast.show(
        context: context,
        message: 'User account logout was successful',
        type: ToastType.success,
        position: ToastPosition.top);
  }

  // Save user data to local storage
  Future<void> saveUserDataToLocalStorage(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setBool('isLoggedIn', true);
  }

  // Get user data from local storage
  Future<Map<String, dynamic>> getUserDataFromLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    return {
      'userId': userId,
      'isLoggedIn': isLoggedIn,
    };
  }

  // Get authentication token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
