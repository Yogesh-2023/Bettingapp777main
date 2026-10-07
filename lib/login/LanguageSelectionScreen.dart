import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:new_sara/Splash.dart';
import 'package:new_sara/login/LoginWithMpinScreen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_sara/main.dart';
import 'package:new_sara/Helper/LocaleHelper.dart';

class LanguageSelectionScreen extends StatelessWidget {
  LanguageSelectionScreen({super.key});

  static const Color buttonColor = Color(0xFF3882F6); // same login button color

  final storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE082), Color(0xFFFFE082)],
            begin: Alignment.topLeft,
            end: Alignment.topRight,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: size.height * 0.12),

              /// ✅ Logo.svg
              SvgPicture.asset(
                "assets/icon/logo.svg",
                height: size.height * 0.07,
              ),

              SizedBox(height: size.height * 0.08),

              /// Buttons Container
              Expanded(
                child: Container(
                  width: double.infinity,

                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),

                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE082),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      languageButton(context, "English"),

                      SizedBox(height: size.height * 0.02),

                      languageButton(context, "हिंदी"),

                      SizedBox(height: size.height * 0.02),

                      languageButton(context, "मराठी"),

                      SizedBox(height: size.height * 0.02),

                      languageButton(context, "ಕನ್ನಡ"),
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

  /// ✅ Language Button Widget
  Widget languageButton(BuildContext context, String text) {
    final Size size = MediaQuery.of(context).size;

    return SizedBox(
      width: double.infinity,
      height: size.height * 0.06,

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),

          elevation: 2,
        ),

        // onPressed: () {
        //   /// Navigate to Login Screen
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (_) => const LoginWithMpinScreen()),
        //   );
        // },
        onPressed: () {
          String languageCode = "";

          if (text == "English") {
            languageCode = "en";
          } else if (text == "हिंदी") {
            languageCode = "hi";
          } else if (text == "मराठी") {
            languageCode = "mr";
          } else if (text == "ಕನ್ನಡ") {
            languageCode = "kn";
          }

          LocaleHelper.setLocale(Locale(languageCode));

          Navigator.pushReplacement(
            context,

            MaterialPageRoute(
              builder: (_) => LoginWithMpinScreen(),
            ),
          );
        },
        child: Text(
          text,

          style: TextStyle(
            fontSize: size.width * 0.045,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F4C81),
          ),
        ),
      ),
    );
  }
}
