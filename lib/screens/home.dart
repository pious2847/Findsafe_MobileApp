import 'dart:io';

import 'package:findsafe/models/devices.dart';
import 'package:findsafe/models/directions_model.dart';
import 'package:findsafe/service/device.dart';
import 'package:findsafe/service/location.dart';
import 'package:findsafe/utilities/directions.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:findsafe/utilities/utils.dart';
import 'package:findsafe/widgets/custom_buttons.dart';
import 'package:findsafe/widgets/device_draggable_sheet.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
                'Location permission denied. please check settings to enable',
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
                'Unable to set current location. please check settings to enable location permission',
            type: ToastType.error,
            position: ToastPosition.top);
      }
      print('Error getting location: $e');
    }
  }

  // Function to toggle the DeviceDraggableSheet
  void _toggleDraggableSheet() {
    setState(() {
      _isDraggableOpen = !_isDraggableOpen;
    });
  }

  // Function to selected device
  Future<void> _selectDevice(String deviceId) async {
    try {
      // Fetch the latest location of the selected device
      final latestLocation =
          await locationApiService.fetchLatestLocation(deviceId);
      final currentLocation = await _getLocation();

      if (latestLocation != null && currentLocation != null) {
        setState(() {
          _deviceCurrentLocation = Marker(
            markerId: const MarkerId('destination'),
            infoWindow: const InfoWindow(title: 'Device Location'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
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
              color: Colors.blue,
              width: 5,
              points: directions.polylinePoints
                  .map(
                    (point) => LatLng(point.latitude, point.longitude),
                  )
                  .toList(),
            ));
          });
        }
      }
    } catch (e) {
      print('Error selecting device: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure initialization happens after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getLocation();
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
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            myLocationEnabled: true,
            mapType: MapType.hybrid,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _googleMapController = controller,

            markers: _markers,
            polylines: _polylines,
            // liteModeEnabled: Platform.isAndroid, // Add this
            compassEnabled: false, // Add this
            // tiltGesturesEnabled: false, // Add this if you don't need tilt
          ),

          // Conditionally display the DeviceDraggableSheet
          if (_isDraggableOpen)
            AbsorbPointer(
              absorbing: false,
              child: DeviceDraggableSheet(
                onTap: _selectDevice,
                current_device: _selectedDeviceId,
              ),
            ),

          Positioned(
            bottom: 100,
            right: 18,
            child: Column(
              children: [
                if (_deviceCurrentLocation != null)
                  Custom_Icon_Buttons(
                      icon: Iconsax.arrow,
                      onTap: () {
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
                      }),
                const SizedBox(
                  height: 30,
                ),
                if (!_isDraggableOpen)
                  Custom_Icon_Buttons(
                    icon: Iconsax.gps,
                    onTap: () {
                      _getLocation();
                    },
                  ),
                const SizedBox(
                  height: 30,
                ),
                Custom_Icon_Buttons(
                  icon: _isDraggableOpen
                      ? Iconsax.arrow_square_down
                      : Iconsax.arrow_square_up,
                  onTap: _toggleDraggableSheet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
