import 'package:findsafe/models/geofence_model.dart';
import 'package:findsafe/service/notification_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find();

  final NotificationService _notificationService = NotificationService();

  final _pushNotificationsEnabled = true.obs;
  final _emailNotificationsEnabled = true.obs;
  final _locationAlertsEnabled = true.obs;
  final _deviceOfflineAlertsEnabled = true.obs;
  final _batteryAlertsEnabled = true.obs;
  final _geofenceNotificationsEnabled = true.obs;
  final _deviceStatusNotificationsEnabled = true.obs;
  final _lowBatteryNotificationsEnabled = true.obs;
  final _securityNotificationsEnabled = true.obs;

  final _pushNotificationsKey = 'pushNotificationsEnabled';
  final _emailNotificationsKey = 'emailNotificationsEnabled';
  final _locationAlertsKey = 'locationAlertsEnabled';
  final _deviceOfflineAlertsKey = 'deviceOfflineAlertsEnabled';
  final _batteryAlertsKey = 'batteryAlertsEnabled';
  final _geofenceNotificationsKey = 'geofenceNotificationsEnabled';
  final _deviceStatusNotificationsKey = 'deviceStatusNotificationsEnabled';
  final _lowBatteryNotificationsKey = 'lowBatteryNotificationsEnabled';
  final _securityNotificationsKey = 'securityNotificationsEnabled';

  bool get pushNotificationsEnabled => _pushNotificationsEnabled.value;
  bool get emailNotificationsEnabled => _emailNotificationsEnabled.value;
  bool get locationAlertsEnabled => _locationAlertsEnabled.value;
  bool get deviceOfflineAlertsEnabled => _deviceOfflineAlertsEnabled.value;
  bool get batteryAlertsEnabled => _batteryAlertsEnabled.value;
  bool get geofenceNotificationsEnabled => _geofenceNotificationsEnabled.value;
  bool get deviceStatusNotificationsEnabled =>
      _deviceStatusNotificationsEnabled.value;
  bool get lowBatteryNotificationsEnabled =>
      _lowBatteryNotificationsEnabled.value;
  bool get securityNotificationsEnabled => _securityNotificationsEnabled.value;

  @override
  void onInit() {
    super.onInit();
    _loadSettingsFromPrefs();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }

  Future<void> _loadSettingsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _pushNotificationsEnabled.value =
        prefs.getBool(_pushNotificationsKey) ?? true;
    _emailNotificationsEnabled.value =
        prefs.getBool(_emailNotificationsKey) ?? true;
    _locationAlertsEnabled.value = prefs.getBool(_locationAlertsKey) ?? true;
    _deviceOfflineAlertsEnabled.value =
        prefs.getBool(_deviceOfflineAlertsKey) ?? true;
    _batteryAlertsEnabled.value = prefs.getBool(_batteryAlertsKey) ?? true;
    _geofenceNotificationsEnabled.value =
        prefs.getBool(_geofenceNotificationsKey) ?? true;
    _deviceStatusNotificationsEnabled.value =
        prefs.getBool(_deviceStatusNotificationsKey) ?? true;
    _lowBatteryNotificationsEnabled.value =
        prefs.getBool(_lowBatteryNotificationsKey) ?? true;
    _securityNotificationsEnabled.value =
        prefs.getBool(_securityNotificationsKey) ?? true;
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

  Future<void> toggleGeofenceNotifications(bool value) async {
    _geofenceNotificationsEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_geofenceNotificationsKey, value);
  }

  Future<void> toggleDeviceStatusNotifications(bool value) async {
    _deviceStatusNotificationsEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_deviceStatusNotificationsKey, value);
  }

  Future<void> toggleLowBatteryNotifications(bool value) async {
    _lowBatteryNotificationsEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_lowBatteryNotificationsKey, value);
  }

  Future<void> toggleSecurityNotifications(bool value) async {
    _securityNotificationsEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_securityNotificationsKey, value);
  }

  // Show a security notification
  Future<void> showSecurityNotification({
    required String title,
    required String body,
  }) async {
    if (!securityNotificationsEnabled) return;

    await _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      payload: 'security',
    );
  }

  // Show a geofence notification
  Future<void> showGeofenceNotification({
    required GeofenceModel geofence,
    required bool isEntry,
    required String deviceName,
  }) async {
    if (!geofenceNotificationsEnabled) return;

    await _notificationService.showGeofenceNotification(
      geofence: geofence,
      isEntry: isEntry,
      deviceName: deviceName,
    );
  }

  // Show a device status notification
  Future<void> showDeviceStatusNotification({
    required String deviceId,
    required String deviceName,
    required String status,
    String? details,
  }) async {
    if (!deviceStatusNotificationsEnabled) return;

    await _notificationService.showDeviceStatusNotification(
      deviceId: deviceId,
      deviceName: deviceName,
      status: status,
      details: details,
    );
  }

  // Show a low battery notification
  Future<void> showLowBatteryNotification({
    required String deviceId,
    required String deviceName,
    required int batteryLevel,
  }) async {
    if (!lowBatteryNotificationsEnabled) return;

    await _notificationService.showLowBatteryNotification(
      deviceId: deviceId,
      deviceName: deviceName,
      batteryLevel: batteryLevel,
    );
  }
}
