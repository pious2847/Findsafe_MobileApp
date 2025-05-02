import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find();
  
  final _pushNotificationsEnabled = true.obs;
  final _emailNotificationsEnabled = true.obs;
  final _locationAlertsEnabled = true.obs;
  final _deviceOfflineAlertsEnabled = true.obs;
  final _batteryAlertsEnabled = true.obs;
  
  final _pushNotificationsKey = 'pushNotificationsEnabled';
  final _emailNotificationsKey = 'emailNotificationsEnabled';
  final _locationAlertsKey = 'locationAlertsEnabled';
  final _deviceOfflineAlertsKey = 'deviceOfflineAlertsEnabled';
  final _batteryAlertsKey = 'batteryAlertsEnabled';
  
  bool get pushNotificationsEnabled => _pushNotificationsEnabled.value;
  bool get emailNotificationsEnabled => _emailNotificationsEnabled.value;
  bool get locationAlertsEnabled => _locationAlertsEnabled.value;
  bool get deviceOfflineAlertsEnabled => _deviceOfflineAlertsEnabled.value;
  bool get batteryAlertsEnabled => _batteryAlertsEnabled.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadSettingsFromPrefs();
  }
  
  Future<void> _loadSettingsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    _pushNotificationsEnabled.value = prefs.getBool(_pushNotificationsKey) ?? true;
    _emailNotificationsEnabled.value = prefs.getBool(_emailNotificationsKey) ?? true;
    _locationAlertsEnabled.value = prefs.getBool(_locationAlertsKey) ?? true;
    _deviceOfflineAlertsEnabled.value = prefs.getBool(_deviceOfflineAlertsKey) ?? true;
    _batteryAlertsEnabled.value = prefs.getBool(_batteryAlertsKey) ?? true;
  }
  
  Future<void> togglePushNotifications(bool value) async {
    _pushNotificationsEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushNotificationsKey, value);
  }
  
  Future<void> toggleEmailNotifications(bool value) async {
    _emailNotificationsEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_emailNotificationsKey, value);
  }
  
  Future<void> toggleLocationAlerts(bool value) async {
    _locationAlertsEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationAlertsKey, value);
  }
  
  Future<void> toggleDeviceOfflineAlerts(bool value) async {
    _deviceOfflineAlertsEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_deviceOfflineAlertsKey, value);
  }
  
  Future<void> toggleBatteryAlerts(bool value) async {
    _batteryAlertsEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_batteryAlertsKey, value);
  }
}
