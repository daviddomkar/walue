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

  double? computeTotalFiatAmountValue(double? fiatPrice) {
    if (fiatPrice != null) {
      return totalAmount! * fiatPrice;
    }

    return null;
  }

  String? computeTotalFiatAmount(double? fiatPrice, String? fiatSymbol, [double simpleFormatBreakpoint = 100000]) {
    if (totalAmount != null && fiatPrice != null && fiatSymbol != null) {
      final totalFiatAmount = totalAmount! * fiatPrice;

      final currencyFormatter = totalFiatAmount >= simpleFormatBreakpoint || totalFiatAmount <= -simpleFormatBreakpoint
          ? NumberFormat.compactSimpleCurrency(locale: 'en', name: fiatSymbol.toUpperCase())
          : NumberFormat.simpleCurrency(locale: 'en', name: fiatSymbol.toUpperCase());

      return currencyFormatter.format(totalFiatAmount);
    }

    return null;
  }

  // ignore: avoid_positional_boolean_parameters
  String? computeTotalAmount([String? symbol, double simpleFormatBreakpoint = 100000, bool cutLastZeros = false]) {
    if (totalAmount != null) {
      var totalAmountText = totalAmount!.toString().split('.')[1].length > 8 ? totalAmount!.toStringAsFixed(8) : '${totalAmount!}';

      if (totalAmountText.endsWith('.0')) {
        totalAmountText = '${totalAmountText}0';
      }

      if (totalAmount! >= simpleFormatBreakpoint || totalAmount! <= -simpleFormatBreakpoint) {
        totalAmountText = NumberFormat.compactSimpleCurrency(locale: 'en', name: '').format(totalAmount);

        return symbol == null ? totalAmountText : '${symbol.toUpperCase()} $totalAmountText';
      }

      final currencyFormatter = NumberFormat.simpleCurrency(locale: 'en', name: '');
      totalAmountText = '${currencyFormatter.format(totalAmount).split('.')[0]}.${totalAmountText.split('.')[1]}';

      totalAmountText = symbol == null ? totalAmountText : '${symbol.toUpperCase()} $totalAmountText';

      if (cutLastZeros && totalAmountText.endsWith('.00')) {
        totalAmountText = totalAmountText.substring(0, totalAmountText.length - 3);
      }

      return totalAmountText;
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
