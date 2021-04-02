import 'currency.dart';

class CryptoCurrency extends Currency {
  final String id;

  CryptoCurrency({required this.id, required String symbol, required String name}) : super(symbol: symbol, name: name);
}
