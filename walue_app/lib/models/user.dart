import 'currency.dart';

class User {
  final String id;
  final String email;
  final String displayName;

  final Currency? fiatCurrency;

  User({required this.id, required this.email, required this.displayName, this.fiatCurrency});
}
