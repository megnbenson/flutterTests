import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

/// Component that listens for drag input across the whole game screen.
/// - Drag to start a circle at the press point and grow it while dragging.
/// - On release, a static physics circle is added to the Forge2D world.
class Circle extends PositionComponent
    with DragCallbacks, HasGameReference<Forge2DGame> {
  Circle({Color color = Colors.blue})
    : _paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill,
      super(anchor: Anchor.topLeft);

  final Paint _paint;

  bool _isDragging = false;
  Vector2? _start; // local start point of the drag (world coordinates)
  double _radius = 0.0;

  @override
  Future<void> onLoad() async {
    // Cover the whole game screen so this receives global drag events.
    await super.onLoad();
    size = game.size.clone();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_isDragging && _start != null && _radius > 0) {
      canvas.drawCircle(_start!.toOffset(), _radius, _paint);
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    _isDragging = true;
    _start = event.localPosition.clone();
    _radius = 0;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!_isDragging || _start == null) return;
    final current = event.localEndPosition;
    _radius = (current - _start!).length;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (_isDragging && _start != null && _radius > 1) {
      // Convert to world coordinates if needed
      // final pos = game.screenToWorld(_start!);

      final worldCenter = game.screenToWorld(_start!);
      // Convert a point at radius distance to world coordinates
      final screenEdge = _start! + Vector2(_radius, 0);
      final worldEdge = game.screenToWorld(screenEdge);
      final worldRadius = (worldEdge - worldCenter).length;
      game.world.add(
        PhysicsStaticCircle(worldCenter, worldRadius, _paint.color),
      );

      // game.world.add(PhysicsStaticCircle(pos, _radius, _paint.color));
    }
    _isDragging = false;
    _start = null;
    _radius = 0;
  }
}

/// Physics-enabled static circle (Forge2D body) with a visual child.
class PhysicsStaticCircle extends BodyComponent {
  PhysicsStaticCircle(this.center, this.radius, this.color);

  final Vector2 center;
  final double radius;
  final Color color;

  @override
  Body createBody() {
    final bd = BodyDef()
      ..position = center
      ..type = BodyType.static;
    final body = world.createBody(bd);
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape)
      ..friction = 0.5
      ..restitution = 0.1;
    body.createFixture(fixtureDef);
    return body;
  }

  @override
  Future<void> onLoad() async {
    // visual child centered on the body
    add(VisualCircle(radius: radius, color: color));
    return super.onLoad();
  }
}

/// Simple visual-only circle placed as a child of the BodyComponent so it renders at the body's position.
class VisualCircle extends PositionComponent {
  VisualCircle({required this.radius, required Color color})
    : _paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill,
      super(
        position: Vector2.zero(),
        size: Vector2.all(radius * 2),
        anchor: Anchor.center,
      );

  final double radius;
  final Paint _paint;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset(radius, radius), radius, _paint);
  }
}
