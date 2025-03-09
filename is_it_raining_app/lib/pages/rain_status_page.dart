// lib/pages/rain_status_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_basic_first_app/models/utils/weather_utils.dart';
import 'package:flutter_basic_first_app/pages/find_rain.dart';
import 'package:flutter_basic_first_app/pages/home_page.dart';
import 'package:flutter_basic_first_app/pages/why_use.dart';
import 'package:flutter_svg/svg.dart';

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
    // print("check rain status: lon : $lo, lan: $la");
    bool isRaining = await WeatherUtils.isItRaining(widget.latitude, widget.longitude);
    setState(() {
      rainStatus = isRaining ? "IT IS\n RAINING!" : "IT IS NOT\n RAINING!";
    });
    bgCol = isRaining ? Color.fromRGBO(110, 148, 245, 1) : Color.fromRGBO(206, 206, 205, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgCol,
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
      backgroundColor: bgCol,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(
            //   rainStatus,
            //   style: TextStyle(fontFamily: 'MegFont', fontSize: 44),
            // ),
            if(rainStatus == "DETECTING...")
              SvgPicture.asset( 
                'assets/images/DETECTING.svg', 
                semanticsLabel: 'Is it raining', 
                height: 100, 
                width: 70, 
              ),
            if(rainStatus == "DETECTING...")
              Image.asset('assets/gifs/NB_Detecting_Cloud_Animation.gif',width: 250,),

            
              
            // Show the button only if it is raining
            if(rainStatus == "IT IS\n RAINING!")
              SvgPicture.asset( 
                  'assets/images/IT_IS_RAINING!.svg', 
                  semanticsLabel: 'Is it raining!', 
                  height: 100, 
                  width: 70, 
                ),

            if(rainStatus == "IT IS\n RAINING!")
              Image.asset('assets/gifs/NB_It_is_Raining_Cloud_Animation.gif', width: 250),

            if(rainStatus == "IT IS\n RAINING!")
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
                  child: Text('STILL RAINING?', 
                  style: TextStyle(fontFamily: 'MegFont', color: Colors.white, fontSize: 24 ),
                  ),
                ),
            if(rainStatus == "IT IS\n RAINING!")
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the new GoHerePage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WhyUsePage(longitude: widget.longitude, latitude: widget.latitude),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(),
                    backgroundColor: Color.fromRGBO(52, 184, 255, 1)),
                  child: Text("NO IT ISN'T", 
              style: TextStyle(fontFamily: 'MegFont', color: Colors.white, fontSize: 24),
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
              Image.asset('assets/gifs/cropped_Not_Raining.gif', width: 250,),
                SizedBox(height: 20),
            
            if (rainStatus == "IT IS NOT\n RAINING!")
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
                child: Text('FIND RAIN?', 
              style: TextStyle(fontFamily: 'MegFont', color: Colors.white),
                ),
            ),
            if (rainStatus == "IT IS NOT\n RAINING!")
              SizedBox(height: 20),
            if (rainStatus == "IT IS NOT\n RAINING!")
              ElevatedButton(
                    onPressed: () {
                      // Navigate to the new GoHerePage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WhyUsePage(longitude: widget.longitude, latitude: widget.latitude),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(),
                      backgroundColor: Color.fromRGBO(52, 184, 255, 1)),
                    child: Text("YES IT IS", 
              style: TextStyle(fontFamily: 'MegFont', color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}