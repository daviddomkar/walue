import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/user.dart';
import 'providers.dart';
import 'screens/choose_fiat_currency/choose_fiat_currency_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'utils/no_transition_page.dart';

class RootLocationViewModel {
  final AsyncValue<User?> user;

  RootLocationViewModel({required this.user});
}

final _rootLocationViewModelProvider = Provider.autoDispose<RootLocationViewModel>((ref) {
  final user = ref.watch(userStreamProvider);

  return RootLocationViewModel(
    user: user,
  );
});

class RootLocation extends BeamLocation {
  final _beamerKey = GlobalKey<BeamerState>();

  @override
  List<String> get pathBlueprints => [
        '/',
        '/login',
        '/choose-fiat-currency',
        '/*',
      ];

  @override
  Widget builder(BuildContext context, Widget navigator) {
    return ProviderListener<RootLocationViewModel>(
      onChange: (context, viewModel) {
        final user = viewModel.user;

        if (user.data != null && user.data!.value == null) {
          context.currentBeamLocation.update((state) => state.copyWith(pathBlueprintSegments: ['login']));
        } else if (user.data != null && user.data!.value != null && user.data!.value!.fiatCurrency == null) {
          context.currentBeamLocation.update((state) => state.copyWith(pathBlueprintSegments: ['choose-fiat-currency']));
        } else {
          context.currentBeamLocation.update((state) => state.copyWith());
        }
      },
      provider: _rootLocationViewModelProvider,
      child: navigator,
    );
  }

  @override
  List<BeamPage> pagesBuilder(BuildContext? context) {
    final container = ProviderScope.containerOf(context!);

    final viewModel = container.read(_rootLocationViewModelProvider);

    return viewModel.user.when(
      data: (user) {
        return [
          if (user == null)
            NoTransitionPage(
              key: const ValueKey('login'),
              child: const LogInScreen(),
            ),
          if (user != null && user.fiatCurrency == null)
            NoTransitionPage(
              key: const ValueKey('choose-fiat-currency'),
              child: const ChooseFiatCurrencyScreen(),
            ),
          if (user != null && user.fiatCurrency != null)
            NoTransitionPage(
              key: const ValueKey('home'),
              child: Beamer(
                key: _beamerKey,
                beamLocations: [
                  HomeLocation(),
                ],
              ),
            ),
        ];
      },
      loading: () {
        return [
          NoTransitionPage(
            key: const ValueKey('splash'),
            child: const SplashScreen(),
          ),
        ];
      },
      error: (error, stackTrace) {
        return [
          NoTransitionPage(
            key: const ValueKey('splash'),
            child: const SplashScreen(),
          ),
        ];
      },
    );
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
    return [
      NoTransitionPage(
        key: const ValueKey('home'),
        child: HomeScreen(),
      ),
    ];
  }
}
