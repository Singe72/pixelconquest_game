import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pixelconquest_game/pixels/land_pixel.dart';
import 'package:pixelconquest_game/pixels/mountain_pixel.dart';
import 'package:pixelconquest_game/pixels/player_pixel.dart';
import 'package:pixelconquest_game/pixels/water_pixel.dart';
import 'package:pixelconquest_game/player.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int rowSize = 20;
  int totalNumberOfPixels = 400;

  List<Player> players = [
    Player(units: 0, playerPos: [90], maxUnits: 150, color: Colors.red),
    Player(units: 0, playerPos: [309], maxUnits: 150, color: Colors.green)
  ];

  List<int> waterPos = [];

  List<int> mountainPos = [];

  void startGame() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        for (var player in players) {
          recalculateMaxPlayerUnits(player);
          generateUnits(player);
          if (player.isExpanding) {
            expand(player);
          }
          if (player.isAttacking) {
            attack(player, players.firstWhere((p) => p != player));
          }
        }
      });
    });
  }

  void expand(Player player) {
    setState(() {
      expandPlayerPosition(player);
    });
  }

  void attack(Player player, Player otherPlayer) {
    setState(() {
      attackPlayerPosition(player, otherPlayer);
    });
  }

  void recalculateMaxPlayerUnits(Player player) {
    player.maxUnits = player.pixels * 150;
  }

  void expandPlayerPosition(Player player) {
    int perimeter = 1;
    int conquestCost = 20;

    List<int> newPlayerPos = List.from(player.playerPos);
    int maxSize = rowSize * rowSize;

    for (int pos in player.playerPos) {
      if (newPlayerPos.length >= maxSize) {
        break;
      }
      int row = pos ~/ rowSize;
      int col = pos % rowSize;
      for (int i = -perimeter; i <= perimeter; i++) {
        for (int j = -perimeter + i.abs(); j <= perimeter - i.abs(); j++) {
          int newRow = row + i;
          int newCol = col + j;
          int newPos = newRow * rowSize + newCol;
          if (newRow >= 0 &&
              newRow < rowSize &&
              newCol >= 0 &&
              newCol < rowSize &&
              !newPlayerPos.contains(newPos)) {
            if (!waterPos.contains(newPos) && !mountainPos.contains(newPos)) {
              if (!players.any((p) => p.playerPos.contains(newPos))) {
                if (player.units >= conquestCost) {
                  newPlayerPos.add(newPos);
                  player.units -= conquestCost;
                  player.pixels++;
                } else {
                  player.isExpanding = false;
                  player.isAttacking = false;
                }
              }
            }
          }
        }
      }
    }
    player.playerPos = newPlayerPos;
  }

  void attackPlayerPosition(Player attacker, Player target) {
    int perimeter = 1;
    int conquestCost = 20;

    List<int> newPlayerPos = List.from(attacker.playerPos);
    int maxSize = rowSize * rowSize;

    Set<int> adjacentPositions = Set();

    for (int pos in attacker.playerPos) {
      int row = pos ~/ rowSize;
      int col = pos % rowSize;
      for (int i = -perimeter; i <= perimeter; i++) {
        for (int j = -perimeter + i.abs(); j <= perimeter - i.abs(); j++) {
          int newRow = row + i;
          int newCol = col + j;
          int newPos = newRow * rowSize + newCol;
          if (newRow >= 0 &&
              newRow < rowSize &&
              newCol >= 0 &&
              newCol < rowSize) {
            adjacentPositions.add(newPos);
          }
        }
      }
    }

    for (int pos in target.playerPos) {
      if (newPlayerPos.length >= maxSize) {
        break;
      }
      if (adjacentPositions.contains(pos)) {
        int row = pos ~/ rowSize;
        int col = pos % rowSize;
        for (int i = -perimeter; i <= perimeter; i++) {
          for (int j = -perimeter + i.abs(); j <= perimeter - i.abs(); j++) {
            int newRow = row + i;
            int newCol = col + j;
            int newPos = newRow * rowSize + newCol;
            if (newRow >= 0 &&
                newRow < rowSize &&
                newCol >= 0 &&
                newCol < rowSize &&
                !newPlayerPos.contains(newPos)) {
              if (!waterPos.contains(newPos) && !mountainPos.contains(newPos)) {
                if (!attacker.playerPos.contains(newPos)) {
                  if (attacker.units >= conquestCost) {
                    newPlayerPos.add(newPos);
                    attacker.units -= conquestCost;
                    attacker.pixels++;
                  }
                }
              }
            }
          }
        }
      }
    }
    attacker.playerPos = newPlayerPos;
  }

  void generateUnits(Player player) {
    int newUnits = player.units + player.pixels * 2;
    if (newUnits > player.maxUnits) {
      player.units = player.maxUnits;
    } else {
      player.units = newUnits;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
              child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  color: players[0].isExpanding ? Colors.red : Colors.grey,
                  onPressed: () {
                    players[0].isExpanding = true;
                  },
                  child: const Text("S'expandre"),
                ),
                const SizedBox(
                  width: 20,
                ),
                MaterialButton(
                  color: players[0].isAttacking ? Colors.red : Colors.grey,
                  onPressed: () {
                    players[0].isAttacking = true;
                  },
                  child: const Text("Attaquer"),
                ),
                const SizedBox(
                  width: 20,
                ),
                MaterialButton(
                  color: Colors.red,
                  onPressed: () {
                    players[0].isExpanding = false;
                    players[0].isAttacking = false;
                  },
                  child: const Text("Arrêter"),
                ),
              ],
            ),
          )),
          Expanded(
            flex: 5,
            child: GridView.builder(
              itemCount: totalNumberOfPixels,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rowSize,
              ),
              itemBuilder: (context, index) {
                for (var player in players) {
                  if (player.playerPos.contains(index)) {
                    return PlayerPixel(
                        units: player.units, color: player.color);
                  }
                }
                if (waterPos.contains(index)) {
                  return const WaterPixel();
                } else if (mountainPos.contains(index)) {
                  return const MountainPixel();
                } else {
                  return const LandPixel();
                }
              },
            ),
          ),
          Expanded(
              child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  color: players[1].isExpanding ? Colors.green : Colors.grey,
                  onPressed: () {
                    players[1].isExpanding = true;
                  },
                  child: const Text("S'expandre"),
                ),
                const SizedBox(
                  width: 20,
                ),
                MaterialButton(
                  color: players[1].isAttacking ? Colors.green : Colors.grey,
                  onPressed: () {
                    players[1].isAttacking = true;
                  },
                  child: const Text("Attaquer"),
                ),
                const SizedBox(
                  width: 20,
                ),
                MaterialButton(
                  color: Colors.green,
                  onPressed: () {
                    players[1].isExpanding = false;
                    players[1].isAttacking = false;
                  },
                  child: const Text("Arrêter"),
                ),
              ],
            ),
          )),
          Expanded(
              child: Center(
            child: MaterialButton(
              color: Colors.pink,
              onPressed: () {
                startGame();
              },
              child: const Text("Jouer"),
            ),
          )),
        ],
      ),
    );
  }
}
