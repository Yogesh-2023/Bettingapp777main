import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:new_sara/HomeScreen/HomeScreen.dart';
import 'package:new_sara/ulits/custom_back_button.dart';
import 'package:new_sara/l10n/app_localizations.dart';

import '../Helper/Toast.dart';
import '../ulits/ColorsR.dart';
import '../ulits/Constents.dart';

class SetNewPinScreen extends StatefulWidget {
  final String mobile;
  const SetNewPinScreen({super.key, required this.mobile});

  @override
  State<SetNewPinScreen> createState() => _SetNewPinScreenState();
}

class _SetNewPinScreenState extends State<SetNewPinScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController pinController = TextEditingController();
  final storage = GetStorage();

  late final String fcmToken;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fcmToken = storage.read("fcmToken") ?? "";
  }

  @override
  void dispose() {
    passwordController.dispose();
    pinController.dispose();
    super.dispose();
  }

  Future<void> setNewPin() async {
    final l10n = AppLocalizations.of(context);
    final password = passwordController.text.trim();
    final newPin = pinController.text.trim();

    if (password.isEmpty) {
      popToast(
        l10n?.enterYourPassword ?? "Please enter your password",
        4,
        Colors.white,
        ColorsR.appColorRed,
      );
      return;
    }

    if (newPin.isEmpty || newPin.length != 4) {
      popToast(
        l10n?.pleaseEnterValid4DigitPin ?? "Please enter a valid 4-digit PIN",
        4,
        Colors.white,
        ColorsR.appColorRed,
      );
      return;
    }

    setState(() => isLoading = true);

    final body = {
      "mobileNo": int.tryParse(widget.mobile),
      "password": password,
      "security_pin": int.tryParse(newPin),
      "fcmToken": fcmToken,
    };

    try {
      final response = await http.post(
        Uri.parse("${Constant.apiEndpoint}reset-mpin"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final json = jsonDecode(response.body);
      final status = json["status"] ?? false;
      final l10n = AppLocalizations.of(context);
      final msg = json["msg"] ?? (l10n?.somethingWentWrong ?? "Something went wrong");

      if (status == true) {
        final info = json["info"];
        storage.write("user_mpin", newPin);
        storage.write("registerId", info["registerId"]);
        storage.write("accessToken", info["accessToken"]);

        popToast(msg, 2, Colors.white, Colors.green);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        popToast(msg, 4, Colors.white, ColorsR.appColorRed);
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      popToast(
        l10n?.errorWithPlaceholder(e.toString()) ?? "Error: $e",
        4,
        Colors.white,
        ColorsR.appColorRed,
      );
    } finally {
      setState(() => isLoading = false);
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

        /// SAME THEME GRADIENT
        decoration: const BoxDecoration(
         color:Color(0xFFFFE082)
        ),

        child: SafeArea(
          child: Column(
            children: [
              //   const SizedBox(height: 20),

              /// ⭐ TITLE
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    //  Container(width: 10, height: 45, color: Color(0xffFF6f00)),
                    //  const SizedBox(width: 10),
                    // Text(
                    //   "SET NEW\nPIN",
                    //   style: GoogleFonts.poppins(
                    //     fontSize: 26,
                    //     fontWeight: FontWeight.w700,
                    //     color: Colors.black,
                    //   ),
                    // )
                  ],
                ),
              ),

              // const SizedBox(height: 20),

              /// ⭐ WHITE ROUNDED CONTAINER
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 10,
                    bottom: 30,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE082),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),

                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CustomBackButton(),
                            const SizedBox(width: 12),

                            Text(
                              l10n?.changeNewMpin ?? "Change New MPIN",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F4C81),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        _buildFieldTitle(l10n?.enterPasswordLabel ?? "Enter Password"),
                        const SizedBox(height: 8),

                        _buildInputField(
                          controller: passwordController,
                          hint: l10n?.enterYourPassword ?? "Enter your password",
                          isNumber: false,
                          isPassword: true,
                          icon: Icons.lock,
                        ),

                        const SizedBox(height: 25),

                        _buildFieldTitle(l10n?.enterNewMpin ?? "Enter New mPin"),
                        const SizedBox(height: 8),

                        _buildInputField(
                          controller: pinController,
                          hint: l10n?.enter4DigitPin ?? "Enter 4-digit PIN",
                          isNumber: true,
                          maxLength: 4,
                          isPassword: true,
                          icon: Icons.password,
                        ),

                        const SizedBox(height: 45),

                        /// ⭐ BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : setNewPin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3882F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    l10n?.setPin ?? "SET PIN",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
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
        ),
      ),
    );
  }

  /// ---------------------------
  /// COMMON FIELD TITLE
  /// ---------------------------
  Widget _buildFieldTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// ---------------------------
  /// COMMON INPUT FIELD (THEME)
  /// ---------------------------
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required bool isNumber,
    bool isPassword = false,
    int maxLength = 50,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF3882F6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              maxLength: maxLength,
              keyboardType: isNumber
                  ? TextInputType.number
                  : TextInputType.text,
              cursorColor: const Color(0xFF3882F6),
              decoration: InputDecoration(
                hintText: hint,
                counterText: "",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
