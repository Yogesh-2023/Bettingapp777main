import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../Helper/TranslationHelper.dart';
import '../Helper/UserController.dart';
import '../ulits/Constents.dart';

// Import your game screens here
import 'games/StarlineSingleDigit.dart';
import 'games/StarlineSinglePana.dart';
import 'games/StarlineDoublePana.dart';
import 'games/StarlineTriplePana.dart';
import 'games/StarlineSPDPTPScreen.dart';
import 'games/StarlineSPMotorsScreen.dart';
import 'games/StarlineDPMotorsScreen.dart';
import 'games/StarlineOddEvenBoardScreen.dart';

class KingStarlineBidType {
  final int id;
  final String title;
  final String image;
  final String type;
  final bool digitPannaStatus;
  String translatedTitle;

  KingStarlineBidType({
    required this.id,
    required this.title,
    required this.image,
    required this.type,
    required this.digitPannaStatus,
    this.translatedTitle = '',
  });

  factory KingStarlineBidType.fromJson(Map<String, dynamic> json) {
    return KingStarlineBidType(
      id: json['id'] ?? 0,
      title: json['name'] ?? '',
      image: json['image'] ?? '',
      type: json['type'] ?? '',
      digitPannaStatus: json['digitPannaStatus'] ?? false,
    );
  }

  void updateTranslatedTitle(String newTitle) {
    translatedTitle = newTitle;
  }
}

class KingStarlineOptionScreen extends StatefulWidget {
  final String gameTime;
  final String title;
  final dynamic starlineGameId;
  final bool paanaStatus;
  final String registeredId;

  const KingStarlineOptionScreen({
    super.key,
    required this.gameTime,
    required this.title,
    required this.starlineGameId,
    required this.paanaStatus,
    required this.registeredId,
  });

  @override
  State<KingStarlineOptionScreen> createState() =>
      _KingStarlineOptionScreenState();
}

class _KingStarlineOptionScreenState extends State<KingStarlineOptionScreen> {
  List<KingStarlineBidType> _options = [];
  bool _isLoading = true;
  final GetStorage _storage = GetStorage();
  final UserController userController = Get.put(UserController());

  late String _currentLanguageCode;
  final Map<String, String> _translationCache = {};
  
  // Translated strings
  String _noGamesAvailable = "No games available";
  String _pleaseLoginAgain = "Please login again";
  String _serverError = "Server error";
  String _networkError = "Network error";
  String _comingSoon = "Coming soon";

  @override
  void initState() {
    super.initState();
    _currentLanguageCode = _storage.read('selectedLanguage') ?? 'en';
    _loadTranslations();
    fetchKingStarlineBidTypes();

    _storage.listenKey('selectedLanguage', (value) {
      if (value is String && value != _currentLanguageCode) {
        _currentLanguageCode = value;
        _translationCache.clear();
        _loadTranslations();
        fetchKingStarlineBidTypes();
      }
    });
  }

  Future<void> _loadTranslations() async {
    _noGamesAvailable = await _getTranslatedText("No games available");
    _pleaseLoginAgain = await _getTranslatedText("Please login again");
    _serverError = await _getTranslatedText("Server error");
    _networkError = await _getTranslatedText("Network error");
    _comingSoon = await _getTranslatedText("Coming soon");
    if (mounted) setState(() {});
  }

  Future<String> _getTranslatedText(String text) async {
    if (_currentLanguageCode == 'en') return text;
    final cacheKey = '$text:$_currentLanguageCode';
    if (_translationCache.containsKey(cacheKey))
      return _translationCache[cacheKey]!;

    try {
      final translated = await TranslationHelper.translate(
        text,
        _currentLanguageCode,
      );
      if (translated.isNotEmpty) {
        _translationCache[cacheKey] = translated;
        return translated;
      }
    } catch (e) {
      log('Translation error: $e');
    }
    return text;
  }

  Future<void> fetchKingStarlineBidTypes() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _options.clear();
    });

    final url = Uri.parse('${Constant.apiEndpoint}starline-game-bid-type');
    final token = _storage.read("accessToken");

    if (token == null || token.isEmpty) {
      _showSnackBar(_pleaseLoginAgain);
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'deviceId': 'qwerr',
          'deviceName': 'sm2233',
          'accessStatus': '1',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['info'] != null) {
          final List<dynamic> list = data['info'];
          var fetched = list
              .map((e) => KingStarlineBidType.fromJson(e))
              .toList();

          // Translate titles
          for (var item in fetched) {
            item.translatedTitle = await _getTranslatedText(item.title);
          }

          if (mounted) {
            setState(() {
              _options = fetched;
              _isLoading = false;
            });
          }
        } else {
          _showSnackBar(_noGamesAvailable);
          setState(() => _isLoading = false);
        }
      } else {
        _showSnackBar("$_serverError: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar(_networkError);
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _navigateToScreen(KingStarlineBidType item) {
    final type = item.type.toLowerCase().trim();
    final title = "${widget.title} - ${item.translatedTitle}";

    Widget? screen;

    switch (type) {
      case 'singledigits':
        screen = StarlineSingleDigitBetScreen(
          title: title,
          gameId: widget.starlineGameId,
          gameName: item.title,
          gameCategoryType: item.type,
          selectionStatus: item.digitPannaStatus,
        );
        break;
      case 'singlepana':
        screen = StarlineSinglePannaScreen(
          title: title,
          gameId: widget.starlineGameId,
          gameName: item.title,
          gameType: item.type,
          selectionStatus: true,
        );
        break;
      case 'doublepana':
        screen = StarlineDoublePanaBetScreen(
          title: title,
          gameId: widget.starlineGameId,
          gameName: item.title,
          gameCategoryType: item.type,
          selectionStatus: true,
        );
        break;
      case 'triplepana':
        screen = StarlineTPMotorsScreen(
          title: title,
          gameId: widget.starlineGameId,
          gameName: item.title,
          gameCategoryType: item.type,
          selectionStatus: true,
        );
        break;
      case 'spdptp':
        screen = StarlineSpDpTpScreen(
          screenTitle: title,
          gameId: widget.starlineGameId,
          gameType: item.type,
        );
        break;
      case 'spmotor':
        screen = StarlineSPMotorsScreen(
          title: title,
          gameId: widget.starlineGameId,
          gameName: item.title,
          gameCategoryType: item.type,
        );
        break;
      case 'dpmotor':
        screen = StarlineDPMotorsScreen(
          title: title,
          gameId: widget.starlineGameId,
          gameName: item.title,
          gameCategoryType: item.type,
        );
        break;
      case 'oddeven':
        screen = StarlineOddEvenBoardScreen(
          title: title,
          gameId: widget.starlineGameId,
          gameName: item.title,
          gameType: item.type,
          selectionStatus: true,
        );
        break;
      default:
        _showSnackBar("$_comingSoon: ${item.title}");
    }

    if (screen != null && mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Space
              const SizedBox(height: 10),

              // Main White Container
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 15, 16, 20),
                  child: Column(
                    children: [
                      // Text(
                      //   widget.title,
                      //   style: const TextStyle(
                      //     fontSize: 24,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.black87,
                      //   ),
                      // ),
                      // const SizedBox(height: 30),

                      // Grid or Loader
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// 🔥 LEFT SIDE (Arrow + Title)
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
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
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ), // 👈 gap between arrow & title
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
                                  child: Text(
                                    widget.title, // 👉 "King"
                                    style: const TextStyle(
                                      color: Color(0xFF0F4C81),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            /// 🔥 RIGHT SIDE (Wallet)
                            Obx(
                              () => userController.accountStatus.value
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0B1223),
                                        borderRadius: BorderRadius.circular(40),
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/images/ic_wallet.png",
                                            width: 20,
                                            height: 20,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "₹${userController.walletBalance.value}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10),
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF3882F6),
                                  strokeWidth: 3,
                                ),
                              )
                            : _options.isEmpty
                            ? Center(
                                child: Text(
                                  _noGamesAvailable,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : GridView.builder(
                                padding: EdgeInsets.zero,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 0.85,
                                      crossAxisSpacing: 6,
                                      mainAxisSpacing: 6,
                                    ),
                                itemCount: _options.length,
                                itemBuilder: (context, index) {
                                  final item = _options[index];
                                  return _buildGameCard(item);
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

  Widget _buildGameCard(KingStarlineBidType item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToScreen(item),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3882F6).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.network(
                      item.image,
                      width: 28,
                      height: 28,
                      color: const Color(0xFF3882F6),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.casino, size: 28, color: Color(0xFF3882F6)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F4C81),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
