import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../generated/locale_keys.g.dart';
import '../../hooks/use_provider_not_null.dart';
import '../../providers.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';
import '../../widgets/basic_button.dart';
import '../../widgets/fiat_currencies_dialog.dart';
import '../../widgets/language_dialog.dart';
import '../../widgets/logo.dart';
import '../../widgets/theme_mode_dialog.dart';
import '../../widgets/w_text_form_field.dart';

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

class SettingsScreen extends HookWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(settingsViewModelProvider);
    final themeMode = useProvider(themeProvider);

    final fiatCurrency = useProviderNotNull(fiatCurrencyStreamProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.light ? Brightness.dark : Brightness.light,
        statusBarBrightness: Theme.of(context).brightness,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF000000),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: SafeArea(
                    minimum: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Logo(
                                  color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                  small: true,
                                ),
                                Transform.translate(
                                  offset: const Offset(0.0, -10.0),
                                  child: Text(
                                    LocaleKeys.settings.tr(),
                                    style: Theme.of(context).textTheme.headline5!.copyWith(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            Transform.translate(
                              offset: const Offset(8.0, 0.0),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  context.beamBack();
                                },
                                icon: FaIcon(
                                  FontAwesomeIcons.arrowLeft,
                                  color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: FaIcon(
                                      FontAwesomeIcons.solidUser,
                                      color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                    ),
                                  ),
                                  Text(
                                    LocaleKeys.account.tr(),
                                    style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 24.0, color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white),
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
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(context).colorScheme.secondary,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        if (viewModel.photoUrl != null)
                                          CachedNetworkImage(
                                            width: 48.0,
                                            height: 48.0,
                                            imageUrl: viewModel.photoUrl!,
                                            imageBuilder: (context, imageProvider) => Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                                              ),
                                            ),
                                          ),
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(left: viewModel.photoUrl != null ? 16.0 : 0.0, right: 16.0),
                                            child: SizedBox(
                                              height: 40.0,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  AutoSizeText(
                                                    viewModel.displayName ?? viewModel.email!,
                                                    style: Theme.of(context).textTheme.headline4!.copyWith(
                                                          fontSize: 18.0,
                                                          color: Colors.white,
                                                        ),
                                                    maxLines: 1,
                                                    minFontSize: 4.0,
                                                  ),
                                                  if (viewModel.displayName != null)
                                                    AutoSizeText(
                                                      viewModel.email!,
                                                      style: Theme.of(context).textTheme.subtitle2!.copyWith(
                                                            color: Colors.white,
                                                          ),
                                                      maxLines: 1,
                                                      minFontSize: 4.0,
                                                    ),
                                                ],
                                              ),
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
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: FaIcon(
                                      FontAwesomeIcons.cog,
                                      color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                    ),
                                  ),
                                  Text(
                                    LocaleKeys.preferences.tr(),
                                    style: Theme.of(context).textTheme.headline4!.copyWith(
                                          fontSize: 24.0,
                                          color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                        ),
                                  ),
                                ],
                              ),
                              if (!viewModel.loading)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Container(
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(16.0),
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          blurRadius: 4.0,
                                          color: Color(0x32000000),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        PreferenceItem(
                                          title: LocaleKeys.fiatCurrency.tr(),
                                          subtitle: LocaleKeys.fiatCurrencyDescription.tr(),
                                          value: fiatCurrency!.symbol.toUpperCase(),
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) {
                                                final currencies = viewModel.fiatCurrencies!.values.where((currency) => currency.symbol != fiatCurrency.symbol).toList();

                                                currencies.sort((currency, other) {
                                                  final name = currency.symbol.tr() == currency.symbol ? currency.name : currency.symbol.tr();
                                                  final otherName = other.symbol.tr() == other.symbol ? other.name : other.symbol.tr();

                                                  return name.compareTo(otherName);
                                                });

                                                return FiatCurrenciesDialog(
                                                  currencies: currencies,
                                                  onCurrencySelected: (currency) {
                                                    viewModel.changeFiatCurrency(currency);
                                                    Navigator.of(context, rootNavigator: true).pop(context);
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        PreferenceItem(
                                          title: LocaleKeys.theme.tr(),
                                          subtitle: LocaleKeys.themeDescription.tr(),
                                          value: ThemeModeDialog.getThemeModeName(themeMode).tr(),
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => const ThemeModeDialog(),
                                            );
                                          },
                                        ),
                                        PreferenceItem(
                                          title: LocaleKeys.language.tr(),
                                          subtitle: LocaleKeys.languageDescription.tr(),
                                          value: context.locale.languageCode.tr(),
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => const LanguageDialog(),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        /*
                        */
                        Padding(
                          padding: const EdgeInsets.only(top: 32.0),
                          child: Container(
                            height: 48.0,
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(16.0),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  blurRadius: 4.0,
                                  color: Color(0x32000000),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
                              child: InkWell(
                                onTap: () {
                                  context.beamToNamed('/settings/about');
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Stack(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          LocaleKeys.about.tr(),
                                          style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                                color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                              ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(
                                          Icons.arrow_forward,
                                          color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 4.0),
                                    child: FaIcon(
                                      FontAwesomeIcons.exclamationTriangle,
                                      color: Colors.red,
                                    ),
                                  ),
                                  Text(
                                    LocaleKeys.dangerZone.tr(),
                                    style: Theme.of(context).textTheme.headline4!.copyWith(
                                          fontSize: 24.0,
                                          color: Colors.red,
                                        ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Container(
                                  height: 48.0,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(16.0),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 4.0,
                                        color: Color(0x32000000),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
                                    child: InkWell(
                                      onTap: () {
                                        final adRepository = context.read(adRepositoryProvider);

                                        showDialog(
                                          context: context,
                                          builder: (context) => DeleteAccountDialog(onDeleteAccount: () {
                                            viewModel.deleteAccount().then((value) {
                                              adRepository.notifyAccountDeleted();
                                            }).onError((error, stackTrace) {
                                              Navigator.of(context, rootNavigator: true).pop();

                                              final snackBar = SnackBar(
                                                backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.red : const Color(0xFFEE5349),
                                                shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(16.0),
                                                    topRight: Radius.circular(16.0),
                                                  ),
                                                ),
                                                content: Text(
                                                  LocaleKeys.anErrorOccured.tr(),
                                                  style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                                        fontSize: 16.0,
                                                        color: Colors.white,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              );

                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            });
                                          }),
                                        );
                                      },
                                      child: Center(
                                        child: Text(
                                          LocaleKeys.deleteAccount.tr(),
                                          style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                                color: Colors.red,
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
              ),
            );
          },
        ),
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
        color: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white),
                        ),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                                fontSize: 12.0,
                                color: Theme.of(context).brightness == Brightness.light ? const Color(0x80222222) : const Color(0x80FFFFFF),
                              ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DeleteAccountDialog extends StatefulWidget {
  final void Function() onDeleteAccount;

  const DeleteAccountDialog({
    required this.onDeleteAccount,
    Key? key,
  }) : super(key: key);

  @override
  _DeleteAccountDialogState createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  LocaleKeys.warning.tr(),
                  style: Theme.of(context).textTheme.headline4!.copyWith(color: Colors.red, fontSize: 24.0),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  LocaleKeys.yourAccountWillBeDeletedYouSure.tr(),
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              BasicButton(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  showDialog(
                    context: context,
                    builder: (context) => DeleteAccountConfirmationDialog(
                      onDeleteAccount: widget.onDeleteAccount,
                    ),
                  );
                },
                child: Text(
                  LocaleKeys.deleteAccount.tr(),
                  style: const TextStyle(
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeleteAccountConfirmationDialog extends StatefulWidget {
  final void Function() onDeleteAccount;

  const DeleteAccountConfirmationDialog({
    required this.onDeleteAccount,
    Key? key,
  }) : super(key: key);

  @override
  _DeleteAccountConfirmationDialogState createState() => _DeleteAccountConfirmationDialogState();
}

class _DeleteAccountConfirmationDialogState extends State<DeleteAccountConfirmationDialog> {
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  LocaleKeys.confirmDelete.tr(),
                  style: Theme.of(context).textTheme.headline4!.copyWith(color: Colors.red, fontSize: 24.0),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  LocaleKeys.typeDelete.tr(),
                  style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Form(
                  key: _formKey,
                  child: WTextFormField(
                    autofocus: true,
                    hintText: LocaleKeys.deleteThatUserHasToType.tr(),
                    validator: (value) => value == LocaleKeys.deleteThatUserHasToType.tr() ? null : LocaleKeys.invalidValue.tr(),
                  ),
                ),
              ),
              BasicButton(
                loading: _loading,
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                onPressed: () {
                  if (_formKey.currentState == null) {
                    return;
                  }

                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _loading = true;
                    });

                    widget.onDeleteAccount();
                  }
                },
                child: Text(
                  LocaleKeys.confirm.tr(),
                  style: const TextStyle(
                    fontSize: 18.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
