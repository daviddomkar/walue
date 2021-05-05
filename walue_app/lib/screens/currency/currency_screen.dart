import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers.dart';
import '../../repositories/user_repository.dart';
import '../../widgets/buy_record_dialog.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/logo.dart';
import 'currency_view_model.dart';

final currencyViewModelProvider = ChangeNotifierProvider.autoDispose.family<CurrencyViewModel, String>((ref, id) {
  final userRepository = ref.watch(userRepositoryProvider);
  final user = ref.watch(userStreamProvider);
  final fiatCurrencies = ref.watch(fiatCurrenciesStreamProvider);
  final currency = ref.watch(cryptoCurrencyStreamProvider(id));
  final portfolioRecord = ref.watch(portfolioRecordStreamProvider(id));

  return CurrencyViewModel(
    userRepository: userRepository,
    user: user,
    currency: currency,
    portfolioRecord: portfolioRecord,
    fiatCurrencies: fiatCurrencies,
  );
});

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
    final viewModel = useProvider(currencyViewModelProvider(id));

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
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (viewModel.currencyImageUrl != null || currencyImageUrl != null)
                                          CachedNetworkImage(
                                            width: 24.0,
                                            height: 24.0,
                                            imageUrl: viewModel.currencyImageUrl ?? currencyImageUrl!,
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
                                              viewModel.currencyName ?? currencyName ?? '',
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
                                      viewModel.totalFiatAmount ?? (viewModel.buyRecords == null || viewModel.buyRecords!.isEmpty ? null : totalFiatAmount) ?? '',
                                      style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
                                    ),
                                  ),
                                  Text(
                                    viewModel.totalAmount ?? (viewModel.buyRecords == null || viewModel.buyRecords!.isEmpty ? null : totalAmount) ?? '',
                                    style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Colors.white),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0, bottom: 90.0),
                                    child: SizedBox(
                                      width: 200.0,
                                      height: 48.0,
                                      child: AutoSizeText(
                                        viewModel.increasePercentage ?? (viewModel.buyRecords == null || viewModel.buyRecords!.isEmpty ? null : increasePercentage) ?? '',
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
                                    if (!viewModel.loading)
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          if (viewModel.favouriteCurrencyIds!.contains(id)) {
                                            viewModel.deleteFromFavourites();
                                          } else {
                                            viewModel.addToFavourites();
                                          }
                                        },
                                        icon: FaIcon(
                                          viewModel.favouriteCurrencyIds!.contains(id) ? FontAwesomeIcons.solidStar : FontAwesomeIcons.star,
                                          color: viewModel.favouriteCurrencyIds!.contains(id) ? Colors.amber : const Color(0xFF222222),
                                        ),
                                      ),
                                  ],
                                ),
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
                                    child: BuyRecordList(viewModel: viewModel),
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
                                  fiatCurrencies: viewModel.fiatCurrencies,
                                  selectedCurrency: viewModel.fiatCurrency,
                                  onAddRecord: (buyPrice, amount, currency) {
                                    viewModel.addBuyRecord(buyPrice, amount, currency);
                                    Navigator.of(context, rootNavigator: true).pop(context);
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

class BuyRecordList extends StatelessWidget {
  const BuyRecordList({
    Key? key,
    required this.viewModel,
  }) : super(key: key);

  final CurrencyViewModel viewModel;

  @override
  Widget build(BuildContext context) {
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
        child: viewModel.loading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                  strokeWidth: 2.0,
                ),
              )
            : viewModel.buyRecords!.isEmpty
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
                          for (var i = 0; i < viewModel.buyRecords!.length; i++) ...[
                            BuyRecordListItem(viewModel: viewModel, i: i),
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
  const BuyRecordListItem({
    Key? key,
    required this.viewModel,
    required this.i,
  }) : super(key: key);

  final CurrencyViewModel viewModel;
  final int i;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => BuyRecordDialog(
            initialRecord: viewModel.buyRecords![i],
            onEditRecord: (id, buyPrice, amount) {
              viewModel.editBuyRecord(id, buyPrice, amount);
              Navigator.of(context, rootNavigator: true).pop(context);
            },
            onDeleteRecord: (id) {
              viewModel.deleteBuyRecord(id);
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
                viewModel.buyRecords![i].formattedBuyPrice,
                style: Theme.of(context).textTheme.subtitle1!.copyWith(
                      fontSize: 14.0,
                    ),
              ),
            ),
            Expanded(
              child: Text(
                viewModel.buyRecords![i].formattedAmount,
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: const Color(0x80222222),
                    ),
              ),
            ),
            SizedBox(
              width: 90.0,
              child: (() {
                final record = viewModel.buyRecords![i];

                final profit = record.calculateProfit(viewModel.currency.data!.value!.additionalFiatPrices![record.fiatCurrency.symbol]!);
                final profitText = record.calculateformattedProfit(viewModel.currency.data!.value!.additionalFiatPrices![record.fiatCurrency.symbol]!);

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
