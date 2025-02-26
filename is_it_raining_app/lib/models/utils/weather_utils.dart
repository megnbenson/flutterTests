import 'dart:math';
import 'package:flutter_basic_first_app/models/weather_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class WeatherUtils {
  static Future<bool> isItRaining(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.rainviewer.com/public/weather-maps.json'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load weather data');
      }

      WeatherData weatherData = WeatherData.fromJson(json.decode(response.body));

      // Check if past data is available
      if (weatherData.past.isEmpty) {
        return false; // No past data available
      }

      // Use the first past frame instead of the last
      WeatherFrame firstFrame = weatherData.past.first;

      // Retrieve the tile image based on the first past frame
      int zoomLevel = 17;
      int tileX = ((longitude + 180.0) / 360.0 * (1 << zoomLevel)).toInt();
      int tileY = ((1 -
                  (log(tan(latitude * (3.141592653589793 / 180.0)) +
                          1.0 /
                              cos(latitude * (3.141592653589793 / 180.0))) /
                      3.141592653589793)) /
              2.0 *
          (1 << zoomLevel))
          .toInt();

      String tileUrl =
          '${weatherData.host}${firstFrame.path}/256/$zoomLevel/$tileX/$tileY/2/1_1.png';

      final tileResponse = await http.get(Uri.parse(tileUrl));

      if (tileResponse.statusCode != 200) {
        throw Exception('Failed to load tile image');
      }

      img.Image tileImage = img.decodeImage(Uint8List.fromList(tileResponse.bodyBytes))!;

      // Define a threshold for identifying rain based on color (e.g., blue indicates rain)
      int rainColorThreshold = 25;

      // Check for the rain color in the image (blue being the primary indicator)
      for (int y = 0; y < tileImage.height; y += 10) {
        for (int x = 0; x < tileImage.width; x += 10) {
          // Get pixel color components using the updated API
          img.Pixel pixel = tileImage.getPixel(x, y);
          num r = pixel.r;
          num g = pixel.g;
          num b = pixel.b;

          print("r: $r, g: $g, b: $b");
          // If the blue component is significantly higher than red and green, it's likely rain
          if (b > r + rainColorThreshold && b > g + rainColorThreshold) {
            print("true!!!!!");
            return true; // It is raining
          }
        }
      }

      return false; // It is not raining
    } catch (e) {
      print('Error checking rain status: $e');
      return false;
    }
  }

   // New method to calculate the direction of rain
  static Future<Map<String, String>> getRainDirection(double latitude, double longitude) async {
    try {
      final response = await http.get(Uri.parse('https://api.rainviewer.com/public/weather-maps.json'));
      if (response.statusCode != 200) throw Exception('Failed to load weather data');

      WeatherData weatherData = WeatherData.fromJson(json.decode(response.body));
      if (weatherData.past.isEmpty || weatherData.forecast.isEmpty) return {"direction": "Insufficient data", "intensity": "Unknown"};

      WeatherFrame firstPastFrame = weatherData.past.first;
      WeatherFrame firstForecastFrame = weatherData.forecast.first;

      int zoomLevel = 10;
      int tileX = _getTileX(longitude, zoomLevel);
      int tileY = _getTileY(latitude, zoomLevel);

      String pastTileUrl = '${weatherData.host}${firstPastFrame.path}/256/$zoomLevel/$tileX/$tileY/2/1_1.png';
      String forecastTileUrl = '${weatherData.host}${firstForecastFrame.path}/256/$zoomLevel/$tileX/$tileY/2/1_1.png';

      final pastTileResponse = await http.get(Uri.parse(pastTileUrl));
      final forecastTileResponse = await http.get(Uri.parse(forecastTileUrl));

      if (pastTileResponse.statusCode != 200 || forecastTileResponse.statusCode != 200) {
        throw Exception('Failed to load tile images');
      }

      img.Image pastTileImage = img.decodeImage(Uint8List.fromList(pastTileResponse.bodyBytes))!;
      img.Image forecastTileImage = img.decodeImage(Uint8List.fromList(forecastTileResponse.bodyBytes))!;

      // Use both past & forecast images to determine direction
      var stormDataPast = getStormCenter(pastTileImage);
      var stormDataForecast = getStormCenter(forecastTileImage);

      if (stormDataPast["centerX"] == null || stormDataForecast["centerX"] == null) {
        return {"direction": "No rain detected", "intensity": "None"};
      }

      String direction = getArrowDirection(
        stormDataPast["centerX"], stormDataPast["centerY"], 
        stormDataForecast["centerX"], stormDataForecast["centerY"]
      );

      String intensity = stormDataForecast["intensity"] > 0.2 ? "Heavy Rain" 
                        : stormDataForecast["intensity"] > 0.05 ? "Moderate Rain" 
                        : "Light Rain";

      return {"direction": direction, "intensity": intensity};
    } catch (e) {
      print('Error determining rain direction: $e');
      return {"direction": "Error", "intensity": "Unknown"};
    }
  }

  // Helper method to calculate the tile X position based on longitude and zoom level
  static int _getTileX(double longitude, int zoomLevel) {
    return ((longitude + 180.0) / 360.0 * (1 << zoomLevel)).toInt();
  }

  // Helper method to calculate the tile Y position based on latitude and zoom level
  static int _getTileY(double latitude, int zoomLevel) {
    return ((1 - (log(tan(latitude * (3.141592653589793 / 180.0)) + 1.0 / cos(latitude * (3.141592653589793 / 180.0))) / 3.141592653589793)) / 2.0 * (1 << zoomLevel)).toInt();
  }

  // Helper method to check if a pixel represents rain (based on color)
  static bool _isRainPixel(img.Pixel pixel) {
    num r = pixel.r;
    num g = pixel.g;
    num b = pixel.b;

    // Simple condition where blue indicates rain
    return b > r + 50 && b > g + 50;
  }
  
  static Map<String, dynamic> getStormCenter(img.Image tileImage) {
    int width = tileImage.width;
    int height = tileImage.height;
    int totalX = 0, totalY = 0, rainPixels = 0;
    double intensitySum = 0.0;

    for (int y = 0; y < height; y += 5) { // Sample every 5 pixels
      for (int x = 0; x < width; x += 5) {
        img.Pixel pixel = tileImage.getPixel(x, y);
        if (_isRainPixel(pixel)) {
          totalX += x;
          totalY += y;
          rainPixels++;
          intensitySum += pixel.b / 255.0; // Normalize intensity
        }
      }
    }

    if (rainPixels == 0) return {"centerX": null, "centerY": null, "intensity": 0.0};

    return {
      "centerX": totalX ~/ rainPixels,
      "centerY": totalY ~/ rainPixels,
      "intensity": intensitySum / rainPixels
    };
  }

  static String getArrowDirection(int pastX, int pastY, int futureX, int futureY) {
    int dx = futureX - pastX;
    int dy = futureY - pastY;

    if (dx.abs() > dy.abs()) {
      return dx > 0 ? "Rain moving East" : "Rain moving West";
    } else {
      return dy > 0 ? "Rain moving South" : "Rain moving North";
    }
  }
}