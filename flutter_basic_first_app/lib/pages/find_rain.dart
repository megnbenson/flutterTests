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
    print("getRainDirection: lon : $lo, lan: $la");
    String direction = await WeatherUtils.getRainDirection(widget.latitude, widget.longitude);
    
    // Calculate the opposite angle based on the rain direction
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
      rainDirection = direction;
      arrowAngle = angle;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rainDirection,
              style: GoogleFonts.jost(fontSize: 44),
            ),
            const SizedBox(height: 40),
            if (rainDirection != "Loading rain direction..." &&
                rainDirection != "No rain movement detected near you - sorry!" &&
                !rainDirection.startsWith("Error") &&
                !rainDirection.startsWith("Insufficient"))
              Transform.rotate(
                angle: arrowAngle * (3.141592653589793 / 180.0), // Convert degrees to radians
                child: CustomPaint(
                  size: const Size(100, 100),
                  painter: ArrowPainter(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill
      ..strokeWidth = 4.0;

    final path = Path();
    
    // Draw arrow shaft
    path.moveTo(size.width * 0.5, size.height * 0.8); // Start at bottom
    path.lineTo(size.width * 0.5, size.height * 0.2); // Line to top
    
    // Draw arrow head
    path.moveTo(size.width * 0.2, size.height * 0.4); // Left point
    path.lineTo(size.width * 0.5, size.height * 0.2); // Top point
    path.lineTo(size.width * 0.8, size.height * 0.4); // Right point
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}