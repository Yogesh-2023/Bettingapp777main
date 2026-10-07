import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_sara/Language/language_screen.dart';

import 'HomeScreen/HomeScreen.dart';
import 'login/LoginScreen.dart'; // Fixed import
import 'login/LoginWithMpinScreen.dart';
import 'components/AppNameBold.dart';

final storage = GetStorage();
String? fcmToken;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Background FCM handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await _showFlutterNotification(message);
  log("🔔 Background message received: ${message.messageId}");
}

/// Show notification
@pragma('vm:entry-point')
Future<void> _showFlutterNotification(RemoteMessage message) async {
  final title = message.data['title'];
  final body = message.data['body'];

  if (title == null || body == null) return;

  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Used for general notifications.',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/launcher_icon',
      playSound: true,
    ),
  );

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    title,
    body,
    details,
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    /// 🔥 INIT ANIMATION
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    _initializeAllDependencies();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    final isLoggedIn = storage.read('isLoggedIn') ?? false;
    final hasLanguage = storage.read('selectedLanguage') != null;

    Widget target;
    if (isLoggedIn) {
      target = const LoginWithMpinScreen();
    } else if (hasLanguage) {
      target = const EnterMobileScreen();
    } else {
      target = const LanguageScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => target,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Future<void> _initializeAllDependencies() async {
    try {
      log("🚀 Starting init...");

      if (!await hasInternetConnection()) {
        log("❌ No internet. Skipping FCM init.");
        await Future.delayed(const Duration(seconds: 3));
        _navigateToNextScreen();
        return;
      }

      log("✅ Internet OK");

      await GetStorage.init();

      await _initLocalNotifications();

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      final messaging = FirebaseMessaging.instance;

      try {
        final settings = await messaging
            .requestPermission(alert: true, badge: true, sound: true)
            .timeout(const Duration(seconds: 4));

        log('🔐 Notification permission: ${settings.authorizationStatus}');
      } catch (e) {
        log('⚠️ Permission error: $e');
      }

      try {
        fcmToken = await messaging.getToken().timeout(
          const Duration(seconds: 4),
        );
        if (fcmToken != null) storage.write('fcmToken', fcmToken);
        log("📲 Token saved => $fcmToken");
      } catch (e) {
        log("⚠️ Token error: $e");
      }

      try {
        await messaging
            .subscribeToTopic('All')
            .timeout(const Duration(seconds: 3));
        log("✅ Subscribed to 'All'");
      } catch (e) {
        log("⚠️ Topic error: $e");
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        storage.write('fcmToken', token);
        log("♻️ Token refreshed");
      });

      FirebaseMessaging.onMessage.listen(_showFlutterNotification);

      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) _handleMessageTap(initialMessage);

      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

      await _getAndSaveDeviceInfo();

      log("🎉 Init complete");
    } catch (e, st) {
      log("🚨 Init error: $e");
      log("$st");
    } finally {
      Future.delayed(const Duration(seconds: 3), _navigateToNextScreen);
    }
  }

  Future<void> _initLocalNotifications() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) {
        log("🔗 Local notif tapped: ${resp.payload}");
      },
    );

    final androidImpl = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidImpl?.createNotificationChannel(
      const AndroidNotificationChannel(
        'default_channel',
        'Default Channel',
        description: 'Used for general notifications.',
        importance: Importance.high,
      ),
    );

    await androidImpl?.requestNotificationsPermission();
  }

  void _handleMessageTap(RemoteMessage message) {
    log("👉 Notification tapped: ${message.data}");

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => HomeScreen(),
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

  Future<void> _getAndSaveDeviceInfo() async {
    final plugin = DeviceInfoPlugin();
    String? deviceId;
    String? deviceName;

    try {
      if (Platform.isAndroid) {
        final android = await plugin.androidInfo;
        deviceId = android.id;
        deviceName = android.model;
      } else {
        final ios = await plugin.iosInfo;
        deviceId = ios.identifierForVendor;
        deviceName = ios.name;
      }
    } catch (e) {
      log("Device info error: $e");
    }

    if (deviceId != null) storage.write('deviceId', deviceId);
    if (deviceName != null) storage.write('deviceName', deviceName);
  }

  Future<bool> hasInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        // ✅ BACKGROUND GRADIENT
        decoration: const BoxDecoration(color: Color(0xFFFFE082)), // Reverted to original peach background

        child: Column(
          children: [
            /// TOP SPACE
            const SizedBox(height: 70),

            /// WHITE ROUNDED CONTAINER
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// IMAGE WITH ANIMATION
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.asset(
                        'assets/icon/icon.png',
                        width: 280,
                        fit: BoxFit.contain,
                        color: const Color(0xFFFFE082),
                        colorBlendMode: BlendMode.multiply,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
