// ignore_for_file: library_private_types_in_public_api

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4, Quaternion, Vector3;
import 'camera.dart';
import 'node.dart';

class ScenePainter extends CustomPainter {
  final Camera camera;
  final ui.Image? sceneImage;
  final Size canvasSize;

  ScenePainter(this.camera, this.sceneImage, this.canvasSize);

  @override
  void paint(Canvas canvas, Size size) {
    if (sceneImage == null) return;

    final paint = Paint();

    // Compute the transformation matrix for the canvas based on the camera
    Matrix4 transform = camera.computeTransform(canvasSize.width / canvasSize.height);

    // Apply the transformation to the canvas
    canvas.transform(transform.storage);

    // Draw the image on the transformed canvas
    canvas.drawImage(sceneImage!, Offset.zero, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class SceneWidget extends StatelessWidget {
  final Node root;
  final Camera camera;
  final bool alwaysRepaint;

  const SceneWidget({
    super.key,
    required this.root,
    required this.camera,
    this.alwaysRepaint = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          painter: ScenePainter(camera, root.sceneImage, Size(constraints.maxWidth, constraints.maxHeight)),
          child: Container(),
        );
      },
    );
  }
}


class Scene extends StatefulWidget {
  final Node node;
  final String skySphereModelAsset;

  const Scene({super.key, 
  required this.node, required this.skySphereModelAsset});

  @override
  _SceneState createState() => _SceneState();
}

class _SceneState extends State<Scene> {
  Vector3 _direction = Vector3(0, 0, -1);
  double _distance = 7.5;

  double _startScaleDistance = 1;

  Future<Node> _loadSkySphere(String skySphereModelAsset) async {
    return await Node.fromAsset(skySphereModelAsset);
  }

  @override
  Widget build(BuildContext context) {
    Vector3 cameraPosition = Vector3(0, 1.65, 0) + _direction * _distance;

    return FutureBuilder<Node>(
      future: _loadSkySphere(widget.skySphereModelAsset),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Error: No data'));
        } else {
          return GestureDetector(
            onScaleStart: (details) {
              _startScaleDistance = _distance;
            },
            onScaleUpdate: (details) {
              setState(() {
                _distance = _startScaleDistance / details.scale;

                double panDistance = details.focalPointDelta.distance;
                if (panDistance < 1e-3) {
                  return;
                }

                Matrix4 viewToWorldTransform = Matrix4.inverted(
                    matrix4LookAt(Vector3.zero(), -_direction, Vector3(0, 1, 0)));

                Vector3 screenSpacePanDirection = Vector3(
                        details.focalPointDelta.dx, -details.focalPointDelta.dy, 0)
                    .normalized();
                Vector3 screenSpacePanAxis =
                    screenSpacePanDirection.cross(Vector3(0, 0, 1)).normalized();
                Vector3 panAxis = viewToWorldTransform * screenSpacePanAxis;
                Vector3 newDirection =
                    Quaternion.axisAngle(panAxis, panDistance / 100)
                        .rotate(_direction)
                        .normalized();
                if (newDirection.length > 1e-1) {
                  _direction = newDirection;
                }
              });
            },
            child: SceneWidget(
              root: Node(children: [
                widget.node,
                snapshot.data!,
              ]),
              camera: Camera(position: cameraPosition, target: Vector3(0, 1.75, 0)),
            ),
          );
        }
      },
    );
  }
}
