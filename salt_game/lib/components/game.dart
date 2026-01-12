import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:salt_game/components/circle.dart';
import 'cup.dart';
import 'salt.dart';

class SaltGame extends Forge2DGame {
  SaltGame()
    : super(
        gravity: Vector2(0, 10),
        camera: CameraComponent.withFixedResolution(width: 800, height: 600),
      );

  int saltCount = 100;
  Vector2 cupPosition = Vector2.zero();
  late TextComponent _countText;
  TextComponent? _winText;
  @override
  Color backgroundColor() => const Color.fromARGB(255, 5, 57, 77); // dark blue background

  @override
  FutureOr<void> onLoad() async {
    final cupImage = await images.load('cup.png');
    Sprite cupSprite = Sprite(cupImage);
    final saltImage = await images.load('salt.png');
    Sprite saltSprite = Sprite(saltImage);

    // Add global salt count text
    _countText = TextComponent(
      text: saltCount.toString(),
      anchor: Anchor.topLeft,
      position: Vector2(0, 100),
      priority: 10,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_countText);
    _winText = TextComponent(
      text: 'YOU WIN',
      position: Vector2(camera.visibleWorldRect.center.dx, camera.visibleWorldRect.center.dy),
      priority: 11,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Color.fromARGB(255, 0, 128, 0),
          fontSize: 100,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    await addCup(cupSprite);
    unawaited(addSalt(saltSprite));
    await add(Circle());

    final saltPos = Vector2(
      camera.visibleWorldRect.center.dx,
      camera.visibleWorldRect.center.dy,
    );
    await world.add(Salt(saltPos, saltSprite));
    return super.onLoad();
  }

  Future<void> addCup(Sprite cupSprite) {
     cupPosition = Vector2(0, (camera.visibleWorldRect.height - cupSize) / 2);
    _countText.position = camera.localToGlobal(cupPosition + Vector2(-2, -cupSize+3));
    //meg make text infront of cup
    _countText.priority = 12;
    return world.addAll([
      Cup(
        cupPosition,
        cupSprite,
        onSaltInCup: _onSaltInCup,
      ),
    ]);
  }

  void _onSaltInCup() {
    saltCount--;
    _countText.text = saltCount.toString();
    if (saltCount == 99 && _winText != null) {
      add(_winText!);
    }
  }

  final _random = Random();
  //MEG - todo:
  // 1. add drawing and have that stop the salt from falling
  // 2. add scoring when salt lands in cup
  // 3. add multiple levels with different cup positions

  Future<void> addSalt(Sprite saltSprite) async {
    for (var x = 0; x < 200; x++) {
      await world.add(
        Salt(
          Vector2(
            camera.visibleWorldRect.right / 3 +
                (_random.nextDouble() * 5 - 2.5),
            -10, // Start salt higher up
          ),
          saltSprite,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
  }
}
