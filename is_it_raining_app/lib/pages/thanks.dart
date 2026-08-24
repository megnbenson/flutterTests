import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:is_it_raining/pages/home_page.dart';
import 'package:google_fonts/google_fonts.dart';

class ThanksPage extends StatefulWidget {
  const ThanksPage({super.key});

  @override
  State<ThanksPage> createState() => _ThanksPageState();
}

class _ThanksPageState extends State<ThanksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/THANKS!.svg',
              semanticsLabel: 'Thanks!',
              height: 100,
              width: 70,
            ),
            SizedBox(height: 50),
            Image.asset('assets/gifs/its_sunny.gif', width: 200),
            SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                // Navigate to the new GoHerePage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
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
                'HOME',
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
