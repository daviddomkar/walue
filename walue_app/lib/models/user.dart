import 'currency.dart';

class User {
  final String email;
  final String displayName;

  final Currency? fiatCurrency;

  User({required this.email, required this.displayName, this.fiatCurrency});
}
