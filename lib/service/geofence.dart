import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:findsafe/models/geofence_model.dart';
import 'package:findsafe/service/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeofenceApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://findsafe-backend.onrender.com/api';
  final AuthProvider _authProvider = AuthProvider();

  // Cache geofences locally
  Future<void> _cacheGeofences(List<GeofenceModel> geofences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final geofencesJson = geofences.map((g) => g.toJson()).toList();
      await prefs.setString('cached_geofences', jsonEncode(geofencesJson));
    } catch (e) {
      debugPrint('Error caching geofences: $e');
    }
  }

  // Get cached geofences
  Future<List<GeofenceModel>> getCachedGeofences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cached_geofences');
      
      if (cachedData != null) {
        final List<dynamic> geofencesJson = jsonDecode(cachedData);
        return geofencesJson.map((json) => GeofenceModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error getting cached geofences: $e');
    }
    
    return [];
  }

  // Fetch all geofences for a user
  Future<List<GeofenceModel>> fetchGeofences(BuildContext context) async {
    try {
      final token = await _authProvider.getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      final response = await _dio.get(
        '$_baseUrl/geofences',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> geofencesJson = response.data['data'];
        final geofences = geofencesJson.map((json) => GeofenceModel.fromJson(json)).toList();
        
        // Cache the geofences
        await _cacheGeofences(geofences);
        
        return geofences;
      } else {
        // If server returns an error, try to get cached data
        final cachedGeofences = await getCachedGeofences();
        if (cachedGeofences.isNotEmpty) {
          return cachedGeofences;
        }
        
        throw Exception('Failed to load geofences');
      }
    } catch (e) {
      debugPrint('Error fetching geofences: $e');
      
      // If there's an error, try to get cached data
      final cachedGeofences = await getCachedGeofences();
      if (cachedGeofences.isNotEmpty) {
        return cachedGeofences;
      }
      
      // If we're in development mode, return some mock data
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        return _getMockGeofences();
      }
      
      throw Exception('Failed to load geofences: $e');
    }
  }

  // Create a new geofence
  Future<GeofenceModel> createGeofence(BuildContext context, GeofenceModel geofence) async {
    try {
      final token = await _authProvider.getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      final response = await _dio.post(
        '$_baseUrl/geofences',
        data: geofence.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 201) {
        final createdGeofence = GeofenceModel.fromJson(response.data['data']);
        
        // Update the cache
        final cachedGeofences = await getCachedGeofences();
        cachedGeofences.add(createdGeofence);
        await _cacheGeofences(cachedGeofences);
        
        return createdGeofence;
      } else {
        throw Exception('Failed to create geofence');
      }
    } catch (e) {
      debugPrint('Error creating geofence: $e');
      
      // If we're in development mode, return a mock response
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        geofence.id = DateTime.now().millisecondsSinceEpoch.toString();
        
        // Update the cache
        final cachedGeofences = await getCachedGeofences();
        cachedGeofences.add(geofence);
        await _cacheGeofences(cachedGeofences);
        
        return geofence;
      }
      
      throw Exception('Failed to create geofence: $e');
    }
  }

  // Update an existing geofence
  Future<GeofenceModel> updateGeofence(BuildContext context, GeofenceModel geofence) async {
    try {
      final token = await _authProvider.getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      if (geofence.id == null) {
        throw Exception('Geofence ID is required for update');
      }
      
      final response = await _dio.put(
        '$_baseUrl/geofences/${geofence.id}',
        data: geofence.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        final updatedGeofence = GeofenceModel.fromJson(response.data['data']);
        
        // Update the cache
        final cachedGeofences = await getCachedGeofences();
        final index = cachedGeofences.indexWhere((g) => g.id == geofence.id);
        if (index != -1) {
          cachedGeofences[index] = updatedGeofence;
          await _cacheGeofences(cachedGeofences);
        }
        
        return updatedGeofence;
      } else {
        throw Exception('Failed to update geofence');
      }
    } catch (e) {
      debugPrint('Error updating geofence: $e');
      
      // If we're in development mode, return a mock response
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        geofence.updatedAt = DateTime.now();
        
        // Update the cache
        final cachedGeofences = await getCachedGeofences();
        final index = cachedGeofences.indexWhere((g) => g.id == geofence.id);
        if (index != -1) {
          cachedGeofences[index] = geofence;
          await _cacheGeofences(cachedGeofences);
        }
        
        return geofence;
      }
      
      throw Exception('Failed to update geofence: $e');
    }
  }

  // Delete a geofence
  Future<bool> deleteGeofence(BuildContext context, String geofenceId) async {
    try {
      final token = await _authProvider.getToken();
      
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      
      final response = await _dio.delete(
        '$_baseUrl/geofences/$geofenceId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      if (response.statusCode == 200) {
        // Update the cache
        final cachedGeofences = await getCachedGeofences();
        cachedGeofences.removeWhere((g) => g.id == geofenceId);
        await _cacheGeofences(cachedGeofences);
        
        return true;
      } else {
        throw Exception('Failed to delete geofence');
      }
    } catch (e) {
      debugPrint('Error deleting geofence: $e');
      
      // If we're in development mode, return a mock response
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        // Update the cache
        final cachedGeofences = await getCachedGeofences();
        cachedGeofences.removeWhere((g) => g.id == geofenceId);
        await _cacheGeofences(cachedGeofences);
        
        return true;
      }
      
      throw Exception('Failed to delete geofence: $e');
    }
  }

  // Get geofences for a specific device
  Future<List<GeofenceModel>> getGeofencesForDevice(BuildContext context, String deviceId) async {
    try {
      final allGeofences = await fetchGeofences(context);
      return allGeofences.where((geofence) => geofence.deviceId == deviceId).toList();
    } catch (e) {
      debugPrint('Error getting geofences for device: $e');
      throw Exception('Failed to get geofences for device: $e');
    }
  }

  // Check if a location is within any geofence
  Future<List<GeofenceModel>> checkGeofences(BuildContext context, LatLng location, String deviceId) async {
    try {
      final geofences = await getGeofencesForDevice(context, deviceId);
      final triggeredGeofences = <GeofenceModel>[];
      
      for (final geofence in geofences) {
        if (!geofence.isActive) continue;
        
        final distance = _calculateDistance(
          geofence.center.latitude,
          geofence.center.longitude,
          location.latitude,
          location.longitude,
        );
        
        if (distance <= geofence.radius) {
          triggeredGeofences.add(geofence);
        }
      }
      
      return triggeredGeofences;
    } catch (e) {
      debugPrint('Error checking geofences: $e');
      return [];
    }
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    const c = 6371000.0; // Earth radius in meters
    
    final a = 0.5 - 
        math.cos((lat2 - lat1) * p) / 2 + 
        math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lon2 - lon1) * p)) / 2;
    
    return 2 * c * math.asin(math.sqrt(a)); // Distance in meters
  }

  // Get mock geofences for development
  List<GeofenceModel> _getMockGeofences() {
    return [
      GeofenceModel(
        id: '1',
        name: 'Home',
        description: 'My home area',
        center: const LatLng(37.7749, -122.4194), // San Francisco
        radius: 200.0,
        type: GeofenceType.both,
        deviceId: 'device1',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        color: 0xFF4CAF50, // Green
      ),
      GeofenceModel(
        id: '2',
        name: 'Work',
        description: 'Office area',
        center: const LatLng(37.7833, -122.4167), // Near SF
        radius: 150.0,
        type: GeofenceType.both,
        deviceId: 'device1',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        color: 0xFF2196F3, // Blue
      ),
      GeofenceModel(
        id: '3',
        name: 'School',
        description: 'School zone',
        center: const LatLng(37.7694, -122.4862), // Another SF location
        radius: 300.0,
        type: GeofenceType.entry,
        deviceId: 'device2',
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        color: 0xFFFFC107, // Amber
      ),
    ];
  }
}


