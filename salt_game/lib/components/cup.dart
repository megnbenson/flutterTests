import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'body_component_with_user_data.dart'; 

const cupSize = 3.0;

class Cup extends BodyComponentWithUserData  {
  Cup(Vector2 position, Sprite sprite)
    : super(
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
        children: [
          SpriteComponent(
            anchor: Anchor.center,
            sprite: sprite,
            size: Vector2.all(cupSize),
            position: Vector2(10, 0),
          ),
        ],
      );
}