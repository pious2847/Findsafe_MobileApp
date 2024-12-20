import 'package:findsafe/models/devices.dart';
import 'package:findsafe/service/device.dart';
import 'package:findsafe/service/location.dart';
import 'package:findsafe/utilities/toast_messages.dart';
import 'package:findsafe/utilities/utils.dart';
import 'package:findsafe/widgets/device_card.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DeviceDraggableSheet extends StatefulWidget {
  final Future<void> Function(String) onTap;
  final String? current_device;

  const DeviceDraggableSheet({
    super.key, 
    required this.onTap, 
    this.current_device
  });

  @override
  State<DeviceDraggableSheet> createState() => _DeviceDraggableSheetState();
}

class _DeviceDraggableSheetState extends State<DeviceDraggableSheet> {
  final deviceApiService = DeviceApiService();
  final locationApiService = LocationApiService();
  List<Device> devices = [];
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

  @override
  void initState() {
    super.initState();
    fetchMobileDevices();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/svg/dataloader.json', // Make sure to add your Lottie file here
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 20),
          const Text(
            'Fetching devices...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                spreadRadius: 2,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
            
                // Title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Devices",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            
                const SizedBox(height: 10),
            
                // Content
                Expanded(
                  child: isLoading
                      ? _buildLoadingState()
                      : _buildDevicesList(scrollController),
                ),
            
                const SizedBox(height: 90),
              ],
            ),
          ),
        );
      },
    );
  }
}