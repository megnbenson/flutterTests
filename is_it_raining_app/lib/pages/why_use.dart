import 'package:flutter/material.dart';
import 'package:is_it_raining/pages/home_page.dart';

class WhyUsePage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const WhyUsePage({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<WhyUsePage> createState() => _WhyUsePageState();
}

class _WhyUsePageState extends State<WhyUsePage> {
  String rainDirection = "Loading rain direction...";
  double arrowAngle = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.amberAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                "Why are you \n even using \n this app?",
                style: TextStyle(fontFamily: 'RainFont', fontSize: 44),
              ),
            SizedBox(height: 50),
            Image.asset('assets/gifs/its_cloudy.gif', width: 250),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                // Navigate to the new GoHerePage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => HomePage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Color.fromRGBO(52, 184, 255, 1)),
                  borderRadius: BorderRadius.circular(6),
                ),
                backgroundColor: Color.fromRGBO(52, 184, 255, 1),
              ),
              child: Text(
                'CHECK AGAIN',
                style: TextStyle(
                  fontFamily: 'RainFont',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
