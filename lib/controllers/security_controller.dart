import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:findsafe/utilities/toast_messages.dart';

class SecurityController extends GetxController {
  static SecurityController get to => Get.find();

  final _biometricAuthEnabled = false.obs;
  final _pinCodeEnabled = false.obs;
  final _twoFactorAuthEnabled = false.obs;

  final _biometricAuthKey = 'biometricAuthEnabled';
  final _pinCodeKey = 'pinCodeEnabled';
  final _twoFactorAuthKey = 'twoFactorAuthEnabled';

  bool get biometricAuthEnabled => _biometricAuthEnabled.value;
  bool get pinCodeEnabled => _pinCodeEnabled.value;
  bool get twoFactorAuthEnabled => _twoFactorAuthEnabled.value;

  @override
  void onInit() {
    super.onInit();
    _loadSettingsFromPrefs();
  }

  Future<void> _loadSettingsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _biometricAuthEnabled.value = prefs.getBool(_biometricAuthKey) ?? false;
    _pinCodeEnabled.value = prefs.getBool(_pinCodeKey) ?? false;
    _twoFactorAuthEnabled.value = prefs.getBool(_twoFactorAuthKey) ?? false;
  }

  Future<void> toggleBiometricAuth(bool value) async {
    _biometricAuthEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricAuthKey, value);
  }

  Future<void> togglePinCode(bool value) async {
    _pinCodeEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinCodeKey, value);
  }

  Future<bool> toggleTwoFactorAuth(bool value, BuildContext context) async {
    // If trying to enable 2FA, check if either PIN or biometric is enabled
    if (value && !_biometricAuthEnabled.value && !_pinCodeEnabled.value) {
      // Show error message
      CustomToast.show(
        context: context,
        message:
            'You must enable either PIN or Biometric authentication before enabling 2FA',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      return false;
    }

    // If all checks pass, update the preference
    _twoFactorAuthEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_twoFactorAuthKey, value);
    return true;
  }
}
