import 'package:findsafe/models/location_model.dart';
import 'package:findsafe/widgets/custom_map_preview.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LocationHistoryTable extends StatelessWidget {
  final List<Location> locationHistory;
  final Future<String> Function(double, double) getPlaceName;

  const LocationHistoryTable({
    super.key,
    required this.locationHistory,
    required this.getPlaceName,
  });

 
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width * 0.95;

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: deviceWidth,
            child: DataTable(
              headingTextStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              headingRowColor: WidgetStateProperty.resolveWith(
                (states) => Colors.blueAccent,
              ),
              dataRowColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? Colors.blue[50]
                    : Colors.white,
              ),
              dataRowHeight: 70,
              headingRowHeight: 60,
              dividerThickness: 1.5,
              columnSpacing: 32,
              columns: const <DataColumn>[
                DataColumn(
                  label: Text(
                    'Location',
                    textAlign: TextAlign.center,
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Timestamp',
                    textAlign: TextAlign.center,
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Action',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              rows: locationHistory.map((location) {
                return DataRow(
                  cells: [
                    DataCell(
                      FutureBuilder<String>(
                        future: getPlaceName(
                          location.latitude,
                          location.longitude,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            );
                          } else {
                            final locationName =
                                snapshot.data ?? 'Unknown location';
                            return Text(
                              locationName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    DataCell(
                      Text(
                        location.timestamp.toLocal().toIso8601String(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    DataCell(IconButton(
                      icon: const Icon(Iconsax.eye),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => LocationPreview(
                            latitude: location.latitude, 
                            longitude:location.longitude, 
                          ),
                        );
                      },
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
