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

      if (weatherData.past.isEmpty && weatherData.forecast.isEmpty) {
        return false;
      }

      int zoomLevel = 6;
      int tileX = ((longitude + 180.0) / 360.0 * (1 << zoomLevel)).toInt();
      int tileY = ((1 -
                  (log(tan(latitude * (3.141592653589793 / 180.0)) +
                          1.0 /
                              cos(latitude * (3.141592653589793 / 180.0))) /
                      3.141592653589793)) /
              2.0 *
          (1 << zoomLevel))
          .toInt();

      WeatherFrame currentFrame = weatherData.past.last;

      String tileUrl =
          '${weatherData.host}${currentFrame.path}/256/$zoomLevel/$tileX/$tileY/2/1_1.png';

      final tileResponse = await http.get(Uri.parse(tileUrl));

      if (tileResponse.statusCode != 200) {
        throw Exception('Failed to load tile image');
      }

      img.Image tileImage = img.decodeImage(Uint8List.fromList(tileResponse.bodyBytes))!;

      int rainColorThreshold = 50;

      for (int y = 0; y < tileImage.height; y += 10) {
        for (int x = 0; x < tileImage.width; x += 10) {
          int pixel = tileImage.getPixel(x, y);
          int r = img.getRed(pixel);
          int g = img.getGreen(pixel);
          int b = img.getBlue(pixel);

          if (b > r + rainColorThreshold && b > g + rainColorThreshold) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      print('Error checking rain status: $e');
      return false;
    }
  }
}
