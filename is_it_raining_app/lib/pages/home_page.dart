// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'rain_status_page.dart';
import 'package:geolocator/geolocator.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController latController =
      TextEditingController(text: "55.9042"); //default lat 55.9042° N, 5.9414 //51.517398
  final TextEditingController lonController =
      TextEditingController(text: "-5.9414"); //default lon //-0.059893

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        leading: IconButton(
        icon: Icon(Icons.home),  // You can use Icons.arrow_back if you prefer
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
          );
        },
      ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'IS IT \n RAINING?',
              style: TextStyle(fontFamily: 'MegFont', fontSize: 44),
            ),
            Image.asset('../assets/gifs/NB_Home_Screen_Cloud_Animation.gif', width: 250,),
            // SizedBox(height: 0),
            ElevatedButton(
              onPressed: () {
                double lat = double.tryParse(latController.text) ?? 51.517398;
                double lon = double.tryParse(lonController.text) ?? -0.059893;

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
              backgroundColor: Color.fromRGBO(52, 184, 255, 1)),
              child: Text('BEGIN', 
              style: TextStyle(fontFamily: 'MegFont', color: Colors.white, fontSize: 24),
              ),
            ),
            SizedBox(height: 10), // Spacing between buttons
            // ElevatedButton(
            //   onPressed: () {
            //     double lat = double.tryParse(latController.text) ?? 51.517398;
            //     double lon = double.tryParse(lonController.text) ?? -0.059893;

            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => WeatherMapWidget(
            //           initialLatitude: lat,
            //           initialLongitude: lon,
            //         ),
            //       ),
            //     );
            //   },
            //   child: Text('SEE MAP'),
            // ),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 20),
            //   child: TextField(
            //     controller: latController,
            //     decoration: InputDecoration(
            //       labelText: 'Enter Latitude',
            //       border: OutlineInputBorder(),
            //     ),
            //     keyboardType: TextInputType.number,
            //   ),
            // ),
            // SizedBox(height: 10),
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 20),
            //   child: TextField(
            //     controller: lonController,
            //     decoration: InputDecoration(
            //       labelText: 'Enter Longitude',
            //       border: OutlineInputBorder(),
            //     ),
            //     keyboardType: TextInputType.number,
            //   ),
            // ),
            // SizedBox(height: 20),
            
          ],
        ),
      ),
    );
  }
}
