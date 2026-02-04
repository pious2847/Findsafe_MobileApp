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
  String deviceId; // Changed to required
  bool isActive;
  DateTime createdAt;
  DateTime? updatedAt;
  int color;

  GeofenceModel({
    this.id,
    required this.name,
    this.description,
    required this.center,
    required this.radius,
    required this.type,
    required this.deviceId, // Changed to required
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    required this.color,
  });

  factory GeofenceModel.fromJson(Map<String, dynamic> json) {
    // Handle different formats of center coordinates
    LatLng getCenter() {
      if (json.containsKey('center')) {
        // Handle center as an object with latitude and longitude
        return LatLng(
          double.parse(json['center']['latitude'].toString()),
          double.parse(json['center']['longitude'].toString()),
        );
      } else if (json.containsKey('latitude') && json.containsKey('longitude')) {
        // Handle flat structure
        return LatLng(
          double.parse(json['latitude'].toString()),
          double.parse(json['longitude'].toString()),
        );
      } else {
        // Default coordinates if none are provided
        return const LatLng(0, 0);
      }
    }

    return GeofenceModel(
      id: json['_id'] ?? json['id'], // Handle both MongoDB _id and client-side id
      name: json['name'] ?? 'Unnamed Geofence',
      description: json['description'],
      center: getCenter(),
      radius: (json['radius'] != null)
          ? double.parse(json['radius'].toString())
          : 100.0,
      type: _parseGeofenceType(json['type']),
      deviceId: json['deviceId'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'].toString()) 
          : null,
      color: json['color'] ?? 0xFF4CAF50, // Default to green if not specified
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'center': {
        'latitude': center.latitude,
        'longitude': center.longitude
      },
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