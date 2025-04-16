import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const BringoApp());
}

class BringoApp extends StatelessWidget {
  const BringoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bringo Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const RideRequestMap(),
    );
  }
}

class RideRequestMap extends StatefulWidget {
  const RideRequestMap({super.key});

  @override
  State<RideRequestMap> createState() => _RideRequestMapState();
}

class _RideRequestMapState extends State<RideRequestMap> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    final status = await Permission.location.request();
    if (!status.isGranted) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = position;
      _markers.add(Marker(
        markerId: const MarkerId("pickup"),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ));
    });

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(position.latitude, position.longitude),
      15,
    ));
  }

  void _confirmRide() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Ride confirmed. Driver arriving soon...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request a Ride')),
      body: Stack(
        children: [
          _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    zoom: 15,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  myLocationEnabled: true,
                  markers: _markers,
                ),
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _confirmRide,
              child: const Text('Confirm Ride'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
