import 'dart:io';
import 'package:dio/dio.dart';
import 'package:findsafe/service/auth.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService {
  final String _baseUrl = 'https://findsafe-backend.onrender.com/api';
  final AuthProvider _authProvider = AuthProvider();
  final Dio _dio = Dio();

  // Upload profile picture
  Future<String?> uploadProfilePicture(
      BuildContext context, File imageFile) async {
    try {
      // Get user data from local storage
      final userData = await _authProvider.getUserDataFromLocalStorage();
      final userId = userData['userId'];

      if (userId == null) {
        throw Exception('User ID is not available in local storage.');
      }

      // Create form data
      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'profile_picture.jpg',
        ),
      });

      // Send POST request to upload profile picture
      final response = await _dio.post(
        '$_baseUrl/upload-profile-picture/$userId',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        final profilePicture = response.data['profilePicture'];
        // If the URL is a Cloudinary URL, return it as is
        if (profilePicture != null &&
            profilePicture.toString().contains('cloudinary.com')) {
          return profilePicture;
        } else {
          // Otherwise, return it as a path to be appended to the base URL
          return profilePicture;
        }
      } else {
        throw Exception('Failed to upload profile picture');
      }
    } catch (e) {
      // Handle errors
      CustomToast.show(
        context: context,
        message: 'Failed to upload profile picture: ${e.toString()}',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      debugPrint('Error uploading profile picture: $e');
      return null;
    }
  }

  // Delete profile picture
  Future<bool> deleteProfilePicture(BuildContext context) async {
    try {
      // Get user data from local storage
      final userData = await _authProvider.getUserDataFromLocalStorage();
      final userId = userData['userId'];

      if (userId == null) {
        throw Exception('User ID is not available in local storage.');
      }

      // Send DELETE request to delete profile picture
      final response = await _dio.delete(
        '$_baseUrl/delete-profile-picture/$userId',
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete profile picture');
      }
    } catch (e) {
      // Handle errors
      CustomToast.show(
        context: context,
        message: 'Failed to delete profile picture: ${e.toString()}',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      debugPrint('Error deleting profile picture: $e');
      return false;
    }
  }

  // Change password
  Future<bool> changePassword(
      BuildContext context, String currentPassword, String newPassword) async {
    try {
      // Get user data from local storage
      final userData = await _authProvider.getUserDataFromLocalStorage();
      final userId = userData['userId'];

      if (userId == null) {
        throw Exception('User ID is not available in local storage.');
      }

      // Send POST request to change password
      final response = await _dio.post(
        '$_baseUrl/change-password/$userId',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to change password');
      }
    } catch (e) {
      // Handle errors
      CustomToast.show(
        context: context,
        message: 'Failed to change password: ${e.toString()}',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      debugPrint('Error changing password: $e');
      return false;
    }
  }

  // Pick image from gallery or camera
  Future<File?> pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      CustomToast.show(
        context: context,
        message: 'Failed to pick image: ${e.toString()}',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      debugPrint('Error picking image: $e');
      return null;
    }
  }
}
