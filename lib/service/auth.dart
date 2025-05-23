import 'package:dio/dio.dart';
import 'package:findsafe/.env.dart';
import 'package:findsafe/constants/custom_bottom_nav.dart';
import 'package:findsafe/models/User_model.dart';
import 'package:findsafe/screens/login.dart';
import 'package:findsafe/service/device.dart';
import 'package:findsafe/utilities/logger.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:findsafe/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider {
  final dio = Dio();
  final deviceApiService = DeviceApiService();
  final _logger = AppLogger.getLogger('AuthProvider');

  Future<Map<String, dynamic>> signUp(BuildContext context, User user) async {
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

        // Return success result
        return {
          'success': true,
          'message': successMessage,
          'userId': response.data['userId'] ?? '',
        };
      } else if (response.statusCode == 400) {
        //Check for specific 400 error
        final errorMessage =
            response.data['message'] ?? 'Invalid Signup Data entered';
        CustomToast.show(
            context: context,
            message: errorMessage,
            type: ToastType.warning,
            position: ToastPosition.top);

        return {
          'success': false,
          'message': errorMessage,
        };
      } else {
        // Handle other error codes (e.g., 409 for existing user)
        final errorMessage =
            response.data['message'] ?? 'Signup failed. Please try again.';
        CustomToast.show(
            context: context,
            message: errorMessage,
            type: ToastType.warning,
            position: ToastPosition.top);

        // Use logger instead of print
        _logger.warning(
            "Signup failed with status ${response.statusCode}: ${response.data}");

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      // Network or other errors
      _logger.severe("Error during signup", e);
      CustomToast.show(
          context: context,
          message:
              'Signup failed. Please check your internet connection and try again.',
          type: ToastType.error,
          position: ToastPosition.top);

      return {
        'success': false,
        'message': 'Network error during signup',
      };
    }
  }

  Future<Map<String, dynamic>> logIn(BuildContext context, User user) async {
    try {
      _logger.info('Attempting login for user: ${user.email}');

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

      if (response.statusCode == 200) {
        _logger.info('Login successful for user: ${user.email}');

        // Get device info for registration
        Map<String, dynamic> deviceInfo = await getDeviceInfo();
        _logger.info('Device info: $deviceInfo');

        String deviceName = deviceInfo['model']; // Get the device name
        String deviceModel = deviceInfo['manufacturer']; // Get the device model

        final prefs = await SharedPreferences.getInstance();
        final isRegisted = prefs.getBool('isRegisted') ?? false;

        if (!isRegisted) {
          _logger
              .info('Registering device for user: ${response.data['userId']}');
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
          _logger.info('Auth token saved');
        }

        await prefs.setBool('showHome', true);

        // Show success message
        final successMessage = response.data['message'];
        CustomToast.show(
            context: context,
            message: successMessage,
            type: ToastType.success,
            position: ToastPosition.top);

        // Navigate to home screen
        Get.to(const CustomBottomNav());

        return {
          'success': true,
          'message': successMessage,
          'userId': response.data['userId'] ?? '',
        };
      } else if (response.statusCode == 400) {
        //Check for specific 400 error
        final errorMessage = response.data['message'] ??
            'Invalid email or password. Please try again.';
        _logger.warning('Login failed with 400 error: $errorMessage');

        CustomToast.show(
            context: context,
            message: errorMessage,
            type: ToastType.warning,
            position: ToastPosition.top);

        return {
          'success': false,
          'message': errorMessage,
        };
      } else {
        // Handle other error codes
        final errorMessage =
            response.data['message'] ?? 'Login failed. Please try again';
        _logger.warning(
            'Login failed with status ${response.statusCode}: $errorMessage');

        CustomToast.show(
            context: context,
            message: errorMessage,
            type: ToastType.error,
            position: ToastPosition.top);

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      // Network or other errors
      _logger.severe('Login error', e);

      CustomToast.show(
          context: context,
          message:
              'Login failed. Please check your internet connection and try again.',
          type: ToastType.error,
          position: ToastPosition.top);

      return {
        'success': false,
        'message': 'Network error during login',
      };
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetEmail(
      BuildContext context, String email) async {
    try {
      _logger.info('Sending password reset email to: $email');

      final response = await dio.post(
        "$APIURL/forgot-password",
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        // Successful password reset request
        final successMessage = response.data['message'] ??
            'Password reset email sent successfully';
        _logger.info('Password reset email sent successfully to: $email');

        CustomToast.show(
            context: context,
            message: successMessage,
            type: ToastType.success,
            position: ToastPosition.top);

        return {
          'success': true,
          'message': successMessage,
          'data': response.data
        };
      } else if (response.statusCode == 400) {
        // Check for specific 400 error
        final errorMessage = response.data['message'] ??
            'Invalid email address. Please try again.';
        _logger.warning('Password reset failed with 400 error: $errorMessage');

        CustomToast.show(
            context: context,
            message: errorMessage,
            type: ToastType.warning,
            position: ToastPosition.top);

        return {
          'success': false,
          'message': errorMessage,
          'data': response.data
        };
      } else {
        // Handle other error codes
        final errorMessage = response.data['message'] ??
            'Password reset failed. Please try again';
        _logger.warning(
            'Password reset failed with status ${response.statusCode}: $errorMessage');

        CustomToast.show(
            context: context,
            message: errorMessage,
            type: ToastType.error,
            position: ToastPosition.top);

        return {
          'success': false,
          'message': errorMessage,
          'data': response.data
        };
      }
    } catch (e) {
      // Network or other errors
      _logger.severe('Password reset error', e);

      CustomToast.show(
          context: context,
          message:
              'Password reset failed. Please check your internet connection and try again.',
          type: ToastType.error,
          position: ToastPosition.top);

      return {
        'success': false,
        'message': 'Network error during password reset'
      };
    }
  }

  Future<void> verifyOtp(BuildContext context, String email, String otp) async {
    try {
      final response = await dio.post(
        "$APIURL/verify-otp",
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
        data: {
          'email': email,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        // Successful verification
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
            message: 'Invalid verification code. Please try again.',
            type: ToastType.warning,
            position: ToastPosition.top);
      } else {
        // Handle other error codes
        final errorMessage =
            response.data['message'] ?? 'Verification failed. Please try again';
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
              'Verification failed. Please check your internet connection and try again.',
          type: ToastType.error,
          position: ToastPosition.top);
      rethrow; // Rethrow to allow handling in the calling function
    }
  }

  // Verify OTP for password reset
  Future<Map<String, dynamic>> verifyResetOtp(
      BuildContext context, String email, String otp) async {
    try {
      final response = await dio.post(
        "$APIURL/verify-reset-otp",
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
        data: {
          'email': email,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        // Successful verification
        final successMessage = response.data['message'];
        CustomToast.show(
            context: context,
            message: successMessage,
            type: ToastType.success,
            position: ToastPosition.top);
          
        // Return the resetToken for password reset
        return {
          'token': response.data['resetToken'].toString(),
          'message': successMessage,
        };
      } else if (response.statusCode == 400) {
        //Check for specific 400 error
        final errorMessage =
            response.data['message'] ?? 'Invalid verification code';
        CustomToast.show(
            context: context,
            message: errorMessage,
            type: ToastType.warning,
            position: ToastPosition.top);
        throw Exception(errorMessage);
      } else {
        // Handle other error codes
        final errorMessage =
            response.data['message'] ?? 'Verification failed. Please try again';
        CustomToast.show(
            context: context,
            message: errorMessage,
            type: ToastType.error,
            position: ToastPosition.top);
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Network or other errors
      CustomToast.show(
          context: context,
          message:
              'Verification failed. Please check your internet connection and try again.',
          type: ToastType.error,
          position: ToastPosition.top);
      rethrow; // Rethrow to allow handling in the calling function
    }
  }

  // Resend verification OTP
  Future<void> resendVerificationOtp(BuildContext context, String email) async {
    try {
      final response = await dio.post(
        "$APIURL/resend-verification",
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
        data: {
          'email': email,
        },
      );

      if (response.statusCode == 200) {
        // Successful resend
        final successMessage = response.data['message'];
        CustomToast.show(
            context: context,
            message: successMessage,
            type: ToastType.success,
            position: ToastPosition.top);
      } else if (response.statusCode == 400) {
        //Check for specific 400 error
        final errorMessage =
            response.data['message'] ?? 'Invalid email address';
        CustomToast.show(
            context: context,
            message: errorMessage,
            type: ToastType.warning,
            position: ToastPosition.top);
        throw Exception(errorMessage);
      } else {
        // Handle other error codes
        final errorMessage =
            response.data['message'] ?? 'Failed to resend verification code';
        CustomToast.show(
            context: context,
            message: errorMessage,
            type: ToastType.error,
            position: ToastPosition.top);
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Network or other errors
      CustomToast.show(
          context: context,
          message:
              'Failed to resend verification code. Please try again later.',
          type: ToastType.error,
          position: ToastPosition.top);
      rethrow; // Rethrow to allow handling in the calling function
    }
  }

  // Reset password with token
  Future<void> resetPassword(BuildContext context, String email, String token,
      String newPassword) async {
    try {
      final response = await dio.post(
        "$APIURL/reset-password",
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
        data: {
          'email': email,
          'resetToken': token,
          'newPassword': newPassword,
        },
      );

      if (response.statusCode == 200) {
        // Successful password reset
        final successMessage = response.data['message'];
        CustomToast.show(
            context: context,
            message: successMessage,
            type: ToastType.success,
            position: ToastPosition.top);
      } else if (response.statusCode == 400) {
        //Check for specific 400 error
        final errorMessage =
            response.data['message'] ?? 'Invalid reset request';
        CustomToast.show(
            context: context,
            message: errorMessage,
            type: ToastType.warning,
            position: ToastPosition.top);
        throw Exception(errorMessage);
      } else {
        // Handle other error codes
        final errorMessage =
            response.data['message'] ?? 'Password reset failed';
        CustomToast.show(
            context: context,
            message: errorMessage,
            type: ToastType.error,
            position: ToastPosition.top);
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Network or other errors
      CustomToast.show(
          context: context,
          message: 'Password reset failed. Please try again later.',
          type: ToastType.error,
          position: ToastPosition.top);
      rethrow; // Rethrow to allow handling in the calling function
    }
  }

  Future<void> updateUser(BuildContext context, user) async {
    try {
      final userData = await getUserDataFromLocalStorage();
      final userId = userData['userId'] as String?;

      _logger.info('User data for user update: $user');

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
        _logger.info("Success Retrieve User data: ${response.data['User']}");

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
      _logger.severe('An Error Occurred', e);
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

    Get.offAll(() => const Signin());
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
