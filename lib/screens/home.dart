import 'package:findsafe/widgets/custom_buttons.dart';
import 'package:findsafe/widgets/device_draggable_sheet.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax/iconsax.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isDraggableOpen = false;

  final CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(37.77483, -122.41942), // Example coordinates (San Francisco)
    zoom: 12.0, // Zoom level
  );

  // Function to toggle the DeviceDraggableSheet
  void _toggleDraggableSheet() {
    setState(() {
      _isDraggableOpen = !_isDraggableOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: initialCameraPosition,
          mapType: MapType.normal,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),

        // Conditionally display the DeviceDraggableSheet
        if (_isDraggableOpen) const DeviceDraggableSheet(),

        
        Positioned(
            bottom: 100,
            right: 25,
            child: Column(
              children: [
               if(!_isDraggableOpen) Custom_Elevated_Buttons(
                  icon: Iconsax.gps,
                  onTap: () {
                    // Add any functionality here
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                Custom_Elevated_Buttons(
                  // Change the icon dynamically based on _isDraggableOpen
                  icon: _isDraggableOpen
                      ? Iconsax.arrow_square_down
                      : Iconsax.arrow_square_up,
                  onTap: _toggleDraggableSheet,
                ),
              ],
            ))
      ],
    );
  }
}
