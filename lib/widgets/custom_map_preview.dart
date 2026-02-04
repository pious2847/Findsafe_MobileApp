import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/utilities/georeverse.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class LocationPreview extends StatefulWidget {
  final double longitude;
  final double latitude;
  final DateTime? timestamp;

  const LocationPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    this.timestamp,
  });

  @override
  State<LocationPreview> createState() => _LocationPreviewState();
}

class _LocationPreviewState extends State<LocationPreview> {
  late GoogleMapController mapController;
  MapType _currentMapType = MapType.normal;
  String? _placeName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaceName();
  }

  Future<void> _loadPlaceName() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final placeName = await getPlaceName(widget.latitude, widget.longitude);
      setState(() {
        _placeName = placeName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _placeName = 'Unknown location';
        _isLoading = false;
      });
    }
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType =
          _currentMapType == MapType.normal ? MapType.hybrid : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    String formattedTimestamp = '';
    if (widget.timestamp != null) {
      final DateFormat formatter = DateFormat('MMM d, yyyy - h:mm a');
      formattedTimestamp = formatter.format(widget.timestamp!.toLocal());
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  Iconsax.location,
                  color: isDarkMode
                      ? AppTheme.darkPrimaryColor
                      : AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: SizedBox(
                            height: 2,
                            child: LinearProgressIndicator(),
                          ),
                        )
                      else
                        Text(
                          _placeName ?? 'Unknown location',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Map
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(widget.latitude, widget.longitude),
                      zoom: 16,
                    ),
                    mapType: _currentMapType,
                    markers: {
                      Marker(
                        markerId: const MarkerId("location_marker"),
                        position: LatLng(widget.latitude, widget.longitude),
                        infoWindow: InfoWindow(
                          title: _placeName ?? 'Device Location',
                          snippet: formattedTimestamp.isNotEmpty
                              ? formattedTimestamp
                              : null,
                        ),
                      ),
                    },
                    onMapCreated: (controller) {
                      mapController = controller;
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                  ),

                  // Map controls
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      children: [
                        // Map type toggle
                        FloatingActionButton.small(
                          heroTag: 'mapTypeToggle',
                          onPressed: _toggleMapType,
                          backgroundColor: isDarkMode
                              ? AppTheme.darkPrimaryColor
                              : AppTheme.primaryColor,
                          child: Icon(
                            _currentMapType == MapType.normal
                                ? Iconsax.map_1
                                : Iconsax.map,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Recenter button
                        FloatingActionButton.small(
                          heroTag: 'recenterMap',
                          onPressed: () {
                            mapController.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(
                                  target:
                                      LatLng(widget.latitude, widget.longitude),
                                  zoom: 16,
                                ),
                              ),
                            );
                          },
                          backgroundColor: isDarkMode
                              ? AppTheme.darkPrimaryColor
                              : AppTheme.primaryColor,
                          child: const Icon(
                            Iconsax.location_tick,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Coordinates display
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.black.withAlpha(179) // 0.7 opacity
                            : Colors.white.withAlpha(230), // 0.9 opacity
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(26), // 0.1 opacity
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (formattedTimestamp.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(
                                  Iconsax.clock,
                                  size: 14,
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  formattedTimestamp,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? Colors.grey[300]
                                        : Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                          Row(
                            children: [
                              Icon(
                                Iconsax.gps,
                                size: 14,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.latitude.toStringAsFixed(6)}, ${widget.longitude.toStringAsFixed(6)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
