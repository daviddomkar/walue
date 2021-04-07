import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/crypto_currency.dart';

class CurrencyViewModel extends ChangeNotifier {
  final AsyncValue<CryptoCurrency?> currency;

  CurrencyViewModel({required this.currency});
}
