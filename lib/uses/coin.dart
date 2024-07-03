import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';

import '../constants/app_models.dart';
import '../modules/node.dart';


class Coin {
  Vector3 position;
  double rotation = 0;
  bool collected = false;

  Vector3 startAnimPosition = Vector3.zero();
  double collectAnimation = 0;

  Coin(this.position);

  Future<Node> _loadCoinNode() async {
    return await Node.fromAsset(AppModels.coin);
  }

  Future<Node> getNode() async {
    Node coinNode = await _loadCoinNode();
    Matrix4 transform = Matrix4.translation(position) *
        Matrix4.rotationY(rotation) *
        Matrix4.diagonal3(Vector3.all(math.min(1.0, 3 - 3 * collectAnimation)));
    return Node(
      sceneImage: null, // Assuming the scene image is not relevant for coins
      children: [
        coinNode,
      ],
    ).transform(transform);
  }

  Future<Node?> update(Vector3 playerPosition, double deltaSeconds) async {
    if (collected && collectAnimation == 1) {
      return null;
    }

    if (!collected) {
      double distance = (playerPosition - position).length;
      if (distance < 2.2) {
        collected = true;
        startAnimPosition = position;
      }
    }
    if (collected) {
      collectAnimation = math.min(1, collectAnimation + deltaSeconds * 2);
      position.y = startAnimPosition.y + math.sin(collectAnimation * 5) * 0.4;
      rotation += deltaSeconds * 10;
    }

    rotation += deltaSeconds * 2;

    return await getNode();
  }
}

class CoinCollection {
  final List<Coin> coins = [
    Coin(Vector3(-1.4 - 0.8 * 0, 1.5, -6 - 2 * 0)),
    Coin(Vector3(-1.4 - 0.8 * 1, 1.5, -6 - 2 * 1)),
    Coin(Vector3(-1.4 - 0.8 * 2, 1.5, -6 - 2 * 2)),
    Coin(Vector3(-1.4 - 0.8 * 3, 1.5, -6 - 2 * 3)),
    Coin(Vector3(-15 + 2 * 0, 1.5, 0.5 - 1.2 * 0)),
    Coin(Vector3(-15 + 2 * 1, 1.5, 0.5 - 1.2 * 1)),
    Coin(Vector3(-15 + 2 * 2, 1.5, 0.5 - 1.2 * 2)),
    Coin(Vector3(-15 + 2 * 3, 1.5, 0.5 - 1.2 * 3)),
    Coin(Vector3(7 + 2 * 0, 1.5, -16 + 1.3 * 0)),
    Coin(Vector3(7 + 2 * 1, 1.5, -16.5 + 1.3 * 1)),
    Coin(Vector3(7 + 2 * 2, 1.5, -16.5 + 1.3 * 2)),
    Coin(Vector3(7 + 2 * 3, 1.5, -16 + 1.3 * 3)),
  ];

  Future<Node> update(Vector3 playerPosition, double deltaSeconds) async {
    List<Node> updatedNodes = [];
    for (var coin in coins) {
      var updatedNode = await coin.update(playerPosition, deltaSeconds);
      if (updatedNode != null) {
        updatedNodes.add(updatedNode);
      }
    }
    return Node(children: updatedNodes);
  }
}