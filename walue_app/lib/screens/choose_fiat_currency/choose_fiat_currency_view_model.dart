import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/currency.dart';
import '../../repositories/user_repository.dart';

class ChooseFiatCurrencyViewModel extends ChangeNotifier {
  final UserRepository userRepository;
  final AsyncValue<Map<String, Currency>?> fiatCurrencies;

  bool _loading;
  String? _error;

  Currency _currency;

  ChooseFiatCurrencyViewModel({required this.userRepository, required this.fiatCurrencies})
      : _loading = false,
        _currency = Currency(name: 'United States Dollar', symbol: 'usd');

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
