import 'currency.dart';

class CryptoCurrency extends Currency {
  final String id;
  final String imageUrl;

  final double fiatPrice;

  CryptoCurrency({required this.id, required String symbol, required String name, required this.imageUrl, required this.fiatPrice}) : super(symbol: symbol, name: name);
}
