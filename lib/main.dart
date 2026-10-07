import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_sara/l10n/app_localizations.dart';

import 'Splash.dart';
import 'Helper/LocaleHelper.dart';

// ---------- Background Handler (Separate Isolate) ----------
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();

  // Use a NEW plugin instance in BG isolate
  final bgPlugin = FlutterLocalNotificationsPlugin();
  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    ), // Fixed: Use @mipmap instead of @drawable
  );
  await bgPlugin.initialize(initSettings);

  const channel = AndroidNotificationChannel(
    'default_channel',
    'Default Channel',
    description: 'Used for general notifications.',
    importance: Importance.high,
  );

  final bgAndroid = bgPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await bgAndroid?.createNotificationChannel(channel);

}

// ---------- Local Notifications Setup ----------
Future<void> _bootstrapLocalNotifications() async {
  final plugin = FlutterLocalNotificationsPlugin();

  const initSettings = InitializationSettings(
    android: AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    ), // Fixed: Use @mipmap instead of @drawable
  );
  await plugin.initialize(initSettings);

  const channel = AndroidNotificationChannel(
    'default_channel',
    'Default Channel',
    description: 'Used for general notifications.',
    importance: Importance.high,
  );

  final android = plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await android?.createNotificationChannel(channel);
  await android?.requestNotificationsPermission(); // Android 13+
}

// ---------- Main Function ----------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetStorage BEFORE using LocaleHelper
  await GetStorage.init();
  
  await Firebase.initializeApp();

  // MUST be registered BEFORE runApp
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await _bootstrapLocalNotifications();

  runApp(const MyApp());
}

// ---------- MyApp Widget ----------
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Listen to locale changes
    LocaleHelper.localeNotifier.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LocaleHelper.localeNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleHelper.localeNotifier,
      builder: (context, locale, child) {
        return MaterialApp(
          title: 'DPBOSS',
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('hi'), // Hindi
            Locale('kn'), // Kannada
            Locale('ml'), // Malayalam
            Locale('gu'), // Gujarati
            Locale('mr'), // Marathi
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          // The home screen is now the SplashScreen, which handles all initialization
          home: const SplashScreen(),
        );
      },
    );
  }
}
