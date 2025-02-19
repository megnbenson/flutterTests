import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/utils/weather_utils.dart';

class FindRainPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const FindRainPage({super.key, required this.latitude, required this.longitude});

  @override
  _FindRainPageState createState() => _FindRainPageState();
}

class _FindRainPageState extends State<FindRainPage> {
  String rainDirection = "Loading rain direction...";
  double arrowAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _getRainDirection();
  }

  Future<void> _getRainDirection() async {
  var lo = widget.longitude;
  var la = widget.latitude;
  print("getRainDirection: lon : $lo, lat: $la");

  Map<String, String> result = await WeatherUtils.getRainDirection(widget.latitude, widget.longitude);

  String direction = result["direction"]!;
  String intensity = result["intensity"]!;

  double angle = 0.0;
  switch (direction) {
    case "Rain moving North":
      angle = 180.0; // Point South
      break;
    case "Rain moving South":
      angle = 0.0; // Point North
      break;
    case "Rain moving East":
      angle = 270.0; // Point West
      break;
    case "Rain moving West":
      angle = 90.0; // Point East
      break;
    default:
      angle = 0.0;
  }

  setState(() {
    rainDirection = "$direction ($intensity)";
    arrowAngle = angle;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("GO HERE", style: GoogleFonts.jost(fontSize: 44),),
            Text(
              rainDirection,
              style: GoogleFonts.jost(fontSize: 24),
            ),
            const SizedBox(height: 40),
            if (rainDirection != "Loading rain direction..." &&
                rainDirection != "No rain movement detected near you - sorry!" &&
                !rainDirection.startsWith("Error") &&
                !rainDirection.startsWith("Insufficient"))
              Transform.rotate(
                angle: arrowAngle * (pi / 180.0),
                child: CustomPaint(
                  size: const Size(120, 160),
                  painter: ArrowPainter(intensity: rainDirection.split('(').last.replaceAll(')', '').trim()),
                ),
              ),

          ],
        ),
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  final String intensity;

  ArrowPainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    Color arrowColor;
    switch (intensity) {
      case "Heavy Rain":
        arrowColor = Colors.red;
        break;
      case "Moderate Rain":
        arrowColor = Colors.orange;
        break;
      case "Light Rain":
        arrowColor = Colors.blue;
        break;
      default:
        arrowColor = Colors.black;
    }

    final paint = Paint()
      ..color = arrowColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 4.0;

    final path = Path();
    path.moveTo(size.width * 0.35, size.height * 0.8);
    path.lineTo(size.width * 0.65, size.height * 0.8);
    path.lineTo(size.width * 0.65, size.height * 0.4);
    path.lineTo(size.width * 0.8, size.height * 0.4);
    path.lineTo(size.width * 0.5, size.height * 0.2);
    path.lineTo(size.width * 0.2, size.height * 0.4);
    path.lineTo(size.width * 0.35, size.height * 0.4);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
