import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_sara/l10n/app_localizations.dart';

import '../Helper/LocaleHelper.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GetStorage storage = GetStorage();

  bool mainNotif = true;
  bool gameNotif = true;
  bool starlineNotif = true;
  bool jackpotNotif = true;
  String selectedLang = 'en';

  final Map<String, String> languageMap = {
    'English': 'en',
    'हिंदी': 'hi',
    'ಕನ್ನಡ': 'kn',
    'മലയാളം': 'ml',
    'ગુજરાતી': 'gu',
    'मराठी': 'mr',
  };

  @override
  void initState() {
    super.initState();
    mainNotif = storage.read('main_notif') ?? true;
    gameNotif = storage.read('game_notif') ?? true;
    starlineNotif = storage.read('starline_notif') ?? true;
    jackpotNotif = storage.read('jackpot_notif') ?? true;
    selectedLang = storage.read('selectedLanguage') ?? 'en';
  }

  void _saveNotification(String key, bool value) {
    storage.write(key, value);
  }

  void _saveLanguage(String langCode) {
    storage.write('selectedLanguage', langCode);
    LocaleHelper.setLocale(Locale(langCode));
    setState(() {
      selectedLang = langCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    try {
      return Scaffold(
        backgroundColor: Colors.white, // White theme
        body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildSectionHeader(l10n?.notificationSettings ?? "Notification Settings"),
              _buildSwitchTile(
                l10n?.mainNotification ?? "Main Notification",
                mainNotif,
                (val) {
                  setState(() => mainNotif = val);
                  _saveNotification('main_notif', val);
                },
              ),
              _buildSwitchTile(
                l10n?.gameNotification ?? "Game Notification",
                gameNotif,
                (val) {
                  setState(() => gameNotif = val);
                  _saveNotification('game_notif', val);
                },
              ),
              _buildSwitchTile(
                l10n?.kingStarlineNotification ?? "King Starline Notification",
                starlineNotif,
                (val) {
                  setState(() => starlineNotif = val);
                  _saveNotification('starline_notif', val);
                },
              ),
              _buildSwitchTile(
                l10n?.kingJackpotNotification ?? "King Jackpot Notification",
                jackpotNotif,
                (val) {
                  setState(() => jackpotNotif = val);
                  _saveNotification('jackpot_notif', val);
                },
              ),
              const SizedBox(height: 20),
              _buildSectionHeader(l10n?.languageSettings ?? "Language Settings"),
              ...languageMap.entries.map(
                (entry) => _buildRadioTile(
                  entry.key,
                  selectedLang,
                  (val) => _saveLanguage(val!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    } catch (e) {
      // Fallback UI in case of any error
      return Scaffold(
        backgroundColor: Colors.white, // White theme
        body: Center(
          child: Text('Error loading settings: $e'),
        ),
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF3882F6),
        borderRadius: BorderRadius.circular(12), // <-- corner radius added here
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F4C81)),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF3882F6),
    );
  }

  Widget _buildRadioTile(
    String title,
    String groupVal,
    Function(String?) onChanged,
  ) {
    return RadioListTile<String>(
      value: languageMap[title]!,
      groupValue: groupVal,
      onChanged: onChanged,
      activeColor: const Color(0xFF3882F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(title),
    );
  }
}
