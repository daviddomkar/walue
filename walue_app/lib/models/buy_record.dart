import 'currency.dart';

class BuyRecord {
  final String id;
  final double buyPrice;
  final double amount;
  final Currency currency;

  BuyRecord({
    required this.id,
    required this.buyPrice,
    required this.amount,
    required this.currency,
  });
}
