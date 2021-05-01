import 'package:intl/intl.dart';

import 'buy_record.dart';

class PortfolioRecord {
  final String id;
  final int? amountOfRecords;
  final double? averageAmountInFiatCurrencyWhenBought;
  final double? totalAmount;

  final List<BuyRecord>? buyRecords;

  PortfolioRecord({
    required this.id,
    this.amountOfRecords,
    this.averageAmountInFiatCurrencyWhenBought,
    this.totalAmount,
    this.buyRecords,
  });

  String? computeTotalFiatAmount(double? fiatPrice, String? fiatSymbol) {
    if (totalAmount != null && fiatPrice != null && fiatSymbol != null) {
      final totalFiatAmount = totalAmount! * fiatPrice;

      final currencyFormatter =
          totalFiatAmount >= 100000 || totalFiatAmount <= -100000 ? NumberFormat.compactSimpleCurrency(locale: 'en', name: fiatSymbol.toUpperCase()) : NumberFormat.simpleCurrency(locale: 'en', name: fiatSymbol.toUpperCase());

      return currencyFormatter.format(totalFiatAmount);
    }

    return null;
  }

  String? computeTotalAmount([String? symbol]) {
    if (totalAmount != null) {
      var totalAmountText = totalAmount!.toString().split('.')[1].length > 8 ? totalAmount!.toStringAsFixed(8) : totalAmount!.toString();

      if (totalAmountText.endsWith('.0')) {
        totalAmountText = totalAmountText.substring(0, totalAmountText.length - 2);
      }

      if (totalAmount! > 999 || totalAmount! < -999) {
        final currencyFormatter = totalAmount! >= 100000 || totalAmount! <= -100000 ? NumberFormat.compactSimpleCurrency(locale: 'en', name: '') : NumberFormat.simpleCurrency(locale: 'en', name: '');
        totalAmountText = currencyFormatter.format(totalAmount);
      }

      return symbol == null ? totalAmountText : '${symbol.toUpperCase()} $totalAmountText';
    }

    return null;
  }

  String? computeIncreasePercentage(double? fiatPrice) {
    if (totalAmount != null && averageAmountInFiatCurrencyWhenBought != null && fiatPrice != null) {
      final totalFiatAmount = totalAmount! * fiatPrice;

      final increasePercentage = ((1.0 / averageAmountInFiatCurrencyWhenBought!) * totalFiatAmount) - 1.0;

      return (increasePercentage > 0 ? '+' : '') + NumberFormat.decimalPercentPattern(locale: 'en', decimalDigits: 2).format(increasePercentage);
    }

    return null;
  }
}
