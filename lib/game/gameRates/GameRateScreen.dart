import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:new_sara/l10n/app_localizations.dart';

class GameRateScreen extends StatefulWidget {
  const GameRateScreen({super.key});

  @override
  State<GameRateScreen> createState() => _GameRateScreenState();
}

class _GameRateScreenState extends State<GameRateScreen> {
  Map<String, dynamic>? gameRates;

  @override
  void initState() {
    super.initState();
    fetchGameRates();
  }

  Future<void> fetchGameRates() async {
    String token = GetStorage().read("accessToken");
    final url = Uri.parse('https://admin.mhmatka.app/api/v1/game-rate');
    final response = await http.get(
      url,
      headers: {
        'deviceId': 'qwert',
        'deviceName': 'sm2233',
        'accessStatus': '1',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          gameRates = jsonData['info'];
        });
      }
    } else {
      if (mounted) {
        debugPrint('Failed to load game rates: ${response.statusCode}');
      }
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3882F6), // Magenta accent
          ),
        ),
      ),
    );
  }


  Widget rateRow(String label, dynamic value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F4C81),
                ),
              ),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F4C81),
                ),
              ),
            ],
          ),
        ),

        // Divider like screenshot
        Container(height: 1, color: Color(0xFF0F4C81).withOpacity(0.2)),
      ],
    );
  }


  Widget buildRates(String title, Map<String, dynamic> rates, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        sectionHeader(title),

        ...rates.entries.map((e) {
          final label = formatLabel(e.key, context);
          return rateCard(
            l10n?.rateFormat(label, e.value.toString()) ??
                "${label}: 10 Ka ${e.value}",
          );
        }).toList(),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget rateCard(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7), // Light peach accent
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFF0F4C81)),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0F4C81).withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F4C81),
          ),
        ),
      ),
    );
  }
  Widget sectionHeader(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF3882F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F4C81),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }


  String formatLabel(String key, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'singleDigit':
        return l10n?.single ?? 'Single';
      case 'jodi':
        return l10n?.jodi ?? 'Jodi';
      case 'singlePanna':
        return l10n?.singlePanna ?? 'Single Panna';
      case 'doublePanna':
        return l10n?.doublePanna ?? 'Double Panna';
      case 'triplePanna':
        return l10n?.triplePanna ?? 'Triple Panna';
      case 'halfSangam':
        return l10n?.halfSangam ?? 'Half Sangam';
      case 'fullSangam':
        return l10n?.fullSangam ?? 'Full Sangam';
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white, // White theme
      body: Container(
        padding: const EdgeInsets.only(top: 12, left: 16, right: 16), // thoda gap
        child: gameRates == null
            ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF3882F6)),
        )
            : SingleChildScrollView(
          child: Column(
            children: [
              buildRates(
                l10n?.gameWinRatioForAllBids ?? 'Game Win Ratio for All Bids',
                gameRates!['gameRate'],
                context,
              ),
              buildRates(
                l10n?.starlineWinRatioForAllBids ?? 'Starline Win Ratio for All Bids',
                gameRates!['starlineGameRate'],
                context,
              ),
              buildRates(
                l10n?.jackpotWinRatio ?? 'Jackpot Win Ratio',
                gameRates!['jackpotGameRate'],
                context,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
