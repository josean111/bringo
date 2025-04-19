import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class RequestRideScreen extends StatefulWidget {
  @override
  _RequestRideScreenState createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  late GoogleMapController mapController;
  late LatLng _currentPosition = LatLng(37.42796133580664, -122.085749655962); // Default to Googleplex location
  late LatLng _dropOffPosition = LatLng(37.42796133580664, -122.085749655962); // Default drop-off position
  Set<Marker> _markers = {};
  bool _isRequesting = false;

  // Define the API key as a class-level variable
  final String apiKey = 'AIzaSyDJy-z1jRM7CZclV8dwcR-pBVXlNeYnrX0'; // Replace with your actual API key

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Function to fetch ETA using Google Maps Directions API
  Future<String> getETA(LatLng origin, LatLng destination, String apiKey) async {
    final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final duration = data['routes'][0]['legs'][0]['duration']['text']; // Extract duration from the response
      return duration;
    } else {
      throw Exception('Failed to fetch ETA');
    }
  }

  Future<void> _requestRide() async {
    setState(() {
      _isRequesting = true;
    });

    try {
      String eta = await getETA(_currentPosition, _dropOffPosition, apiKey);
      // Handle the ride request logic here (e.g., showing ETA)
      print("ETA: $eta");
    } catch (e) {
      print("Error fetching ETA: $e");
    }

    setState(() {
      _isRequesting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Ride'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 14.0,
              ),
              markers: _markers,
            ),
          ),
          _isRequesting
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _requestRide,
                  child: Text('Request Ride'),
                ),
        ],
      ),
    );
  }
}
