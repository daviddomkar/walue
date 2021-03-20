import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repositories/user_repository.dart';
import 'screens/choose_fiat_currency/choose_fiat_currency_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/splash/splash_screen.dart';

class HomeLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/'];

  @override
  Widget builder(BuildContext context, Widget navigator) {
    return ProviderListener<UserRepository>(
      onChange: (context, repository) {
        context.updateCurrentLocation();
      },
      provider: userRepositoryProvider,
      child: navigator,
    );
  }

  @override
  List<BeamPage> pagesBuilder(BuildContext? context) {
    final container = ProviderScope.containerOf(context!);

    final user = container.read(userRepositoryProvider).user;

    if (user.isNotFinished || user.hasError) {
      return [
        BeamPage(
          key: const ValueKey('splash'),
          child: const SplashScreen(),
        ),
      ];
    }

    return [
      if (!user.hasData)
        BeamPage(
          key: const ValueKey('login'),
          child: const LogInScreen(),
        ),
      if (user.hasData && user.data!.fiatCurrency == null)
        BeamPage(
          key: const ValueKey('choose-fiat-currency'),
          child: const ChooseFiatCurrencyScreen(),
        ),
      if (user.hasData && user.data!.fiatCurrency != null)
        BeamPage(
          key: const ValueKey('home'),
          child: const HomeScreen(),
        ),
    ];
  }
}
