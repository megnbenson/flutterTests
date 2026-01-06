import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:salt_game/components/game.dart';

void main() {
  runApp(GameWidget.controlled(gameFactory: SaltGame.new));
}

// class MainApp extends StatelessWidget {
//   const MainApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: Scaffold(
//         body: Center(
//           child: Text('Hello World!'),
//         ),
//       ),
//     );
//   }
// }
