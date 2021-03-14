import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum ThemeType { light, dark }

final themeTypeProvider = StateProvider((ref) => ThemeType.light);

final themeDataProvider = Provider<ThemeData>((ref) {
  final themeType = ref.watch(themeTypeProvider);

  switch (themeType.state) {
    case ThemeType.light:
      return ThemeData.light();
    case ThemeType.dark:
      return ThemeData.dark();
  }
});
