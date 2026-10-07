import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:new_sara/ChartScreen/ChartTableScreen.dart';
import 'package:new_sara/ulits/Constents.dart';
import 'package:new_sara/l10n/app_localizations.dart';

class Game {
  final int gameId;
  final String gameName;
  final String gameType;

  Game({required this.gameId, required this.gameName, required this.gameType});

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      gameId: json['gameId'],
      gameName: json['gameName'],
      gameType: json['gameType'],
    );
  }
}

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  List<Game> allGames = [];
  List<Game> filteredGames = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchGames();
  }

  Future<void> fetchGames() async {
    final url = '${Constant.apiEndpoint}chart-game-list';
    final String accessToken = GetStorage().read('accessToken');
    final String registerId = GetStorage().read('registerId');
    final String deviceId = GetStorage().read('deviceId');
    final String deviceName = GetStorage().read('deviceName');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'deviceId': deviceId,
          'deviceName': deviceName,
          'accessStatus': '1',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // truncated for brevity
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List gamesJson = jsonData['info'];

        final games = gamesJson.map((e) => Game.fromJson(e)).toList();

        setState(() {
          allGames = List<Game>.from(games);
          filteredGames = allGames;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  void filterSearch(String query) {
    final filtered = allGames
        .where(
          (game) => game.gameName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    setState(() {
      filteredGames = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      // Apply the same gradient background as MyBidsPage.dart
      backgroundColor: Colors.transparent,

      body: Container(
        width: double.infinity,
        height: double.infinity,

        /// 🔥 FULL GRADIENT BACKGROUND (Copied from MyBidsPage.dart)
        decoration: const BoxDecoration(
         color:Color(0xffFF6f00)
        ),

        child: SafeArea(
          child: Column(
            children: [
              //SizedBox(height: 12),

              // ⭐ OUTER ROUNDED CONTAINER WITH TOP ROUNDED CORNERS ONLY ⭐
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 0,
                  ), // Remove horizontal margin
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Color(0xffeeeeee),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30), // Match MyBidsPage radius
                      topRight: Radius.circular(30), // Match MyBidsPage radius
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 🔙 Arrow + Charts (LEFT)
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.grey,
                                      size: 26,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ), // gap between arrow & text

                                Text(
                                  l10n?.charts ?? 'Charts',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Search Field
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          controller: searchController,
                          onChanged: filterSearch,
                          decoration: InputDecoration(
                            hintText: l10n?.search ?? 'Search chart',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xffFF6f00),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),

                      // Game Grid
                      Expanded(
                        child: filteredGames.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : GridView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: filteredGames.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      childAspectRatio: 2.4,
                                    ),
                                itemBuilder: (context, index) {
                                  final game = filteredGames[index];
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                    //  backgroundColor: Color(0xffE8910C),
                                      backgroundColor: const Color(0xFFFF6f00), // 🔶 Orange background

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChartTableScreen(
                                            gameId: game.gameId,
                                            gameType: game.gameType,
                                          ),
                                        ),
                                      );
                                      // You can navigate or handle click here
                                    },
                                    child: Text(
                                      game.gameName,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
