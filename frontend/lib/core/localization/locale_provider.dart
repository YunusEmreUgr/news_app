import 'package:flutter/material.dart';
import 'package:frontend_template/core/storage/cache_storage.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';

  Locale _locale = const Locale('tr', 'TR');

  LocaleProvider() {
    _loadSavedLocale();
  }

  Locale get locale => _locale;

  void _loadSavedLocale() {
    final savedLanguageCode = CacheStorage.getString(_localeKey);
    if (savedLanguageCode != null) {
      _locale = Locale(savedLanguageCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!['tr', 'en'].contains(locale.languageCode)) return;
    _locale = locale;
    await CacheStorage.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  void toggleLocale() {
    if (_locale.languageCode == 'tr') {
      setLocale(const Locale('en', 'US'));
    } else {
      setLocale(const Locale('tr', 'TR'));
    }
  }
}

