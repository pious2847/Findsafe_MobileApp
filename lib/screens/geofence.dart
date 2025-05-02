import 'package:findsafe/controllers/geofence_controller.dart';
import 'package:findsafe/models/geofence_model.dart';
import 'package:findsafe/service/device.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:findsafe/widgets/custom_app_bar.dart';
import 'package:findsafe/widgets/custom_buttons.dart';
import 'package:findsafe/widgets/geofence_editor.dart';
import 'package:findsafe/widgets/geofence_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';

class GeofenceScreen extends StatefulWidget {
  final String deviceId;
  final String deviceName;
  
  const GeofenceScreen({
    super.key,
    required this.deviceId,
    required this.deviceName,
  });

  @override
  State<GeofenceScreen> createState() => _GeofenceScreenState();
}

class _GeofenceScreenState extends State<GeofenceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late GeofenceController _geofenceController;
  late GoogleMapController _mapController;
  
  final DeviceApiService _deviceApiService = DeviceApiService();
  
  bool _isEditing = false;
  GeofenceModel? _selectedGeofence;
  LatLng? _deviceLocation;
  
  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialize geofence controller
    if (!Get.isRegistered<GeofenceController>()) {
      Get.put(GeofenceController());
    }
    _geofenceController = Get.find<GeofenceController>();
    
    // Load device location
    _loadDeviceLocation();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _mapController.dispose();
    super.dispose();
  }
  
  Future<void> _loadDeviceLocation() async {
    try {
      final location = await _deviceApiService.fetchLatestLocation(widget.deviceId);
      if (location != null) {
        setState(() {
          _deviceLocation = location;
        });
        
        // If map controller is initialized, move camera to device location
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(location, 15),
        );
            }
    } catch (e) {
      debugPrint('Error loading device location: $e');
    }
  }
  
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    
    // If device location is available, move camera to it
    if (_deviceLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_deviceLocation!, 15),
      );
    }
  }
  
  void _startAddingGeofence() {
    // If device location is not available, show error
    if (_deviceLocation == null) {
      CustomToast.show(
        context: context,
        message: 'Device location not available',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      return;
    }
    
    setState(() {
      _isEditing = true;
      _selectedGeofence = null;
    });
  }
  
  void _editGeofence(GeofenceModel geofence) {
    setState(() {
      _isEditing = true;
      _selectedGeofence = geofence;
    });
  }
  
  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _selectedGeofence = null;
    });
  }
  
  Future<void> _saveGeofence(GeofenceModel geofence) async {
    final context = this.context;
    
    if (geofence.id != null) {
      // Update existing geofence
      final success = await _geofenceController.updateGeofence(geofence, context);
      if (success) {
        setState(() {
          _isEditing = false;
          _selectedGeofence = null;
        });
      }
    } else {
      // Create new geofence
      final success = await _geofenceController.createGeofence(geofence, context);
      if (success) {
        setState(() {
          _isEditing = false;
          _selectedGeofence = null;
        });
      }
    }
  }
  
  Future<void> _deleteGeofence(String geofenceId) async {
    final context = this.context;
    await _geofenceController.deleteGeofence(geofenceId, context);
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Geofences for ${widget.deviceName}',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: isDarkMode ? AppTheme.darkCardColor : Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Iconsax.map),
                  text: 'Map',
                ),
                Tab(
                  icon: Icon(Iconsax.location),
                  text: 'List',
                ),
              ],
              labelColor: isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
              unselectedLabelColor: isDarkMode ? AppTheme.darkTextSecondaryColor : AppTheme.textSecondaryColor,
              indicatorColor: isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Map view
                _buildMapView(),
                
                // List view
                _buildListView(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: !_isEditing
          ? FloatingActionButton(
              onPressed: _startAddingGeofence,
              backgroundColor: isDarkMode ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
              child: const Icon(Iconsax.add),
            )
          : null,
    );
  }
  
  Widget _buildMapView() {
    return Stack(
      children: [
        // Google Map
        Obx(() {
          final geofenceCircles = _geofenceController.geofenceCircles;
          
          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _deviceLocation ?? const LatLng(0, 0),
              zoom: 15,
            ),
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            circles: geofenceCircles,
            markers: _deviceLocation != null
                ? {
                    Marker(
                      markerId: const MarkerId('device'),
                      position: _deviceLocation!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                      infoWindow: InfoWindow(title: widget.deviceName),
                    ),
                  }
                : {},
            onTap: (latLng) {
              if (_isEditing && _selectedGeofence == null) {
                // When adding a new geofence, update the center
                setState(() {
                  _selectedGeofence = GeofenceModel(
                    name: 'New Geofence',
                    center: latLng,
                    radius: 100.0,
                    type: GeofenceType.both,
                    deviceId: widget.deviceId,
                    createdAt: DateTime.now(),
                    color: Colors.blue.value,
                  );
                });
              }
            },
          );
        }),
        
        // Map controls
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            children: [
              CustomIconButton(
                icon: Iconsax.gps,
                onPressed: _loadDeviceLocation,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkCardColor
                    : Colors.white,
                iconColor: Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.darkPrimaryColor
                    : AppTheme.primaryColor,
              ),
            ],
          ),
        ),
        
        // Geofence editor
        if (_isEditing)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: GeofenceEditor(
              initialGeofence: _selectedGeofence,
              deviceId: widget.deviceId,
              onSave: _saveGeofence,
              onCancel: _cancelEditing,
            ),
          ),
      ],
    );
  }
  
  Widget _buildListView() {
    return Obx(() {
      final geofences = _geofenceController.geofences
          .where((g) => g.deviceId == widget.deviceId)
          .toList();
      
      return GeofenceList(
        geofences: geofences,
        onGeofenceSelected: _editGeofence,
        onGeofenceDeleted: _deleteGeofence,
      );
    });
  }
}

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  
  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: iconColor ?? AppTheme.primaryColor,
      ),
    );
  }
}
