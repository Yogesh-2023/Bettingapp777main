import 'dart:convert';
import 'dart:developer';
import 'package:marquee/marquee.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:new_sara/Bids/KingStarlineResultHis/KingStarlineResultHis.dart';
import 'package:new_sara/KingStarline&Jackpot/KingStarlineOptionScreen.dart';
import 'package:new_sara/l10n/app_localizations.dart';

import '../components/KingJackpotBiddingClosedDialog.dart';
import '../ulits/Constents.dart';
import '../Helper/UserController.dart';

//// MAIN STARLINE DASHBOARD ANIMATION
Widget runningTitle(String text) {
  return SizedBox(
    height: 22,
    width: 180,
    child: Marquee(
      text: text,
      scrollAxis: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      blankSpace: 40,
      velocity: 30,
      pauseAfterRound: Duration.zero,
      startPadding: 10,
      accelerationDuration: const Duration(seconds: 1),
      decelerationDuration: const Duration(milliseconds: 500),
      style: GoogleFonts.poppins(
        color: Color(0xFF0F4C81),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

///
///
///
/// ---- Data Model ----
class StarlineGame {
  final int id; // from gameId
  final String time; // from gameName (e.g., "09:30 PM")
  final String status; // from statusText
  final String result; // from result
  final bool isClosed; // !playStatus
  final String openTime; // from openTime
  final String closeTime; // from closeTime
  final String additionalInfo; // "Bid closed at <closeTime>" when closed

  StarlineGame({
    required this.id,
    required this.time,
    required this.status,
    required this.result,
    required this.isClosed,
    required this.openTime,
    required this.closeTime,
    this.additionalInfo = '',
  });

  static bool _toBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      return s == 'true' ||
          s == '1' ||
          s == 'open' ||
          s == 'active' ||
          s == 'running';
    }
    return false;
  }

  factory StarlineGame.fromJson(Map<String, dynamic> json) {
    final int gameId = () {
      final v = json['gameId'];
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }();

    final String gameName = (json['gameName'] ?? 'N/A').toString();
    final String result = (json['result'] ?? '****-*').toString();
    final String statusText = (json['statusText'] ?? 'Unknown').toString();
    final bool playStatus = _toBool(json['playStatus']); // true => open
    final String closeTime = (json['closeTime'] ?? '--:--').toString();
    final String openTime = (json['openTime'] ?? '--:--').toString();

    final bool closed = !playStatus;
    final String displayStatus = statusText.isEmpty
        ? (closed ? 'Closed' : 'Open')
        : statusText;
    // Note: Localization will be handled in the widget where context is available
    final String displayAdditionalInfo = closed
        ? 'Bid closed at $closeTime'
        : '';

    return StarlineGame(
      id: gameId,
      time: gameName,
      status: displayStatus,
      result: result,
      isClosed: closed,
      openTime: openTime,
      closeTime: closeTime,
      additionalInfo: displayAdditionalInfo,
    );
  }
}

/// ---- Screen ----
class KingStarlineDashboardScreen extends StatefulWidget {
  const KingStarlineDashboardScreen({super.key});

  @override
  State<KingStarlineDashboardScreen> createState() =>
      _KingStarlineDashboardScreenState();
}

class _KingStarlineDashboardScreenState
    extends State<KingStarlineDashboardScreen> {
  bool _notificationsEnabled = true;
  List<StarlineGame> _gameTimes = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final GetStorage _storage = GetStorage();
  final UserController userController = Get.put(UserController());

  // Non-nullable registeredId (loaded from local storage)
  String _registeredId = '';

  @override
  void initState() {
    super.initState();
    _loadAuthData();
    _fetchGameList();
  }

  void _loadAuthData() {
    // Signup/Login par jo save kiya tha, wahi se seedha utha rahe hain
    final rid = _storage.read('registerId')?.toString() ?? '';
    _registeredId = rid;
    log(
      'RegisteredId loaded: ${_registeredId.isEmpty ? "(empty)" : _registeredId}',
    );
  }

  Map<String, String> _buildHeaders(
    String accessToken, {
    String? deviceId,
    String? deviceName,
    bool accountStatus = true,
  }) {
    final now = DateTime.now();
    return {
      'deviceId':
          deviceId ??
          (_storage.read('deviceId')?.toString() ?? 'unknown_device'),
      'deviceName':
          deviceName ??
          (_storage.read('deviceName')?.toString() ?? 'unknown_model'),
      'accessStatus': accountStatus ? '1' : '0',
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
      // helpful for backend time reconciliation
      'x-client-time': now.toIso8601String(),
      'x-tz-offset-mins': now.timeZoneOffset.inMinutes.toString(),
      'x-tz-name': now.timeZoneName,
    };
  }

  Future<void> _fetchGameList() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final String? accessToken = _storage.read('accessToken');
    final String? registerId = _storage.read('registerId');
    final bool accountStatus = (_storage.read('accountStatus') ?? true) == true;

      if (accessToken == null || accessToken.isEmpty) {
      log('Error: Access token not found. Cannot fetch Starline game list.');
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _errorMessage = l10n?.accessTokenNotFound ?? 'Access token not found. Please log in again.';
        _isLoading = false;
      });
      return;
    }

    if (registerId == null || registerId.isEmpty) {
      log('Error: Register ID not found. Cannot fetch Starline game list.');
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _errorMessage = l10n?.registerIdNotFound ?? 'Register ID not found. Please log in again.';
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('${Constant.apiEndpoint}starline-game-list');
    final headers = _buildHeaders(accessToken, accountStatus: accountStatus);
    final body = jsonEncode({'registerId': registerId});

    try {
      final response = await http.post(url, headers: headers, body: body);

      log('Starline Game List API Status: ${response.statusCode}');
      log('Starline Game List API Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(response.body) as Map<String, dynamic>;

        if (responseData['status'] == true && responseData['info'] is List) {
          final List rawList = responseData['info'] as List;
          final games = rawList
              .map(
                (e) =>
                    StarlineGame.fromJson((e as Map).cast<String, dynamic>()),
              )
              .toList();

          // Sort by time if parseable (hh:mm a)
          final fmt = DateFormat('hh:mm a');
          games.sort((a, b) {
            DateTime? ta, tb;
            try {
              final pa = fmt.parse(a.time);
              ta = DateTime(1970, 1, 1, pa.hour, pa.minute);
            } catch (_) {}
            try {
              final pb = fmt.parse(b.time);
              tb = DateTime(1970, 1, 1, pb.hour, pb.minute);
            } catch (_) {}
            if (ta == null && tb == null) return 0;
            if (ta == null) return 1;
            if (tb == null) return -1;
            return ta.compareTo(tb);
          });

          if (!mounted) return;
          setState(() {
            _gameTimes = games;
            _isLoading = false;
          });
        } else {
          final l10n = AppLocalizations.of(context);
          final msg = (responseData['msg'] ?? (l10n?.failedToLoadGameData ?? 'Failed to load game data.'))
              .toString();
          log('Starline Game List API Error: $msg');
          if (!mounted) return;
          setState(() {
            _errorMessage = msg;
            _isLoading = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage =
              'Error ${response.statusCode}: ${response.reasonPhrase ?? 'Unknown error'}\n${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Exception during Starline Game List API call: $e');
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _errorMessage = l10n?.anErrorOccurred(e.toString()) ?? 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  void _onPlayTap(StarlineGame game) {
    log(
      'Play Game tapped => id=${game.id}, time=${game.time}, status=${game.status}, isClosed=${game.isClosed}',
    );

    if (game.isClosed) {
      showDialog(
        context: context,
        builder: (_) => KingJackpotBiddingClosedDialog(
          time: game.time,
          resultTime: game.openTime,
          bidLastTime: game.closeTime,
        ),
      );
      return;
    }

    // BEST PRACTICE: registeredId must be non-empty, warna navigate mat karo
    if (_registeredId.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.registerIdMissing ?? 'Register ID missing. Please log in again.'),
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KingStarlineOptionScreen(
          title: l10n?.kingStarline ?? 'King Starline',
          gameTime: game.time,
          starlineGameId: game.id, // session/game id
          paanaStatus: !game.isClosed, // open/close info
          registeredId: _registeredId, // non-null String
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Main Content Container
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
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
                      // Custom Header
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFF5F5F5,
                                ), // second image jaisa look
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  // 🔹 BACK BUTTON (NO CHANGE)
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

                                  const SizedBox(width: 8),

                                  // 🔹 RUNNING TITLE (FIXED OVERFLOW)
                                  Expanded(
                                    child: Builder(
                                      builder: (context) {
                                        final l10n = AppLocalizations.of(context);
                                        return SizedBox(
                                          height: 22,
                                          child: Text(
                                            l10n?.mainStarlineDashboard ?? 'MAIN STARLINE DASHBOARD',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              color: Color(0xFF0F4C81),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );

                                      },
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // 🔹 WALLET CAPSULE (NO CHANGE)
                                  // Obx(
                                  //   () => userController.accountStatus.value
                                  //       ? Container(
                                  //           padding: const EdgeInsets.symmetric(
                                  //             horizontal: 16,
                                  //             vertical: 8,
                                  //           ),
                                  //           decoration: BoxDecoration(
                                  //             color: const Color(0xFF0B1223),
                                  //             borderRadius:
                                  //                 BorderRadius.circular(40),
                                  //           ),
                                  //           child: Row(
                                  //             children: [
                                  //               Image.asset(
                                  //                 "assets/images/ic_wallet.png",
                                  //                 width: 20,
                                  //                 height: 20,
                                  //                 color: Colors.white,
                                  //               ),
                                  //               const SizedBox(width: 8),
                                  //               Text(
                                  //                 "₹${userController.walletBalance.value}",
                                  //                 style: const TextStyle(
                                  //                   color: Colors.white,
                                  //                   fontWeight: FontWeight.w600,
                                  //                   fontSize: 14,
                                  //                 ),
                                  //               ),
                                  //             ],
                                  //           ),
                                  //         )
                                  //       : const SizedBox.shrink(),
                                  // ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 4),
                            // HISTORY AND NOTIFICATIONS CONTROLS BELOW TITLE
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 🔹 HISTORY (ICON + TEXT – GREY)
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            KingStarlineResultScreen(),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.history,
                                        size: 34,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Builder(
                                        builder: (context) {
                                          final l10n = AppLocalizations.of(context);
                                          return Text(
                                            l10n?.history ?? "History",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                // 🔹 NOTIFICATION + SWITCH (RIGHT SIDE)
                                Row(
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final l10n = AppLocalizations.of(context);
                                        return Text(
                                          l10n?.notification ?? "Notification",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),

                                    // 🔹 SMALL SIZE SWITCH (IMAGE JAISE)
                                    Transform.scale(
                                      scale:
                                          0.8, // 👈 yahin se size control hota hai
                                      child: Switch(
                                        value: _notificationsEnabled,
                                        activeColor: Colors.green,
                                        activeTrackColor: Colors.green.shade200,
                                        inactiveThumbColor: Colors.grey,
                                        inactiveTrackColor:
                                            Colors.grey.shade300,
                                        onChanged: (v) {
                                          setState(
                                            () => _notificationsEnabled = v,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
SizedBox(height: 4,),
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5.0,
                              ),
                              child: Column(
                                children: [
                                  Builder(
                                    builder: (context) {
                                      final l10n = AppLocalizations.of(context);
                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              _buildInfoCard(
                                                l10n?.singleDigit ?? 'Single Digit',
                                                '10-100',
                                              ),
                                              const SizedBox(width: 4),
                                              _buildInfoCard(
                                                l10n?.doublePana ?? 'Double Pana',
                                                '10-3200',
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              _buildInfoCard(
                                                l10n?.singlePana ?? 'Single Pana',
                                                '10-1600',
                                              ),
                                              const SizedBox(width: 10),
                                              _buildInfoCard(
                                                l10n?.triplePana ?? 'Triple Pana',
                                                '10-10000',
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 3),
                            if (_isLoading)
                              const Expanded(
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF3882F6),
                                  ),
                                ),
                              )
                            else if (_errorMessage.isNotEmpty)
                              Expanded(
                                child: Center(
                                  child: Text(
                                    _errorMessage,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF3882F6),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                child: Container(
                                  color: Colors.white,
                                  child: GridView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.95,
                                      crossAxisSpacing: 8,
                                      mainAxisSpacing: 8,
                                    ),
                                    itemCount: _gameTimes.length,
                                    itemBuilder: (_, i) {
                                      final g = _gameTimes[i];
                                      return _buildGameTimeGridItem(game: g);
                                    },
                                  ),
                                ),
                              ),
                          ],
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

  Widget _buildInfoCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade400, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3882F6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTimeGridItem({required StarlineGame game}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// 1. TOP SECTION: TIME & RESULT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    game.time,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F4C81),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    game.result.trim().isNotEmpty ? game.result.trim() : "**",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3882F6),
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(),

            /// 2. STATUS TEXT
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: game.isClosed ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    game.isClosed
                        ? (l10n?.closedForToday ?? "Closed for Today").toUpperCase()
                        : (l10n?.runningNow ?? "Running Now").toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: game.isClosed ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                  ),
                );
              },
            ),

            const Spacer(),

            /// 3. PLAY BUTTON (SLEEK WHITE UI)
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return GestureDetector(
                  onTap: () => _onPlayTap(game),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: game.isClosed ? Colors.grey.withOpacity(0.2) : const Color(0xFF3882F6).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: game.isClosed ? Colors.grey.shade300 : const Color(0xFF3882F6).withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          game.isClosed ? Icons.not_interested : Icons.play_circle_fill,
                          color: game.isClosed ? Colors.grey.shade400 : const Color(0xFF3882F6),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          (l10n?.playGame ?? "Play Game").toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: game.isClosed ? Colors.grey.shade500 : const Color(0xFF3882F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  }

