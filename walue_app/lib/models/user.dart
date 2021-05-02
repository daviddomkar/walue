import 'currency.dart';

class User {
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;

  final Currency? fiatCurrency;

  final List<String>? favouriteCurrencyIds;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    this.fiatCurrency,
    this.favouriteCurrencyIds,
  });
}
