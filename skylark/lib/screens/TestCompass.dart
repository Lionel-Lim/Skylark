import 'package:flutter/material.dart';
import 'package:smooth_compass/utils/src/compass_ui.dart';

class Compass extends StatefulWidget {
  const Compass({super.key});

  @override
  State<Compass> createState() => _CompassState();
}

class _CompassState extends State<Compass> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("compass"),
      ),
      body: Center(
        child: SmoothCompass(
          rotationSpeed: 200,
          height: 300,
          width: 300,
          compassBuilder: (context, AsyncSnapshot<CompassModel>? compassData,
              Widget compassAsset) {
            return compassAsset;
          },
        ),
      ),
    );
  }
}
