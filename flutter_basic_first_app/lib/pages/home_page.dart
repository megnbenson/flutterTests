// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_basic_first_app/pages/rain_status_page.dart';
import 'package:flutter_basic_first_app/widgets/weather_map_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RainStatusPage()),
                );
              },
              child: Text('BEGIN'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeatherMapWidget()),
                );
              },
              child: Text('See map'),
            ),
          ],
        ),
      ),
    );
  }
}