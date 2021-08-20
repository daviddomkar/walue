import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'currency.dart';

class BuyRecord {
  final String id;
  final double buyPrice;
  final double amount;
  final Currency fiatCurrency;

  BuyRecord({required this.id, required this.buyPrice, required this.amount, required this.fiatCurrency});

  double calculateProfit(double currentPrice) => (currentPrice * amount) - (buyPrice * amount);

  String calculateformattedProfit(BuildContext context, double currentPrice, [double simpleFormatBreakpoint = 100000]) {
    final profit = calculateProfit(currentPrice);

    final currencyFormatter = profit >= simpleFormatBreakpoint || profit <= -simpleFormatBreakpoint
        ? NumberFormat.compactSimpleCurrency(locale: context.locale.languageCode, name: fiatCurrency.symbol.toUpperCase())
        : NumberFormat.simpleCurrency(locale: context.locale.languageCode, name: fiatCurrency.symbol.toUpperCase());

    if (profit > 0) {
      return '+${currencyFormatter.format(profit)}';
    }

    return currencyFormatter.format(profit);
  }

  String calucalteFormattedBuyPrice(BuildContext context, [double simpleFormatBreakpoint = 100000]) {
    final currencyFormatter = buyPrice >= simpleFormatBreakpoint || buyPrice <= -simpleFormatBreakpoint
        ? NumberFormat.compactSimpleCurrency(locale: context.locale.languageCode, name: fiatCurrency.symbol.toUpperCase())
        : NumberFormat.simpleCurrency(locale: context.locale.languageCode, name: fiatCurrency.symbol.toUpperCase());

    return currencyFormatter.format(buyPrice);
  }

  String calculateFormattedAmount(BuildContext context, [double simpleFormatBreakpoint = 100000]) {
    var amountText = Decimal.parse(amount.toString()).toString();

    if (amountText.endsWith('.0')) {
      amountText = '${amountText}0';
    }

    if (!amountText.contains('.')) {
      amountText = '$amountText.00';
    }

    if (amount > simpleFormatBreakpoint || amount < -simpleFormatBreakpoint) {
      return NumberFormat.compactSimpleCurrency(locale: context.locale.languageCode, name: '').format(amount);
    }

    final decimalDigits = amountText.split('.')[1].length;

    final currencyFormatter = NumberFormat.simpleCurrency(locale: context.locale.languageCode, name: '', decimalDigits: decimalDigits);

    return currencyFormatter.format(amount);
  }
}
