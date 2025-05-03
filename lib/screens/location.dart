import 'package:findsafe/models/devices.dart';
import 'package:findsafe/models/location_model.dart';
import 'package:findsafe/service/device.dart';
import 'package:findsafe/service/location.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/utilities/georeverse.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:findsafe/utilities/utils.dart';
import 'package:findsafe/widgets/custom_app_bar.dart';
import 'package:findsafe/widgets/location_history_table.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

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
  bool isRefreshing = false;

  // Date range filter
  DateTime? startDate;
  DateTime? endDate;

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

  Future<void> fetchLocationHistory(Device device) async {
    try {
      setState(() {
        isRefreshing = true;
      });

      final history = await locationApiService.fetchLocationHistory(device.id);

      // Apply date filters if set
      List<Location> filteredHistory = history;
      if (startDate != null || endDate != null) {
        filteredHistory = history.where((location) {
          final locationDate = location.timestamp;
          if (startDate != null && endDate != null) {
            return locationDate.isAfter(startDate!) &&
                locationDate.isBefore(endDate!.add(const Duration(days: 1)));
          } else if (startDate != null) {
            return locationDate.isAfter(startDate!);
          } else if (endDate != null) {
            return locationDate.isBefore(endDate!.add(const Duration(days: 1)));
          }
          return true;
        }).toList();
      }

      setState(() {
        locationHistory = filteredHistory;
        isRefreshing = false;
      });
    } catch (e, stackTrace) {
      setState(() {
        isRefreshing = false;
      });

      CustomToast.show(
        context: context,
        message: 'Failed to fetch location history',
        type: ToastType.error,
        position: ToastPosition.top,
      );
      debugPrint('Error fetching location history: $e\n$stackTrace');
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });

      if (selectedDevice != null) {
        fetchLocationHistory(selectedDevice!);
      }
    }
  }

  void _clearDateFilter() {
    setState(() {
      startDate = null;
      endDate = null;
    });

    if (selectedDevice != null) {
      fetchLocationHistory(selectedDevice!);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMobileDevices();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Format date range for display
    String dateRangeText = 'All Time';
    if (startDate != null && endDate != null) {
      final DateFormat formatter = DateFormat('MMM d, yyyy');
      dateRangeText =
          '${formatter.format(startDate!)} - ${formatter.format(endDate!)}';
    } else if (startDate != null) {
      final DateFormat formatter = DateFormat('MMM d, yyyy');
      dateRangeText = 'From ${formatter.format(startDate!)}';
    } else if (endDate != null) {
      final DateFormat formatter = DateFormat('MMM d, yyyy');
      dateRangeText = 'Until ${formatter.format(endDate!)}';
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Location History',
        showBackButton: false,
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: () {
              if (selectedDevice != null) {
                fetchLocationHistory(selectedDevice!);
              }
            },
          ),
          // Filter button
          IconButton(
            icon: const Icon(Iconsax.calendar),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Lottie.asset(
                'assets/svg/dataloader.json',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                if (selectedDevice != null) {
                  await fetchLocationHistory(selectedDevice!);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Device selector card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Device',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
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
                                  items: devices.map<DropdownMenuItem<Device>>(
                                      (Device device) {
                                    return DropdownMenuItem<Device>(
                                      value: device,
                                      child: Text(device.devicename),
                                    );
                                  }).toList(),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: isDarkMode
                                            ? Colors.grey[700]!
                                            : Colors.grey[300]!,
                                      ),
                                    ),
                                    hintText: "Select a Device",
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                  ),
                                  icon: const Icon(Iconsax.arrow_down_1),
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 16,
                                  ),
                                  dropdownColor: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white,
                                )
                              else
                                const Center(
                                  child: Text(
                                    'No devices found. Please add a device.',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Date filter info
                      if (startDate != null || endDate != null)
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Icon(Iconsax.calendar, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Date Range: $dateRangeText',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Iconsax.close_circle,
                                      size: 20),
                                  onPressed: _clearDateFilter,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Location history
                      if (isRefreshing)
                        Center(
                          child: Lottie.asset(
                            'assets/svg/circleloading.json',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        )
                      else if (locationHistory.isNotEmpty)
                        LocationHistoryTable(
                          locationHistory: locationHistory,
                          getPlaceName: getPlaceName,
                        )
                      else if (selectedDevice != null)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                'assets/svg/empty.json',
                                width: 200,
                                height: 200,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Iconsax.location_slash,
                                      size: 80, color: Colors.grey);
                                },
                              ),
                              const Text(
                                'No location history found',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try changing the date filter or selecting a different device',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                    
              const SizedBox(height: 85),

                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
