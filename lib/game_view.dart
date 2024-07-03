import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vector_math/vector_math_64.dart';
import 'constants/app_models.dart';
import 'modules/node.dart';
import 'modules/scene.dart';
import 'uses/coin.dart';
import 'uses/follow_camera.dart';
import 'uses/kinematic_player.dart';

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late Ticker tick;
  double time = 0;
  double deltaSeconds = 0;

  final KinematicPlayer player = KinematicPlayer();
  final FollowCamera camera = FollowCamera();
  final CoinCollection coins = CoinCollection();

  @override
  void initState() {
    tick = Ticker(
      (elapsed) {
        setState(() {
          double previousTime = time;
          time = elapsed.inMilliseconds / 1000.0;
          deltaSeconds = previousTime > 0 ? time - previousTime : 0;
        });
      },
    );
    tick.start();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final Offset center = Offset(screenSize.width, screenSize.height) / 2;
    final double inputMapping = 1 / min(center.dx, center.dy);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onScaleStart: (details) {
        var dir = (details.localFocalPoint - center) * inputMapping;
        player.inputDirection = Vector2(dir.dx, -dir.dy);
      },
      onScaleUpdate: (details) {
        var dir = (details.localFocalPoint - center) * inputMapping;
        player.inputDirection = Vector2(dir.dx, -dir.dy);
      },
      onScaleEnd: (details) {
        player.inputDirection = Vector2.zero();
      },
      child: Scaffold(
        body: FutureBuilder<Node>(
          future: coins.update(player.position, deltaSeconds),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return SceneWidget(
                root: Node(children: [
                  Node.asset(AppModels.ground),
                  player.update(deltaSeconds),
                  Node(
                    position: camera.position,
                    children: [
                      Node.asset(AppModels.skySphere),
                    ],
                  ).transform(Matrix4.rotationY(3)),
                  snapshot.data!,
                ]),
                camera: camera.update(
                  player.position,
                  Vector3(player.velocityXZ.x, 0, player.velocityXZ.y) *
                      player.kMaxSpeed,
                  deltaSeconds,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    tick.dispose();
    super.dispose();
  }
}