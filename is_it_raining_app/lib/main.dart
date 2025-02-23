// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IS IT RAINING?',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.amberAccent,
        primarySwatch: Colors.blue,
        fontFamily: 'RainFont'
      ),
      home: HomePage(),  // Changed from WeatherMapWidget to HomePage
    );
  }
}