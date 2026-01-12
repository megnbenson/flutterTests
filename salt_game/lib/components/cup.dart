// import 'dart:ui';

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/painting.dart';
import 'body_component_with_user_data.dart';
import 'salt.dart';

const cupSize = 8.0;

class Cup extends BodyComponentWithUserData with ContactCallbacks {
  Cup(Vector2 position, Sprite sprite, {required void Function() onSaltInCup})
      : _sprite = sprite,
        _onSaltInCup = onSaltInCup,
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
  final void Function() _onSaltInCup;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      SpriteComponent(
        anchor: Anchor.center,
        sprite: _sprite,
        size: Vector2.all(cupSize),
        position: Vector2(0, 0),
      ),
    );
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Salt) {
      // Only count if salt is above the cup (touching the top)
      final saltY = other.body.position.y;
      final cupY = body.position.y - (cupSize / 2);
      if (saltY < cupY + 0.1) {
        _onSaltInCup();
        other.removeFromParent();
      }
    }
    super.beginContact(other, contact);
  }
}
