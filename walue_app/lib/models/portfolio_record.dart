import 'package:decimal/decimal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'buy_record.dart';

class PortfolioRecord {
  final String id;
  final int? amountOfRecords;
  final double? totalAmountInFiatCurrencyWhenBought;
  final double? totalAmount;

  final List<BuyRecord>? buyRecords;

  PortfolioRecord({
    required this.id,
    this.amountOfRecords,
    this.totalAmountInFiatCurrencyWhenBought,
    this.totalAmount,
    this.buyRecords,
  });

  double? computeTotalFiatAmountValue(double? fiatPrice) {
    if (fiatPrice != null) {
      return totalAmount! * fiatPrice;
    }

    return null;
  }

  String? computeTotalFiatAmount(BuildContext context, double? fiatPrice, String? fiatSymbol, [double simpleFormatBreakpoint = 100000]) {
    if (totalAmount != null && fiatPrice != null && fiatSymbol != null) {
      final totalFiatAmount = totalAmount! * fiatPrice;

      final currencyFormatter = totalFiatAmount >= simpleFormatBreakpoint || totalFiatAmount <= -simpleFormatBreakpoint
          ? NumberFormat.compactSimpleCurrency(locale: context.locale.languageCode, name: fiatSymbol.toUpperCase())
          : NumberFormat.simpleCurrency(locale: context.locale.languageCode, name: fiatSymbol.toUpperCase());

      return currencyFormatter.format(totalFiatAmount);
    }

    return null;
  }

  String? computeTotalAmount(BuildContext context, [String? symbol, double simpleFormatBreakpoint = 100000]) {
    if (totalAmount != null) {
      var totalAmountText = Decimal.parse(totalAmount!.toString()).toString();

      if (totalAmountText.endsWith('.0')) {
        totalAmountText = '${totalAmountText}0';
      }

      if (!totalAmountText.contains('.')) {
        totalAmountText = '$totalAmountText.00';
      }

      if (totalAmount! >= simpleFormatBreakpoint || totalAmount! <= -simpleFormatBreakpoint) {
        return NumberFormat.compactSimpleCurrency(locale: context.locale.languageCode, name: symbol != null ? symbol.toUpperCase() : '').format(totalAmount);
      }

      final decimalDigits = totalAmountText.split('.')[1].length;

      final currencyFormatter = NumberFormat.simpleCurrency(locale: context.locale.languageCode, name: symbol != null ? symbol.toUpperCase() : '', decimalDigits: decimalDigits);

      return currencyFormatter.format(totalAmount);
    }

    return null;
  }

  String? computeIncreasePercentage(BuildContext context, double? fiatPrice) {
    if (totalAmount != null && totalAmountInFiatCurrencyWhenBought != null && fiatPrice != null) {
      final totalFiatAmount = totalAmount! * fiatPrice;

      final increasePercentage = totalFiatAmount / totalAmountInFiatCurrencyWhenBought! - 1.0;

      return (increasePercentage > 0 ? '+' : '') + NumberFormat.decimalPercentPattern(locale: context.locale.languageCode, decimalDigits: 2).format(increasePercentage);
    }

    return null;
  }
}
