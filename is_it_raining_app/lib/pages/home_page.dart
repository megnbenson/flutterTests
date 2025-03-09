// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_basic_first_app/widgets/weather_map_widget.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'rain_status_page.dart';
import 'package:geolocator/geolocator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Default coordinates to use as fallback
  //MEG LON AND LAT SET HERE
  final double defaultLat = 46.580002;
  final double defaultLon = -0.340000;

  final TextEditingController latController = TextEditingController();
  final TextEditingController lonController = TextEditingController();

  // Location state variables
  bool isLoading = false;
  String locationStatus = '';
  bool isDebugMode = false; // 🔹 Toggleable debug mode

  @override
  void initState() {
    super.initState();
    latController.text = defaultLat.toString();  // ✅ Initialize after instance is created
    lonController.text = defaultLon.toString();
  }

  @override
  void dispose() {
    latController.dispose(); // ✅ Clean up controllers when widget is disposed
    lonController.dispose();
    super.dispose();
  }

  Future<Position?> getUserLocation() async {
    setState(() {
      isLoading = true;
      locationStatus = 'Getting location...';
    });
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          locationStatus = 'Location services disabled';
          isLoading = false;
        });
        return null;
      }
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            locationStatus = 'Location permission denied';
            isLoading = false;
          });
          return null;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          locationStatus = 'Location permissions permanently denied';
          isLoading = false;
        });
        return null;
      }
      
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      setState(() {
        locationStatus = 'Location obtained';
        isLoading = false;
      });
      
      return position;
    } catch (e) {
      setState(() {
        locationStatus = 'Error: $e';
        isLoading = false;
      });
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
            );
          },
        ),
        actions: [
          Row(
            children: [
              Text("Debug", style: GoogleFonts.jost(fontSize: 16, color: Colors.black)),
              Switch(
                value: isDebugMode,
                onChanged: (value) {
                  setState(() {
                    isDebugMode = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset( 
              'assets/images/IS_IT_RAINING.svg', 
              semanticsLabel: 'Is it raining', 
              height: 100, 
              width: 70, 
            ),
            Image.asset('assets/gifs/NB_Home_Screen_Cloud_Animation.gif', width: 250),
            if (isLoading) 
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(52, 184, 255,
                 1)),
              ),
            if (locationStatus.isNotEmpty && !isLoading)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  locationStatus,
                  style: GoogleFonts.jost(fontSize: 14, color: Colors.grey),
                ),
              ),
            ElevatedButton(
              onPressed: () async {
                  double lat =  defaultLat;
                  double lon =  defaultLon;

                if(!isDebugMode){
                  Position? position = await getUserLocation();
                  lat = position?.latitude ?? defaultLat;
                  lon = position?.longitude ?? defaultLon;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RainStatusPage(latitude: lat, longitude: lon),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(),
                backgroundColor: Color.fromRGBO(52, 184, 255, 1)
              ),
              child: Text(
                'BEGIN',
                style: GoogleFonts.jost(color: Colors.white, fontSize: 24),
              ),
            ),
            if(isDebugMode)
                SizedBox(height: 10),
            if (isDebugMode)
              ElevatedButton(
                onPressed: () async {
                  double lat =  defaultLat;
                  double lon =  defaultLon;

                if(!isDebugMode){
                  Position? position = await getUserLocation();
                  lat = position?.latitude ?? defaultLat;
                  lon = position?.longitude ?? defaultLon;
                }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WeatherMapWidget(
                        initialLatitude: lat,
                        initialLongitude: lon,
                      ),
                    ),
                  );
                },
                child: Text('SEE MAP', style: GoogleFonts.jost(),),
              ),
              if(isDebugMode)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: latController,
                    decoration: InputDecoration(
                      labelText: 'Enter Latitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              if(isDebugMode)
                SizedBox(height: 10),
              if(isDebugMode)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: lonController,
                    decoration: InputDecoration(
                      labelText: 'Enter Longitude',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}