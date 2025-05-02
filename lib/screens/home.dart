import 'package:findsafe/controllers/geofence_controller.dart';
import 'package:findsafe/models/directions_model.dart';
import 'package:findsafe/service/location.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/utilities/directions.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:findsafe/widgets/custom_app_bar.dart';
import 'package:findsafe/widgets/device_draggable_sheet.dart';
import 'package:findsafe/widgets/map_controls.dart';
import 'package:findsafe/widgets/route_info_card.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isDraggableOpen = false;
  late GoogleMapController _googleMapController;
  late LocationPermission permission;
  Marker? _deviceCurrentLocation;
  Directions? _info;
  String? _selectedDeviceId;
  List<dynamic> locationHistory = [];
  final Set<Polyline> _polylines = {};
  MapType _currentMapType = MapType.hybrid;
  late GeofenceController _geofenceController;
  bool _showGeofences = false;

  final locationApiService = LocationApiService();

  // Use a Set for markers to work with GoogleMap
  final Set<Marker> _markers = {};

  CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(37.77483, -122.41942),
    zoom: 12.0,
  );

// Function for getting user current position
  Future<dynamic> _getLocation() async {
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      if (mounted) {
        CustomToast.show(
            context: context,
            message:
                'Location permission denied. Please check settings to enable',
            type: ToastType.warning,
            position: ToastPosition.top);
      }
      return;
    }

    try {
      Position currentPosition = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      // Batch your setState calls
      setState(() {
        initialCameraPosition = CameraPosition(
          target: LatLng(currentPosition.latitude, currentPosition.longitude),
          zoom: 18.5,
          tilt: 50.0,
        );

        // Remove existing 'current_location' marker if it exists
        _markers.removeWhere(
            (marker) => marker.markerId.value == 'current_location');

        // Add the new marker
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position:
                LatLng(currentPosition.latitude, currentPosition.longitude),
            infoWindow: const InfoWindow(title: 'My Location'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      });

      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(initialCameraPosition),
      );

      return currentPosition;
    } catch (e) {
      if (mounted) {
        CustomToast.show(
          context: context,
          message:
              'Unable to set current location. Please check settings to enable location permission',
          type: ToastType.error,
          position: ToastPosition.top,
        );
      }
      debugPrint('Error getting location: $e');
    }
  }

  // Function to toggle the DeviceDraggableSheet
  void _toggleDraggableSheet() {
    setState(() {
      _isDraggableOpen = !_isDraggableOpen;
    });
  }

  // Function to toggle map type
  void _toggleMapType() {
    setState(() {
      _currentMapType =
          _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }

  // Function to toggle geofences visibility
  void _toggleGeofences() {
    setState(() {
      _showGeofences = !_showGeofences;
    });
  }

  // Function to navigate to device location
  void _navigateToDeviceLocation() {
    if (_deviceCurrentLocation != null) {
      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _deviceCurrentLocation!.position,
            zoom: 18.5,
            tilt: 50.0,
          ),
        ),
      );
    }
  }

  // Function to clear route info
  void _clearRouteInfo() {
    setState(() {
      _info = null;
      _polylines.clear();
    });
  }

  // Function to select device
  Future<void> _selectDevice(String deviceId) async {
    try {
      // Clear previous route
      _polylines.clear();

      // Fetch the latest location of the selected device
      final latestLocation =
          await locationApiService.fetchLatestLocation(deviceId);
      final currentLocation = await _getLocation();

      if (latestLocation != null && currentLocation != null) {
        setState(() {
          // Remove existing device location marker if it exists
          _markers
              .removeWhere((marker) => marker.markerId.value == 'destination');

          // Add the new device location marker
          _deviceCurrentLocation = Marker(
            markerId: const MarkerId('destination'),
            infoWindow: const InfoWindow(title: 'Device Location'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            position: latestLocation,
          );
          _markers.add(_deviceCurrentLocation!);
          _selectedDeviceId = deviceId;
        });

        // Fetch directions from the API
        final directions = await DirectionsRepository().getDirections(
          origin: LatLng(currentLocation.latitude, currentLocation.longitude),
          destination: latestLocation,
        );

        if (directions != null) {
          setState(() {
            _info = directions;

            // Add a polyline to represent the route
            _polylines.add(Polyline(
              polylineId: const PolylineId('route'),
              color: AppTheme.primaryColor,
              width: 5,
              points: directions.polylinePoints
                  .map((point) => LatLng(point.latitude, point.longitude))
                  .toList(),
            ));
          });

          // Zoom to show the entire route
          LatLngBounds bounds = LatLngBounds(
            southwest: LatLng(
              directions.bounds.southwest.latitude,
              directions.bounds.southwest.longitude,
            ),
            northeast: LatLng(
              directions.bounds.northeast.latitude,
              directions.bounds.northeast.longitude,
            ),
          );

          _googleMapController.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 50),
          );
        }
      }
    } catch (e) {
      debugPrint('Error selecting device: $e');
      CustomToast.show(
        context: context,
        message: 'Error locating device. Please try again.',
        type: ToastType.error,
        position: ToastPosition.top,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize geofence controller
    if (!Get.isRegistered<GeofenceController>()) {
      Get.put(GeofenceController());
    }
    _geofenceController = Get.find<GeofenceController>();

    // Use WidgetsBinding to ensure initialization happens after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getLocation();
      _geofenceController.loadGeofences();
    });
  }

// proper deposal handling
  @override
  void dispose() {
    _markers.clear();
    _polylines.clear();
    _googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: 'FindSafe',
        showBackButton: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.notification,
              color: isDarkMode ? Colors.white : Colors.white,
            ),
            onPressed: () {
              // Show notifications
            },
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Google Map
          Obx(() {
            final geofenceCircles = _showGeofences
                ? _geofenceController.geofenceCircles
                : <Circle>{};

            return GoogleMap(
              initialCameraPosition: initialCameraPosition,
              myLocationEnabled: true,
              mapType: _currentMapType,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (controller) => _googleMapController = controller,
              markers: _markers,
              polylines: _polylines,
              circles: geofenceCircles,
              compassEnabled: true,
              cloudMapId: '',
            );
          }),

          // Route information card
          if (_info != null)
            RouteInfoCard(
              distance: _info!.totalDistance,
              duration: _info!.totalDuration,
              onClose: _clearRouteInfo,
            ),

          // Device draggable sheet
          if (_isDraggableOpen)
            DeviceDraggableSheet(
              onTap: _selectDevice,
              current_device: _selectedDeviceId,
            ),

          // Map controls
          MapControls(
            onMyLocationPressed: _getLocation,
            onDeviceLocationPressed: _navigateToDeviceLocation,
            onToggleDeviceSheet: _toggleDraggableSheet,
            onToggleGeofences: _toggleGeofences,
            isDeviceSheetOpen: _isDraggableOpen,
            hasDeviceLocation: _deviceCurrentLocation != null,
            isMapTypeHybrid: _currentMapType == MapType.hybrid,
            showGeofences: _showGeofences,
            onToggleMapType: _toggleMapType,
          ),
        ],
      ),
    );
  }
}
