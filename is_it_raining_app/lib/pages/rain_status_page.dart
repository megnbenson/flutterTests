// lib/pages/rain_status_page.dart

import 'package:flutter/material.dart';
import 'package:is_it_raining/models/utils/weather_utils.dart';
import 'package:is_it_raining/pages/find_rain.dart';
import 'package:is_it_raining/pages/how_much.dart';
import 'package:is_it_raining/pages/why_use.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class RainStatusPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const RainStatusPage({
    super.key,
    required this.latitude,
    required this.longitude,
  });

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
    // print("check rain status: lon : $lo, lan: $la");
    // var la = widget.latitude;
    // var lo = widget.longitude;
    // print("meg just checking lon and lat: $la , $lo");
    bool isRaining = await WeatherUtils.isItRaining(
      widget.latitude,
      widget.longitude,
    );
    setState(() {
      rainStatus = isRaining ? "IT IS\n RAINING!" : "IT IS NOT\n RAINING!";
    });
    bgCol =
        isRaining
            ? Color.fromRGBO(110, 148, 245, 1)
            : Color.fromRGBO(255, 255, 255, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgCol,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: bgCol,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(
            //   rainStatus,
            //   style: TextStyle(fontFamily: 'MegFont', fontSize: 44),
            // ),
            if (rainStatus == "DETECTING...")
              SvgPicture.asset(
                'assets/images/DETECTING.svg',
                semanticsLabel: 'Is it raining',
                height: 100,
                width: 70,
              ),
            if (rainStatus == "DETECTING...")
              Image.asset(
                'assets/gifs/NB_Detecting_Cloud_Animation.gif',
                width: 250,
              ),

            // Show the button only if it is raining
            if (rainStatus == "IT IS\n RAINING!")
              SvgPicture.asset(
                'assets/images/IT_IS_RAINING!.svg',
                semanticsLabel: 'Is it raining!',
                height: 100,
                width: 70,
              ),

            if (rainStatus == "IT IS\n RAINING!")
              Image.asset(
                'assets/gifs/NB_It_is_Raining_Cloud_Animation.gif',
                width: 250,
              ),

            if (rainStatus == "IT IS\n RAINING!")
              ElevatedButton(
                onPressed: () {
                  // Navigate to the new GoHerePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => HowMuchPage(
                            latitude: widget.latitude,
                            longitude: widget.longitude,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Color.fromRGBO(52, 184, 255, 1)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Color.fromRGBO(52, 184, 255, 1),
                ),
                child: Text(
                  'STILL RAINING?',
                  style: GoogleFonts.jost(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (rainStatus == "IT IS\n RAINING!") SizedBox(height: 10),
            if (rainStatus == "IT IS\n RAINING!")
              ElevatedButton(
                onPressed: () {
                  // Navigate to the new GoHerePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => HowMuchPage(
                            longitude: widget.longitude,
                            latitude: widget.latitude,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Color.fromRGBO(52, 184, 255, 1)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Color.fromRGBO(52, 184, 255, 1),
                ),
                child: Text(
                  "NO IT ISN'T...",
                  style: GoogleFonts.jost(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            if (rainStatus == "IT IS NOT\n RAINING!")
              SvgPicture.asset(
                'assets/images/IT_IS_NOT_RAINING!.svg',
                semanticsLabel: 'It is not raining!',
                height: 100,
                width: 70,
              ),

            if (rainStatus == "IT IS NOT\n RAINING!")
              Image.asset('assets/gifs/cropped_Not_Raining.gif', width: 250),
            SizedBox(height: 20),

            if (rainStatus == "IT IS NOT\n RAINING!")
              ElevatedButton(
                onPressed: () {
                  // Navigate to the new GoHerePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // builder: (context) => HowMuchPage(longitude: widget.longitude, latitude: widget.latitude),
                      builder:
                          (context) => FindRainPage(
                            longitude: widget.longitude,
                            latitude: widget.latitude,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Color.fromRGBO(52, 184, 255, 1)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Color.fromRGBO(52, 184, 255, 1),
                ),
                child: Text(
                  'FIND RAIN?',
                  style: GoogleFonts.jost(color: Colors.white),
                ),
              ),
            if (rainStatus == "IT IS NOT\n RAINING!") SizedBox(height: 20),
            if (rainStatus == "IT IS NOT\n RAINING!")
              ElevatedButton(
                onPressed: () {
                  // Navigate to the new GoHerePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => HowMuchPage(
                            longitude: widget.longitude,
                            latitude: widget.latitude,
                          ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Color.fromRGBO(52, 184, 255, 1)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Color.fromRGBO(52, 184, 255, 1),
                ),
                child: Text(
                  "YES IT IS",
                  style: GoogleFonts.jost(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
