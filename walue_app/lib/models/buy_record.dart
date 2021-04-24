import 'package:intl/intl.dart';
import 'currency.dart';

class BuyRecord {
  final String id;
  final double buyPrice;
  final double amount;
  final Currency fiatCurrency;

  BuyRecord({required this.id, required this.buyPrice, required this.amount, required this.fiatCurrency});

  String calculateformattedProfit(double currentPrice) {
    final profit = (currentPrice * amount) - (buyPrice * amount);

    if (profit > 0) {
      return '+${NumberFormat.simpleCurrency(locale: 'en', name: fiatCurrency.symbol.toUpperCase()).format(profit)}';
    }

    return NumberFormat.simpleCurrency(locale: 'en', name: fiatCurrency.symbol.toUpperCase()).format(profit);
  }

  String get formattedBuyPrice {
    return NumberFormat.simpleCurrency(locale: 'en', name: fiatCurrency.symbol.toUpperCase()).format(buyPrice);
  }
}
