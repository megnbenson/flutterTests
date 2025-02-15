// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'rain_status_page.dart';
import '../widgets/weather_map_widget.dart'; // Import the WeatherMapWidget

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController latController =
      TextEditingController(text: "51.517398");
  final TextEditingController lonController =
      TextEditingController(text: "-0.059893");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'IS IT RAINING?',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
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
            SizedBox(height: 10),
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
            SizedBox(height: 20),
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
              child: Text('BEGIN'),
            ),
            SizedBox(height: 10), // Spacing between buttons
            ElevatedButton(
              onPressed: () {
                double lat = double.tryParse(latController.text) ?? 51.517398;
                double lon = double.tryParse(lonController.text) ?? -0.059893;

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
              child: Text('SEE MAP'),
            ),
          ],
        ),
      ),
    );
  }
}
