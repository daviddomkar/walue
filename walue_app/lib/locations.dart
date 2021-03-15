import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:walue_app/models/user.dart';
import 'package:walue_app/utils/resource.dart';

import 'repositories/auth_repository.dart';

import 'screens/choose_fiat_currency/choose_fiat_currency_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/splash/splash_screen.dart';

class MainLocation extends BeamLocation {
  @override
  Widget builder(BuildContext context, Widget navigator) {
    return ProviderListener<AuthRepository>(
      onChange: (context, repository) {
        context.updateCurrentLocation(data: {
          'user': repository.user,
        });
      },
      provider: authRepositoryProvider,
      child: navigator,
    );
  }

  @override
  List<BeamPage> pagesBuilder(BuildContext? context) {
    if (_user.state == ResourceState.empty || _user.state == ResourceState.loading) {
      return [
        BeamPage(
          key: const ValueKey('splash'),
          child: const SplashScreen(),
        ),
      ];
    }

    return [
      if (!_user.hasError && !_user.hasData)
        BeamPage(
          key: const ValueKey('login'),
          child: const LogInScreen(),
        ),
      if (!_user.hasError && _user.hasData && _user.data!.fiatCurrency == null)
        BeamPage(
          key: const ValueKey('choose-fiat-currency'),
          child: const ChooseFiatCurrencyScreen(),
        ),
      if (!_user.hasError && _user.hasData && _user.data!.fiatCurrency != null)
        BeamPage(
          key: const ValueKey('dashboard'),
          child: const DashboardScreen(),
        ),
    ];
  }

  @override
  List<String> get pathBlueprints => ['/'];

  Resource<User?, dynamic> get _user => data.containsKey('user') ? data['user'] as Resource<User?, dynamic> : const Resource.empty();
}
