// lib/pages/rain_status_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_basic_first_app/models/utils/weather_utils.dart';
import '../widgets/weather_map_widget.dart';

class RainStatusPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const RainStatusPage({super.key, required this.latitude, required this.longitude});

  @override
  _RainStatusPageState createState() => _RainStatusPageState();
}

class _RainStatusPageState extends State<RainStatusPage> {
  String rainStatus = "Checking...";

  @override
  void initState() {
    super.initState();
    checkRainStatus();
  }

  Future<void> checkRainStatus() async {
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
        child: Text(
          rainStatus,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
