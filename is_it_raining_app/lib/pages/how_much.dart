import 'package:flutter/material.dart';
import 'package:is_it_raining/pages/why_use.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HowMuchPage extends StatefulWidget {
  final double latitude;
  final double longitude;

  const HowMuchPage({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<HowMuchPage> createState() => _HowMuchPageState();
}

// Custom track shape that paints a linear gradient across the slider track.
class GradientSliderTrackShape extends RoundedRectSliderTrackShape {
  final Gradient gradient;

  GradientSliderTrackShape({required this.gradient});

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
    Offset? secondaryOffset,
    required TextDirection textDirection,
  }) {
    if (sliderTheme.trackHeight == 0) return;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final Paint paint = Paint()..shader = gradient.createShader(trackRect);
    final RRect rRect = RRect.fromRectAndRadius(trackRect, Radius.circular(trackRect.height / 2));
    context.canvas.drawRRect(rRect, paint);
  }
}

class _HowMuchPageState extends State<HowMuchPage> {
  String rainDirection = "Loading rain direction...";
  double arrowAngle = 0.0;
  double _currentDiscreteSliderValue = 0;

  Color _backgroundForValue() {
    final int v = _currentDiscreteSliderValue.round();
    switch (v) {
      case 0:
        return const Color(0xFFFEA72A); // #FEA72A
      case 33:
        return const Color(0xFFFFFFFF); // #FFFFFF
      case 67:
        return const Color(0xFF6E94F5); // #6E94F5
      case 100:
        return const Color(0xFF477BFF); // #477BFF
      default:
        return const Color(0xFFFEA72A);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bg = _backgroundForValue();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: bg,
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
            if (_currentDiscreteSliderValue.round() == 0)
              Image.asset('assets/gifs/Its_Raining_Animation.gif', width: 200),
            if (_currentDiscreteSliderValue.round() == 33)
              Image.asset('assets/gifs/its_Cloudy_Animation.gif', width: 200),
            if (_currentDiscreteSliderValue.round() == 67)
              Image.asset('assets/gifs/Its_Raining_Animation.gif', width: 200),
            if (_currentDiscreteSliderValue.round() == 100)
              Image.asset('assets/gifs/Its_bucketing_it_down_Animation.gif', width: 200),
            SizedBox(height: 20),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackShape: GradientSliderTrackShape(
                    gradient: LinearGradient(
                      colors: [Color.fromRGBO(254, 167, 42, 1), Color.fromRGBO(52, 184, 255, 1)],
                    ),
                  ),
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: Color.fromRGBO(52, 184, 255, 1),
                  overlayColor: Color.fromRGBO(52, 184, 255, 0.12),
                  trackHeight: 8.0,
                ),
                child: SizedBox(
                  width: 250,
                  child: Slider(
                    value: _currentDiscreteSliderValue,
                    max: 100,
                    divisions: 3,
                    label: _currentDiscreteSliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _currentDiscreteSliderValue = value;
                      });
                    },
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the new GoHerePage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => WhyUsePage(
                          longitude: widget.longitude,
                          latitude: widget.latitude,
                        ),
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
                'SUBMIT',
                style: GoogleFonts.jost(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
