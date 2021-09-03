import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
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

  String? calculateFormattedFiatPrice(BuildContext context, String? fiatSymbol) {
    if (fiatSymbol == null) return null;

    var fiatPriceText = Decimal.parse(fiatPrice.toString()).toString();

    if (fiatPriceText.endsWith('.0')) {
      fiatPriceText = '${fiatPriceText}0';
    }

    if (!fiatPriceText.contains('.')) {
      fiatPriceText = '$fiatPriceText.00';
    }

    final decimalDigits = fiatPriceText.split('.')[1].length;

    final currencyFormatter = fiatPrice >= 100000 || fiatPrice <= -100000
        ? NumberFormat.compactSimpleCurrency(locale: context.locale.languageCode, name: fiatSymbol.toUpperCase())
        : NumberFormat.simpleCurrency(name: fiatSymbol.toUpperCase(), decimalDigits: decimalDigits);

    return currencyFormatter.format(fiatPrice);
  }
}
