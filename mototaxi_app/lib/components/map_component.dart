import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapComponent extends StatelessWidget {
  final double lat;
  final double lng;

  const MapComponent({Key? key, this.lat = -23.550520, this.lng = -46.633308}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(lat, lng),
        zoom: 13,
      ),
      myLocationEnabled: true,
    );
  }
}
