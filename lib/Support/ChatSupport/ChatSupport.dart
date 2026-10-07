import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Helper/UserController.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  late final UserController userController;
  final GetStorage box = GetStorage();

  String phoneNumber = '';
  bool hasLaunched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    userController = Get.find<UserController>();
    phoneNumber = box.read('whatsappNumber') ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchWhatsAppChat();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Close the screen when user returns from WhatsApp
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _launchWhatsAppChat() async {
    if (hasLaunched) return; // Prevent duplicate calls
    hasLaunched = true;

    if (phoneNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WhatsApp number not found.'),
            backgroundColor: Color(0xFF3882F6),
          ),
        );
      }
      return;
    }

    final cleanNumber = phoneNumber.replaceAll('+', '').trim();
    log('Launching WhatsApp with number: $cleanNumber');

    final Uri whatsappUrl = Uri.parse('https://wa.me/$cleanNumber');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp. Please install the app.'),
            backgroundColor: Color(0xFF3882F6),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White theme
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chat Support',
          style: TextStyle(color: Color(0xFF0F4C81), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF3882F6),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF3882F6)),
            const SizedBox(height: 20),
            const Text(
              'Redirecting to WhatsApp...',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _launchWhatsAppChat,
              child: const Text('Click here if it doesn\'t open'),
            ),
          ],
        ),
      ),
    );
  }
}
