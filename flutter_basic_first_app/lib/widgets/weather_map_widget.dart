// lib/widgets/weather_map_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/weather_data.dart';

class WeatherMapWidget extends StatefulWidget {
  const WeatherMapWidget({super.key});

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
        title: Text('Weather Radar'),
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
                center: LatLng(51.517398,-0.059893), // tower hamlets coordinates
                zoom: 6,//6
                // interactiveFlags:InteractionOptions(
                //   enableScrollWheel: true,
                //   enableMultiFingerGestureRace: true,
                // ),
              ),
              children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                    subdomains: ['a', 'b', 'c'],
                    maxZoom: 19,
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
          if (getCurrentFrame() != null)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Time: ${DateTime.fromMillisecondsSinceEpoch(getCurrentFrame()!.time * 1000)}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous),
                  onPressed: weatherData != null ? () {
                    setState(() {
                      currentFrameIndex = (currentFrameIndex - 1 + 
                          (weatherData!.past.length + weatherData!.forecast.length)) % 
                          (weatherData!.past.length + weatherData!.forecast.length);
                    });
                  } : null,
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: weatherData != null ? toggleAnimation : null,
                ),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: weatherData != null ? () {
                    setState(() {
                      currentFrameIndex = (currentFrameIndex + 1) % 
                          (weatherData!.past.length + weatherData!.forecast.length);
                    });
                  } : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}