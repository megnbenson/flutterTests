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
                angle: arrowAngle * (3.141592653589793 / 180.0), // Convert degrees to radians
                child: CustomPaint(
                  size: const Size(120, 160), // Made the arrow larger
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
      ..color = Colors.black // Changed to black
      ..style = PaintingStyle.fill
      ..strokeWidth = 4.0;

    final path = Path();
    
    // Draw arrow body (wider shaft)
    path.moveTo(size.width * 0.35, size.height * 0.8); // Left bottom
    path.lineTo(size.width * 0.65, size.height * 0.8); // Right bottom
    path.lineTo(size.width * 0.65, size.height * 0.4); // Right before head
    path.lineTo(size.width * 0.8, size.height * 0.4); // Right edge before head
    path.lineTo(size.width * 0.5, size.height * 0.2); // Top point
    path.lineTo(size.width * 0.2, size.height * 0.4); // Left edge before head
    path.lineTo(size.width * 0.35, size.height * 0.4); // Left before head
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}