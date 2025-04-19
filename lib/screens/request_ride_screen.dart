import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;

class RequestRideScreen extends StatefulWidget {
  @override
  _RequestRideScreenState createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  late GoogleMapController mapController;
  late LatLng _currentPosition = LatLng(37.42796133580664, -122.085749655962); // Default to Googleplex location
  late LatLng _dropOffPosition = LatLng(37.42796133580664, -122.085749655962);
  Set<Marker> _markers = {};
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    await FlutterConfig.load();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _requestRide() async {
    setState(() {
      _isRequesting = true;
    });

    String apiKey = FlutterConfig.get('google_maps_api_key');
    String eta = await getETA(_currentPosition, _dropOffPosition, apiKey);
    
    // Handle ride request logic here (e.g., API call to request a ride, etc.)
    print("ETA: $eta");

    setState(() {
      _isRequesting = false;
    });
  }

  Future<String> getETA(LatLng origin, LatLng destination, String apiKey) async {
    String url = "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey";
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Process ETA data from the response
        return "5 mins"; // Return mock ETA (you can parse the real response here)
      } else {
        throw Exception('Failed to load ETA');
      }
    } catch (e) {
      print(e);
      return "Error fetching ETA";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Request Ride'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 14.0,
              ),
              markers: _markers,
              onTap: (LatLng location) {
                setState(() {
                  _dropOffPosition = location;
                  _markers = {
                    Marker(
                      markerId: MarkerId('dropoff'),
                      position: _dropOffPosition,
                      infoWindow: InfoWindow(title: 'Dropoff Location'),
                    ),
                  };
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _isRequesting ? null : _requestRide,
              child: _isRequesting
                  ? CircularProgressIndicator()
                  : Text("Request Ride"),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 16.0),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
