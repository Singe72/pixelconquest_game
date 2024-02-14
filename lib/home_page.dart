import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pixelconquest_game/land_pixel.dart';
import 'package:pixelconquest_game/mountain_pixel.dart';
import 'package:pixelconquest_game/player.dart';
import 'package:pixelconquest_game/player_pixel.dart';
import 'package:pixelconquest_game/water_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int rowSize = 20;
  int totalNumberOfCells = 400;

  List<Player> players = [
    Player(units: 512, playerPos: [90], maxUnits: 512 * 150, color: Colors.red),
    Player(
        units: 512, playerPos: [309], maxUnits: 512 * 150, color: Colors.green)
  ];

  List<int> waterPos = [];

  List<int> mountainPos = [];

  void startGame() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        for (var player in players) {
          recalculateMaxPlayerUnits(player);
          generateUnits(player);
          expandPlayerPosition(player);
        }
      });
    });
  }

  void recalculateMaxPlayerUnits(Player player) {
    player.maxUnits = player.cells * 150;
  }

  void expandPlayerPosition(Player player) {
    int perimeter = 1; // Example: 1 cell in each diagonal direction
    int conquestCost = 20; // Cost for conquering a LandPixel

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
              // Check if the new position is a LandPixel and not already occupied by another player
              if (!players.any((p) => p.playerPos.contains(newPos))) {
                // Check if the player has enough units to conquer the LandPixel
                if (player.units >= conquestCost) {
                  newPlayerPos.add(newPos);
                  player.units -=
                      conquestCost; // Deduct the cost from player's units
                  player.cells++;
                }
              }
            }
          }
        }
      }
    }
    player.playerPos = newPlayerPos;
  }

  void generateUnits(Player player) {
    int newUnits = player.units + player.cells * 2;
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
          Expanded(child: Container()),
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: totalNumberOfCells,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: rowSize,
              ),
              itemBuilder: (context, index) {
                for (var player in players) {
                  if (player.playerPos.contains(index)) {
                    return PlayerPixel(
                        units: player.units,
                        color:
                            player.color); // Pass player's color to PlayerPixel
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
              child: MaterialButton(
                color: Colors.green,
                onPressed: () {
                  startGame();
                },
                child: const Text("Jouer"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
