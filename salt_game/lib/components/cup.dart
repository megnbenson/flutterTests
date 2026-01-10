// import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/painting.dart';
import 'body_component_with_user_data.dart'; 
import 'salt.dart';

const cupSize = 3.0;


class Cup extends BodyComponentWithUserData with ContactCallbacks {
  Cup(Vector2 position, Sprite sprite)
      : _sprite = sprite,
        super(
          renderBody: false,
          bodyDef: BodyDef()
            ..position = position
            ..type = BodyType.static,
          fixtureDefs: [
            FixtureDef(
              PolygonShape()..setAsBoxXY(cupSize / 2, cupSize / 2),
              friction: 0.3,
            ),
          ],
        );

  final Sprite _sprite;
  int saltCount = 0;
  late TextComponent _countText;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(SpriteComponent(
      anchor: Anchor.center,
      sprite: _sprite,
      size: Vector2.all(cupSize),
      position: Vector2(10, 0),
    ));
    _countText = TextComponent(
      text: saltCount.toString(),
      anchor: Anchor.topCenter,
      position: Vector2(10, -cupSize / 2 - 10),
      priority: 1,
      textRenderer: TextPaint(      
        style: TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_countText);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Salt) {
      // Only count if salt is above the cup (touching the top)
      final saltY = other.body.position.y;
      final cupY = body.position.y - (cupSize / 2);
      if (saltY < cupY + 0.2) { // 0.2 is a small threshold
        saltCount++;
        _countText.text = saltCount.toString();
        other.removeFromParent();
      }
    }
    super.beginContact(other, contact);
  }
}