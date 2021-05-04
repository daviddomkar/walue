import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/buy_record.dart';
import '../../models/crypto_currency.dart';
import '../../models/currency.dart';
import '../../models/portfolio_record.dart';
import '../../models/user.dart';
import '../../repositories/user_repository.dart';

class CurrencyViewModel extends ChangeNotifier {
  final UserRepository userRepository;

  final AsyncValue<User?> user;
  final AsyncValue<CryptoCurrency?> currency;
  final AsyncValue<PortfolioRecord?> portfolioRecord;
  final AsyncValue<Map<String, Currency>?> _fiatCurrencies;

  CurrencyViewModel({
    required this.userRepository,
    required this.user,
    required this.currency,
    required this.portfolioRecord,
    required AsyncValue<Map<String, Currency>?> fiatCurrencies,
  }) : _fiatCurrencies = fiatCurrencies;

  void addToFavourites() {
    userRepository.addCryptoCurrencyToFavourites(currency.data!.value!);
  }

  void deleteFromFavourites() {
    userRepository.deleteCryptoCurrencyFromFavourites(currency.data!.value!);
  }

  void addBuyRecord(double buyPrice, double amount, Currency fiatCurrency) {
    userRepository.addCryptoCurrencyBuyRecord(
      currency.data!.value!,
      buyPrice,
      amount,
      fiatCurrency,
    );
  }

  void editBuyRecord(String id, double? buyPrice, double? amount) {
    userRepository.editCryptoCurrencyBuyRecord(
      currency.data!.value!,
      id,
      buyPrice,
      amount,
    );
  }

  void deleteBuyRecord(String id) {
    userRepository.deleteCryptoCurrencyBuyRecord(
      currency.data!.value!,
      id,
    );
  }

  bool get loading => currency is AsyncLoading || portfolioRecord is AsyncLoading || user is AsyncLoading || fiatCurrencies is AsyncLoading;

  List<String>? get favouriteCurrencyIds => user.data?.value?.favouriteCurrencyIds;

  Currency? get fiatCurrency => user.data?.value?.fiatCurrency;
  Map<String, Currency>? get fiatCurrencies => _fiatCurrencies.data?.value;

  String? get currencyImageUrl => currency.data?.value?.imageUrl;
  String? get currencyName => currency.data?.value?.name;
  String? get currencySymbol => currency.data?.value?.symbol.toUpperCase();

  String? get totalFiatAmount => portfolioRecord.data?.value?.computeTotalFiatAmount(currency.data?.value?.fiatPrice, user.data?.value?.fiatCurrency?.symbol);

  String? get totalAmount => currency.data?.value?.symbol != null ? portfolioRecord.data?.value?.computeTotalAmount(currency.data?.value?.symbol) : null;

  String? get increasePercentage => portfolioRecord.data?.value?.computeIncreasePercentage(currency.data?.value?.fiatPrice);

  List<BuyRecord>? get buyRecords => portfolioRecord.data?.value?.buyRecords;
}
