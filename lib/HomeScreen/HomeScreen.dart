// File: lib/HomeScreen.dart
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:new_sara/components/AppNameBold.dart';
import 'package:new_sara/l10n/app_localizations.dart';
import 'package:new_sara/ulits/wallet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Bids/MyBidsPage.dart';
import '../ChartScreen/ChartScreen.dart';
import '../Helper/Toast.dart';
import '../Helper/UserController.dart';
import '../login/LoginWithMpinScreen.dart';
import '../Navigation/FundsFragmentContainer.dart';
import '../Notice/WithdrawInfoScreen.dart';
import '../Notification/NotificationScreen.dart';
import '../Passbook/PassbookPage.dart';
import '../SetMPIN/SetNewPinScreen.dart';
import '../SettingsScreen/SettingsScreen.dart';
import '../Support/ChatSupport/ChatSupport.dart';
import '../Support/SupportPage.dart';
import '../Video/LanguageSelectionScreen.dart';
import '../components/AppName.dart';
import '../game/gameRates/GameRateScreen.dart';
import '../ulits/ColorsR.dart';
import '../ulits/Constents.dart';
import 'HomePage.dart';

// for ui changes  //
double sw(BuildContext c) => MediaQuery.of(c).size.width;
double sh(BuildContext c) => MediaQuery.of(c).size.height;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final UserController userController = Get.isRegistered<UserController>()
      ? Get.find<UserController>()
      : Get.put(UserController(), permanent: true);

  final GetStorage storage = GetStorage();
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    log('HomeScreen sees UserController hash: ${userController.hashCode}');
    _bootstrapLoad();
    storage.write('isLoggedIn', true);
    userController.startLivePolling(interval: const Duration(seconds: 6));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    userController.stopLivePolling();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      userController.fetchAndUpdateUserDetails();
    }
  }

  Future<void> _bootstrapLoad() async {
    try {
      await userController.fetchAndUpdateUserDetails();
      await Future.wait([
        userController.fetchAndUpdateFeeSettings(),
        userController.fetchAndUpdateContactDetails(),
        userController.fetchPaymentDetails(),
      ]);
    } catch (e, st) {
      log('Warm-up error: $e', stackTrace: st);
    }
  }

  String _normalizePhone(String raw, {String defaultCountryCode = '91'}) {
    var p = raw.replaceAll(RegExp(r'[^0-9]'), '');
    p = p.replaceFirst(RegExp(r'^0+'), '');
    if (p.length == 10) p = '$defaultCountryCode$p';
    return p;
  }

  String? _getSupportNumber() {
    final w = userController.contactWhatsappNo.value.trim();
    if (w.isNotEmpty) return w;
    final c = userController.contactMobileNo.value.trim();
    if (c.isNotEmpty) return c;
    final s = (storage.read('whatsappNo') ?? '').toString().trim();
    if (s.isNotEmpty) return s;
    final u = userController.mobileNo.value.trim();
    if (u.isNotEmpty) return u;
    return null;
  }

  Future<void> launchWhatsAppChat({String? message}) async {
    try {
      final raw = _getSupportNumber();
      if (raw == null) {
        final l10n = AppLocalizations.of(context);
        popToast(
          l10n?.whatsappNumberNotAvailable ?? "WhatsApp number not available",
          4,
          Colors.white,
          ColorsR.appColorRed,
        );
        log("❌ WhatsApp number missing (all sources empty)");
        return;
      }

      final phone = _normalizePhone(raw);
      final encoded = (message ?? '').trim().isEmpty
          ? ''
          : Uri.encodeComponent(message!.trim());

      final nativeUri = Uri.parse(
        'whatsapp://send?phone=$phone${encoded.isNotEmpty ? '&text=$encoded' : ''}',
      );
      if (await canLaunchUrl(nativeUri)) {
        final ok = await launchUrl(
          nativeUri,
          mode: LaunchMode.externalApplication,
        );
        log(
          ok ? '✅ Launched WhatsApp (native): $nativeUri' : '❌ Failed (native)',
        );
        if (ok) return;
      }

      final webUri = Uri.parse(
        'https://wa.me/$phone${encoded.isNotEmpty ? '?text=$encoded' : ''}',
      );
      if (await canLaunchUrl(webUri)) {
        final ok = await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
        log(ok ? '✅ Launched WhatsApp (web): $webUri' : '❌ Failed (web)');
        if (ok) return;
      }

      final l10n1 = AppLocalizations.of(context);
      popToast(
        l10n1?.couldNotOpenWhatsapp ?? "Could not launch WhatsApp",
        4,
        Colors.white,
        ColorsR.appColorRed,
      );
    } catch (e, st) {
      log('❌ WhatsApp launch error: $e', stackTrace: st);
      final l10n2 = AppLocalizations.of(context);
      popToast(
        l10n2?.errorLaunchingWhatsapp ?? "Error launching WhatsApp",
        4,
        Colors.white,
        ColorsR.appColorRed,
      );
    }
  }

  final List<Widget> _screens = [
    BidScreen(),
    PassbookPage(),
    HomePage(),
    FundsFragmentContainer(),
    SupportPage(),
    WithdrawInfoScreen(),
    SettingsScreen(),
    GameRateScreen(),
    ChatScreen(),
  ];

  void _onItemTapped(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() => _selectedIndex = index);
    } else {
      log("Error: Attempted to select invalid index: $index");
    }
  }

  void _navigateToNewScreen(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _navigateToDrawerScreenAndPush(Widget screen) {
    Navigator.pop(context);
    _navigateToNewScreen(screen);
  }

  Widget _buildBodyHeader() {
    // Hide header when on Funds screen (index 3) or Bid screen (index 0)
    if (_selectedIndex == 3 || _selectedIndex == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F4C81), // Navy Blue
            Color(0xFF3882F6), // Light Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0F4C81).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // APP NAME SECTION (Menu + Launcher Logo)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openDrawer(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_rounded, 
                      color: Color(0xFFFFC107), // Yellow contrast against Navy
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Using dpboss image as requested
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Image.asset(
                  "assets/images/dpboss.png",
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // WALLET (Styled for Pink Background)
              WalletBalancePill(
                accountStatus: userController.accountStatus,
                walletBalance: userController.walletBalance,
                horizontalPadding: 16,
                verticalPadding: 8,
              ),
              const SizedBox(width: 10),
              // NOTIFICATION (White style)
              Obx(
                () => userController.accountStatus.value
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NoticeHistoryScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade200, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.notifications_active_outlined,
                            color: Color(0xFFFFC107), // Yellow
                            size: 22,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Drawer(
      backgroundColor: const Color(0xFFFFFDE7), // Light Peach Accent
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              height: 110,
              // decoration: const BoxDecoration(
              //   gradient: LinearGradient(
              //     colors: [
              //       Color(0xFFFFF9C4),  // Soft Yellow-Orange
              //       Color(0xFFE3F2FD),  // Soft Off-White Mint
              //     ],
              //     begin: Alignment.centerLeft,
              //     end: Alignment.centerRight,
              //   ),
              // ),
              color: const Color(0xFFFFFDE7), // Light Peach Accent
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFF3882F6).withOpacity(0.2),
                    child: const Icon(
                      Icons.person,
                      size: 34,
                      color: Color(0xFF0F4C81),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            userController.fullName.value,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F4C81),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Obx(
                          () => Text(
                            userController.mobileNoEnc.value,
                            style: const TextStyle(color: Color(0xFF0F4C81)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF0F4C81)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(
                () => ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  children: [
                    _buildDrawerItem(
                      "assets/images/home_nav.png",
                      l10n?.home ?? "Home",
                      () {
                        Navigator.pop(context);
                        _onItemTapped(2);
                      },
                      true,
                    ),
                    _buildDrawerItem(
                      "assets/images/bid_nav.png",
                      l10n?.myBids ?? "My Bids",
                      () {
                        Navigator.pop(context);
                        _onItemTapped(0);
                      },
                      userController.accountStatus.value,
                    ),
                    _buildDrawerItem(
                      "assets/images/mpin_nav.png",
                      l10n?.mpin ?? "M-PIN",
                      () {
                        Navigator.pop(context);
                        _handleMpin();
                      },
                      userController.accountStatus.value,
                    ),
                    _buildDrawerItem(
                      "assets/images/passbook.png",
                      l10n?.passbook ?? "Passbook",
                      () =>
                          _navigateToDrawerScreenAndPush(const PassbookPage()),
                      userController.accountStatus.value,
                    ),
                    _buildDrawerItem(
                      "assets/images/funds_nav.png",
                      l10n?.funds ?? "Funds",
                      () {
                        Navigator.pop(context);
                        _onItemTapped(3);
                      },
                      userController.accountStatus.value,
                    ),
                    _buildDrawerItem(
                      "assets/images/videos.png",
                      l10n?.videos ?? "Videos",
                      () => _navigateToDrawerScreenAndPush(
                        const LanguageSelectionScreen(),
                      ),
                      userController.accountStatus.value,
                    ),
                    _buildDrawerItem(
                      "assets/images/rate_stars.png",
                      l10n?.gameRates ?? "Game Rates",
                      () {
                        Navigator.pop(context);
                        _onItemTapped(7);
                      },
                      userController.accountStatus.value,
                    ),
                    _buildDrawerItem(
                      "assets/images/charts.png",
                      l10n?.charts ?? "Charts",
                      () => _navigateToDrawerScreenAndPush(const ChartScreen()),
                      userController.accountStatus.value,
                    ),
                    _buildDrawerItem(
                      "assets/images/setting_nav.png",
                      l10n?.settings ?? "Settings",
                      () {
                        Navigator.pop(context);
                        _onItemTapped(6);
                      },
                      userController.accountStatus.value,
                    ),
                    _buildDrawerItem(
                      "assets/images/share.png",
                      l10n?.shareApplication ?? "Share Application",
                      () {
                        Navigator.pop(context);
                        Share.share(
                          l10n?.imLovingSara777App ??
                              "I'm loving Sara 777 App\n\nDownload App now\n\nFrom:-\nhttps://admin.sara777.app",
                          subject:
                              l10n?.checkOutSara777App ??
                              "Check out the Sara 777 App!",
                        );
                      },
                      userController.accountStatus.value,
                    ),
                    _buildDrawerItem(
                      "assets/images/power.png",
                      l10n?.logout ?? "Logout",
                      () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginWithMpinScreen(),
                          ),
                        );
                      },
                      true,
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

  Widget _buildDrawerItem(
    String imagePath,
    String title,
    VoidCallback onTap,
    bool visible,
  ) {
    if (!visible) return const SizedBox.shrink();
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF3882F6), // 🔶 Magenta background
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                imagePath,
                width: 20,
                height: 20,
                fit: BoxFit.contain,
                color: Colors.white, // ⚪ icon white
              ),
            ),
          ),

          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Color(0xFF0F4C81),
            ),
          ),
          onTap: onTap,
        ),

        // 🔥 Divider added here
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Divider(thickness: 1, color: Colors.black12),
        ),
      ],
    );
  }

  void _handleMpin() async {
    final String mobile = userController.mobileNo.value;
    if (mobile.isEmpty) {
      log("Mobile number is not available.");
      final l10n = AppLocalizations.of(context);
      popToast(
        l10n?.mobileNumberNotAvailable ?? "Mobile number is not available",
        4,
        Colors.white,
        ColorsR.appColorRed,
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SetNewPinScreen(mobile: mobile)),
    );
  }

  Widget _buildBottomAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Obx(() {
      final accountStatus = userController.accountStatus.value;
      return SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 70,

              decoration: const BoxDecoration(
                color: Color(0xFF0F4C81), // Navy Blue for totally new look
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          "assets/images/bid_nav.png",
                          l10n?.myBids ?? "My Bids",
                          0,
                          visible: accountStatus,
                        ),
                        _buildNavItem(
                          "assets/images/passbook.png",
                          l10n?.passbook ?? "Passbook",
                          1,
                          visible: accountStatus,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.20),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(
                          "assets/images/funds.png",
                          l10n?.funds ?? "Funds",
                          3,
                          visible: accountStatus,
                        ),
                        _buildNavItem(
                          "assets/images/chat_icon.png",
                          l10n?.chat ?? "Chat",
                          8,
                          visible: accountStatus,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              child: GestureDetector(
                onTap: () => _onItemTapped(2),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107), // Yellow Center
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      "assets/images/home1.png",
                      width: 32, // 🔽 icon size control
                      height: 32, // 🔽 icon size control
                      fit: BoxFit.contain,
                      color: Color(0xFF0F4C81), // Navy Blue Logo inside Yellow Circle
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNavItem(
    String iconPath,
    String label,
    int index, {
    bool visible = true,
  }) {
    if (!visible) return const SizedBox.shrink();
    final isSelected = _selectedIndex == index;
    final color = isSelected ? const Color(0xFFFFC107) : Colors.white70; // Yellow if selected, White if unselected

    return GestureDetector(
      onTap: () {
        if (index == 8) {
          launchWhatsAppChat();
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PassbookPage()),
          );
        } else {
          _onItemTapped(index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, width: 26, height: 26, color: color),
          const SizedBox(height: 4),
          SizedBox(
            width: 50, // 👈 width control (important)
            child: Text(
              label,
              maxLines: 1, // 👈 ek hi line
              overflow: TextOverflow.ellipsis, // 👈 dot dot
              textAlign: TextAlign.center,
              style: TextStyle(color: color, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showQuitDialog() async {
    final l10n = AppLocalizations.of(context);
    final shouldQuit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final dialogL10n = AppLocalizations.of(dialogContext);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Orange Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3882F6),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    dialogL10n?.quit ?? 'Quit',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Body
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Large orange icon (person running/exiting)
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3882F6).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.exit_to_app,
                          size: 50,
                          color: Color(0xFF3882F6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Question text
                      Text(
                        dialogL10n?.areYouSureYouWantToQuitTheApp ??
                            'Are you sure you want to quit the app?',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // No button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3882F6),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                dialogL10n?.no ?? 'No',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Yes button
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3882F6),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                dialogL10n?.yes ?? 'Yes',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldQuit == true) {
      // Exit the app using SystemNavigator
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 2) {
          _onItemTapped(2);
          return false;
        }
        // Show quit dialog when on HomePage
        _showQuitDialog();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white, // Changed to white as per user request
        resizeToAvoidBottomInset: false,
        drawer: _buildDrawer(context),
        // appBar: _buildAppBar(context),
        body: Container(
          decoration: const BoxDecoration(color: Colors.white),

          child: SafeArea(
            top: false,

            child: Column(
              children: [
                _buildBodyHeader(),

                Expanded(
                  child:
                      (_selectedIndex >= 0 && _selectedIndex < _screens.length)
                      ? _screens[_selectedIndex]
                      : Center(
                          child: Text(
                            l10n?.screenNotFound ?? "Error: Screen not found",
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(child: _buildBottomAppBar(context)),
      ),
    );
  }
}
