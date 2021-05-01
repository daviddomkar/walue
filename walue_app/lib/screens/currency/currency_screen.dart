import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../providers.dart';
import '../../repositories/user_repository.dart';
import '../../widgets/buy_record_dialog.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/logo.dart';
import 'currency_view_model.dart';

final currencyViewModelProvider = ChangeNotifierProvider.autoDispose.family<CurrencyViewModel, String>((ref, id) {
  final userRepository = ref.watch(userRepositoryProvider);
  final user = ref.watch(userStreamProvider);
  final currency = ref.watch(cryptoCurrencyStreamProvider(id));
  final portfolioRecord = ref.watch(portfolioRecordStreamProvider(id));

  return CurrencyViewModel(
    userRepository: userRepository,
    user: user,
    currency: currency,
    portfolioRecord: portfolioRecord,
  );
});

class CurrencyScreen extends ConsumerWidget {
  final String id;

  const CurrencyScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final viewModel = watch(currencyViewModelProvider(id));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight),
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
                                        Container(
                                          width: 24.0,
                                          height: 24.0,
                                          decoration: BoxDecoration(
                                            image: viewModel.currencyImageUrl != null ? DecorationImage(image: NetworkImage(viewModel.currencyImageUrl!), fit: BoxFit.contain) : null,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 4.0),
                                          child: LimitedBox(
                                            maxWidth: 200.0,
                                            child: Text(
                                              viewModel.currencyName ?? '',
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
                                      viewModel.totalFiatAmount ?? '',
                                      style: Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white),
                                    ),
                                  ),
                                  Text(
                                    viewModel.totalAmount ?? '',
                                    style: Theme.of(context).textTheme.subtitle2!.copyWith(color: Colors.white),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0, bottom: 96.0),
                                    child: Text(
                                      viewModel.increasePercentage ?? '',
                                      style: Theme.of(context).textTheme.headline4!.copyWith(color: Colors.white),
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
                                        context.beamBack();
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
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 250),
                                        child: viewModel.loading
                                            ? Center(
                                                child: CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                                                  strokeWidth: 2.0,
                                                ),
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
                                                        InkWell(
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

                                                                    final profit = record.calculateProfit(viewModel.currency.data!.value.additionalFiatPrices![record.fiatCurrency.symbol]!);
                                                                    final profitText = record.calculateformattedProfit(viewModel.currency.data!.value.additionalFiatPrices![record.fiatCurrency.symbol]!);

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
                                    ),
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
                                  onAddRecord: (buyPrice, amount) {
                                    viewModel.addBuyRecord(buyPrice, amount);
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
