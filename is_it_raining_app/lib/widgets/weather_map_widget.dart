// lib/widgets/weather_map_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/weather_data.dart';

class WeatherMapWidget extends StatefulWidget {
  final double initialLatitude;
  final double initialLongitude;

  const WeatherMapWidget({super.key, required this.initialLatitude, required this.initialLongitude});

  @override
  _WeatherMapWidgetState createState() => _WeatherMapWidgetState();
}

class _WeatherMapWidgetState extends State<WeatherMapWidget> {
  WeatherData? weatherData;
  int currentFrameIndex = 0;
  Timer? animationTimer;
  bool isPlaying = false;
  final mapController = MapController();

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  @override
  void dispose() {
    animationTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchWeatherData() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.rainviewer.com/public/weather-maps.json'),
      );

      if (response.statusCode == 200) {
        setState(() {
          weatherData = WeatherData.fromJson(json.decode(response.body));
          currentFrameIndex = weatherData!.past.length - 1;
        });
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
    }
  }

  void toggleAnimation() {
    setState(() {
      if (isPlaying) {
        animationTimer?.cancel();
      } else {
        animationTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
          setState(() {
            currentFrameIndex = (currentFrameIndex + 1) %
                (weatherData!.past.length + weatherData!.forecast.length);
          });
        });
      }
      isPlaying = !isPlaying;
    });
  }

  WeatherFrame? getCurrentFrame() {
    if (weatherData == null) return null;

    if (currentFrameIndex < weatherData!.past.length) {
      return weatherData!.past[currentFrameIndex];
    } else {
      return weatherData!.forecast[currentFrameIndex - weatherData!.past.length];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
                // backgroundColor: Colors.amberAccent,
        actions: [
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: weatherData != null ? toggleAnimation : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(widget.initialLatitude, widget.initialLongitude), // Use passed lat/lon
                initialZoom: 17.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                if (weatherData != null && getCurrentFrame() != null)
                  Opacity(
                    opacity: 0.7,
                    child: TileLayer(
                      urlTemplate: '${weatherData!.host}${getCurrentFrame()!.path}/256/{z}/{x}/{y}/2/1_1.png',
                      maxZoom: 19,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
