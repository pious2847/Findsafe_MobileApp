import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  
  Future<void> toggleTwoFactorAuth(bool value) async {
    _twoFactorAuthEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_twoFactorAuthKey, value);
  }
}
