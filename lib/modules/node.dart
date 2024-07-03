import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';


class Node {
  final ui.Image? sceneImage;
  final List<Node> children;
  final Vector3 position;
  final String? assetUri;
  final List<String>? animations;
  final Map<String, List<double>> animationStates;

  Node({
    this.sceneImage,
    this.children = const [],
    Vector3? position,
    this.assetUri,
    this.animations,
    this.animationStates = const {},
  }) : position = position ?? Vector3.zero();

  factory Node.asset(String assetUri, {List<String>? animations}) {
    return Node(
      assetUri: assetUri,
      animations: animations,
    );
  }

  static Future<Node> fromAsset(String assetUri, {List<String>? animations}) async {
    final ByteData data = await rootBundle.load(assetUri);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return Node(
      sceneImage: frame.image,
      assetUri: assetUri,
      animations: animations,
    );
  }

  Node transform(Matrix4 transform) {
    // Apply transformation to the current node
    Vector3 newPosition = transform.perspectiveTransform(position);
    List<Node> transformedChildren = children.map((child) {
      return child.transform(transform);
    }).toList();

    return Node(
      sceneImage: sceneImage,
      children: transformedChildren,
      position: newPosition,
      assetUri: assetUri,
      animations: animations,
      animationStates: animationStates,
    );
  }

  Node setAnimationState(String animationName, bool loop, bool reversed, double start, double end) {
    // Add or update animation state
    List<double> state = [start, end];
    animationStates[animationName] = state;
    return this;
  }
}