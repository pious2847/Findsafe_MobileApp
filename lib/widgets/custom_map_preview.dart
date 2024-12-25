import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPreview extends StatefulWidget {
  final double longitude;
  final double latitude;

  const LocationPreview({super.key, required this.latitude, required this.longitude});

  @override
  State<LocationPreview> createState() => _LocationPreviewState();
}

class _LocationPreviewState extends State<LocationPreview> {
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Location Preview"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.latitude, widget.longitude),
            zoom: 16,
          ),
          mapType: MapType.hybrid,
          markers: {
            Marker(
              markerId: const MarkerId("location_marker"),
              position: LatLng(widget.latitude, widget.longitude),
              infoWindow: const InfoWindow(title: 'Device Location'),
            ),
          },
          onMapCreated: (controller) {
            mapController = controller;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Close"),
        ),
      ],
    );
  }
}
