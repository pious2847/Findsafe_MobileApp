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
            message: 'Signup failed. Please check your internet connection and try again.',
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
          await addDeviceInfo(
            response.data['userId'],
            deviceName,
            deviceModel,
          );
        }

        await saveUserDataToLocalStorage(response.data['userId']);
        prefs.setBool('showHome', true);
        // Successful signup
        final successMessage = response.data['message'];
        CustomToast.show(
            context: context,
            message: successMessage,
            type: ToastType.success,
            position: ToastPosition.top);

      Get.to(const CustomBottomNav()); // Redirect to Signin page

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
       
        print(
            "Login failed with status ${response.statusCode}: ${response.data}");
      }
    } catch (e) {
      // Network or other errors
      print("Error during signup: $e");
       CustomToast.show(
            context: context,
            message: 'Login failed. Please check your internet connection and try again.',
            type: ToastType.error,
            position: ToastPosition.top);
    }
  }
}
