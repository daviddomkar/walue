import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences sharedPreferences;

  ThemeNotifier({required this.sharedPreferences}) : super(sharedPreferences.containsKey('theme') ? ThemeMode.values[sharedPreferences.getInt('theme')!] : ThemeMode.system);

  set mode(ThemeMode mode) {
    state = mode;
    sharedPreferences.setInt('theme', mode.index);
  }

  ThemeMode get mode => state;
}

final themeProvider = StateNotifierProvider.autoDispose<ThemeNotifier, ThemeMode>((ref) => throw UnimplementedError());
