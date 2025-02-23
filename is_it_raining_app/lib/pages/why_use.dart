import 'package:flutter/material.dart';
import 'package:flutter_basic_first_app/pages/find_rain.dart';
import 'package:flutter_basic_first_app/pages/rain_status_page.dart';
import 'package:google_fonts/google_fonts.dart';

class WhyUsePage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const WhyUsePage({super.key, required this.latitude, required this.longitude});

  @override
  _WhyUsePageState createState() => _WhyUsePageState();
}

class _WhyUsePageState extends State<WhyUsePage> {
  String rainDirection = "Loading rain direction...";
  double arrowAngle = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
      ),
      backgroundColor: Colors.amberAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "WHY ARE YOU\n EVEN USING\n THIS APP... ",
              style: TextStyle(fontFamily: 'MegFont', fontSize: 44),
            ),
                Image.asset('../assets/images/cat.gif', width: 300,),
                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the new GoHerePage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RainStatusPage(longitude: widget.longitude, latitude: widget.latitude),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(),
                    backgroundColor: Color.fromRGBO(52, 184, 255, 1)),
                  child: Text('CHECK AGAIN', 
              style: TextStyle(fontFamily: 'MegFont', color: Colors.white),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}