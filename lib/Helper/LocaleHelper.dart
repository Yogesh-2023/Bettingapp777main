import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class LocaleHelper {
  static GetStorage? _storage;
  static ValueNotifier<Locale>? _localeNotifier;

  static GetStorage get _getStorage {
    _storage ??= GetStorage();
    return _storage!;
  }

  static ValueNotifier<Locale> get localeNotifier {
    _localeNotifier ??= ValueNotifier<Locale>(
      Locale(_getStorage.read('selectedLanguage') ?? 'en'),
    );
    return _localeNotifier!;
  }

  static Locale getCurrentLocale() {
    final langCode = _getStorage.read('selectedLanguage') ?? 'en';
    return Locale(langCode);
  }

  static void setLocale(Locale locale) {
    _getStorage.write('selectedLanguage', locale.languageCode);
    localeNotifier.value = locale;
  }

  static String getLanguageCode() {
    return _getStorage.read('selectedLanguage') ?? 'en';
  }
}

