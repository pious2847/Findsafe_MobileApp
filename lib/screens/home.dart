import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(37.77483, -122.41942), // Example coordinates (San Francisco)
    zoom: 12.0, // Zoom level
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const DeviceDraggableSheet(),
        GoogleMap(
          initialCameraPosition: initialCameraPosition,
          mapType: MapType.normal, // Optional map type
          myLocationEnabled: true, // Show the user's location
          myLocationButtonEnabled: true, // Enable location button
        ),
      ],
    );
  }
}

class DeviceDraggableSheet extends StatelessWidget {
  const DeviceDraggableSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4, // Starting height (30% of the screen)
      minChildSize: 0.1, // Minimum height
      maxChildSize: 0.9, // Maximum height (90% of the screen)
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white, // Set background color
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26, // Shadow color
                blurRadius: 8, // How blurry the shadow is
                spreadRadius: 2, // How much the shadow expands (optional)
                offset: Offset(2, 2), // Offset from the box: (x,y)
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              controller: scrollController,
              itemCount: 20,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item $index'),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
