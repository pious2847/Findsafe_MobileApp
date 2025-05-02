import 'package:findsafe/models/geofence_model.dart';
import 'package:findsafe/service/geofence.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeofenceController extends GetxController {
  static GeofenceController get to => Get.find();
  
  final GeofenceApiService _geofenceService = GeofenceApiService();
  
  final RxList<GeofenceModel> _geofences = <GeofenceModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isEditing = false.obs;
  final Rx<GeofenceModel?> _selectedGeofence = Rx<GeofenceModel?>(null);
  final RxSet<Circle> _geofenceCircles = <Circle>{}.obs;
  
  List<GeofenceModel> get geofences => _geofences;
  bool get isLoading => _isLoading.value;
  bool get isEditing => _isEditing.value;
  GeofenceModel? get selectedGeofence => _selectedGeofence.value;
  Set<Circle> get geofenceCircles => _geofenceCircles;
  
  @override
  void onInit() {
    super.onInit();
    loadGeofences();
  }
  
  // Load all geofences
  Future<void> loadGeofences() async {
    _isLoading.value = true;
    
    try {
      final context = Get.context;
      if (context == null) {
        _isLoading.value = false;
        return;
      }
      
      final geofences = await _geofenceService.fetchGeofences(context);
      _geofences.assignAll(geofences);
      _updateGeofenceCircles();
    } catch (e) {
      debugPrint('Error loading geofences: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Create a new geofence
  Future<bool> createGeofence(GeofenceModel geofence, BuildContext context) async {
    _isLoading.value = true;
    
    try {
      final createdGeofence = await _geofenceService.createGeofence(context, geofence);
      _geofences.add(createdGeofence);
      _updateGeofenceCircles();
      
      CustomToast.show(
        context: context,
        message: 'Geofence created successfully',
        type: ToastType.success,
        position: ToastPosition.top,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error creating geofence: $e');
      
      CustomToast.show(
        context: context,
        message: 'Failed to create geofence',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Update an existing geofence
  Future<bool> updateGeofence(GeofenceModel geofence, BuildContext context) async {
    _isLoading.value = true;
    
    try {
      final updatedGeofence = await _geofenceService.updateGeofence(context, geofence);
      
      final index = _geofences.indexWhere((g) => g.id == geofence.id);
      if (index != -1) {
        _geofences[index] = updatedGeofence;
      }
      
      _updateGeofenceCircles();
      
      CustomToast.show(
        context: context,
        message: 'Geofence updated successfully',
        type: ToastType.success,
        position: ToastPosition.top,
      );
      
      return true;
    } catch (e) {
      debugPrint('Error updating geofence: $e');
      
      CustomToast.show(
        context: context,
        message: 'Failed to update geofence',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Delete a geofence
  Future<bool> deleteGeofence(String geofenceId, BuildContext context) async {
    _isLoading.value = true;
    
    try {
      final success = await _geofenceService.deleteGeofence(context, geofenceId);
      
      if (success) {
        _geofences.removeWhere((g) => g.id == geofenceId);
        _updateGeofenceCircles();
        
        if (_selectedGeofence.value?.id == geofenceId) {
          _selectedGeofence.value = null;
        }
        
        CustomToast.show(
          context: context,
          message: 'Geofence deleted successfully',
          type: ToastType.success,
          position: ToastPosition.top,
        );
        
        return true;
      } else {
        throw Exception('Failed to delete geofence');
      }
    } catch (e) {
      debugPrint('Error deleting geofence: $e');
      
      CustomToast.show(
        context: context,
        message: 'Failed to delete geofence',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Select a geofence
  void selectGeofence(GeofenceModel? geofence) {
    _selectedGeofence.value = geofence;
    _isEditing.value = geofence != null;
  }
  
  // Toggle editing mode
  void toggleEditing(bool value) {
    _isEditing.value = value;
    if (!value) {
      _selectedGeofence.value = null;
    }
  }
  
  // Get geofences for a specific device
  List<GeofenceModel> getGeofencesForDevice(String deviceId) {
    return _geofences.where((geofence) => geofence.deviceId == deviceId).toList();
  }
  
  // Update the circles on the map
  void _updateGeofenceCircles() {
    final circles = <Circle>{};
    
    for (final geofence in _geofences) {
      final circle = Circle(
        circleId: CircleId(geofence.id ?? 'temp-${DateTime.now().millisecondsSinceEpoch}'),
        center: geofence.center,
        radius: geofence.radius,
        fillColor: Color(geofence.color).withOpacity(0.3),
        strokeColor: Color(geofence.color),
        strokeWidth: 2,
      );
      
      circles.add(circle);
    }
    
    _geofenceCircles.value = circles;
  }
  
  // Check if a location is within any geofence
  Future<List<GeofenceModel>> checkGeofences(LatLng location, String deviceId, BuildContext context) async {
    try {
      return await _geofenceService.checkGeofences(context, location, deviceId);
    } catch (e) {
      debugPrint('Error checking geofences: $e');
      return [];
    }
  }
}
