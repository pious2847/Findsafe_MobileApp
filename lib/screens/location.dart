import 'package:findsafe/models/devices.dart';
import 'package:findsafe/models/location_model.dart';
import 'package:findsafe/service/device.dart';
import 'package:findsafe/service/location.dart';
import 'package:findsafe/utilities/georeverse.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:findsafe/utilities/utils.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LocationHistory extends StatefulWidget {
  const LocationHistory({super.key});

  @override
  State<LocationHistory> createState() => _LocationHistoryState();
}

class _LocationHistoryState extends State<LocationHistory> {
  final deviceApiService = DeviceApiService();
  final locationApiService = LocationApiService();
  List<Device> devices = [];
  Device? selectedDevice;
  List<Location> locationHistory = [];
  bool isLoading = true;

  Future<void> fetchMobileDevices() async {
    try {
      setState(() {
        isLoading = true;
      });

      final userData = await getUserDataFromLocalStorage();
      final userId = userData['userId'] as String?;

      if (userId == null) {
        CustomToast.show(
          context: context,
          message: 'Unable to load user data from local storage',
          type: ToastType.warning,
          position: ToastPosition.top,
        );
        return;
      }

      if (!mounted) return;

      final mobileDevices = await deviceApiService.fetchDevices(userId);

      if (!mounted) return;

      setState(() {
        devices = mobileDevices;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      CustomToast.show(
        context: context,
        message: 'Error fetching mobile devices',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      print('Error fetching mobile devices: $e');
    }
  }

  fetchLocationHistory(Device device) async {
    try {
      final history = await locationApiService.fetchLocationHistory(device.id);
      setState(() {
        locationHistory = history;
      });
    } catch (e) {
      CustomToast.show(
        context: context,
        message: 'Failed to fetch location history',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      print('Failed to fetch location history: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMobileDevices();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Location History',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
              ),
              const SizedBox(
                height: 50,
              ),
              if (devices.isNotEmpty)
                DropdownButtonFormField<Device>(
                  value: selectedDevice,
                  onChanged: (Device? newValue) {
                    setState(() {
                      selectedDevice = newValue!;
                      fetchLocationHistory(selectedDevice!);
                    });
                  },
                  items: devices.map<DropdownMenuItem<Device>>((Device device) {
                    return DropdownMenuItem<Device>(
                      value: device,
                      child: Text(device.devicename),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Select Device',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                          color: Colors.grey[300]!), // Use a named constant
                    ),
                    //Add a hint if the field is empty
                    hintText: "Select a Device",
                  ),
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                )
              else
                Center(
                  child: Lottie.asset(
                    'assets/svg/dataloader.json', // Make sure to add your Lottie file here
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              SizedBox(
                height: 20,
              ),
              if (locationHistory.isNotEmpty)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(
                        16.0), // Add padding around the list
                    children: [
                      DataTable(
                        columns: const <DataColumn>[
                          DataColumn(
                            label: Text(
                              'Location',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    18, // Adjust font size for column headers
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Timestamp',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black87,
                              ),
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
                                          fontSize: 14,
                                        ),
                                      );
                                    } else {
                                      final locationName =
                                          snapshot.data ?? 'Unknown location';
                                      return Text(
                                        locationName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                              DataCell(
                                Text(
                                  location.timestamp.toString(),
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                        dataRowHeight: 60, // Adjust the row height
                        headingRowHeight: 55, // Adjust the heading row height
                        dividerThickness: 1.5, // Adjust the divider thickness
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Adjust heading font size
                          color: Colors.white,
                        ),
                        headingRowColor: WidgetStateColor.resolveWith(
                          (states) => Colors.indigo, // Adjust heading row color
                        ),
                        dataTextStyle: const TextStyle(
                          fontSize: 16, // Adjust data text size
                          color: Colors.black87,
                        ),
                        columnSpacing: 24, // Add spacing between columns
                      ),
                    ],
                  ),
                )
              else if (selectedDevice != null)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else
                const Center(
                  child: Text(
                    'No location history available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
