import 'package:flutter/widgets.dart';
import 'package:res/strings/strings.dart';
import 'package:res/strings/strings_en.dart';
import 'package:res/strings/strings_es.dart';

extension LocalizationExtension on BuildContext {
  static Strings _getStrings(Locale locale) {
    switch (locale.languageCode) {
      case 'es':
        return StringsEs();
      default: // Defaults to English
        return StringsEn();
    }
  }

  Strings get strings => _getStrings(Localizations.localeOf(this));
}
