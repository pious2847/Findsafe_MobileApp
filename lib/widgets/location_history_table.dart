import 'package:findsafe/models/location_model.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/widgets/custom_map_preview.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class LocationHistoryTable extends StatelessWidget {
  final List<Location> locationHistory;
  final Future<String> Function(double, double) getPlaceName;

  const LocationHistoryTable({
    super.key,
    required this.locationHistory,
    required this.getPlaceName,
  });

  String _formatDateTime(DateTime dateTime) {
    final DateFormat dateFormatter = DateFormat('MMM d, yyyy');
    final DateFormat timeFormatter = DateFormat('h:mm a');
    return '${dateFormatter.format(dateTime)} at ${timeFormatter.format(dateTime)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: locationHistory.length,
      itemBuilder: (context, index) {
        final location = locationHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Map preview
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(location.latitude, location.longitude),
                          zoom: 14,
                        ),
                        mapType: MapType.normal,
                        zoomControlsEnabled: false,
                        zoomGesturesEnabled: false,
                        rotateGesturesEnabled: false,
                        scrollGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        markers: {
                          Marker(
                            markerId: MarkerId('loc_$index'),
                            position:
                                LatLng(location.latitude, location.longitude),
                          ),
                        },
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => LocationPreview(
                                latitude: location.latitude,
                                longitude: location.longitude,
                                timestamp: location.timestamp,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? AppTheme.darkPrimaryColor
                                  : AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Iconsax.maximize_4,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Location details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location name
                    FutureBuilder<String>(
                      future: getPlaceName(
                        location.latitude,
                        location.longitude,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Row(
                            children: [
                              Icon(Iconsax.location, size: 18),
                              SizedBox(width: 8),
                              SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return const Row(
                            children: [
                              Icon(Iconsax.location,
                                  size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Error loading location',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        } else {
                          final locationName =
                              snapshot.data ?? 'Unknown location';
                          return Row(
                            children: [
                              Icon(
                                Iconsax.location,
                                size: 18,
                                color: isDarkMode
                                    ? AppTheme.darkPrimaryColor
                                    : AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  locationName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    // Timestamp
                    Row(
                      children: [
                        Icon(
                          Iconsax.clock,
                          size: 16,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDateTime(location.timestamp.toLocal()),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Coordinates
                    Row(
                      children: [
                        Icon(
                          Iconsax.gps,
                          size: 16,
                          color:
                              isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // View button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => LocationPreview(
                              latitude: location.latitude,
                              longitude: location.longitude,
                              timestamp: location.timestamp,
                            ),
                          );
                        },
                        icon: const Icon(Iconsax.eye),
                        label: const Text('View on Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? AppTheme.darkPrimaryColor
                              : AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
