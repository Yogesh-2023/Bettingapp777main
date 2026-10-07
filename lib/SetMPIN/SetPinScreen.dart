import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:new_sara/HomeScreen/HomeScreen.dart';
import 'package:new_sara/login/LoginWithMpinScreen.dart';
import 'package:new_sara/l10n/app_localizations.dart';
import 'SetNewPinScreen.dart';

import '../../ulits/ColorsR.dart';
import '../../Helper/Toast.dart';
import '../ulits/Constents.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final TextEditingController mpinController = TextEditingController();
  final storage = GetStorage();

  bool isLoading = false;

  Future<void> _onSetPinPressed() async {
    final l10n = AppLocalizations.of(context);
    final pin = mpinController.text.trim();

    if (pin.isEmpty || pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin)) {
      popToast(
        l10n?.pleaseEnterValid4DigitPin ?? "Please enter a valid 4-digit PIN",
        4,
        Colors.white,
        ColorsR.appColorRed,
      );
      return;
    }

    final mobile = storage.read('mobile');
    final username = storage.read('username');
    final password = storage.read('password');

    if (mobile == null || mobile.toString().isEmpty) {
      popToast(
        l10n?.mobileNumberNotAvailable ?? "Mobile number not found",
        4,
        Colors.white,
        ColorsR.appColorRed,
      );
      return;
    }

    // Ensure we have username and password (should be saved from CreateAccountScreen)
    if (username == null || password == null) {
      popToast(
        "Missing account details. Please restart.",
        4,
        Colors.white,
        ColorsR.appColorRed,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Save PIN first
      storage.write('user_mpin', pin);

      // Complete registration API call (Bypass VerifyMobileScreen)
      await _completeRegistration(mobile, username, password, pin);
    } catch (e) {
      popToast(
        l10n?.somethingWentWrongWithError(e.toString()) ??
            "Something went wrong: $e",
        4,
        Colors.white,
        ColorsR.appColorRed,
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> _completeRegistration(
    String mobile,
    String fullName,
    String password,
    String securityPin,
  ) async {
    final l10n = AppLocalizations.of(context);
    try {
      final Uri url = Uri.parse('${Constant.apiEndpoint}user-register');
      final Map<String, String> headers = {
        'deviceId': 'qwert',
        'deviceName': 'sm2233',
        'accessStatus': '1',
        'Content-Type': 'application/json',
      };

      final body = {
        "fullName": fullName,
        "mobileNo": int.tryParse(mobile.toString()) ?? mobile,
        "password": password,
        "password_confirmation": password,
        "security_pin": int.tryParse(securityPin) ?? securityPin,
      };

      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      log("📥 Register Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'] ?? false;
        final msg = data['msg'] ?? "Registration completed";

        if (status == true) {
          // Save tokens if available
          if (data['info'] != null) {
            final info = data['info'];
            if (info['accessToken'] != null) {
              storage.write("accessToken", info['accessToken']);
            }
            if (info['registerId'] != null) {
              storage.write("registerId", info['registerId']);
            }
          }

          popToast(msg, 2, Colors.white, Colors.green);

          // Navigate directly to HomeScreen
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          }
        } else {
          // Check if user already registered
          if (msg.toString().toLowerCase().contains("already registered")) {
            popToast(msg, 4, Colors.white, ColorsR.appColorRed);
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SetNewPinScreen(mobile: mobile),
                ),
              );
            }
          } else {
            popToast(msg, 4, Colors.white, ColorsR.appColorRed);
            setState(() => isLoading = false);
          }
        }
      } else {
        popToast(
          "Server Error: ${response.statusCode}",
          4,
          Colors.white,
          ColorsR.appColorRed,
        );
        setState(() => isLoading = false);
      }
    } on TimeoutException {
      popToast(
        "Request timed out. Please try again.",
        4,
        Colors.white,
        ColorsR.appColorRed,
      );
      setState(() => isLoading = false);
    } catch (e) {
      log("Registration error: $e");
      popToast(
        "Registration failed. Please try again.",
        4,
        Colors.white,
        ColorsR.appColorRed,
      );
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    mpinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFFFE082),
      body: Column(
        children: [
          const SizedBox(height: 80),
          // White Container
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 30,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE082),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    /// TITLE
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Container(
                                width: 10, height: 45, color: const Color(0xFF3882F6)),
                            const SizedBox(width: 10),
                            Text(
                              l10n?.setYourPin ?? "SET YOUR\nPIN",
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F4C81),
                              ),
                            ),
                          ],
                        )),

                    const SizedBox(height: 30),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n?.enterNewMpin ?? "Enter New mPin",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// PIN INPUT FIELD
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      color: const Color(0xffeeeeee),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFF3882F6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.password,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: mpinController,
                                maxLength: 4,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                cursorColor: const Color(0xFF3882F6),
                                decoration: InputDecoration(
                                  hintText: l10n?.enter4DigitMpin ??
                                      "Enter 4-digit mPin",
                                  counterText: "",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onSetPinPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3882F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Color(0xFF0F4C81),
                              )
                            : Text(
                                l10n?.setPin ?? "SET PIN",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
