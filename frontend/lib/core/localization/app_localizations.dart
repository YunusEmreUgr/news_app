import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('tr', 'TR'));
  }

  static const _localizedValues = <String, Map<String, String>>{
    'tr': {
      'app_title': 'Enterprise App',
      'login': 'Giriş Yap',
      'register': 'Kayıt Ol',
      'email': 'E-posta',
      'password': 'Şifre',
      'welcome': 'Hoş Geldiniz',
      'dashboard': 'Ana Sayfa',
      'settings': 'Ayarlar',
      'profile': 'Profil',
      'logout': 'Çıkış Yap',
      'language': 'Dil / Language',
      'theme': 'Tema',
      'dark_mode': 'Karanlık Mod',
    },
    'en': {
      'app_title': 'Enterprise App',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'welcome': 'Welcome',
      'dashboard': 'Dashboard',
      'settings': 'Settings',
      'profile': 'Profile',
      'logout': 'Logout',
      'language': 'Language',
      'theme': 'Theme',
      'dark_mode': 'Dark Mode',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['tr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
