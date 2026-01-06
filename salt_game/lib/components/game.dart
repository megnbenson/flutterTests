import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'cup.dart';
import 'salt.dart';

class SaltGame extends Forge2DGame {
  SaltGame()
    : super(
        gravity: Vector2(0, 10),
        camera: CameraComponent.withFixedResolution(width: 800, height: 600),
      );
  @override
  Color backgroundColor() => const Color.fromARGB(255, 5, 57, 77); // dark blue background

  @override
  FutureOr<void> onLoad() async {
    //make cup as a sprite
    final cupImage = await images.load('cup.png');
    Sprite cupSprite = Sprite(cupImage);
    final saltImage = await images.load('salt.png');
    Sprite saltSprite = Sprite(saltImage);

    await addCup(cupSprite);
    unawaited(addSalt(saltSprite));

    final saltPos = Vector2(
      camera.visibleWorldRect.center.dx,
      camera.visibleWorldRect.center.dy,
    );
    await world.add(Salt(saltPos, saltSprite));
    // await addPlayer();

    return super.onLoad();
  }

  Future<void> addCup(Sprite cupSprite) {
    return world.addAll([
      Cup(
        Vector2(0, (camera.visibleWorldRect.height - cupSize) / 2),
        cupSprite,
      ),
    ]);
  }
  final _random = Random();                                

  Future<void> addSalt(Sprite saltSprite) async {
      for (var x = 0; x < 200; x ++){
          // Salt(
          //   Vector2(x, (camera.visibleWorldRect.height - cupSize) / 2),
          //   saltSprite,
          // ),
      await world.add(
        Salt( Vector2(
            camera.visibleWorldRect.right / 3 +
                (_random.nextDouble() * 5 - 2.5),
            0,
          ), saltSprite,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
    

      }
  }
}
