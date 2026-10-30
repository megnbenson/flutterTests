import 'dart:async';
import 'dart:math';
import 'package:is_it_raining/models/weather_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image/image.dart' as img;

class RainTarget {
  final double bearingDegrees;
  final double distanceKilometers;

  const RainTarget({
    required this.bearingDegrees,
    required this.distanceKilometers,
  });
}

class WeatherUtils {
  static Future<bool> isItRaining(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.rainviewer.com/public/weather-maps.json'),
        headers: {'User-Agent': 'IsItRainingApp/1.0'},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to load weather data');
      }

      final weatherData = WeatherData.fromJson(json.decode(response.body));
      if (weatherData.past.isEmpty) return false;

      const zoomLevel = 10;
      final tileX = ((longitude + 180) / 360 * (1 << zoomLevel)).floor();
      final latitudeRadians = latitude * pi / 180;
      final tileY =
          ((1 - log(tan(latitudeRadians) + 1 / cos(latitudeRadians)) / pi) /
                  2 *
                  (1 << zoomLevel))
              .floor();
      final frame = weatherData.past.first;
      final tileUrl =
          '${weatherData.host}${frame.path}/256/$zoomLevel/$tileX/$tileY/2/1_1.png';
      final tileResponse = await http
          .get(
            Uri.parse(tileUrl),
            headers: {'User-Agent': 'IsItRainingApp/1.0'},
          )
          .timeout(const Duration(seconds: 10));
      if (tileResponse.statusCode != 200) {
        throw Exception('Failed to load tile image');
      }

      final tileImage = img.decodeImage(tileResponse.bodyBytes);
      if (tileImage == null) throw Exception('Failed to decode tile image');

      for (var y = 0; y < tileImage.height; y += 10) {
        for (var x = 0; x < tileImage.width; x += 10) {
          final pixel = tileImage.getPixel(x, y);
          if (pixel.b > pixel.r + 25 && pixel.b > pixel.g + 25) return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<RainTarget?> getNearestRain(
    double latitude,
    double longitude,
  ) async {
    final metadataResponse = await http
        .get(Uri.parse('https://api.rainviewer.com/public/weather-maps.json'))
        .timeout(const Duration(seconds: 10));
    if (metadataResponse.statusCode != 200) {
      throw Exception('Failed to load radar metadata');
    }

    final weatherData = WeatherData.fromJson(
      json.decode(metadataResponse.body),
    );
    if (weatherData.past.isEmpty) return null;

    const zoomLevel = 10;
    const tileSize = 256;
    final tileCount = 1 << zoomLevel;
    final worldPixelSize = tileCount * tileSize;
    final normalizedLongitude = ((longitude + 180) % 360 + 360) % 360 - 180;
    final latitudeForProjection =
        latitude.clamp(-85.05112878, 85.05112878).toDouble();
    final latitudeRadians = latitudeForProjection * pi / 180;
    final globalPixelX = (normalizedLongitude + 180) / 360 * worldPixelSize;
    final globalPixelY =
        (0.5 -
            log((1 + sin(latitudeRadians)) / (1 - sin(latitudeRadians))) /
                (4 * pi)) *
        worldPixelSize;
    final centerTileX = (globalPixelX / tileSize).floor();
    final centerTileY = (globalPixelY / tileSize).floor();
    final localPixelX = globalPixelX - centerTileX * tileSize;
    final localPixelY = globalPixelY - centerTileY * tileSize;
    final frame = weatherData.past.last;

    final tileOffsets = <(int, int)>[
      for (var yOffset = -1; yOffset <= 1; yOffset++)
        for (var xOffset = -1; xOffset <= 1; xOffset++) (xOffset, yOffset),
    ];
    final tileResponses = await Future.wait(
      tileOffsets.map((offset) async {
        final xOffset = offset.$1;
        final yOffset = offset.$2;
        final tileY = centerTileY + yOffset;
        if (tileY < 0 || tileY >= tileCount) return null;

        final tileX =
            ((centerTileX + xOffset) % tileCount + tileCount) % tileCount;
        final tileUrl =
            '${weatherData.host}${frame.path}/$tileSize/$zoomLevel/$tileX/$tileY/2/1_1.png';
        try {
          final response = await http
              .get(Uri.parse(tileUrl))
              .timeout(const Duration(seconds: 10));
          return response.statusCode == 200 ? response : null;
        } catch (_) {
          return null;
        }
      }),
    );

    var successfulTiles = 0;
    var nearestDistanceSquared = double.infinity;
    var nearestDx = 0.0;
    var nearestDy = 0.0;

    for (var index = 0; index < tileResponses.length; index++) {
      final response = tileResponses[index];
      if (response == null) continue;

      final tileImage = img.decodeImage(response.bodyBytes);
      if (tileImage == null) continue;
      successfulTiles++;

      final offset = tileOffsets[index];
      for (var y = 0; y < tileImage.height; y += 4) {
        for (var x = 0; x < tileImage.width; x += 4) {
          final pixel = tileImage.getPixel(x, y);
          if (!_isRainPixel(pixel)) continue;

          final dx = offset.$1 * tileSize + x + 0.5 - localPixelX;
          final dy = offset.$2 * tileSize + y + 0.5 - localPixelY;
          final distanceSquared = dx * dx + dy * dy;
          if (distanceSquared < nearestDistanceSquared) {
            nearestDistanceSquared = distanceSquared;
            nearestDx = dx;
            nearestDy = dy;
          }
        }
      }
    }

    if (successfulTiles == 0) throw Exception('Failed to load radar tiles');
    if (nearestDistanceSquared == double.infinity) return null;

    final bearing =
        nearestDistanceSquared == 0
            ? 0.0
            : (atan2(nearestDx, -nearestDy) * 180 / pi + 360) % 360;
    final distanceKilometers =
        sqrt(nearestDistanceSquared) *
        40075.017 *
        cos(latitudeRadians) /
        worldPixelSize;

    return RainTarget(
      bearingDegrees: bearing,
      distanceKilometers: distanceKilometers,
    );
  }

  static bool _isRainPixel(img.Pixel pixel) {
    return pixel.a > 0;
  }
}
