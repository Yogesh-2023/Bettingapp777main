import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_sara/l10n/app_localizations.dart';

import '../login/LoginScreen.dart';
import '../login/LoginWithMpinScreen.dart';
import '../Helper/LocaleHelper.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final GetStorage _storage = GetStorage();
  String? _selectedLanguageCode;

  // Language configuration
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'nativeName': 'English', 'englishName': 'English'},
    {'code': 'hi', 'nativeName': 'हिंदी', 'englishName': 'Hindi'},
    {'code': 'kn', 'nativeName': 'ಕನ್ನಡ', 'englishName': 'Kannada'},
    {'code': 'ml', 'nativeName': 'മലയാളം', 'englishName': 'Malayalam'},
    {'code': 'gu', 'nativeName': 'ગુજરાતી', 'englishName': 'Gujarati'},
    {'code': 'mr', 'nativeName': 'मराठी', 'englishName': 'Marathi'},
  ];

  @override
  void initState() {
    super.initState();
    // Load saved language or default to English
    _selectedLanguageCode = _storage.read('selectedLanguage') ?? 'en';
    // Ensure the locale is set on init if it was previously saved
    if (_selectedLanguageCode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        LocaleHelper.setLocale(Locale(_selectedLanguageCode!));
      });
    }
  }

  void _selectLanguage(String languageCode) {
    setState(() {
      _selectedLanguageCode = languageCode;
    });
    // Save language preference
    _storage.write('selectedLanguage', languageCode);
    // Update locale immediately - this will trigger app rebuild
    LocaleHelper.setLocale(Locale(languageCode));
  }

  void _continueToNext() async {
    // Save language preference (already saved in _selectLanguage)
    if (_selectedLanguageCode != null) {
      LocaleHelper.setLocale(Locale(_selectedLanguageCode!));
      // Wait to ensure locale change propagates
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // Navigate to next screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => _storage.read('isLoggedIn') == true
              ? const LoginWithMpinScreen()
              : const EnterMobileScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFE082), // Replaced Orange with Peach (image 2)
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50),
            // ⚪ WHITE CONTENT AREA
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Choose Language Text
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 30, 24, 16),
                      child: Text(
                        l10n?.chooseLanguage ?? "Choose Language",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F4C81), // Royal Blue for unity
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    // 🔹 Language List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _languages.length,
                        itemBuilder: (context, index) {
                          final lang = _languages[index];
                          final isSelected = _selectedLanguageCode == lang['code'];

                          return LanguageCard(
                            nativeName: lang['nativeName']!,
                            englishName: lang['englishName']!,
                            selected: isSelected,
                            onTap: () => _selectLanguage(lang['code']!),
                          );
                        },
                      ),
                    ),
                    
                    // 🔹 Continue Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                      child: Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFE082), Color(0xFFFFCA28)], // Yellow gradient matching top
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFE082).withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(30),
                            onTap: _continueToNext,
                            child: Center(
                              child: const Text(
                                "CONTINUE",
                                style: TextStyle(
                                  color: Color(0xFF0F4C81), // Requested Navy Blue
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
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
    );
  }
}

class LanguageCard extends StatelessWidget {
  final String nativeName;
  final String englishName;
  final bool selected;
  final VoidCallback onTap;

  const LanguageCard({
    super.key,
    required this.nativeName,
    required this.englishName,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF3882F6) : Colors.grey.shade200, 
            width: selected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 🟠 PEACH FLAG ICON
            Container(
              height: 48,
              width: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE082), // Replaced Orange with Peach (image 2)
                shape: BoxShape.circle, // Circular shape for a more modern look
              ),
              child: const Icon(Icons.flag, color: Color(0xFF0F4C81), size: 24), // Blue flag icon to stand out on peach
            ),
            const SizedBox(width: 16),
            // 📝 NATIVE LANGUAGE NAME
            Expanded(
              child: Text(
                nativeName,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? const Color(0xFF0F4C81) : Colors.black87,
                ),
              ),
            ),
            // 📝 ENGLISH LANGUAGE NAME
            Text(
              englishName,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? const Color(0xFF3882F6) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
