import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repositories/user_repository.dart';
import 'screens/choose_fiat_currency/choose_fiat_currency_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'utils/no_transition_page.dart';

class RootLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => [
        '/',
        '/login',
        '/choose-fiat-currency',
        '/*',
      ];

  @override
  Widget builder(BuildContext context, Widget navigator) {
    return ProviderListener<UserRepository>(
      onChange: (context, repository) {
        final user = repository.user;

        if (!user.hasData) {
          context.currentBeamLocation.update((state) => state.copyWith(pathBlueprintSegments: ['login']));
        } else if (user.hasData && user.data!.fiatCurrency == null) {
          context.currentBeamLocation.update((state) => state.copyWith(pathBlueprintSegments: ['choose-fiat-currency']));
        } else {
          context.currentBeamLocation.update((state) => state.copyWith());
        }
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
        NoTransitionPage(
          key: const ValueKey('splash'),
          child: const SplashScreen(),
        ),
      ];
    }

    return [
      if (!user.hasData)
        NoTransitionPage(
          key: const ValueKey('login'),
          child: const LogInScreen(),
        ),
      if (user.hasData && user.data!.fiatCurrency == null)
        NoTransitionPage(
          key: const ValueKey('choose-fiat-currency'),
          child: const ChooseFiatCurrencyScreen(),
        ),
      if (user.hasData && user.data!.fiatCurrency != null)
        NoTransitionPage(
          key: const ValueKey('home'),
          child: const HomeScreen(),
        ),
    ];
  }
}

class HomeLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => [
        '/',
        '/settings',
        '/currency/:currencyId',
      ];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) {
    // TODO: implement pagesBuilder
    throw UnimplementedError();
  }
}
