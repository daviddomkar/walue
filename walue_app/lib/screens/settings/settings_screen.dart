import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/currency.dart';
import '../../models/user.dart';
import '../../providers.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';
import '../../widgets/fiat_currencies_dialog.dart';
import '../../widgets/logo.dart';
import 'settings_view_model.dart';

final settingsViewModelProvider = ChangeNotifierProvider.autoDispose<SettingsViewModel>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  final user = ref.watch(userStreamProvider);
  final fiatCurrencies = ref.watch(fiatCurrenciesStreamProvider);

  return SettingsViewModel(
    authRepository: authRepository,
    userRepository: userRepository,
    user: user,
    fiatCurrencies: fiatCurrencies,
  );
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final viewModel = watch(settingsViewModelProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, left: 32.0, right: 32.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Logo(
                                color: Color(0xFF222222),
                                small: true,
                              ),
                              Transform.translate(
                                offset: const Offset(0.0, -10.0),
                                child: Text(
                                  'Settings',
                                  style: Theme.of(context).textTheme.headline5!.copyWith(color: const Color(0xFF222222)),
                                ),
                              ),
                            ],
                          ),
                          Transform.translate(
                            offset: const Offset(8.0, -8.0),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                context.beamToNamed('/', replaceCurrent: true);
                              },
                              icon: const FaIcon(
                                FontAwesomeIcons.arrowLeft,
                                color: Color(0xFF222222),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 32.0, right: 32.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 4.0),
                                child: FaIcon(
                                  FontAwesomeIcons.solidUser,
                                  color: Color(0xFF222222),
                                ),
                              ),
                              Text(
                                'Account',
                                style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 24.0),
                              ),
                            ],
                          ),
                          if (!viewModel.loading)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(16.0),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).primaryColor,
                                      Theme.of(context).accentColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48.0,
                                      height: 48.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(image: NetworkImage(viewModel.photoUrl!), fit: BoxFit.contain),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              viewModel.displayName!,
                                              style: Theme.of(context).textTheme.headline4!.copyWith(
                                                    fontSize: 18.0,
                                                    color: Colors.white,
                                                  ),
                                            ),
                                            Text(
                                              viewModel.email!,
                                              style: Theme.of(context).textTheme.subtitle2!.copyWith(
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        viewModel.signOut();
                                      },
                                      icon: const FaIcon(
                                        FontAwesomeIcons.signOutAlt,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, left: 32.0, right: 32.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 4.0),
                                child: FaIcon(
                                  FontAwesomeIcons.cog,
                                  color: Color(0xFF222222),
                                ),
                              ),
                              Text(
                                'Preferences',
                                style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 24.0),
                              ),
                            ],
                          ),
                          if (!viewModel.loading)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 4.0,
                                      color: Color(0x32000000),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    PreferenceItem(
                                      title: 'Fiat currency',
                                      subtitle: 'Currency in which your stats are displayed',
                                      value: viewModel.fiatCurrency!.symbol.toUpperCase(),
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => FiatCurrenciesDialog(
                                            currencies: viewModel.fiatCurrencies!.values.where((currency) => currency.symbol != viewModel.fiatCurrency!.symbol).toList(),
                                            onCurrencySelected: (currency) {
                                              viewModel.changeFiatCurrency(currency);
                                              Navigator.of(context, rootNavigator: true).pop(context);
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                    PreferenceItem(
                                      title: 'Theme',
                                      subtitle: 'visual style of the app',
                                      value: 'System',
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0, left: 32.0, right: 32.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 4.0),
                                child: FaIcon(
                                  FontAwesomeIcons.exclamationTriangle,
                                  color: Color(0xFFD90D00),
                                ),
                              ),
                              Text(
                                'Danger zone',
                                style: Theme.of(context).textTheme.headline4!.copyWith(
                                      fontSize: 24.0,
                                      color: const Color(0xFFD90D00),
                                    ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                              height: 48.0,
                              clipBehavior: Clip.hardEdge,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16.0),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 4.0,
                                    color: Color(0x32000000),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.white,
                                child: InkWell(
                                  onTap: () {
                                    viewModel.deleteAccount();
                                  },
                                  child: Center(
                                    child: Text(
                                      'Delete account',
                                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                            color: const Color(0xFFD90D00),
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PreferenceItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;

  final void Function() onTap;

  const PreferenceItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            fontSize: 12.0,
                            color: const Color(0x80222222),
                          ),
                    ),
                  ],
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
