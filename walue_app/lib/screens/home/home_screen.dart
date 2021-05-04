import 'package:auto_size_text/auto_size_text.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../providers.dart';
import '../../repositories/user_repository.dart';
import '../../widgets/crypto_select_sheet.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/logo.dart';

import 'home_view_model.dart';

final homeViewModelProvider = ChangeNotifierProvider.autoDispose<HomeViewModel>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final user = ref.watch(userStreamProvider);
  final ownedCurrencies = ref.watch(ownedCryptoCurrenciesStreamProvider);
  final portfolioRecords = ref.watch(portfolioRecordsStreamProvider);

  return HomeViewModel(
    userRepository: userRepository,
    user: user,
    ownedCurrencies: ownedCurrencies,
    portfolioRecords: portfolioRecords,
  );
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final viewModel = watch(homeViewModelProvider);

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
                              SizedBox(
                                height: 128.0 + 16.0,
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    final itemCount = viewModel.favouritesLoading ? 1 : viewModel.favouriteCurrencyIds!.length + 1;

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
                                                  child: viewModel.favouritesLoading
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
                                                                ownedCurrencies: viewModel.ownedCurrencies!.values.toList(),
                                                                onCryptoCurrencySelected: (currency) {
                                                                  viewModel.addToFavourites(currency);
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
                                                  child: viewModel.ownedCurrencies == null || !viewModel.ownedCurrencies!.containsKey(viewModel.favouriteCurrencyIds![index])
                                                      ? Center(
                                                          child: CircularProgressIndicator(
                                                            valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                                                            strokeWidth: 2.0,
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () {
                                                            final id = viewModel.favouriteCurrencyIds![index];

                                                            context.beamToNamed('/currency/$id', popToNamed: '/', data: {
                                                              'currencyImageUrl': viewModel.ownedCurrencies?[id]?.imageUrl,
                                                              'currencyName': viewModel.ownedCurrencies?[id]?.name,
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
                                                                        image: DecorationImage(image: NetworkImage(viewModel.ownedCurrencies![viewModel.favouriteCurrencyIds![index]]!.imageUrl), fit: BoxFit.contain),
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
                                                                              viewModel.ownedCurrencies![viewModel.favouriteCurrencyIds![index]]!.name,
                                                                              style: Theme.of(context).textTheme.bodyText1,
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            viewModel.ownedCurrencies![viewModel.favouriteCurrencyIds![index]]!.symbol.toUpperCase(),
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
                                                                      viewModel.ownedCurrencies![viewModel.favouriteCurrencyIds![index]]!.calculateFormattedFiatPrice(viewModel.fiatCurrencySymbol)!,
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
                                  itemCount: viewModel.favouritesLoading ? 1 : viewModel.favouriteCurrencyIds!.length + 1,
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
                                        child: viewModel.portfolioRecordsLoading
                                            ? Center(
                                                child: CircularProgressIndicator(
                                                  valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                                                  strokeWidth: 2.0,
                                                ),
                                              )
                                            : viewModel.portfolioRecords!.isEmpty
                                                ? Center(
                                                    child: Text('No portfolio records found'),
                                                  )
                                                : Container(
                                                    constraints: const BoxConstraints.expand(),
                                                    child: Material(
                                                      color: Colors.white,
                                                      child: Column(
                                                        children: [
                                                          for (var i = 0; i < viewModel.portfolioRecords!.length; i++) ...[
                                                            if (viewModel.ownedCurrencies!.containsKey(viewModel.portfolioRecords![i].id))
                                                              InkWell(
                                                                onTap: () {
                                                                  final id = viewModel.portfolioRecords?[i].id;

                                                                  context.beamToNamed('/currency/${id!}', popToNamed: '/', data: {
                                                                    'currencyImageUrl': viewModel.ownedCurrencies?[id]?.imageUrl,
                                                                    'currencyName': viewModel.ownedCurrencies?[id]?.name,
                                                                    'totalFiatAmount': viewModel.portfolioRecords?[i].computeTotalFiatAmount(
                                                                      viewModel.ownedCurrencies?[id]?.fiatPrice,
                                                                      viewModel.fiatCurrencySymbol,
                                                                    ),
                                                                    'totalAmount': viewModel.portfolioRecords?[i].computeTotalAmount(),
                                                                    'increasePercentage': viewModel.portfolioRecords?[i].computeIncreasePercentage(
                                                                      viewModel.ownedCurrencies?[id]?.fiatPrice,
                                                                    ),
                                                                  });
                                                                },
                                                                child: Container(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                                  height: 64.0,
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        width: 32.0,
                                                                        height: 32.0,
                                                                        decoration: BoxDecoration(
                                                                          image: DecorationImage(image: NetworkImage(viewModel.ownedCurrencies![viewModel.portfolioRecords![i].id]!.imageUrl), fit: BoxFit.contain),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                                          child: Column(
                                                                            mainAxisSize: MainAxisSize.min,
                                                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                            children: [
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  LimitedBox(
                                                                                    maxWidth: 80.0,
                                                                                    child: Text(
                                                                                      viewModel.ownedCurrencies![viewModel.portfolioRecords![i].id]!.name,
                                                                                      style: Theme.of(context).textTheme.bodyText1,
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                  ),
                                                                                  LimitedBox(
                                                                                    maxWidth: 80.0,
                                                                                    child: Text(
                                                                                      viewModel.portfolioRecords![i].computeTotalFiatAmount(
                                                                                        viewModel.ownedCurrencies![viewModel.portfolioRecords![i].id]!.fiatPrice,
                                                                                        viewModel.fiatCurrencySymbol,
                                                                                      )!,
                                                                                      style: Theme.of(context).textTheme.bodyText1,
                                                                                      textAlign: TextAlign.right,
                                                                                      maxLines: 1,
                                                                                      overflow: TextOverflow.ellipsis,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Text(
                                                                                    viewModel.ownedCurrencies![viewModel.portfolioRecords![i].id]!.symbol.toUpperCase(),
                                                                                  ),
                                                                                  Text(
                                                                                    viewModel.portfolioRecords![i].computeTotalAmount()!,
                                                                                    textAlign: TextAlign.right,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      if (viewModel.ownedCurrencies!.containsKey(viewModel.portfolioRecords![i].id))
                                                                        SizedBox(
                                                                          width: 90.0,
                                                                          child: AutoSizeText(
                                                                            viewModel.portfolioRecords![i].computeIncreasePercentage(
                                                                              viewModel.ownedCurrencies![viewModel.portfolioRecords![i].id]!.fiatPrice,
                                                                            )!,
                                                                            maxLines: 1,
                                                                            style: Theme.of(context).textTheme.subtitle1!.copyWith(
                                                                              color: (() {
                                                                                final profitText = viewModel.portfolioRecords![i].computeIncreasePercentage(
                                                                                  viewModel.ownedCurrencies![viewModel.portfolioRecords![i].id]!.fiatPrice,
                                                                                )!;

                                                                                var color = const Color(0xFF222222);

                                                                                if (profitText.startsWith('+')) {
                                                                                  color = const Color(0xFF54D790);
                                                                                } else if (profitText.startsWith('-')) {
                                                                                  color = const Color(0xFFD90D00);
                                                                                }

                                                                                return color;
                                                                              })(),
                                                                            ),
                                                                            textAlign: TextAlign.right,
                                                                          ),
                                                                        )
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
                                  ownedCurrencies: viewModel.ownedCurrencies!.values.toList(),
                                  onCryptoCurrencySelected: (currency) {
                                    Navigator.of(context).pop(context);
                                    context.beamToNamed('/currency/${currency.id}', popToNamed: '/', data: {
                                      'currencyImageUrl': currency.imageUrl,
                                      'currencyName': currency.name,
                                    });
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              'Add new crypto',
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
