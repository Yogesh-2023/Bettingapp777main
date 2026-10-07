// File: lib/HomePage.dart
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import 'package:new_sara/Fund/WithdrawScreen.dart';
import 'package:new_sara/Navigation/FundsFragmentContainer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Helper/UserController.dart';
import '../KingStarline&Jackpot/KingJackpotDashboard.dart';
import '../KingStarline&Jackpot/KingStarlineDashboard.dart';
import '../components/closeBidDialogue.dart';
import '../game/GameScreen.dart';
import '../ulits/Constents.dart';
import 'package:new_sara/l10n/app_localizations.dart';
import 'package:new_sara/Helper/LocaleHelper.dart';
import 'CricketQuizWidget.dart';

/// HomePage — merged final UI (gradient, marquee, pills, big card list)

// ---------------- Data Models ----------------
class HomeData {
  final bool status;
  final String msg;
  final List<Info>? result;

  HomeData({required this.status, required this.msg, this.result});

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
    status: _b(json["status"]),
    msg: json["msg"]?.toString() ?? '',
    result: json["info"] == null
        ? []
        : List<Info>.from(
            (json["info"] as List).map(
              (x) => Info.fromJson(x as Map<String, dynamic>),
            ),
          ),
  );
}

class Info {
  final int gameId;
  final String gameName;
  final String gameNameHindi;
  final String openTime;
  final String closeTime;
  final String result;
  final String statusText;
  final bool openSessionStatus;
  final bool closeSessionStatus;

  Info({
    required this.gameId,
    required this.gameName,
    this.gameNameHindi = '',
    required this.openTime,
    required this.closeTime,
    required this.result,
    required this.statusText,
    required this.openSessionStatus,
    required this.closeSessionStatus,
  });

  factory Info.fromJson(Map<String, dynamic> json) => Info(
    gameId: int.tryParse(json["gameId"].toString()) ?? 0,
    gameName: json["gameName"]?.toString() ?? '',
    gameNameHindi:
        json["gameNameHindi"]?.toString() ??
        json["game_name_hindi"]?.toString() ??
        '',
    openTime: json["openTime"]?.toString() ?? '',
    closeTime: json["closeTime"]?.toString() ?? '',
    result: json["result"]?.toString() ?? '',
    statusText: json["statusText"]?.toString() ?? '',
    openSessionStatus: _b(json["openSessionStatus"]),
    closeSessionStatus: _b(json["closeSessionStatus"]),
  );
}

bool _b(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    return s == '1' || s == 'true' || s == 'yes' || s == 'y';
  }
  return false;
}

class ContactDetails {
  final String? mobileNo;
  final String? whatsappNo;
  final String? homepageContent;

  ContactDetails({this.mobileNo, this.whatsappNo, this.homepageContent});
}

HomeData homeDataFromJson(String str) =>
    HomeData.fromJson(json.decode(str) as Map<String, dynamic>);

// ---------------- HomePage ----------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<HomeData> _futureHomeData;
  late Future<ContactDetails?> _futureContactDetails;
  final GetStorage _storage = GetStorage();

  late final UserController userController = Get.isRegistered<UserController>()
      ? Get.find<UserController>()
      : Get.put(UserController(), permanent: true);

  late String _preferredLanguage;

  // Helper function to translate game names based on locale
  String _translateGameName(
    String gameName,
    String gameNameHindi,
    BuildContext context,
  ) {
    final langCode = LocaleHelper.getLanguageCode();

    // Use Hindi name if available and language is Hindi
    if (langCode == 'hi' && gameNameHindi.isNotEmpty) {
      return gameNameHindi;
    }

    // For other Indian languages, you can add more mappings here
    // For now, return original English name
    return gameName;
  }

  @override
  void initState() {
    super.initState();
    _preferredLanguage = _storage.read('selectedLanguage') ?? 'en';
    _futureHomeData = _fetchDashboardData();
    _futureContactDetails = fetchContactDetail();

    // react to auth/token changes
    everAll([userController.accessToken, userController.registerId], (_) {
      setState(() {
        _futureHomeData = _fetchDashboardData();
        _futureContactDetails = fetchContactDetail();
      });
    });
  }

  // Removed _preTranslateUI and _t as we'll use AppLocalizations directly

  Future<HomeData> _fetchDashboardData() async {
    final token = _storage.read('accessToken') ?? '';
    final regId = _storage.read('registerId') ?? '';

    if (token.isEmpty || regId.isEmpty) {
      log("Missing token/regId — returning empty HomeData");
      return HomeData(status: false, msg: "Not logged", result: []);
    }

    final response = await http.post(
      Uri.parse("${Constant.apiEndpoint}game-list"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode({"registerId": regId}),
    );

    if (response.statusCode == 200) {
      try {
        return homeDataFromJson(response.body);
      } catch (e, st) {
        log("Parse error: $e", stackTrace: st);
        return HomeData(status: false, msg: "Parse error", result: []);
      }
    } else {
      log("game-list failed: ${response.statusCode} ${response.body}");
      return HomeData(status: false, msg: "Failed", result: []);
    }
  }

  Future<ContactDetails?> fetchContactDetail() async {
    try {
      final response = await http.get(
        Uri.parse("${Constant.apiEndpoint}contact-detail"),
        headers: {
          "Authorization": "Bearer ${_storage.read('accessToken') ?? ''}",
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final contactInfo =
            (data['info'] as Map?)?['contactInfo'] as Map<String, dynamic>?;
        return ContactDetails(
          mobileNo: contactInfo?['mobileNo']?.toString(),
          whatsappNo: contactInfo?['whatsappNo']?.toString(),
          homepageContent: contactInfo?['homepageContent']?.toString(),
        );
      }
    } catch (e) {
      log("contact-detail error: $e");
    }
    return null;
  }

  Future<void> _handleRefresh() async {
    try {
      await userController.refreshEverything();
      setState(() {
        _futureHomeData = _fetchDashboardData();
        _futureContactDetails = fetchContactDetail();
      });
    } catch (e) {
      log("refresh error: $e");
    }
  }

  // Open/Call helpers (used by contact pills)
  Future<void> _openWhatsApp(String raw) async {
    var p = raw.replaceAll(RegExp(r'[^0-9]'), '');
    p = p.replaceFirst(RegExp(r'^0+'), '');
    if (p.length == 10) p = '91$p';
    final uri = Uri.parse('https://wa.me/$p');
    if (await canLaunchUrl(uri))
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EEF5),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFE8EEF5)), 
        child: RefreshIndicator(
            color: const Color(0xFF3882F6),
            onRefresh: _handleRefresh,
            child: FutureBuilder<HomeData>(
              future: _futureHomeData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3882F6)),
                  );
                }
                if (snapshot.hasError) {
                  log("Future error: ${snapshot.error}");
                  final l10n = AppLocalizations.of(context);
                  return Center(
                    child: Text(
                      l10n?.errorLoadingData ?? "Error loading data.",
                      style: const TextStyle(color: Color(0xFF3882F6)),
                    ),
                  );
                }
                final results = snapshot.data?.result ?? [];
                if (results.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    children: [
                      // show marquee if available
                      FutureBuilder<ContactDetails?>(
                        future: _futureContactDetails,
                        builder: (context, s) {
                          if (s.hasData &&
                              (s.data?.homepageContent ?? '').isNotEmpty) {
                            return SizedBox(
                              // height: 30,
                              child: Marquee(
                                text: s.data!.homepageContent!,
                                style: GoogleFonts.poppins(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                blankSpace: 50,
                                velocity: 32,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                      const SizedBox(height: 12),
                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context);
                          return Center(
                            child: Text(
                              l10n?.noGameDataAvailable ??
                                  "No game data available.",
                              style: const TextStyle(color: Colors.black54),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }

                return ListView(
                  padding: const EdgeInsets.only(top: 0, bottom: 2),
                  children: [
                    // ------- MARQUEE (top) ------- (Wrapped in Obx for accountStatus check)
                    Obx(
                      () => userController.accountStatus.value
                          ? Container(
                              margin: EdgeInsets.zero,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.4),
                                border: Border(
                                  top: BorderSide(color: const Color(0xFF3882F6).withOpacity(0.2), width: 1),
                                  bottom: BorderSide(color: const Color(0xFF3882F6).withOpacity(0.2), width: 1),
                                ),
                              ),
                              child: FutureBuilder<ContactDetails?>(
                                future: _futureContactDetails,
                                builder: (context, s) {
                                  if (s.hasData && (s.data?.homepageContent ?? '').isNotEmpty) {
                                    return SizedBox(
                                      height: 30,
                                      child: Marquee(
                                        text: "📢 WELCOME TO SARA777 - 24*7 SERVICE AVAILABLE  |  " + (s.data?.homepageContent ?? '') + '     ',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF0F4C81), // Royal Blue
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                        blankSpace: 50,
                                        velocity: 35,
                                        pauseAfterRound: const Duration(seconds: 1),
                                        startPadding: 10.0,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 8),

                    // ———————— UNIFIED ACTION CARD (Games + Funds) ————————
                    Obx(
                      () => userController.accountStatus.value
                          ? Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // 1. Unified Category Row (Starline & Jackpot) - Stuck to top
                                    Container(
                                      height: 55,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.5),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ZoomingWidget(
                                              child: Builder(builder: (context) {
                                                final l10n = AppLocalizations.of(context);
                                                return _categoryButtonUnified(
                                                  title: l10n?.kingStarline ?? "KING STARLINE",
                                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KingStarlineDashboardScreen())),
                                                );
                                              }),
                                            ),
                                          ),
                                          Container(width: 1, color: Colors.grey.shade300, height: 55),
                                          Expanded(
                                            child: ZoomingWidget(
                                              child: Builder(builder: (context) {
                                                final l10n = AppLocalizations.of(context);
                                                return _categoryButtonUnified(
                                                  title: l10n?.kingJackpot ?? "KING JACKPOT",
                                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => KingJackpotDashboard())),
                                                );
                                              }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // 2. Main Padding for content below
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Column(
                                        children: [
                                          // Fund Action Row (Magenta Bar)
                                          Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)], // Crystal blue gradient
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              border: Border.all(color: Colors.white, width: 2),
                                              boxShadow: [
                                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                                              ],
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Builder(builder: (context) {
                                                    final l10n = AppLocalizations.of(context);
                                                    return _fundActionButtonUnified(
                                                      icon: Icons.currency_rupee,
                                                      title: l10n?.addMoney ?? "ADD MONEY",
                                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FundsFragmentContainer())),
                                                    );
                                                  }),
                                                ),
                                                Container(
                                                  width: 1.5,
                                                  height: 20,
                                                  color: Colors.white,
                                                ),
                                                Expanded(
                                                  child: Builder(builder: (context) {
                                                    final l10n = AppLocalizations.of(context);
                                                    return _fundActionButtonUnified(
                                                      icon: Icons.account_balance,
                                                      title: l10n?.withdrawFunds ?? "WITHDRAW",
                                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawScreen())),
                                                    );
                                                  }),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          // 3. Separate WhatsApp Support Tiles
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _whatsappContactPillSeparate("+918905004880"),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: _whatsappContactPillSeparate("+918905004880"),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // ------- BIG CARD vs QUIZ -------
                    Obx(
                      () => userController.accountStatus.value
                          ? Container(
                              margin: const EdgeInsets.only(top: 15),
                              padding: const EdgeInsets.only(top: 10, bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.4), // Section background glassy
                                border: Border.all(color: Colors.white, width: 2), // White outline
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(35),
                                  topRight: Radius.circular(35),
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Section Header for Games
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                    child: Row(
                                      children: [
                                        Container(width: 4, height: 20, color: const Color(0xFF0F4C81)),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "ALL MARKET GAMES",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF0F4C81),
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                    _buildBigGameCard(results),
                                  ],
                                ),
                              ).animateIn(delay: 200) // Animation for section
                          : const CricketQuizWidget(),
                    ),

                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
          ),
      ),
    );
  }

  // ---------------- Widgets ----------------

  Widget _categoryButtonUnified({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFF0F4C81), // Blue icon circle
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF0F4C81),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fundActionButtonUnified({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(icon, size: 16, color: const Color(0xFF3882F6)),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0F4C81),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getStatusIcon(String status) {
    status = status.toLowerCase();

    if (status.contains("open for today")) {
      return "assets/images/open_icon.png";
    }
    if (status.contains("closed for today")) {
      return "assets/images/closed_icon.png";
    }
    if (status.contains("holiday for today")) {
      return "assets/images/holiday_icon.png";
    }

    return "assets/images/closed_icon.png"; // default
  }

  Widget _whatsappContactPillSeparate(String number) {
    return GestureDetector(
      onTap: () => _openWhatsApp(number),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/whatsapp.png",
              width: 24,
              height: 24,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.chat, color: Color(0xFF25D366), size: 20),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                number,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF25D366),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactPill({
    required String icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Image.asset(
              icon,
              width: 24,
              height: 24,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.phone, color: Colors.green),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getPlayIcon(String status) {
    status = status.toLowerCase();

    if (status.contains("open for today")) {
      return "assets/images/play3.png"; // आपकी open image
    } else if (status.contains("closed for today")) {
      return "assets/images/play6.png"; // आपकी open image
    } else if (status.contains("holiday for today")) {
      return "assets/images/play4.png"; // आपकी closed image
    }
    return "assets/images/play4.png"; // आपकी closed image
  }

  Widget _buildBigGameCard(List<Info> results) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        childAspectRatio: 0.75, // Adjust this to fit all elements
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final game = results[index];
        final bool isClosed = game.statusText.toLowerCase().contains("closed") || 
                             game.statusText.toLowerCase().contains("holiday");

        return FadeInUp(
          delay: (index % 6) * 100,
          child: Card(
            elevation: 0,
            color: Colors.white.withOpacity(0.6), // Individual card glassy
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.white, width: 1.5),
            ),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// 1. GAME NAME (Top - Centered)
                  Text(
                    _translateGameName(
                      game.gameName,
                      game.gameNameHindi,
                      context,
                    ).toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF0F4C81),
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  /// 2. ACTION ICON (Centered)
                  _statusActionIcon(game),

                  /// 3. BID TIMES
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context);
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _timeColumn(l10n?.openBids ?? "OPEN", game.openTime),
                              _timeColumn(l10n?.closeBids ?? "CLOSE", game.closeTime),
                            ],
                          ),
                        ],
                      );
                    },
                  ),

                  /// 4. RESULT (Purple/Bold)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      game.result.isEmpty ? "***-**-***" : game.result,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF480E53),
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  /// 5. STATUS (Small Red/Green)
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context);
                      String statusText = game.statusText;
                      if (statusText.toLowerCase().contains("closed")) {
                        statusText = l10n?.closedForToday ?? "CLOSED FOR TODAY";
                      } else if (statusText.toLowerCase().contains("open")) {
                        statusText = l10n?.bettingIsRunning ?? "RUNNING";
                      }

                      return Text(
                        statusText.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: !isClosed ? const Color(0xFF2E7D32) : const Color(0xFFB71C1C),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _timeColumn(String label, String time) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _statusActionIcon(Info game) {
    final status = game.statusText.toLowerCase();
    final bool isClosed =
        status.contains("closed for today") || status.contains("holiday");

    return GestureDetector(
      onTap: () {
        if (isClosed) {
          closeBidDialogue(
            context: context,
            gameName: game.gameName,
            openResultTime: game.openTime,
            openBidLastTime: game.openTime,
            closeResultTime: game.closeTime,
            closeBidLastTime: game.closeTime,
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GameMenuScreen(
                title: game.gameName,
                gameId: game.gameId,
                openSessionStatus: game.openSessionStatus,
                closeSessionStatus: game.closeSessionStatus,
              ),
            ),
          );
        }
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFF0F4C81), // Vibrant Blue
          shape: BoxShape.circle,
        ),
        child: Icon(
          isClosed ? Icons.close : Icons.play_arrow,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}

extension WidgetAnimation on Widget {
  Widget animateIn({int delay = 0}) => FadeInUp(delay: delay, child: this);
}

// ———————— HELPER ANIMATION WIDGETS ————————
class FadeInUp extends StatefulWidget {
  final Widget child;
  final int delay;
  const FadeInUp({super.key, required this.child, this.delay = 0});

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _offset = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
} // End of HomePage class extension or helper section

// ———————— HELPER ANIMATION WIDGET ————————
class ZoomingWidget extends StatefulWidget {
  final Widget child;
  const ZoomingWidget({super.key, required this.child});

  @override
  State<ZoomingWidget> createState() => _ZoomingWidgetState();
}

class _ZoomingWidgetState extends State<ZoomingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
