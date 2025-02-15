// lib/pages/rain_status_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_basic_first_app/models/utils/weather_utils.dart';
import 'package:flutter_basic_first_app/pages/find_rain.dart';
import '../widgets/weather_map_widget.dart';

class RainStatusPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const RainStatusPage({super.key, required this.latitude, required this.longitude});

  @override
  _RainStatusPageState createState() => _RainStatusPageState();
}

class _RainStatusPageState extends State<RainStatusPage> {
  String rainStatus = "Detecting...";

  @override
  void initState() {
    super.initState();
    checkRainStatus();
  }

  Future<void> checkRainStatus() async {
      await Future.delayed(Duration(seconds: 2));

    bool isRaining = await WeatherUtils.isItRaining(widget.latitude, widget.longitude);
    setState(() {
      rainStatus = isRaining ? "It is raining" : "It is not raining";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rain Status'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rainStatus,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Show the button only if it is raining
            if (rainStatus == "It is not raining")
              ElevatedButton(
                onPressed: () {
                  // Navigate to the new GoHerePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FindRainPage(),
                    ),
                  );
                },
                child: Text('Go Here'),
            ),
          ],
        ),
      ),
    );
  }
}