

import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

import '../constants/app_models.dart';

class Scene2 extends StatefulWidget {
  const Scene2({super.key});

  @override
  State<Scene2> createState() => _Scene2State();
}

class _Scene2State extends State<Scene2> {
  late Flutter3DController _groundController;

  @override
  void initState() {
    super.initState();
    _groundController = Flutter3DController();
    _groundController.setCameraOrbit(50, 8, 5);
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
      children: [
        Flutter3DViewer(
        controller: _groundController,
        src: AppModels.ground, 
                )

      ],
    ),
    );
  }
}