// lib/pages/rain_status_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_basic_first_app/models/utils/weather_utils.dart';
import 'package:flutter_basic_first_app/pages/find_rain.dart';
import 'package:google_fonts/google_fonts.dart';

class RainStatusPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const RainStatusPage({super.key, required this.latitude, required this.longitude});

  @override
  _RainStatusPageState createState() => _RainStatusPageState();
}

class _RainStatusPageState extends State<RainStatusPage> {
  String rainStatus = "DETECTING...";
  Color bgCol = Colors.amberAccent;

  @override
  void initState() {
    super.initState();
    checkRainStatus();
  }

  Future<void> checkRainStatus() async {
      await Future.delayed(Duration(seconds: 2));
    var lo = widget.longitude;
    var la = widget.latitude;
    print("check rain status: lon : $lo, lan: $la");
    bool isRaining = await WeatherUtils.isItRaining(widget.latitude, widget.longitude);
    setState(() {
      rainStatus = isRaining ? "IT IS RAINING" : "IT IS NOT\n RAINING";
    });
    bgCol = isRaining ? Color.fromRGBO(84, 152, 255, 1) : Colors.amberAccent;
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
              rainStatus,
              style: GoogleFonts.jost(fontSize: 44),
            ),
            SizedBox(height: 90),
            // Show the button only if it is raining
            if(rainStatus == "IT IS RAINING")
              ElevatedButton(
                onPressed: () {
                  // Navigate to the new GoHerePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FindRainPage(longitude: widget.longitude, latitude: widget.latitude),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(),
                  backgroundColor: Color.fromRGBO(52, 184, 255, 1)),
                child: Text('STILL RAINING?', style: GoogleFonts.jost(color: Colors.white)),
              ),
            if (rainStatus == "IT IS NOT\n RAINING")
              ElevatedButton(
                onPressed: () {
                  // Navigate to the new GoHerePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FindRainPage(longitude: widget.longitude, latitude: widget.latitude),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(),
                  backgroundColor: Color.fromRGBO(52, 184, 255, 1)),
                child: Text('FIND RAIN?', style: GoogleFonts.jost(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}