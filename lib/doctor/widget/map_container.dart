import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapContainer extends StatefulWidget {
  final double latitude;
  final double longitude;

  const MapContainer({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MapContainerState createState() => _MapContainerState();
}

class _MapContainerState extends State<MapContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude, widget.longitude),
          zoom: 14.0,
        ),
        onMapCreated: (GoogleMapController controller) {},
        markers: {
          Marker(
            markerId: const MarkerId('locationMarker'),
            position: LatLng(widget.latitude, widget.longitude),
          ),
        },
      ),
    );
  }
}
