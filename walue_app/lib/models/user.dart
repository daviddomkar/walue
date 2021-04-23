import 'currency.dart';

class User {
  final String id;
  final String email;
  final String displayName;

  final Currency? fiatCurrency;

  final List<String>? favouriteCurrencyIds;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    this.fiatCurrency,
    this.favouriteCurrencyIds,
  });
}
