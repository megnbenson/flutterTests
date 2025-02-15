import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data'; // For handling image data
import 'package:image/image.dart' as img; // Image package for processing
import '../models/weather_data.dart';
import 'dart:math';

class WeatherMapWidget extends StatefulWidget {
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

  // Convert latitude and longitude to tile coordinates
  int getTileX(double longitude, int zoom) {
    return ((longitude + 180.0) / 360.0 * (1 << zoom)).toInt();
  }

  int getTileY(double latitude, int zoom) {
      double latRad = latitude * (3.141592653589793 / 180.0);
    return ((1 - (log(tan(latRad) + 1.0 / cos(latRad)) / 3.141592653589793)) / 2.0 * (1 << zoom)).toInt();
  }

  // Function to download the tile image
  Future<img.Image> downloadTileImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      return img.decodeImage(Uint8List.fromList(bytes))!;
    } else {
      throw Exception('Failed to load image');
    }
  }

  // Function to check if a tile contains rain by analyzing its color
  bool isTileRainy(img.Image image) {
    int rainColorThreshold = 50; // You may need to adjust this value based on the actual radar colors

    // Loop through the pixels of the image
    for (int y = 0; y < image.height; y += 10) {  // Sampling every 10 pixels, for performance
      for (int x = 0; x < image.width; x += 10) {
        int pixel = image.getPixel(x, y); // Get the color at (x, y)

        int r = img.getRed(pixel);  // Red component of the pixel
        int g = img.getGreen(pixel);  // Green component of the pixel
        int b = img.getBlue(pixel);  // Blue component of the pixel

        // Check if the pixel is more blue-ish than the red and green values
        if (b > r + rainColorThreshold && b > g + rainColorThreshold) {
          return true;  // It’s likely rain!
        }
      }
    }

    return false;  // No rain detected
  }


  // Function to check if it is raining at a given latitude and longitude
  Future<bool> isItRaining(double latitude, double longitude) async {
    if (weatherData == null) return false;

    // Get the tile coordinates for the given lat/lon
    int zoomLevel = 6; // You can adjust the zoom level as needed
    int tileX = getTileX(longitude, zoomLevel);
    int tileY = getTileY(latitude, zoomLevel);

    // Get the current radar frame and its tile URL
    WeatherFrame? currentFrame = getCurrentFrame();
    if (currentFrame == null) return false;

    // Generate the URL for the radar tile
    String tileUrl = '${weatherData!.host}${currentFrame.path}/256/$zoomLevel/$tileX/$tileY/2/1_1.png';

    // Download the tile image
    try {
      img.Image tileImage = await downloadTileImage(tileUrl);

      // Check if the tile has rain based on its color
      return isTileRainy(tileImage);
    } catch (e) {
      print('Error downloading or processing tile image: $e');
      return false;
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
                center: LatLng(51.752022, -1.257677), //51.517398, -0.059893), // tower hamlets coordinates
                zoom: 17, // Zoom level
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
                ElevatedButton(
                  onPressed: () async {
                    // Test for rain at a given lat/lon (e.g., Tower Hamlets)
                    double lat = 51.517398;
                    double lon = -0.059893;
                    bool raining = await isItRaining(lat, lon);
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('Rain Check'),
                        content: Text(raining ? 'It is raining!' : 'No rain detected.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('Check if it\'s raining'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
