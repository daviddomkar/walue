import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final adRepositoryProvider = Provider<AdRepository>((ref) => throw UnimplementedError());

abstract class AdRepository {
  Future<void> notifyNewBuyRecord();
  Future<void> notifyNewCryproCurrency();
  Future<void> notifyUserLoggedIn();
}

class AdmobAdRepository extends AdRepository {
  final SharedPreferences sharedPreferences;

  int _newBuyRecordCount;
  int _newCryptoCurrencyCount;
  DateTime _userLastLoggedIn;

  AdmobAdRepository({required this.sharedPreferences})
      : _newBuyRecordCount = sharedPreferences.containsKey('new_buy_record_count') ? sharedPreferences.getInt('new_buy_record_count')! : 0,
        _newCryptoCurrencyCount = sharedPreferences.containsKey('new_crypto_currency_count') ? sharedPreferences.getInt('new_crypto_currency_count')! : 0,
        _userLastLoggedIn = sharedPreferences.containsKey('user_last_logged_in') ? DateTime.fromMicrosecondsSinceEpoch(sharedPreferences.getInt('user_last_logged_in')!) : DateTime.now();

  @override
  Future<void> notifyNewBuyRecord() async {}

  @override
  Future<void> notifyNewCryproCurrency() async {}

  @override
  Future<void> notifyUserLoggedIn() async {}
}
