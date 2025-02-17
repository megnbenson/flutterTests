// lib/models/weather_data.dart
class WeatherFrame {
  final int time;
  final String path;

  WeatherFrame({required this.time, required this.path});

  factory WeatherFrame.fromJson(Map<String, dynamic> json) {
    return WeatherFrame(
      time: json['time'],
      path: json['path'],
    );
  }
}

class WeatherData {
  final String host;
  final List<WeatherFrame> past;
  final List<WeatherFrame> forecast;

  WeatherData({
    required this.host,
    required this.past,
    required this.forecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      host: json['host'],
      past: (json['radar']['past'] as List)
          .map((frame) => WeatherFrame.fromJson(frame))
          .toList(),
      forecast: (json['radar']['nowcast'] as List)
          .map((frame) => WeatherFrame.fromJson(frame))
          .toList(),
    );
  }
}