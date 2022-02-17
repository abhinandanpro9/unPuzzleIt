
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

enum RobotState {
  idle,
  running,
}

class FlameCustomCharacter extends FlameGame with TapDetector {
  var height;

  var width;

  late SpriteAnimationGroupComponent robot;

  FlameCustomCharacter({ Key? key, required this.width, required this.height});


  @override
  Future<void> onLoad() async {
    // final running = await loadSpriteAnimation(
    //   'parallax/ember.png',
    //   SpriteAnimationData.sequenced(
    //     amount: 8,
    //     stepTime: 0.2,
    //     textureSize: Vector2(16, 18),
    //   ),
    // );
    final idle = await loadSpriteAnimation(
      'parallax/ember.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.4,
        textureSize: Vector2(16, 18),
      ),
    );

    final robotSize = Vector2(width, height);
    robot = SpriteAnimationGroupComponent<RobotState>(
        animations: {
          // RobotState.running: running,
          RobotState.idle: idle,
        },
        current: RobotState.idle,
        // position: size / 2 - robotSize / 2,
        size: robotSize,
        // paint: Paint()..color = Colors.transparent,
        );

    add(robot);
    super.onLoad();
  }

  @override
  void onTapDown(_) {
    robot.current = RobotState.running;
  }

  @override
  void onTapCancel() {
    robot.current = RobotState.idle;
  }

  @override
  void onTapUp(_) {
    robot.current = RobotState.idle;
  }

  @override
  Color backgroundColor() => Colors.transparent;
}
