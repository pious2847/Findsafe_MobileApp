import 'package:findsafe/utilities/logger.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionService {
  static final _logger = AppLogger.getLogger('LocationPermissionService');

  /// Request location permissions with proper flow for background access
  static Future<LocationPermissionResult> requestLocationPermissions(BuildContext context) async {
    try {
      _logger.info('Starting location permission request flow');

      // Step 1: Check current permission status
      LocationPermission currentPermission = await Geolocator.checkPermission();
      _logger.info('Current location permission: $currentPermission');

      // If already have always permission, we're good
      if (currentPermission == LocationPermission.always) {
        _logger.info('Already have always location permission');
        return LocationPermissionResult.alwaysGranted;
      }

      // If permission is denied forever, direct to settings
      if (currentPermission == LocationPermission.deniedForever) {
        _logger.warning('Location permission denied forever');
        await _showPermissionDeniedDialog(context);
        return LocationPermissionResult.deniedForever;
      }

      // Step 2: Request basic location permission first
      if (currentPermission == LocationPermission.denied) {
        _logger.info('Requesting basic location permission');
        currentPermission = await Geolocator.requestPermission();
        
        if (currentPermission == LocationPermission.denied || 
            currentPermission == LocationPermission.deniedForever) {
          _logger.warning('Basic location permission denied');
          return LocationPermissionResult.denied;
        }
      }

      // Step 3: If we have "while in use", request "always" permission
      if (currentPermission == LocationPermission.whileInUse) {
        _logger.info('Have while-in-use permission, requesting always permission');
        
        // Show explanation dialog first
        bool userAccepted = await _showAlwaysLocationDialog(context);
        if (!userAccepted) {
          _logger.info('User declined always location permission');
          return LocationPermissionResult.whileInUseOnly;
        }

        // Request always permission using permission_handler
        PermissionStatus alwaysStatus = await Permission.locationAlways.request();
        
        if (alwaysStatus.isGranted) {
          _logger.info('Always location permission granted');
          return LocationPermissionResult.alwaysGranted;
        } else if (alwaysStatus.isDenied) {
          _logger.warning('Always location permission denied');
          return LocationPermissionResult.whileInUseOnly;
        } else if (alwaysStatus.isPermanentlyDenied) {
          _logger.warning('Always location permission permanently denied');
          await _showPermissionDeniedDialog(context);
          return LocationPermissionResult.deniedForever;
        }
      }

      // Final check
      final finalPermission = await Geolocator.checkPermission();
      _logger.info('Final location permission: $finalPermission');
      
      if (finalPermission == LocationPermission.always) {
        return LocationPermissionResult.alwaysGranted;
      } else if (finalPermission == LocationPermission.whileInUse) {
        return LocationPermissionResult.whileInUseOnly;
      } else {
        return LocationPermissionResult.denied;
      }

    } catch (e, stackTrace) {
      _logger.severe('Error requesting location permissions', e, stackTrace);
      return LocationPermissionResult.error;
    }
  }

  /// Show dialog explaining why we need always location permission
  static Future<bool> _showAlwaysLocationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Background Location Access'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FindSafe needs "Always" location access to protect your device even when the app is closed.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'This allows us to:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Track your device location every 15 minutes'),
              Text('• Send location updates even when app is closed'),
              Text('• Help locate your device if it\'s lost or stolen'),
              SizedBox(height: 16),
              Text(
                'Your location data is only used for device security and is never shared with third parties.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not Now'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Allow Always'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Show dialog when permission is denied forever
  static Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FindSafe needs location access to protect your device. Please enable location permissions in your device settings.',
              ),
              SizedBox(height: 16),
              Text(
                'Go to: Settings > Apps > FindSafe > Permissions > Location > Allow all the time',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Check if we have sufficient permissions for background tracking
  static Future<bool> hasBackgroundLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always;
    } catch (e) {
      _logger.severe('Error checking background location permission', e);
      return false;
    }
  }

  /// Get current permission status as a user-friendly string
  static Future<String> getPermissionStatusString() async {
    try {
      final permission = await Geolocator.checkPermission();
      switch (permission) {
        case LocationPermission.always:
          return 'Always (Background tracking enabled)';
        case LocationPermission.whileInUse:
          return 'While using app (Background tracking disabled)';
        case LocationPermission.denied:
          return 'Denied';
        case LocationPermission.deniedForever:
          return 'Permanently denied';
        case LocationPermission.unableToDetermine:
          return 'Unable to determine';
      }
    } catch (e) {
      return 'Error checking permission';
    }
  }

  /// Show toast message about permission status
  static void showPermissionToast(BuildContext context, LocationPermissionResult result) {
    switch (result) {
      case LocationPermissionResult.alwaysGranted:
        CustomToast.show(
          context: context,
          message: 'Background location tracking enabled!',
          type: ToastType.success,
          position: ToastPosition.top,
        );
        break;
      case LocationPermissionResult.whileInUseOnly:
        CustomToast.show(
          context: context,
          message: 'Location access granted, but background tracking is limited',
          type: ToastType.warning,
          position: ToastPosition.top,
        );
        break;
      case LocationPermissionResult.denied:
        CustomToast.show(
          context: context,
          message: 'Location permission denied. Background tracking disabled.',
          type: ToastType.error,
          position: ToastPosition.top,
        );
        break;
      case LocationPermissionResult.deniedForever:
        CustomToast.show(
          context: context,
          message: 'Location permission permanently denied. Please enable in settings.',
          type: ToastType.error,
          position: ToastPosition.top,
        );
        break;
      case LocationPermissionResult.error:
        CustomToast.show(
          context: context,
          message: 'Error requesting location permission',
          type: ToastType.error,
          position: ToastPosition.top,
        );
        break;
    }
  }
}

enum LocationPermissionResult {
  alwaysGranted,
  whileInUseOnly,
  denied,
  deniedForever,
  error,
}
