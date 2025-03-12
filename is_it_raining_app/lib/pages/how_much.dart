import 'package:flutter/material.dart';
import 'package:flutter_basic_first_app/pages/home_page.dart';
import 'package:flutter_basic_first_app/pages/rain_status_page.dart';
import 'package:flutter_basic_first_app/pages/why_use.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HowMuchPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const HowMuchPage({super.key, required this.latitude, required this.longitude});

  @override
  _HowMuchPageState createState() => _HowMuchPageState();
}

class _HowMuchPageState extends State<HowMuchPage> {
  String rainDirection = "Loading rain direction...";
  double arrowAngle = 0.0;
  double _currentDiscreteSliderValue = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(254, 167, 42, 1),
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
      backgroundColor: Color.fromRGBO(254, 167, 42, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              SvgPicture.asset( 
                      'assets/images/HOW_MUCH.svg', 
                      semanticsLabel: 'How much', 
                      height: 100, 
                      width: 70, 
                    ),
                SizedBox(height: 20),
                if(_currentDiscreteSliderValue==0)
                  Image.asset('assets/gifs/its_sunny.gif', width: 250),
                if(_currentDiscreteSliderValue==50)
                  Image.asset('assets/gifs/its_cloudy.gif', width:250), 
                if(_currentDiscreteSliderValue==100)
                  Image.asset('assets/gifs/Its_Raining.gif', width:250),             
                Container(
                  width: 250,
                  child: Slider(
                    value: _currentDiscreteSliderValue,
                    max: 100,
                    divisions: 2,
                    label: _currentDiscreteSliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentDiscreteSliderValue = value;
                      });
                    },
                  ),
              ),
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
                  child: Text('SUBMIT', 
                  style: GoogleFonts.jost(color: Colors.white),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}