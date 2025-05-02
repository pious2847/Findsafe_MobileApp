import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacyController extends GetxController {
  static PrivacyController get to => Get.find();
  
  final _locationSharingEnabled = true.obs;
  final _dataCollectionEnabled = true.obs;
  final _analyticsEnabled = true.obs;
  
  final _locationSharingKey = 'locationSharingEnabled';
  final _dataCollectionKey = 'dataCollectionEnabled';
  final _analyticsKey = 'analyticsEnabled';
  
  bool get locationSharingEnabled => _locationSharingEnabled.value;
  bool get dataCollectionEnabled => _dataCollectionEnabled.value;
  bool get analyticsEnabled => _analyticsEnabled.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadSettingsFromPrefs();
  }
  
  Future<void> _loadSettingsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    _locationSharingEnabled.value = prefs.getBool(_locationSharingKey) ?? true;
    _dataCollectionEnabled.value = prefs.getBool(_dataCollectionKey) ?? true;
    _analyticsEnabled.value = prefs.getBool(_analyticsKey) ?? true;
  }
  
  Future<void> toggleLocationSharing(bool value) async {
    _locationSharingEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationSharingKey, value);
  }
  
  Future<void> toggleDataCollection(bool value) async {
    _dataCollectionEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dataCollectionKey, value);
  }
  
  Future<void> toggleAnalytics(bool value) async {
    _analyticsEnabled.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_analyticsKey, value);
  }
}
