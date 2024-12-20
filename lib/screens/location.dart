import 'package:findsafe/models/devices.dart';
import 'package:findsafe/models/location_model.dart';
import 'package:findsafe/service/device.dart';
import 'package:findsafe/service/location.dart';
import 'package:findsafe/utilities/georeverse.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:findsafe/utilities/utils.dart';
import 'package:findsafe/widgets/location_history_table.dart';
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
        selectedDevice = devices.isNotEmpty ? devices.first : null;
        if (selectedDevice != null) {
          fetchLocationHistory(selectedDevice!);
        }
        isLoading = false;
      });
    } catch (e, stackTrace) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      CustomToast.show(
        context: context,
        message: 'An error occurred: ${e.toString()}',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      debugPrint('Error fetching mobile devices: $e\n$stackTrace');
    }
  }

  fetchLocationHistory(Device device) async {
    try {
      final history = await locationApiService.fetchLocationHistory(device.id);

      setState(() {
        locationHistory = history;
      });
    } catch (e, stackTrace) {
      CustomToast.show(
        context: context,
        message: 'Failed to fetch location history',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      debugPrint('Error fetching location history: $e\n$stackTrace');
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
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
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
                    if (newValue != null) {
                      setState(() {
                        selectedDevice = newValue;
                        fetchLocationHistory(selectedDevice!);
                      });
                    }
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
                    'assets/svg/dataloader.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error,
                          size: 50, color: Colors.red);
                    },
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              if (locationHistory.isNotEmpty)
                LocationHistoryTable(
                    locationHistory: locationHistory,
                    getPlaceName: getPlaceName)
              else if (selectedDevice != null)
                Center(
                  child: Lottie.asset(
                    'assets/svg/circleloading.json', // Make sure to add your Lottie file here
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              if (devices.isEmpty)
                const Center(
                  child: Text(
                    'No devices found. Please add a device.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
