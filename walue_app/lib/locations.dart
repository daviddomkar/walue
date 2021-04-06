import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/user.dart';
import 'providers.dart';
import 'screens/choose_fiat_currency/choose_fiat_currency_screen.dart';
import 'screens/currency/currency_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/settings/settings_screen.dart';
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
  List<BeamPage> pagesBuilder(BuildContext? context, BeamState state) {
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
                routerDelegate: BeamerRouterDelegate(
                  locationBuilder: BeamerLocationBuilder(
                    beamLocations: [
                      HomeLocation(),
                      CurrencyLocation(),
                      SettingsLocation(),
                    ],
                  ),
                ),
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
      ];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) {
    return [
      NoTransitionPage(
        key: const ValueKey('home'),
        child: const HomeScreen(),
      ),
    ];
  }
}

class CurrencyLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => [
        '/currency/:currencyId',
      ];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) {
    return [
      NoTransitionPage(
        key: ValueKey('currency-${state.pathParameters['currencyId']!}'),
        child: CurrencyScreen(id: state.pathParameters['currencyId']!),
      ),
    ];
  }
}

class SettingsLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => [
        '/settings',
      ];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) {
    return [
      NoTransitionPage(
        key: const ValueKey('settings'),
        child: const SettingsScreen(),
      ),
    ];
  }
}
