import 'package:findsafe/models/devices.dart';
import 'package:findsafe/service/device.dart';
import 'package:findsafe/service/location.dart';
import 'package:findsafe/theme/app_theme.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:findsafe/utilities/utils.dart';
import 'package:findsafe/widgets/custom_buttons.dart';
import 'package:findsafe/widgets/device_card.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';

class DeviceDraggableSheet extends StatefulWidget {
  final Future<void> Function(String) onTap;
  final String? current_device;

  const DeviceDraggableSheet({
    super.key,
    required this.onTap,
    this.current_device,
  });

  @override
  State<DeviceDraggableSheet> createState() => _DeviceDraggableSheetState();
}

class _DeviceDraggableSheetState extends State<DeviceDraggableSheet> {
  final deviceApiService = DeviceApiService();
  final locationApiService = LocationApiService();
  List<Device> devices = [];
  bool isLoading = true;
  bool isRefreshing = false;
  String? searchQuery;
  final TextEditingController _searchController = TextEditingController();

  Future<void> fetchMobileDevices({bool refresh = false}) async {
    try {
      setState(() {
        if (refresh) {
          isRefreshing = true;
        } else {
          isLoading = true;
        }
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
        isRefreshing = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        isRefreshing = false;
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

  List<Device> get filteredDevices {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return devices;
    }

    return devices
        .where((device) => device.devicename
            .toLowerCase()
            .contains(searchQuery!.toLowerCase()))
        .toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMobileDevices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildLoadingState() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode
        ? AppTheme.darkTextSecondaryColor
        : AppTheme.textSecondaryColor;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/svg/dataloader.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          Text(
            'Fetching devices...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode
        ? AppTheme.darkTextSecondaryColor
        : AppTheme.textSecondaryColor;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.mobile,
            size: 80,
            color: textColor.withAlpha(100),
          ),
          const SizedBox(height: 24),
          Text(
            searchQuery != null && searchQuery!.isNotEmpty
                ? 'No devices match your search'
                : 'No devices found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            searchQuery != null && searchQuery!.isNotEmpty
                ? 'Try a different search term'
                : 'Add a device to get started',
            style: TextStyle(
              fontSize: 14,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (searchQuery != null && searchQuery!.isNotEmpty)
            CustomButton(
              text: 'Clear Search',
              icon: Iconsax.close_circle,
              onPressed: () {
                _searchController.clear();
                setState(() {
                  searchQuery = null;
                });
              },
              isOutlined: true,
            ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(ScrollController scrollController) {
    final devices = filteredDevices;

    if (devices.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => fetchMobileDevices(refresh: true),
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final Device device = devices[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DevicesCards(
              phone: device,
              onTap: widget.onTap,
              isActive: device.id == widget.current_device,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppTheme.darkCardColor : Colors.white;
    final textColor =
        isDarkMode ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),

              // Header with title and refresh button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Your Devices",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Iconsax.refresh,
                        color: isDarkMode
                            ? AppTheme.darkPrimaryColor
                            : AppTheme.primaryColor,
                      ),
                      onPressed: isRefreshing
                          ? null
                          : () => fetchMobileDevices(refresh: true),
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search devices...',
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                      ),
                      prefixIcon: Icon(
                        Iconsax.search_normal,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Iconsax.close_circle,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[500],
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  searchQuery = null;
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: isLoading
                    ? _buildLoadingState()
                    : _buildDevicesList(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }
}
