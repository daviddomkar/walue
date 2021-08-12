import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'currency.dart';

class BuyRecord {
  final String id;
  final double buyPrice;
  final double amount;
  final Currency fiatCurrency;

  BuyRecord({required this.id, required this.buyPrice, required this.amount, required this.fiatCurrency});

  double calculateProfit(double currentPrice) => (currentPrice * amount) - (buyPrice * amount);

  String calculateformattedProfit(double currentPrice, [double simpleFormatBreakpoint = 100000]) {
    final profit = calculateProfit(currentPrice);

    final currencyFormatter = profit >= simpleFormatBreakpoint || profit <= -simpleFormatBreakpoint
        ? NumberFormat.compactSimpleCurrency(locale: 'en', name: fiatCurrency.symbol.toUpperCase())
        : NumberFormat.simpleCurrency(locale: 'en', name: fiatCurrency.symbol.toUpperCase());

    if (profit > 0) {
      return '+${currencyFormatter.format(profit)}';
    }

    return currencyFormatter.format(profit);
  }

  String calucalteFormattedBuyPrice([double simpleFormatBreakpoint = 100000]) {
    final currencyFormatter = buyPrice >= simpleFormatBreakpoint || buyPrice <= -simpleFormatBreakpoint
        ? NumberFormat.compactSimpleCurrency(locale: 'en', name: fiatCurrency.symbol.toUpperCase())
        : NumberFormat.simpleCurrency(locale: 'en', name: fiatCurrency.symbol.toUpperCase());

    return currencyFormatter.format(buyPrice);
  }

  String calculateFormattedAmount([double simpleFormatBreakpoint = 100000]) {
    var amountText = Decimal.parse(amount.toString()).toString();

    if (amountText.endsWith('.0')) {
      amountText = '${amountText}0';
    }

    if (!amountText.contains('.')) {
      amountText = '$amountText.00';
    }

    if (amount > simpleFormatBreakpoint || amount < -simpleFormatBreakpoint) {
      return NumberFormat.compactSimpleCurrency(locale: 'en', name: '').format(amount);
    }

    final currencyFormatter = NumberFormat.simpleCurrency(locale: 'en', name: '');

    return '${currencyFormatter.format(amount).split('.')[0]}.${amountText.split('.')[1]}';
  }
}
