import 'package:flutter/material.dart';
import '../constants/app_animations.dart';
import '../constants/app_models.dart';
import '../modules/node.dart';
import '../modules/scene.dart';
import 'manynodes.dart';

class DashWidget extends StatefulWidget {
  const DashWidget({super.key});

  @override
  State<DashWidget> createState() => _DashWidgetState();
}

class _DashWidgetState extends State<DashWidget> {
  Future<Node> _loadDashNode() async {
    return await Node.fromAsset(
      AppModels.dash, 
      animations: [AppAnimations.walk]
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Node>(
      future: _loadDashNode(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Error: No data'));
        } else {
          return Scene(
            skySphereModelAsset: AppModels.skySphere,
            node: manyNodes(snapshot.data!),
          );
        }
      },
    );
  }
}
