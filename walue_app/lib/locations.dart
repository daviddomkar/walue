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
  @override
  List<String> get pathBlueprints => [
        '/',
        '/login',
        '/choose-fiat-currency',
        '/settings',
        '/currency/:currencyId',
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
          context.currentBeamLocation.update();
        }
      },
      provider: _rootLocationViewModelProvider,
      child: navigator,
    );
  }

  @override
  List<BeamPage> buildPages(BuildContext? context, BeamState state) {
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
          if (user != null && user.fiatCurrency != null) ...[
            NoTransitionPage(
              key: const ValueKey('home'),
              child: const HomeScreen(),
            ),
            if (state.pathBlueprintSegments.contains('currency'))
              NoTransitionPage(
                key: ValueKey('currency-${state.pathParameters['currencyId']!}'),
                child: CurrencyScreen(
                  id: state.pathParameters['currencyId']!,
                  currencyImageUrl: state.data['currencyImageUrl'] != null ? state.data['currencyImageUrl'] as String : null,
                  currencyName: state.data['currencyName'] != null ? state.data['currencyName'] as String : null,
                  totalFiatAmount: state.data['totalFiatAmount'] != null ? state.data['totalFiatAmount'] as String : null,
                  totalAmount: state.data['totalAmount'] != null ? state.data['totalAmount'] as String : null,
                  increasePercentage: state.data['increasePercentage'] != null ? state.data['increasePercentage'] as String : null,
                ),
              ),
            if (state.pathBlueprintSegments.contains('settings'))
              NoTransitionPage(
                key: const ValueKey('settings'),
                child: const SettingsScreen(),
              ),
          ]
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
