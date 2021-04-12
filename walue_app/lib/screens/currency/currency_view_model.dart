import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/buy_record.dart';
import '../../models/crypto_currency.dart';
import '../../repositories/user_repository.dart';

class CurrencyViewModel extends ChangeNotifier {
  final UserRepository userRepository;

  final AsyncValue<CryptoCurrency?> currency;
  final AsyncValue<List<BuyRecord>> buyRecords;

  CurrencyViewModel({required this.userRepository, required this.currency, required this.buyRecords});

  void addBuyRecord(BuyRecord record) {
    userRepository.addCryptoCurrencyBuyRecord(currency.data!.value!, record.buyPrice, record.amount);
  }
}
