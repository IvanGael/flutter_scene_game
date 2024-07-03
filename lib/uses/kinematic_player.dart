import 'dart:math';


import 'package:vector_math/vector_math_64.dart';

import '../constants/app_animations.dart';
import '../constants/app_models.dart';
import '../modules/node.dart';

class KinematicPlayer {
  final double kAccelerationRate = 8;
  final double kFrictionRate = 4;
  final double kMaxSpeed = 8;

  Vector3 _position = Vector3.zero();
  Vector3 get position => _position;

  final Vector3 _direction = Vector3(0, 0, -1);
  Vector2 _velocityXZ = Vector2.zero();
  Vector2 _inputDirection = Vector2.zero();

  set inputDirection(Vector2 inputDirection) {
    _inputDirection = inputDirection;
    if (_inputDirection.length > 1) {
      _inputDirection.normalize();
    }
  }

  Vector2 get velocityXZ => _velocityXZ;


  Node get node {
    Matrix4 transform = Matrix4.translation(_position) *
        Matrix4.rotationY(
            Vector3(0, 0, -1).angleToSigned(_direction, Vector3(0, 1, 0)));

    double speed = _velocityXZ.length;

    Node characterModel = Node(assetUri: AppModels.dash);
    // Set animation states
    characterModel.setAnimationState(AppAnimations.walk, false, true, 0.0, 1.0);
    characterModel.setAnimationState(AppAnimations.idle, true, true, 1 - speed, 1.2);
    characterModel.setAnimationState(AppAnimations.run, true, true, speed, 0.9);
    // characterModel.setAnimationState("Blink", true, true, 1.0, 1.0);

    return characterModel.transform(transform);
  }

  Node update(double deltaSeconds) {
    if (_inputDirection.length2 > 1e-3) {
      _velocityXZ += _inputDirection * kAccelerationRate * deltaSeconds;
      if (_velocityXZ.length > 1) {
        _velocityXZ.normalize();
      }
    } else if (_velocityXZ.length2 > 0) {
      double speed = max(0, _velocityXZ.length - kFrictionRate * deltaSeconds);
      _velocityXZ = _velocityXZ.normalized() * speed;
    }

    Vector3 velocity = Vector3(_velocityXZ.x, 0, _velocityXZ.y);
    _position += velocity * kMaxSpeed * deltaSeconds;

    if (_velocityXZ.length2 > 1e-3) {
      Quaternion rotation = Quaternion.axisAngle(
          Vector3(0, 1, 0),
          _direction.angleToSigned(velocity.normalized(), Vector3(0, -1, 0)) *
              0.2);
      rotation.rotate(_direction);
    }

    return node;
  }
}
