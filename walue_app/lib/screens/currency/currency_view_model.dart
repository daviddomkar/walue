import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/buy_record.dart';
import '../../models/crypto_currency.dart';
import '../../models/portfolio_record.dart';
import '../../models/user.dart';
import '../../repositories/user_repository.dart';

class CurrencyViewModel extends ChangeNotifier {
  static final _percentageFormatter = NumberFormat.decimalPercentPattern(locale: 'en', decimalDigits: 2);

  final UserRepository userRepository;

  final AsyncValue<User?> user;
  final AsyncValue<CryptoCurrency> currency;
  final AsyncValue<PortfolioRecord> currencyData;

  CurrencyViewModel({
    required this.userRepository,
    required this.user,
    required this.currency,
    required this.currencyData,
  });

  void addBuyRecord(double buyPrice, double amount) {
    userRepository.addCryptoCurrencyBuyRecord(
      currency.data!.value,
      buyPrice,
      amount,
    );
  }

  void editBuyRecord(String id, double? buyPrice, double? amount) {
    userRepository.editCryptoCurrencyBuyRecord(
      currency.data!.value,
      id,
      buyPrice,
      amount,
    );
  }

  void deleteBuyRecord(String id) {
    userRepository.deleteCryptoCurrencyBuyRecord(
      currency.data!.value,
      id,
    );
  }

  bool get loading => currency is AsyncLoading || currencyData is AsyncLoading || user is AsyncLoading;

  String? get currencyImageUrl => currency.data?.value.imageUrl;
  String? get currencyName => currency.data?.value.name;
  String? get currencySymbol => currency.data?.value.symbol.toUpperCase();

  String? get totalFiatAmount {
    final fiatSymbol = user.data?.value?.fiatCurrency?.symbol;
    final totalAmount = currencyData.data?.value.totalAmount;

    if (totalAmount != null && currency.data != null && fiatSymbol != null) {
      final totalAmount = currencyData.data!.value.totalAmount!;
      final fiatPrice = currency.data!.value.fiatPrice;

      final totalFiatAmount = totalAmount * fiatPrice;

      final currencyFormatter = NumberFormat.simpleCurrency(locale: 'en', name: fiatSymbol.toUpperCase());

      return currencyFormatter.format(totalFiatAmount);
    }

    return null;
  }

  String? get totalAmount {
    if (currencyData.data?.value.totalAmount != null && currency.data != null) {
      return '${currency.data!.value.symbol.toUpperCase()} ${currencyData.data!.value.totalAmount!}';
    }

    return null;
  }

  String? get increasePercentage {
    if (currencyData.data?.value.totalAmount != null && currency.data != null) {
      final averageAmountInFiatCurrencyWhenBought = currencyData.data!.value.averageAmountInFiatCurrencyWhenBought!;

      final totalAmount = currencyData.data!.value.totalAmount!;
      final fiatPrice = currency.data!.value.fiatPrice;

      final totalFiatAmount = totalAmount * fiatPrice;

      final increasePercentage = ((1.0 / averageAmountInFiatCurrencyWhenBought) * totalFiatAmount) - 1.0;

      var mark = '';

      if (increasePercentage > 0) {
        mark = '+';
      }

      return mark + _percentageFormatter.format(increasePercentage);
    }

    return null;
  }

  List<BuyRecord>? get buyRecords => currencyData.data?.value.buyRecords;
}
