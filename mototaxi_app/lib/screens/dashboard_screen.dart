import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DashboardScreen extends StatefulWidget {
  final String cpf;

  DashboardScreen({required this.cpf});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late GoogleMapController mapController;

  static final CameraPosition initialCamera = CameraPosition(
    target: LatLng(-23.550520, -46.633308), // São Paulo
    zoom: 13,
  );

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo, ${widget.cpf}'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: initialCamera,
        myLocationEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }
}
