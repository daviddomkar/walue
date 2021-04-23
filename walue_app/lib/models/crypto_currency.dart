import 'currency.dart';

class CryptoCurrency extends Currency {
  final String id;
  final String imageUrl;

  final double fiatPrice;

  final Map<String, double>? additionalFiatPrices;

  CryptoCurrency({
    required this.id,
    required String symbol,
    required String name,
    required this.imageUrl,
    required this.fiatPrice,
    this.additionalFiatPrices,
  }) : super(symbol: symbol, name: name);
}
