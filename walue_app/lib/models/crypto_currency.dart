import 'currency.dart';

class CryptoCurrency extends Currency {
  final String id;
  final String imageUrl;

  CryptoCurrency({required this.id, required String symbol, required String name, required this.imageUrl}) : super(symbol: symbol, name: name);
}
