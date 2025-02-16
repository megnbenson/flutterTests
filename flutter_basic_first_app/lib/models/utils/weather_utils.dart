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
      int rainColorThreshold = 50;

      // Check for the rain color in the image (blue being the primary indicator)
      for (int y = 0; y < tileImage.height; y += 10) {
        for (int x = 0; x < tileImage.width; x += 10) {
          int pixel = tileImage.getPixel(x, y);
          int r = img.getRed(pixel);
          int g = img.getGreen(pixel);
          int b = img.getBlue(pixel);

          // If the blue component is significantly higher than red and green, it's likely rain
          if (b > r + rainColorThreshold && b > g + rainColorThreshold) {
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
  static Future<String> getRainDirection(double latitude, double longitude, {int zoomLevel = 10, int movementThreshold = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.rainviewer.com/public/weather-maps.json'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load weather data');
      }

      WeatherData weatherData = WeatherData.fromJson(json.decode(response.body));

      // Ensure we have both past and forecast data
      if (weatherData.past.isEmpty || weatherData.forecast.isEmpty) {
        print("insufficient data");
        return "Insufficient data to determine rain direction";
      }

      // Use the first past frame and the first future frame (forecast)
      WeatherFrame firstPastFrame = weatherData.past.first;
      WeatherFrame firstForecastFrame = weatherData.forecast.first;

      // Calculate the tile positions for both past and forecast frames
      int tileXPast = _getTileX(longitude, zoomLevel);
      int tileYPast = _getTileY(latitude, zoomLevel);
      int tileXForecast = _getTileX(longitude, zoomLevel);
      int tileYForecast = _getTileY(latitude, zoomLevel);

      // Retrieve tile images for both frames
      String pastTileUrl = '${weatherData.host}${firstPastFrame.path}/256/$zoomLevel/$tileXPast/$tileYPast/2/1_1.png';
      String forecastTileUrl = '${weatherData.host}${firstForecastFrame.path}/256/$zoomLevel/$tileXForecast/$tileYForecast/2/1_1.png';

      final pastTileResponse = await http.get(Uri.parse(pastTileUrl));
      final forecastTileResponse = await http.get(Uri.parse(forecastTileUrl));

      if (pastTileResponse.statusCode != 200 || forecastTileResponse.statusCode != 200) {
        throw Exception('Failed to load tile images');
      }

      img.Image pastTileImage = img.decodeImage(Uint8List.fromList(pastTileResponse.bodyBytes))!;
      img.Image forecastTileImage = img.decodeImage(Uint8List.fromList(forecastTileResponse.bodyBytes))!;

      // Calculate the shift in the rain pattern
      int width = pastTileImage.width;
      int height = pastTileImage.height;
      int totalShiftX = 0;
      int totalShiftY = 0;
      int comparisonPoints = 0;

      for (int y = 0; y < height; y += 10) {
        for (int x = 0; x < width; x += 10) {
          int pastPixel = pastTileImage.getPixel(x, y);
          int forecastPixel = forecastTileImage.getPixel(x, y);

          // Check if the pixel indicates rain (blue color)
          if (_isRainPixel(pastPixel) && _isRainPixel(forecastPixel)) {
            // Calculate the shift only if it's above the movement threshold
            int shiftX = (x - width / 2).abs() as int;
            int shiftY = (y - height / 2).abs() as int;

            if (shiftX > movementThreshold || shiftY > movementThreshold) {
              totalShiftX += (x - width / 2) as int;
              totalShiftY += (y - height / 2) as int;
              comparisonPoints++;
            }
          }
        }
      }

      if (comparisonPoints == 0) {
        return "No rain movement detected near you - sorry!";
      }

      // Calculate the direction
      double averageShiftX = totalShiftX / comparisonPoints;
      double averageShiftY = totalShiftY / comparisonPoints;

      if (averageShiftX.abs() > averageShiftY.abs()) {
        return averageShiftX > 0 ? "Rain moving East" : "Rain moving West";
      } else {
        return averageShiftY > 0 ? "Rain moving South" : "Rain moving North";
      }
    } catch (e) {
      print('Error determining rain direction: $e');
      return "Error calculating rain direction";
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
  static bool _isRainPixel(int pixel) {
    int r = img.getRed(pixel);
    int g = img.getGreen(pixel);
    int b = img.getBlue(pixel);

    // Simple condition where blue indicates rain
    return b > r + 50 && b > g + 50;
  }
}