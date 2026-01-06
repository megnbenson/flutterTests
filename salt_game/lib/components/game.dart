import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'cup.dart';

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

    await addCup(cupSprite);
    // unawaited(addBricks().then((_) => addEnemies()));
    // await addPlayer();

    return super.onLoad();
  }

  Future<void> addCup(Sprite cupSprite) {
    return world.addAll([
        // for (
        //   var x = camera.visibleWorldRect.left;
        //   x < camera.visibleWorldRect.right + cupSize;
        //   x += cupSize
        // )
        Cup(
          Vector2(0, (camera.visibleWorldRect.height - cupSize) / 2),
          cupSprite,
        ),
    ]);
  }
}
