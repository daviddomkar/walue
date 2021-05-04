import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/currency.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';

class ChooseFiatCurrencyViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  final AsyncValue<Map<String, Currency>?> fiatCurrencies;

  bool _loading;
  String? _error;

  Currency _currency;

  ChooseFiatCurrencyViewModel({required this.authRepository, required this.userRepository, required this.fiatCurrencies})
      : _loading = false,
        _currency = Currency(name: 'United States Dollar', symbol: 'usd');

  void signOut() {
    authRepository.signOut();
  }

  Future<void> chooseFiatCurrency() async {
    _loading = true;
    notifyListeners();

    try {
      await userRepository.chooseFiatCurrency(_currency);
    } catch (error) {
      _error = 'An error occured';
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }

  set currency(Currency currency) {
    _currency = currency;
    notifyListeners();
  }

  Currency get currency => _currency;

  bool get loading => _loading;

  String? get error => _error;
}
