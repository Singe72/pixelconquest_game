import 'package:flutter/material.dart';

class Player {
  int units;
  int maxUnits;
  Color color;
  int cells;
  List<int> playerPos;

  Player(
      {required this.units,
      required this.playerPos,
      required this.maxUnits,
      required this.color,
      this.cells = 1});
}
