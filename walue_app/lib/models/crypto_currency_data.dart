import 'buy_record.dart';

class CryptoCurrencyData {
  final int? amountOfRecords;
  final double? averageAmountInFiatCurrencyWhenBought;
  final double? totalAmount;

  final List<BuyRecord> buyRecords;

  CryptoCurrencyData({this.amountOfRecords, this.averageAmountInFiatCurrencyWhenBought, this.totalAmount, required this.buyRecords});
}
