import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_basic_first_app/pages/home_page.dart';
import 'package:flutter_svg/svg.dart';
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
      angle = Random().nextDouble() * 90;
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
        leading: IconButton(
        icon: Icon(Icons.home),  // You can use Icons.arrow_back if you prefer
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
          );
        },
      ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset( 
                    'assets/images/GO_HERE.svg', 
                    semanticsLabel: 'Go here', 
                    height: 100, 
                    width: 70, 
                  ),
            // Text("GO HERE", 
            //   style: TextStyle(fontFamily: 'MegFont', fontSize: 44),
            // ),
            Text(
              "DEBUGMODE: $rainDirection",
              style: TextStyle(fontFamily: 'MegFont', fontSize: 24),
            ),
            // const SizedBox(height: 10),
            Transform.rotate(
                angle: arrowAngle * (pi / 180.0),
                child: Container(
                  padding: const EdgeInsets.all(0.5),
                  // color:  const Color(0xFFE8581C),
                  child: Image.asset('assets/gifs/Arrow_cropped.gif', width: 50)
                  ),
                ),
              // Transform.rotate(
              //   angle: arrowAngle * (pi / 180.0),
              //   child: Container(
              //     padding: const EdgeInsets.all(0.2),
              //     // color:  const Color(0xFFE8581C),
              //     child:  
              //       CustomPaint(
              //         size: const Size(120, 160),
              //         painter: ArrowPainter(intensity: rainDirection.split('(').last.replaceAll(')', '').trim()),
              //       ),
              //     ),
              //   ),
              Image.asset('assets/gifs/full_cup.gif', width: 100)
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
