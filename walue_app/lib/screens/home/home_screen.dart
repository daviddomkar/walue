import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../hooks/use_provider_cached.dart';
import '../../hooks/use_provider_not_null.dart';
import '../../models/crypto_currency.dart';
import '../../providers.dart';
import '../../repositories/user_repository.dart';
import '../../widgets/crypto_select_sheet.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/header_background.dart';
import '../../widgets/logo.dart';
import '../../widgets/portfolio_record_list_item.dart';

class HomeScreen extends HookWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = useProvider(userRepositoryProvider);

    final ownedCurrencies = useProviderCached(ownedCryptoCurrenciesStreamProvider);
    final portfolioRecords = useProviderCached(portfolioRecordsStreamProvider);

    final totalValueNumber = portfolioRecords.data?.value?.map((record) => record.computeTotalFiatAmountValue(ownedCurrencies.data?.value?[record.id]?.fiatPrice)).fold<double>(0.0, (previousValue, element) {
      return previousValue += element ?? 0;
    });

    final fiatCurrency = useProviderNotNull(fiatCurrencyStreamProvider);

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final currencyFormatter = totalValueNumber != null
        ? (totalValueNumber >= (isLandscape ? 1000000000000000000 : 1000000000000) || totalValueNumber <= -(isLandscape ? 1000000000000000000 : 1000000000)
            ? NumberFormat.compactSimpleCurrency(locale: 'en', name: fiatCurrency?.symbol.toUpperCase())
            : NumberFormat.simpleCurrency(locale: 'en', name: fiatCurrency?.symbol.toUpperCase()))
        : null;

    final totalValue = currencyFormatter?.format(totalValueNumber);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
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
                  child: Stack(
                    children: [
                      const HeaderBackground(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SafeArea(
                            bottom: false,
                            minimum: const EdgeInsets.only(top: 32.0, left: 32.0, right: 32.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Logo(
                                      small: true,
                                    ),
                                  ],
                                ),
                                Transform.translate(
                                  offset: const Offset(8.0, 0.0),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      context.beamToNamed('/settings', popToNamed: '/');
                                    },
                                    icon: const FaIcon(
                                      FontAwesomeIcons.userCog,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 24.0, bottom: 20.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(right: 4.0, left: 32.0),
                                      child: FaIcon(
                                        FontAwesomeIcons.solidStar,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!.favourites,
                                      style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 24.0, color: Colors.white),
                                    ),
                                  ],
                                ),
                                FavouriteList(
                                  onAddFavourite: (currency) => viewModel.addCryptoCurrencyToFavourites(currency.id),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SafeArea(
                              top: false,
                              bottom: false,
                              minimum: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 4.0),
                                        child: FaIcon(
                                          FontAwesomeIcons.list,
                                          color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 16.0),
                                        child: Text(
                                          AppLocalizations.of(context)!.portfolio,
                                          style: Theme.of(context).textTheme.headline4!.copyWith(
                                                fontSize: 24.0,
                                                color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                              ),
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: 24.0,
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: AutoSizeText(
                                              totalValue.toString(),
                                              style: Theme.of(context).textTheme.headline4!.copyWith(
                                                    fontSize: 24.0,
                                                    color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                                  ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 16.0, top: 8.0),
                                      child: PortfolioRecordList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SafeArea(
                            top: false,
                            minimum: EdgeInsets.only(bottom: 32.0, left: 32.0, right: 32.0),
                            child: AddNewCryptoButton(),
                          )
                        ],
                      ),
                    ],
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

class AddNewCryptoButton extends HookWidget {
  const AddNewCryptoButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final portfolioRecords = useProviderCached(portfolioRecordsStreamProvider);

    return GradientButton(
      loading: portfolioRecords is AsyncLoading,
      onPressed: () {
        if (portfolioRecords.data?.value != null) {
          showModalBottomSheet(
            clipBehavior: Clip.hardEdge,
            context: context,
            isScrollControlled: true,
            backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0),
              ),
            ),
            builder: (context) => CryptoSelectSheet(
              ownedCurrencyIds: portfolioRecords.data!.value!.map((record) => record.id).toList(),
              onCryptoCurrencySelected: (currency) {
                Navigator.of(context).pop(context);
                context.beamToNamed('/currency/${currency.id}', popToNamed: '/', data: {
                  'currencyImageUrl': currency.imageUrl,
                  'currencyName': currency.name,
                });
              },
            ),
          );
        }
      },
      child: Text(
        AppLocalizations.of(context)!.addNewCrypto,
        style: const TextStyle(
          fontSize: 18.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class FavouriteList extends HookWidget {
  final void Function(CryptoCurrency currency) onAddFavourite;

  const FavouriteList({
    Key? key,
    required this.onAddFavourite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fiatCurrency = useProviderNotNull(fiatCurrencyStreamProvider);
    final favouriteCurrencyIds = useProviderNotNull(favouriteCurrencyIdsStreamProvider);

    final _ownedCurrencies = useProviderCached(ownedCryptoCurrenciesStreamProvider);

    final error = _ownedCurrencies is AsyncError;
    final loading = _ownedCurrencies is AsyncLoading || favouriteCurrencyIds == null || fiatCurrency == null;

    final ownedCurrencies = _ownedCurrencies.data?.value;

    return SizedBox(
      height: 128.0 + 16.0,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final itemCount = error || loading ? 1 : favouriteCurrencyIds!.length + 1;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              width: 128.0,
              height: 128.0,
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
                child: index == itemCount - 1
                    ? AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: loading
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary),
                                  strokeWidth: 2.0,
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  if (error) return;

                                  showModalBottomSheet(
                                    clipBehavior: Clip.hardEdge,
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(40.0),
                                        topRight: Radius.circular(40.0),
                                      ),
                                    ),
                                    builder: (context) => CryptoSelectSheet(
                                      ownedCurrencyIds: favouriteCurrencyIds!,
                                      onCryptoCurrencySelected: (currency) {
                                        onAddFavourite(currency);
                                        Navigator.of(context).pop(context);
                                      },
                                    ),
                                  );
                                },
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(
                                        FontAwesomeIcons.plus,
                                        color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          AppLocalizations.of(context)!.addFavourite,
                                          style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                                fontSize: 14.0,
                                                color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: ownedCurrencies == null || !ownedCurrencies.containsKey(favouriteCurrencyIds![index])
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary),
                                  strokeWidth: 2.0,
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  final id = favouriteCurrencyIds[index];

                                  context.beamToNamed('/currency/$id', popToNamed: '/', data: {
                                    'currencyImageUrl': ownedCurrencies[id]?.imageUrl,
                                    'currencyName': ownedCurrencies[id]?.name,
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          CachedNetworkImage(
                                            width: 32.0,
                                            height: 32.0,
                                            imageUrl: ownedCurrencies[favouriteCurrencyIds[index]]!.imageUrl,
                                            imageBuilder: (context, imageProvider) => Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                LimitedBox(
                                                  maxWidth: 70.0,
                                                  child: Text(
                                                    ownedCurrencies[favouriteCurrencyIds[index]]!.name,
                                                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                                                          color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                                        ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  ownedCurrencies[favouriteCurrencyIds[index]]!.symbol.toUpperCase(),
                                                  style: TextStyle(
                                                    height: 0.9,
                                                    color: Theme.of(context).brightness == Brightness.light ? const Color(0x80222222) : const Color(0x80FFFFFF),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            AppLocalizations.of(context)!.marketPrice,
                                            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                                                  fontSize: 12.0,
                                                  color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                                ),
                                            textAlign: TextAlign.right,
                                          ),
                                          Text(
                                            ownedCurrencies[favouriteCurrencyIds[index]]!.calculateFormattedFiatPrice(fiatCurrency!.symbol)!,
                                            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                                                  fontSize: 18.0,
                                                  color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF222222) : Colors.white,
                                                ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            width: 16.0,
          );
        },
        itemCount: error || loading ? 1 : favouriteCurrencyIds!.length + 1,
      ),
    );
  }
}

class PortfolioRecordList extends HookWidget {
  const PortfolioRecordList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fiatCurrency = useProviderNotNull(fiatCurrencyStreamProvider);

    final ownedCurrencies = useProviderCached(ownedCryptoCurrenciesStreamProvider);
    final portfolioRecords = useProviderCached(portfolioRecordsStreamProvider);

    final loading = ownedCurrencies is AsyncLoading || portfolioRecords is AsyncLoading || fiatCurrency == null || portfolioRecords.data?.value == null || ownedCurrencies.data?.value == null;
    final error = ownedCurrencies is AsyncError || portfolioRecords is AsyncError;

    // final totalValue = portfolioRecords.data?.value?.map((record) => record.computeTotalFiatAmount(fiatPrice, fiatSymbol))

    return Container(
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
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: error
            ? Center(
                child: Text(
                  AppLocalizations.of(context)!.errorWhileFetchingRecords,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Colors.red,
                      ),
                  textAlign: TextAlign.center,
                ),
              )
            : loading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Theme.of(context).brightness == Brightness.light ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondary),
                      strokeWidth: 2.0,
                    ),
                  )
                : portfolioRecords.data!.value!.isEmpty
                    ? Center(
                        child: Text(
                          AppLocalizations.of(context)!.noPortfolioRecordsFound,
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.light ? const Color(0x80222222) : const Color(0x80FFFFFF),
                          ),
                        ),
                      )
                    : Container(
                        constraints: const BoxConstraints.expand(),
                        child: Material(
                          color: Theme.of(context).brightness == Brightness.light ? Colors.white : const Color(0xFF222222),
                          child: Column(
                            children: [
                              for (var i = 0; i < portfolioRecords.data!.value!.length; i++) ...[
                                if (ownedCurrencies.data!.value!.containsKey(portfolioRecords.data!.value![i].id))
                                  PortfolioRecordListItem(
                                    record: portfolioRecords.data!.value![i],
                                    currency: ownedCurrencies.data!.value![portfolioRecords.data!.value![i].id]!,
                                    fiatCurrency: fiatCurrency!,
                                  ),
                                if (i != portfolioRecords.data!.value!.length - 1 && ownedCurrencies.data!.value!.containsKey(portfolioRecords.data!.value![i].id))
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Theme.of(context).brightness == Brightness.light ? const Color(0x20000000) : const Color(0x20FFFFFF),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }
}
