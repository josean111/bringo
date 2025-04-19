import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;
import 'package:bringo/screens/home_screen.dart';
import 'package:bringo/screens/request_ride_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterConfig.loadEnv(); // Load config file
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bringo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/requestRide': (context) => RequestRideScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bringo - Ride Request'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to "Request a Ride" screen
            Navigator.pushNamed(context, '/requestRide');
          },
          child: Text('Request a Ride'),
        ),
      ),
    );
  }
}

class RequestRideScreen extends StatefulWidget {
  @override
  _RequestRideScreenState createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  late GoogleMapController mapController;
  late LatLng _currentPosition = LatLng(0.0, 0.0);
  bool _isLocationLoaded = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLocationLoaded = true;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Request Ride"),
      ),
      body: _isLocationLoaded
          ? GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 14.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('current_position'),
                  position: _currentPosition,
                  infoWindow: InfoWindow(title: 'Your Location'),
                ),
              },
            )
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Sample pick-up and drop-off locations
          LatLng dropOffLocation = LatLng(37.42796133580664, -122.085749655962);

          // Fetch API key from FlutterConfig
          String apiKey = FlutterConfig.get('google_maps_api_key');
          String eta = await getETA(_currentPosition, dropOffLocation, apiKey);

          // Pass ETA and Driver info to Confirmation screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RideConfirmationScreen(
                eta: eta,
                driverName: 'John Doe',
              ),
            ),
          );
        },
        child: Icon(Icons.add_location_alt),
        tooltip: 'Request Ride',
      ),
    );
  }

  Future<String> getETA(LatLng origin, LatLng destination, String apiKey) async {
    final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final duration = data['routes'][0]['legs'][0]['duration']['text'];
      return duration;
    } else {
      throw Exception('Failed to fetch ETA');
    }
  }
}

class RideConfirmationScreen extends StatelessWidget {
  final String eta;
  final String driverName;

  RideConfirmationScreen({required this.eta, required this.driverName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ride Confirmation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Driver: $driverName", style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text("Estimated Time of Arrival (ETA): $eta", style: TextStyle(fontSize: 18)),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Confirm the ride logic here, possibly saving it to Firebase or something
              },
              child: Text("Confirm Ride"),
            ),
          ],
        ),
      ),
    );
  }
}
