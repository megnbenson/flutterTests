import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'body_component_with_user_data.dart';

const brickScale = 0.5;


class Salt extends BodyComponentWithUserData {
  final Sprite sprite;

  Salt(Vector2 position, this.sprite) :
       super(
         renderBody: false,
         bodyDef: BodyDef()
           ..position = position
           ..type = BodyType.dynamic,
         fixtureDefs: [
           FixtureDef(
               PolygonShape()..setAsBoxXY(
                 brickScale,
                 brickScale,
               ),
             )
             ..restitution = 0.4
             ..density = 1
             ..friction = 1,
         ],
       );

  late final SpriteComponent _spriteComponent;

  @override
  Future<void> onLoad() {
    _spriteComponent = SpriteComponent(
      anchor: Anchor.center,
      scale: Vector2.all(1),
      sprite: sprite,
      size: Vector2.all(brickScale),
      position: Vector2(0, 0),
    );
    add(_spriteComponent);
    return super.onLoad();
  }
}