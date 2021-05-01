import 'package:intl/intl.dart';

import 'currency.dart';

class CryptoCurrency extends Currency {
  final String id;
  final String imageUrl;

  final double fiatPrice;

  final Map<String, double>? additionalFiatPrices;

  CryptoCurrency({
    required this.id,
    required String symbol,
    required String name,
    required this.imageUrl,
    required this.fiatPrice,
    this.additionalFiatPrices,
  }) : super(symbol: symbol, name: name);

  String? calculateFormattedFiatPrice(String? fiatSymbol) {
    if (fiatSymbol == null) return null;

    final currencyFormatter = fiatPrice >= 100000 || fiatPrice <= -100000 ? NumberFormat.compactSimpleCurrency(locale: 'en', name: fiatSymbol.toUpperCase()) : NumberFormat.simpleCurrency(locale: 'en', name: fiatSymbol.toUpperCase());

    return currencyFormatter.format(fiatPrice);
  }
}
