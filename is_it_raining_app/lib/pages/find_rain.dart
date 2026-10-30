import 'dart:async';
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/utils/weather_utils.dart';

class FindRainPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const FindRainPage({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<FindRainPage> createState() => _FindRainPageState();
}

class _FindRainPageState extends State<FindRainPage> {
  String rainStatus = "Searching nearby radar...";
  double? rainBearingDegrees;
  double? rainDistanceKilometers;
  double? compassHeadingDegrees;
  bool isDebugMode = false;
  StreamSubscription<CompassEvent>? _compassSubscription;
  Timer? _radarRefreshTimer;

  @override
  void initState() {
    super.initState();
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (!mounted || event.heading == null) return;
      setState(() => compassHeadingDegrees = event.heading);
    });
    _updateNearestRain();
    _radarRefreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _updateNearestRain(),
    );
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _radarRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _updateNearestRain() async {
    try {
      final target = await WeatherUtils.getNearestRain(
        widget.latitude,
        widget.longitude,
      );
      if (!mounted) return;

      setState(() {
        rainBearingDegrees = target?.bearingDegrees;
        rainDistanceKilometers = target?.distanceKilometers;
        rainStatus =
            target == null
                ? "No rain found in nearby radar tiles"
                : "Nearest rain: ${target.distanceKilometers.toStringAsFixed(1)} km away";
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        rainBearingDegrees = null;
        rainDistanceKilometers = null;
        rainStatus = "Unable to load radar data";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
            ); // This will pop the current route off the stack
          },
        ),
        actions: [
          Row(
            children: [
              Text(
                "Debug",
                style: GoogleFonts.jost(fontSize: 16, color: Colors.black),
              ),
              Switch(
                value: isDebugMode,
                onChanged: (value) {
                  setState(() {
                    isDebugMode = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "GO HERE",
              style: TextStyle(fontFamily: 'RainFont', fontSize: 44),
            ),
            // Text("GO HERE",
            //   style: TextStyle(fontFamily: 'MegFont', fontSize: 44),
            // ),
            if (isDebugMode)
              Text(
                "Bearing: ${rainBearingDegrees?.toStringAsFixed(1) ?? 'n/a'}°  "
                "Heading: ${compassHeadingDegrees?.toStringAsFixed(1) ?? 'n/a'}°",
                style: GoogleFonts.jost(fontSize: 24),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(rainStatus, style: GoogleFonts.jost(fontSize: 18)),
            ),
            if (rainBearingDegrees != null)
              Transform.rotate(
                angle:
                    (rainBearingDegrees! - (compassHeadingDegrees ?? 0)) *
                    (pi / 180),
                child: Image.asset('assets/gifs/Arrow_cropped.gif', width: 50),
              ),
            if (rainBearingDegrees != null && compassHeadingDegrees == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Compass unavailable; arrow is north-aligned",
                  style: GoogleFonts.jost(fontSize: 14),
                ),
              ),
            Image.asset('assets/gifs/full_cup.gif', width: 100),
          ],
        ),
      ),
    );
  }
}
