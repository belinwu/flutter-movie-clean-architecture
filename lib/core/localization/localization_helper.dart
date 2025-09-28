import 'package:flutter/material.dart';
import 'package:flutter_movie_clean_architecture/core/localization/app_localizations.dart';

extension LocalizationHelper on BuildContext {
  String translate(String key, {List<String>? args}) {
    return AppLocalizations.of(this)?.translate(key, args: args) ?? key;
  }
}