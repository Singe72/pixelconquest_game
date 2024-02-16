import 'package:flutter/material.dart';

class Player {
  int units;
  int maxUnits;
  Color color;
  int pixels;
  List<int> playerPos;
  bool isExpanding = false;
  bool isAttacking = false;

  Player(
      {required this.units,
      required this.playerPos,
      required this.maxUnits,
      required this.color,
      this.pixels = 1});
}
