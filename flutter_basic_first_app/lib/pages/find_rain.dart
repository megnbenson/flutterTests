import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/utils/weather_utils.dart'; // Import WeatherUtils

class FindRainPage extends StatefulWidget {
    final double latitude;
  final double longitude;

  const FindRainPage({super.key, required this.latitude, required this.longitude});

  @override
  _FindRainPageState createState() => _FindRainPageState();
}

class _FindRainPageState extends State<FindRainPage> {
  String rainDirection = "Loading rain direction...";

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
    setState(() {
      rainDirection = direction;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
      ),
      body: Center(
        child: Text(
          rainDirection,
          style: GoogleFonts.jost(fontSize: 44),
        ),
      ),
    );
  }
}
