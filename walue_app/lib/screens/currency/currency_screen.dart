import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../hooks/use_provider_cached.dart';
import '../../hooks/use_provider_not_null.dart';
import '../../models/buy_record.dart';
import '../../models/crypto_currency.dart';
import '../../providers.dart';
import '../../repositories/user_repository.dart';
import '../../widgets/buy_record_dialog.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/logo.dart';

class CurrencyScreen extends HookWidget {
  final String id;

  final String? currencyImageUrl;
  final String? currencyName;
  final String? totalFiatAmount;
  final String? totalAmount;
  final String? increasePercentage;

  const CurrencyScreen({
    Key? key,
    required this.id,
    this.currencyImageUrl,
    this.currencyName,
    this.totalFiatAmount,
    this.totalAmount,
    this.increasePercentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _currency = useProviderCached(cryptoCurrencyStreamProvider(id));
    final fiatCurrency = useProviderNotNull(fiatCurrencyStreamProvider);
    final _portfolioRecord = useProviderCached(portfolioRecordStreamProvider(id));
    final fiatCurrencies = useProviderCached(fiatCurrenciesStreamProvider);

    final currency = _currency.data?.value;

    final portfolioRecord = _portfolioRecord.data?.value;
    final buyRecords = portfolioRecord?.buyRecords;

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
                          child: CurrencyScreenHeader(
                            id: id,
                            currencyName: currency?.name ?? currencyName ?? '',
                            currencyImageUrl: currency?.imageUrl ?? currencyImageUrl ?? '',
                            totalFiatAmount: portfolioRecord?.computeTotalFiatAmount(currency?.fiatPrice, fiatCurrency?.symbol) ?? (buyRecords == null || buyRecords.isEmpty ? null : totalFiatAmount) ?? '',
                            totalAmount: (currency?.symbol != null ? portfolioRecord?.computeTotalAmount(currency?.symbol) : null) ?? (buyRecords == null || buyRecords.isEmpty ? null : totalAmount) ?? '',
                            increasePercentage: portfolioRecord?.computeIncreasePercentage(currency?.fiatPrice) ?? (buyRecords == null || buyRecords.isEmpty ? null : increasePercentage) ?? '',
                            onAddToFavourites: () {
                              context.read(userRepositoryProvider).addCryptoCurrencyToFavourites(id);
                            },
                            onDeleteFromFavourites: () {
                              context.read(userRepositoryProvider).deleteCryptoCurrencyFromFavourites(id);
                            },
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
                                        FontAwesomeIcons.dollarSign,
                                        color: Color(0xFF222222),
                                      ),
                                    ),
                                    Text(
                                      'Buy Records',
                                      style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 24.0),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
                                    child: BuyRecordList(id: id),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32.0, left: 32.0, right: 32.0),
                          child: GradientButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => BuyRecordDialog(
                                  fiatCurrencies: fiatCurrencies.data?.value,
                                  selectedCurrency: fiatCurrency,
                                  onAddRecord: (buyPrice, amount, fiatCurrency) {
                                    if (currency != null) {
                                      context.read(userRepositoryProvider).addCryptoCurrencyBuyRecord(currency, buyPrice, amount, fiatCurrency);
                                      Navigator.of(context, rootNavigator: true).pop(context);
                                    }
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              'Add new buy record',
                              style: TextStyle(
                                fontSize: 18.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
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

class CurrencyScreenHeader extends HookWidget {
  final String id;
  final String currencyName;
  final String currencyImageUrl;
  final String totalFiatAmount;
  final String totalAmount;
  final String increasePercentage;

  final void Function() onAddToFavourites;
  final void Function() onDeleteFromFavourites;

  const CurrencyScreenHeader({
    required this.id,
    required this.currencyImageUrl,
    required this.currencyName,
    required this.totalFiatAmount,
    required this.totalAmount,
    required this.increasePercentage,
    required this.onAddToFavourites,
    required this.onDeleteFromFavourites,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favouriteCurrencyIds = useProviderNotNull(favouriteCurrencyIdsStreamProvider);

    return Row(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    width: 24.0,
                    height: 24.0,
                    imageUrl: currencyImageUrl,
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: LimitedBox(
                      maxWidth: 200.0,
                      child: Text(
                        currencyName,
                        style: Theme.of(context).textTheme.headline5!.copyWith(color: const Color(0xCCFFFFFF)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                totalFiatAmount,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
              ),
            ),
            Text(
              totalAmount,
              style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 90.0),
              child: SizedBox(
                width: 200.0,
                height: 48.0,
                child: AutoSizeText(
                  increasePercentage,
                  style: Theme.of(context).textTheme.headline4!.copyWith(color: Colors.white),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
        Transform.translate(
          offset: const Offset(8.0, -8.0),
          child: Column(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  context.beamToNamed('/', replaceCurrent: true);
                },
                icon: const FaIcon(
                  FontAwesomeIcons.arrowLeft,
                  color: Color(0xFF222222),
                ),
              ),
              if (favouriteCurrencyIds != null)
                IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (favouriteCurrencyIds.contains(id)) {
                      onDeleteFromFavourites();
                    } else {
                      onAddToFavourites();
                    }
                  },
                  icon: FaIcon(
                    favouriteCurrencyIds.contains(id) ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
                    color: favouriteCurrencyIds.contains(id) ? Colors.amber : const Color(0xFF222222),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class BuyRecordList extends HookWidget {
  final String id;

  const BuyRecordList({
    required this.id,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _currency = useProviderCached(cryptoCurrencyStreamProvider(id));
    final _portfolioRecord = useProviderCached(portfolioRecordStreamProvider(id));

    final error = _currency is AsyncError || _portfolioRecord is AsyncError;
    final loading = _currency is AsyncLoading || _portfolioRecord is AsyncLoading || _currency.data?.value == null || _portfolioRecord.data?.value == null;

    final currency = _currency.data?.value;
    final buyRecords = _portfolioRecord.data?.value?.buyRecords;

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
                  'An error occured while fetching records, Walue will attempt another fetch in a moment!',
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
                : buyRecords!.isEmpty
                    ? const Center(
                        child: Text('No buy records found'),
                      )
                    : Container(
                        constraints: const BoxConstraints.expand(),
                        child: Material(
                          color: Colors.white,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                height: 56.0,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 120.0,
                                      child: Text(
                                        'Buy price',
                                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                              fontSize: 14.0,
                                            ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Amount',
                                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                                              color: const Color(0x80222222),
                                            ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 90.0,
                                      child: Text(
                                        'Profit',
                                        style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                              fontSize: 14.0,
                                            ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: Color(0x20000000),
                              ),
                              for (var i = 0; i < buyRecords.length; i++) ...[
                                BuyRecordListItem(
                                  record: buyRecords[i],
                                  currency: currency!,
                                  onEditBuyRecord: (id, buyPrice, amount) {
                                    context.read(userRepositoryProvider).editCryptoCurrencyBuyRecord(currency, id, buyPrice, amount);
                                  },
                                  onDeleteBuyRecord: (id) {
                                    context.read(userRepositoryProvider).deleteCryptoCurrencyBuyRecord(currency, id);
                                  },
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

class BuyRecordListItem extends StatelessWidget {
  final BuyRecord record;
  final CryptoCurrency currency;

  final void Function(String id, double? buyPrice, double? amount) onEditBuyRecord;
  final void Function(String id) onDeleteBuyRecord;

  const BuyRecordListItem({
    required this.record,
    required this.currency,
    required this.onEditBuyRecord,
    required this.onDeleteBuyRecord,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => BuyRecordDialog(
            initialRecord: record,
            onEditRecord: (id, buyPrice, amount) {
              onEditBuyRecord(id, buyPrice, amount);
              Navigator.of(context, rootNavigator: true).pop(context);
            },
            onDeleteRecord: (id) {
              onDeleteBuyRecord(id);
              Navigator.of(context, rootNavigator: true).pop(context);
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        height: 48.0,
        child: Row(
          children: [
            SizedBox(
              width: 120.0,
              child: Text(
                record.formattedBuyPrice,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      fontSize: 14.0,
                    ),
              ),
            ),
            Expanded(
              child: Text(
                record.formattedAmount,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: const Color(0x80222222),
                    ),
              ),
            ),
            SizedBox(
              width: 90.0,
              child: (() {
                final profit = record.calculateProfit(currency.additionalFiatPrices![record.fiatCurrency.symbol]!);
                final profitText = record.calculateformattedProfit(currency.additionalFiatPrices![record.fiatCurrency.symbol]!);

                var color = const Color(0xFF222222);

                if (profit > 0) {
                  color = const Color(0xFF54D790);
                } else if (profit < 0) {
                  color = const Color(0xFFD90D00);
                }

                return Text(
                  profitText,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: color,
                      ),
                  maxLines: 1,
                );
              })(),
            ),
          ],
        ),
      ),
    );
  }
}
