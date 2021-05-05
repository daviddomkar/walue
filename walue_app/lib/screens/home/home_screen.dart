import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../hooks/use_provider_cached.dart';
import '../../hooks/use_provider_not_null.dart';
import '../../models/crypto_currency.dart';
import '../../providers.dart';
import '../../repositories/user_repository.dart';
import '../../widgets/crypto_select_sheet.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/logo.dart';
import '../../widgets/portfolio_record_list_item.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final viewModel = watch(userRepositoryProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Stack(
                  children: [
                    Transform(
                      transform: Matrix4.rotationZ(0.4)..translate(-150.0, -96.0),
                      alignment: Alignment.center,
                      child: Container(
                        width: 400.0,
                        height: 400.0,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(40.0),
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
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                    small: true,
                                  ),
                                  Transform.translate(
                                    offset: const Offset(0.0, -10.0),
                                    child: Text(
                                      'Dashboard',
                                      style: Theme.of(context).textTheme.headline5!.copyWith(color: const Color(0xCCFFFFFF)),
                                    ),
                                  ),
                                ],
                              ),
                              Transform.translate(
                                offset: const Offset(8.0, -8.0),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    context.beamToNamed('/settings', popToNamed: '/');
                                  },
                                  icon: const FaIcon(
                                    FontAwesomeIcons.userCog,
                                    color: Color(0xFF222222),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
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
                                    'Favourites',
                                    style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 24.0, color: Colors.white),
                                  ),
                                ],
                              ),
                              FavouriteList(
                                onAddFavourite: (currency) => viewModel.addCryptoCurrencyToFavourites(currency),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(right: 4.0),
                                      child: FaIcon(
                                        FontAwesomeIcons.list,
                                        color: Color(0xFF222222),
                                      ),
                                    ),
                                    Text(
                                      'Portfolio',
                                      style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 24.0),
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
                        const Padding(
                          padding: EdgeInsets.only(bottom: 32.0, left: 32.0, right: 32.0),
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
            backgroundColor: Colors.white,
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
      child: const Text(
        'Add new crypto',
        style: TextStyle(
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

    final loading = _ownedCurrencies is AsyncLoading || favouriteCurrencyIds == null || fiatCurrency == null;

    final ownedCurrencies = _ownedCurrencies.data?.value;

    return SizedBox(
      height: 128.0 + 16.0,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final itemCount = loading ? 1 : favouriteCurrencyIds!.length + 1;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              width: 128.0,
              height: 128.0,
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
                child: index == itemCount - 1
                    ? AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: loading
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                                  strokeWidth: 2.0,
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    clipBehavior: Clip.hardEdge,
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.white,
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
                                      const FaIcon(
                                        FontAwesomeIcons.plus,
                                        color: Color(0xFF222222),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'Add favourite',
                                          style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                                fontSize: 14.0,
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
                                  valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
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
                                          Container(
                                            width: 32.0,
                                            height: 32.0,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(image: NetworkImage(ownedCurrencies[favouriteCurrencyIds[index]]!.imageUrl), fit: BoxFit.contain),
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
                                                    style: Theme.of(context).textTheme.bodyText1,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(
                                                  ownedCurrencies[favouriteCurrencyIds[index]]!.symbol.toUpperCase(),
                                                  style: const TextStyle(height: 0.9),
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
                                            'Market Price',
                                            style: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 12.0),
                                            textAlign: TextAlign.right,
                                          ),
                                          Text(
                                            ownedCurrencies[favouriteCurrencyIds[index]]!.calculateFormattedFiatPrice(fiatCurrency!.symbol)!,
                                            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                                                  fontSize: 18.0,
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
        itemCount: loading ? 1 : favouriteCurrencyIds!.length + 1,
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

    return Container(
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
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: error
            ? Center(
                child: Text(
                  'An error occured while fetching records, check your connection and try again!',
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: const Color(0xFFD90D00),
                      ),
                  textAlign: TextAlign.center,
                ),
              )
            : loading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                      strokeWidth: 2.0,
                    ),
                  )
                : portfolioRecords.data!.value!.isEmpty
                    ? const Center(
                        child: Text('No portfolio records found'),
                      )
                    : Container(
                        constraints: const BoxConstraints.expand(),
                        child: Material(
                          color: Colors.white,
                          child: Column(
                            children: [
                              for (var i = 0; i < portfolioRecords.data!.value!.length; i++) ...[
                                if (ownedCurrencies.data!.value!.containsKey(portfolioRecords.data!.value![i].id))
                                  PortfolioRecordListItem(
                                    record: portfolioRecords.data!.value![i],
                                    currency: ownedCurrencies.data!.value![portfolioRecords.data!.value![i].id]!,
                                    fiatCurrency: fiatCurrency!,
                                  ),
                                const Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: Color(0x20000000),
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
