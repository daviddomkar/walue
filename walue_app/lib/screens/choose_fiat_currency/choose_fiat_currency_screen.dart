import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../generated/locale_keys.g.dart';
import '../../providers.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';
import '../../widgets/basic_button.dart';
import '../../widgets/logo.dart';
import 'choose_fiat_currency_view_model.dart';

final chooseFiatCurrencyViewModelProvider = ChangeNotifierProvider.autoDispose<ChooseFiatCurrencyViewModel>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final fiatCurrencies = ref.watch(fiatCurrenciesStreamProvider);

  return ChooseFiatCurrencyViewModel(
    authRepository: authRepository,
    userRepository: userRepository,
    fiatCurrencies: fiatCurrencies,
  );
});

class ChooseFiatCurrencyScreen extends HookWidget {
  const ChooseFiatCurrencyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(chooseFiatCurrencyViewModelProvider);

    final fiatCurrencies = viewModel.fiatCurrencies;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Logo(
                small: true,
              ),
              Text(
                LocaleKeys.chooseYourFiatCurrency.tr(),
                style: Theme.of(context).textTheme.headline5!.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              if (fiatCurrencies.data?.value != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Theme(
                    data: Theme.of(context).copyWith(canvasColor: Theme.of(context).colorScheme.primary),
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: 'usd',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontFamily: Theme.of(context).textTheme.bodyText1!.fontFamily,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      iconDisabledColor: Colors.white,
                      iconEnabledColor: Colors.white,
                      onChanged: (String? newValue) {
                        viewModel.currency = fiatCurrencies.data!.value![newValue]!;
                      },
                      items: fiatCurrencies.data!.value!.keys.map((symbol) {
                        final currencies = fiatCurrencies.data!.value!;

                        return DropdownMenuItem<String>(
                          value: symbol,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(currencies[symbol]!.name),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(currencies[symbol]!.symbol.toUpperCase()),
                              ),
                            ],
                          ),
                        );
                      }).toList()
                        ..sort((item, other) => fiatCurrencies.data!.value![item.value]!.name.compareTo(fiatCurrencies.data!.value![other.value]!.name)),
                    ),
                  ),
                ),
                BasicButton(
                  loading: viewModel.loading,
                  onPressed: () {
                    viewModel.chooseFiatCurrency().onError((error, stackTrace) {
                      final snackBar = SnackBar(
                        backgroundColor: Colors.red,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                        ),
                        content: Text(
                          viewModel.error!,
                          style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    });
                  },
                  child: Text(
                    LocaleKeys.continueWithFiatCurrency.tr(),
                    style: const TextStyle(
                      fontSize: 18.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextButton(
                    onPressed: () {
                      viewModel.signOut();
                    },
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.resolveWith((states) => const Color(0x16000000)),
                      padding: MaterialStateProperty.resolveWith((states) => const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
                      shape: MaterialStateProperty.resolveWith(
                        (states) => const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(16.0),
                          ),
                        ),
                      ),
                    ),
                    child: Text(
                      LocaleKeys.signOut.tr(),
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
