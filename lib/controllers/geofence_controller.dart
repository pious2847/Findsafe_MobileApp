import 'package:findsafe/controllers/notification_controller.dart';
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
  Future<bool> createGeofence(
      GeofenceModel geofence, BuildContext context) async {
    _isLoading.value = true;

    try {
      final createdGeofence =
          await _geofenceService.createGeofence(context, geofence);
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
  Future<bool> updateGeofence(
      GeofenceModel geofence, BuildContext context) async {
    _isLoading.value = true;

    try {
      final updatedGeofence =
          await _geofenceService.updateGeofence(context, geofence);

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
      final success =
          await _geofenceService.deleteGeofence(context, geofenceId);

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
    return _geofences
        .where((geofence) => geofence.deviceId == deviceId)
        .toList();
  }

  // Update the circles on the map
  void _updateGeofenceCircles() {
    final circles = <Circle>{};

    for (final geofence in _geofences) {
      final circle = Circle(
        circleId: CircleId(
            geofence.id ?? 'temp-${DateTime.now().millisecondsSinceEpoch}'),
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
  Future<List<GeofenceModel>> checkGeofences(LatLng location, String deviceId,
      String deviceName, BuildContext context) async {
    try {
      // Get previously triggered geofences from memory
      final List<String> previouslyTriggeredGeofenceIds =
          _getTriggeredGeofenceIds(deviceId);

      // Check current geofences
      final List<GeofenceModel> triggeredGeofences =
          await _geofenceService.checkGeofences(context, location, deviceId);

      // Get notification controller
      NotificationController? notificationController;
      if (Get.isRegistered<NotificationController>()) {
        notificationController = Get.find<NotificationController>();
      }

      // Check for entry events (geofences that weren't triggered before but are now)
      for (final geofence in triggeredGeofences) {
        if (geofence.id != null &&
            !previouslyTriggeredGeofenceIds.contains(geofence.id)) {
          // This is a new entry event
          debugPrint('Geofence entry event: ${geofence.name}');

          // Send notification if controller is available
          if (notificationController != null) {
            notificationController.showGeofenceNotification(
              geofence: geofence,
              isEntry: true,
              deviceName: deviceName,
            );
          }
        }
      }

      // Check for exit events (geofences that were triggered before but aren't now)
      final List<String> currentTriggeredGeofenceIds = triggeredGeofences
          .map((g) => g.id ?? '')
          .where((id) => id.isNotEmpty)
          .toList();

      for (final previousId in previouslyTriggeredGeofenceIds) {
        if (!currentTriggeredGeofenceIds.contains(previousId)) {
          // This is an exit event
          debugPrint('Geofence exit event: $previousId');

          // Find the geofence model
          final geofence =
              _geofences.firstWhereOrNull((g) => g.id == previousId);

          if (geofence != null && notificationController != null) {
            notificationController.showGeofenceNotification(
              geofence: geofence,
              isEntry: false,
              deviceName: deviceName,
            );
          }
        }
      }

      // Save current triggered geofences
      _saveTriggeredGeofenceIds(deviceId, currentTriggeredGeofenceIds);

      return triggeredGeofences;
    } catch (e) {
      debugPrint('Error checking geofences: $e');
      return [];
    }
  }

  // Get previously triggered geofence IDs for a device
  List<String> _getTriggeredGeofenceIds(String deviceId) {
    final key = 'triggered_geofences_$deviceId';
    final List<String> triggeredIds = <String>[];

    // In a real app, this would be stored in shared preferences or a database
    // For simplicity, we're using a memory cache here
    if (Get.parameters.containsKey(key)) {
      final String idsString = Get.parameters[key] ?? '';
      if (idsString.isNotEmpty) {
        triggeredIds.addAll(idsString.split(','));
      }
    }

    return triggeredIds;
  }

  // Save triggered geofence IDs for a device
  void _saveTriggeredGeofenceIds(String deviceId, List<String> geofenceIds) {
    final key = 'triggered_geofences_$deviceId';
    final String idsString = geofenceIds.join(',');

    // In a real app, this would be stored in shared preferences or a database
    // For simplicity, we're using a memory cache here
    Get.parameters[key] = idsString;
  }
}
