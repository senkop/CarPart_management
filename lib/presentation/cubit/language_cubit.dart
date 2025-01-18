import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LanguageCubit extends Cubit<Locale> {
  final SharedPreferences sharedPreferences;

  LanguageCubit(this.sharedPreferences) : super(const Locale('en')) {
    _loadLanguage();
  }

  void _loadLanguage() {
    final languageCode = sharedPreferences.getString('language_code') ?? 'en';
    emit(Locale(languageCode));
  }

  void changeLanguage(Locale locale) {
    sharedPreferences.setString('language_code', locale.languageCode);
    emit(locale);
  }
}
