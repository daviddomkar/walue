import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/crypto_currency.dart';
import '../../models/portfolio_record.dart';
import '../../models/user.dart';
import '../../repositories/user_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final UserRepository userRepository;

  final AsyncValue<User?> user;
  final AsyncValue<Map<String, CryptoCurrency>?> _ownedCurrencies;
  final AsyncValue<List<PortfolioRecord>?> _portfolioRecords;

  HomeViewModel({
    required this.userRepository,
    required this.user,
    required AsyncValue<Map<String, CryptoCurrency>?> ownedCurrencies,
    required AsyncValue<List<PortfolioRecord>?> portfolioRecords,
  })   : _ownedCurrencies = ownedCurrencies,
        _portfolioRecords = portfolioRecords;

  void addToFavourites(CryptoCurrency currency) {
    userRepository.addCryptoCurrencyToFavourites(currency);
  }

  bool get favouritesLoading => user is AsyncLoading || user is AsyncError || _ownedCurrencies is AsyncLoading || _ownedCurrencies is AsyncError || user.data?.value == null || _ownedCurrencies.data?.value == null;
  bool get portfolioRecordsLoading =>
      user is AsyncLoading ||
      user is AsyncError ||
      _portfolioRecords is AsyncLoading ||
      _portfolioRecords is AsyncError ||
      _ownedCurrencies is AsyncLoading ||
      _ownedCurrencies is AsyncError ||
      user.data?.value == null ||
      _ownedCurrencies.data?.value == null ||
      _portfolioRecords.data?.value == null;

  String? get fiatCurrencySymbol => user.data?.value?.fiatCurrency?.symbol;

  List<String>? get favouriteCurrencyIds => user.data?.value?.favouriteCurrencyIds;
  List<PortfolioRecord>? get portfolioRecords => _portfolioRecords.data?.value;

  Map<String, CryptoCurrency>? get ownedCurrencies => _ownedCurrencies.data?.value;
}
