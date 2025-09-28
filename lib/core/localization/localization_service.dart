import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalizationService {
  static const String _localizationPath = 'assets/l10n';
  static const List<String> supportedLocales = ['en', 'es'];
  
  Locale? _locale;
  Map<String, String>? _localizedStrings;

  Locale? get locale => _locale;
  bool get isInitialized => _locale != null && _localizedStrings != null;

  Future<bool> load(Locale locale) async {
    _locale = locale;
    try {
      String jsonString = await rootBundle
          .loadString('$_localizationPath/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = {};
      jsonMap.forEach((key, value) {
        _localizedStrings![key] = value.toString();
      });
      return true;
    } catch (e) {
      debugPrint('Failed to load localization: $e');
      return false;
    }
  }

  String translate(String key, {List<String>? args}) {
    if (_localizedStrings == null) {
      return key;
    }
    
    String? value = _localizedStrings![key];
    if (value == null) {
      return key;
    }
    
    // If arguments are provided, format the string
    if (args != null && args.isNotEmpty) {
      for (int i = 0; i < args.length; i++) {
        value = value!.replaceAll('{$i}', args[i]);
      }
    }
    
    return value!;
  }

  // Get the current locale
  Locale getCurrentLocale() {
    return _locale ?? const Locale('en', 'US');
  }
  
  // Change locale
  Future<void> changeLocale(String languageCode) async {
    await load(Locale(languageCode));
  }
}

// Singleton instance
final localizationService = LocalizationService();