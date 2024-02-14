import 'package:flutter/material.dart';

class PlayerPixel extends StatelessWidget {
  final int units;
  final Color color;

  const PlayerPixel({required this.units, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.1),
      child: Container(
        color: color,
        child: Center(
            child: Text(
          units.toString(),
          style: const TextStyle(fontSize: 12),
        )),
      ),
    );
  }
}
