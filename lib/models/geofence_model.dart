import 'package:google_maps_flutter/google_maps_flutter.dart';

enum GeofenceType {
  entry, // Alert when entering the zone
  exit, // Alert when exiting the zone
  dwell, // Alert when staying in the zone for a period
  both // Alert on both entry and exit
}

class GeofenceModel {
  String? id;
  String name;
  String? description;
  LatLng center;
  double radius;
  GeofenceType type;
  String? deviceId;
  bool isActive;
  DateTime createdAt;
  DateTime? updatedAt;

  // Color for the geofence (stored as an integer)
  int color;

  GeofenceModel({
    this.id,
    required this.name,
    this.description,
    required this.center,
    required this.radius,
    required this.type,
    this.deviceId,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    required this.color,
  });

  factory GeofenceModel.fromJson(Map<String, dynamic> json) {
    // Handle different formats of center coordinates
    LatLng getCenter() {
      if (json.containsKey('latitude') && json.containsKey('longitude')) {
        return LatLng(
          double.parse(json['latitude'].toString()),
          double.parse(json['longitude'].toString()),
        );
      } else if (json.containsKey('center')) {
        if (json['center'] is Map) {
          return LatLng(
            double.parse(json['center']['latitude'].toString()),
            double.parse(json['center']['longitude'].toString()),
          );
        } else {
          // If center is not a map, use default coordinates
          return const LatLng(0, 0);
        }
      } else {
        // Default coordinates if none are provided
        return const LatLng(0, 0);
      }
    }

    return GeofenceModel(
      id: json['id'],
      name: json['name'] ?? 'Unnamed Geofence',
      description: json['description'],
      center: getCenter(),
      radius: (json['radius'] != null)
          ? double.parse(json['radius'].toString())
          : 100.0,
      type: _parseGeofenceType(json['type']),
      deviceId: json['deviceId'],
      isActive: json['isActive'] ?? true,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      color: json['color'] ?? 0xFF2196F3, // Default to blue if not specified
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': center.latitude,
      'longitude': center.longitude,
      'radius': radius,
      'type': type.toString().split('.').last,
      'deviceId': deviceId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'color': color,
    };
  }

  static GeofenceType _parseGeofenceType(String? typeStr) {
    if (typeStr == null) return GeofenceType.both;

    switch (typeStr.toLowerCase()) {
      case 'entry':
        return GeofenceType.entry;
      case 'exit':
        return GeofenceType.exit;
      case 'dwell':
        return GeofenceType.dwell;
      case 'both':
        return GeofenceType.both;
      default:
        return GeofenceType.both;
    }
  }
}
