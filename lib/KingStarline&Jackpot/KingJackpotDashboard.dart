import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import 'package:new_sara/Bids/KingJackpotResultHis/KingJackpotResultScreen.dart';
import 'package:new_sara/KingStarline&Jackpot/JackpotJodiOptionsScreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_sara/components/KingJackpotBiddingClosedDialog.dart';

import '../l10n/app_localizations.dart';
import '../ulits/Constents.dart';

class KingJackpotDashboard extends StatefulWidget {
  const KingJackpotDashboard({super.key});

  @override
  State<KingJackpotDashboard> createState() => _KingJackpotDashboardState();
}

class _KingJackpotDashboardState extends State<KingJackpotDashboard> {
  static const Color kCardBg = Colors.white;
  static const Color kPrimaryDark = Color(0xFF1D2232);

  bool isNotificationOn = true;
  late Future<JackpotGameData> futureGameData;

  int _totalJodiElements = 0;

  @override
  void initState() {
    super.initState();
    futureGameData = fetchGameData();
  }

  Future<JackpotGameData> fetchGameData() async {
    final storage = GetStorage();
    final String accessToken = storage.read('accessToken') ?? '';
    final String registerId = storage.read('registerId') ?? '';
    final String deviceId =
        storage.read('deviceId')?.toString() ?? 'unknown_device';
    final String deviceName =
        storage.read('deviceName')?.toString() ?? 'unknown_model';
    final bool accountStatus = (storage.read('accountStatus') ?? true) == true;

    dev.log('[Jackpot] Fetching...', name: 'KingJackpot');

    try {
      final now = DateTime.now();
      final uri = Uri.parse('${Constant.apiEndpoint}jackpot-game-list');
      final res = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
              'deviceId': deviceId,
              'deviceName': deviceName,
              'accessStatus': accountStatus ? '1' : '0',
              'Authorization': 'Bearer $accessToken',
              'x-client-time': now.toIso8601String(),
              'x-tz-offset-mins': now.timeZoneOffset.inMinutes.toString(),
              'x-tz-name': now.timeZoneName,
            },
            body: json.encode({'registerId': registerId}),
          )
          .timeout(const Duration(seconds: 20));

      dev.log('[Jackpot] Status: ${res.statusCode}', name: 'KingJackpot');
      dev.log('[Jackpot] Body: ${res.body}', name: 'KingJackpot');

      if (res.statusCode == 200) {
        final data = jackpotGameDataFromJson(res.body);

        if (data.info != null) {
          final count = data.info!.length;
          dev.log('[Jackpot] Total Jodi Elements: $count', name: 'KingJackpot');
          if (mounted) setState(() => _totalJodiElements = count);
        }
        return data;
      }

      throw Exception(
        'Failed to load jackpot game data: ${res.statusCode} - ${res.body}',
      );
    } catch (e) {
      dev.log('[Jackpot] Error: $e', name: 'KingJackpot');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Column(
            children: [
              //  const SizedBox(height: 4),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 8),
                      _buildChips(),
                      const SizedBox(height: 10),
                      Expanded(
                        child: RefreshIndicator(
                          color: Color(0xFF3882F6),
                          onRefresh: () async {
                            setState(() => futureGameData = fetchGameData());
                            await futureGameData;
                          },
                          child: FutureBuilder<JackpotGameData>(
                            future: futureGameData,
                            builder: (context, snap) {
                              if (snap.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF3882F6),
                                  ),
                                );
                              }

                              if (snap.hasError) {
                                return _errorView(
                                  context,
                                  message: '${l10n?.errorColon ?? 'Error:'} ${snap.error}',
                                  onRetry: () => setState(
                                    () => futureGameData = fetchGameData(),
                                  ),
                                );
                              }

                              final info = snap.data?.info;
                              if (info == null || info.isEmpty) {
                                return Center(
                                  child: Text(
                                    l10n?.noDataAddedYet ?? 'No data available.',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                );
                              }

                              return GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                                physics: const AlwaysScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.95,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: info.length,
                                itemBuilder: (context, i) {
                                  final g = info[i];
                                  return _buildGameGridCard(
                                      gameId: g.gameId,
                                      timeLabel: g.gameName,
                                      result: g.result,
                                      statusText: g.statusText,
                                      closeTime: g.closeTime,
                                      playStatus: g.playStatus,
                                  );
                                },
                              );
                            },
                          ),
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

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF0F4C81),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 24,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      l10n?.jackpotDashboard ?? 'Jackpot Dashboard',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F4C81),
                      ),
                    ),
                  ),
                ),


              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const SizedBox(width: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => KingJackpotResultScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //    SizedBox(width: 5),
                        Icon(Icons.history, color: Colors.black, size: 35),
                        SizedBox(width: 4),
                        Text(
                          l10n?.history ?? 'History',
                          style: TextStyle(
                            color: Color(0xFF0F4C81),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    l10n?.notifications ?? 'Notifications',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Transform.scale(
                    scale: 0.75, // 👈 size control
                    child: Switch(
                      value: isNotificationOn,
                      onChanged: (v) => setState(() => isNotificationOn = v),
                      activeColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChips() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(40)),
        child: _chip(
          l10n?.jodi ?? 'Jodi',
          isSelected: true,
        ),
      ),
    );
  }

  Widget _chip(String label, {bool isSelected = false}) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          children: [
            TextSpan(
              text: '${l10n?.jodi ?? 'Jodi'}         ',
              style: const TextStyle(color: Color(0xFF0F4C81)), // ✅ Jodi BLUE
            ),
            const TextSpan(
              text: '1 - 100',
              style: TextStyle(color: Color(0xFF3882F6)), // ✅ 1-100 MAGENTA
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameGridCard({
    required int gameId,
    required String timeLabel,
    required String result,
    required String statusText,
    required String closeTime,
    required bool playStatus,
  }) {
    final statusLower = statusText.toLowerCase().trim();
    final isClosedByText = statusLower == 'closed';
    final isRunningByText = statusLower == 'running';
    final canPlay = playStatus && !isClosedByText;
    final bool isRunning = isRunningByText || canPlay;

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
                    timeLabel,
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
                    result.trim().isNotEmpty ? result.trim() : "**",
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isClosedByText ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusText.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isClosedByText ? Colors.red.shade700 : Colors.green.shade700,
                ),
              ),
            ),

            const Spacer(),

            /// 3. PLAY BUTTON (SLEEK WHITE UI)
            GestureDetector(
              onTap: () => _onPlayPressed(
                canPlay: canPlay,
                timeLabel: timeLabel,
                closeTime: closeTime,
                gameId: gameId,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isRunning ? const Color(0xFF3882F6).withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: isRunning ? const Color(0xFF3882F6).withOpacity(0.5) : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isRunning ? Icons.play_circle_fill : Icons.not_interested,
                      color: isRunning ? const Color(0xFF3882F6) : Colors.grey.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      (AppLocalizations.of(context)?.playGame ?? "Play Game").toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isRunning ? const Color(0xFF3882F6) : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPlayPressed({
    required bool canPlay,
    required String timeLabel,
    required String closeTime,
    required int gameId,
  }) {
    if (!canPlay) {
      showDialog(
        context: context,
        builder: (_) => KingJackpotBiddingClosedDialog(
          time: timeLabel,
          resultTime: closeTime,
          bidLastTime: closeTime,
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JackpotJodiOptionsScreen(
          title: '${l10n?.kingJackpot ?? 'King Jackpot'}, $timeLabel',
          gameTime: timeLabel,
          gameId: gameId,
          digitJodiStatus: false,
          sessionSelection: true,
        ),
      ),
    );
  }

  Widget _errorView(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Color(0xFF3882F6)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF3882F6)),
              child: Text(l10n?.retry ?? 'Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================= NEW LEFT → RIGHT STAGGERED ANIMATION =========================
class _AnimatedGridItem extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedGridItem({required this.index, required this.child});

  @override
  State<_AnimatedGridItem> createState() => _AnimatedGridItemState();
}

class _AnimatedGridItemState extends State<_AnimatedGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Slide from Left to Right
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.2, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    // Staggered delay - row wise (2 items per row)
    final int rowIndex = widget.index ~/ 2;
    final int delayMs = 80 + (rowIndex * 180); // Very smooth wave effect

    Future.delayed(Duration(milliseconds: delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value.dx * 80, 0), // Strong slide feel
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

// ======================= MODELS (UNCHANGED) =======================

JackpotGameData jackpotGameDataFromJson(String str) =>
    JackpotGameData.fromJson(json.decode(str) as Map<String, dynamic>);

String jackpotGameDataToJson(JackpotGameData data) =>
    json.encode(data.toJson());

class JackpotGameData {
  final bool status;
  final String msg;
  final List<JackpotGameInfo>? info;

  JackpotGameData({required this.status, required this.msg, this.info});

  factory JackpotGameData.fromJson(Map<String, dynamic> json) {
    final rawInfo = json['info'];
    List<JackpotGameInfo>? parsedInfo;
    if (rawInfo is List) {
      parsedInfo = rawInfo
          .map(
            (x) => JackpotGameInfo.fromJson((x as Map).cast<String, dynamic>()),
          )
          .toList();
    }

    final dynamic s = json['status'];
    final status = s == true || s == 1 || s == '1';

    return JackpotGameData(
      status: status,
      msg: (json['msg'] ?? '').toString(),
      info: parsedInfo,
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'msg': msg,
    'info': info?.map((x) => x.toJson()).toList(),
  };
}

class JackpotGameInfo {
  final int gameId;
  final String gameName;
  final String openTime;
  final String closeTime;
  final String result;
  final String statusText;
  final bool playStatus;

  JackpotGameInfo({
    required this.gameId,
    required this.gameName,
    required this.openTime,
    required this.closeTime,
    required this.result,
    required this.statusText,
    required this.playStatus,
  });

  factory JackpotGameInfo.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    bool parseBool(dynamic v) {
      if (v is bool) return v;
      final s = v?.toString().toLowerCase().trim();
      return s == '1' ||
          s == 'true' ||
          s == 'yes' ||
          s == 'open' ||
          s == 'running';
    }

    return JackpotGameInfo(
      gameId: parseInt(json['gameId']),
      gameName: (json['gameName'] ?? '').toString(),
      openTime: (json['openTime'] ?? '').toString(),
      closeTime: (json['closeTime'] ?? '').toString(),
      result: (json['result'] ?? '').toString(),
      statusText: (json['statusText'] ?? '').toString(),
      playStatus: parseBool(json['playStatus']),
    );
  }

  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'gameName': gameName,
    'openTime': openTime,
    'closeTime': closeTime,
    'result': result,
    'statusText': statusText,
    'playStatus': playStatus,
  };
}
