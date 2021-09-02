import 'currency.dart';

class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? fiatCurrencySymbol;

  final bool? hasCompletedGuide;

  final List<String> favouriteCurrencyIds;

  User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    this.fiatCurrencySymbol,
    this.hasCompletedGuide,
    this.favouriteCurrencyIds = const [],
  });
}
