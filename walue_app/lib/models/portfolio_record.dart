import 'buy_record.dart';

class PortfolioRecord {
  final int? amountOfRecords;
  final double? averageAmountInFiatCurrencyWhenBought;
  final double? totalAmount;

  final List<BuyRecord> buyRecords;

  PortfolioRecord({
    this.amountOfRecords,
    this.averageAmountInFiatCurrencyWhenBought,
    this.totalAmount,
    required this.buyRecords,
  });
}
