import 'package:findsafe/service/biometric_auth.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

class BiometricController extends GetxController {
  static BiometricController get to => Get.find();
  
  final BiometricAuthService _biometricAuthService = BiometricAuthService();
  
  final RxBool _isBiometricAvailable = false.obs;
  final RxBool _isBiometricEnabled = false.obs;
  final RxList<BiometricType> _availableBiometrics = <BiometricType>[].obs;
  final RxString _biometricString = ''.obs;
  
  bool get isBiometricAvailable => _isBiometricAvailable.value;
  bool get isBiometricEnabled => _isBiometricEnabled.value;
  List<BiometricType> get availableBiometrics => _availableBiometrics;
  String get biometricString => _biometricString.value;
  
  @override
  void onInit() {
    super.onInit();
    _checkBiometricAvailability();
  }
  
  // Check if biometric authentication is available
  Future<void> _checkBiometricAvailability() async {
    _isBiometricAvailable.value = await _biometricAuthService.isBiometricAvailable();
    _isBiometricEnabled.value = await _biometricAuthService.isBiometricEnabled();
    _availableBiometrics.value = await _biometricAuthService.getAvailableBiometrics();
    _biometricString.value = await _biometricAuthService.getBiometricString();
  }
  
  // Toggle biometric authentication
  Future<bool> toggleBiometric(bool value, BuildContext context) async {
    // If trying to enable biometrics
    if (value) {
      // Check if biometrics are available
      if (!_isBiometricAvailable.value) {
        CustomToast.show(
          context: context,
          message: 'Biometric authentication is not available on this device',
          type: ToastType.error,
          position: ToastPosition.top,
        );
        return false;
      }
      
      // Check if there are any biometrics enrolled
      if (_availableBiometrics.isEmpty) {
        CustomToast.show(
          context: context,
          message: 'No biometrics enrolled on this device',
          type: ToastType.error,
          position: ToastPosition.top,
        );
        return false;
      }
      
      // Authenticate to confirm
      final authenticated = await _biometricAuthService.authenticate(
        localizedReason: 'Authenticate to enable biometric login',
      );
      
      if (!authenticated) {
        CustomToast.show(
          context: context,
          message: 'Authentication failed',
          type: ToastType.error,
          position: ToastPosition.top,
        );
        return false;
      }
    }
    
    // Save the preference
    await _biometricAuthService.setBiometricEnabled(value);
    _isBiometricEnabled.value = value;
    
    // Show success message
    CustomToast.show(
      context: context,
      message: value 
          ? 'Biometric authentication enabled' 
          : 'Biometric authentication disabled',
      type: ToastType.success,
      position: ToastPosition.top,
    );
    
    return true;
  }
  
  // Authenticate with biometrics
  Future<bool> authenticate({
    required String reason,
    required BuildContext context,
  }) async {
    // Check if biometrics are enabled in settings
    if (!_isBiometricEnabled.value) {
      return true; // Skip authentication if not enabled
    }
    
    // Check if biometrics are available
    if (!_isBiometricAvailable.value) {
      CustomToast.show(
        context: context,
        message: 'Biometric authentication is not available on this device',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      return false;
    }
    
    // Authenticate
    final authenticated = await _biometricAuthService.authenticate(
      localizedReason: reason,
    );
    
    if (!authenticated) {
      CustomToast.show(
        context: context,
        message: 'Authentication failed',
        type: ToastType.error,
        position: ToastPosition.top,
      );
    }
    
    return authenticated;
  }
}
