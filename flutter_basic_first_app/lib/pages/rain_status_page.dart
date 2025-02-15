import 'package:flutter/material.dart';
import 'package:flutter_basic_first_app/models/utils/weather_utils.dart';

class RainStatusPage extends StatefulWidget {
  const RainStatusPage({super.key});

  @override
  _RainStatusPageState createState() => _RainStatusPageState();
}

class _RainStatusPageState extends State<RainStatusPage> {
  bool? isRaining;

  @override
  void initState() {
    super.initState();
    checkRainStatus();
  }

  Future<void> checkRainStatus() async {
    double lat = 51.517398;
    double lon = -0.059893;
    bool raining = await WeatherUtils.isItRaining(lat, lon);
    setState(() {
      isRaining = raining;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rain Status'),
      ),
      body: Center(
        child: isRaining == null
            ? CircularProgressIndicator()
            : Text(
                isRaining! ? 'It is raining' : 'It is not raining',
                style: TextStyle(fontSize: 24),
              ),
      ),
    );
  }
}
