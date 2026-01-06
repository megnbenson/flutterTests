import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class Background extends SpriteComponent with HasGameReference<Forge2DGame> {
  Background({required super.sprite})
      : super(anchor: Anchor.center, position: Vector2.zero());

  @override
  void onMount() {
    super.onMount();

    size = Vector2.all(
      max(
        game.camera.visibleWorldRect.width,
        game.camera.visibleWorldRect.height,
      ),
    );
  }
}