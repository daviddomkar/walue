import 'package:intl/intl.dart';
import 'currency.dart';

class BuyRecord {
  final String id;
  final double buyPrice;
  final double amount;
  final Currency fiatCurrency;

  BuyRecord({required this.id, required this.buyPrice, required this.amount, required this.fiatCurrency});

  double calculateProfit(double currentPrice) => (currentPrice * amount) - (buyPrice * amount);

  String calculateformattedProfit(double currentPrice) {
    final profit = calculateProfit(currentPrice);

    final currencyFormatter =
        profit >= 100000 || profit <= -100000 ? NumberFormat.compactSimpleCurrency(locale: 'en', name: fiatCurrency.symbol.toUpperCase()) : NumberFormat.simpleCurrency(locale: 'en', name: fiatCurrency.symbol.toUpperCase());

    if (profit > 0) {
      return '+${currencyFormatter.format(profit)}';
    }

    return currencyFormatter.format(profit);
  }

  String get formattedBuyPrice {
    final currencyFormatter =
        buyPrice >= 100000 || buyPrice <= -100000 ? NumberFormat.compactSimpleCurrency(locale: 'en', name: fiatCurrency.symbol.toUpperCase()) : NumberFormat.simpleCurrency(locale: 'en', name: fiatCurrency.symbol.toUpperCase());

    return currencyFormatter.format(buyPrice);
  }

  String get formattedAmount {
    var amountText = amount.toString().split('.')[1].length > 8 ? amount.toStringAsFixed(8) : amount.toString();

    if (amountText.endsWith('.0')) {
      amountText = amountText.substring(0, amountText.length - 2);
    }

    if (amount > 999 || amount < -999) {
      final currencyFormatter = amount >= 100000 || amount <= -100000 ? NumberFormat.compactSimpleCurrency(locale: 'en', name: '') : NumberFormat.simpleCurrency(locale: 'en', name: '');
      amountText = currencyFormatter.format(amount);
    }

    return amountText;
  }
}
