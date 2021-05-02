import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/currency.dart';
import '../../models/user.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  final AsyncValue<User?> user;
  final AsyncValue<Map<String, Currency>?> _fiatCurrencies;

  SettingsViewModel({
    required this.authRepository,
    required this.userRepository,
    required this.user,
    required AsyncValue<Map<String, Currency>?> fiatCurrencies,
  }) : _fiatCurrencies = fiatCurrencies;

  void signOut() {
    authRepository.signOut();
  }

  void deleteAccount() {}

  bool get loading => user is AsyncLoading || user is AsyncError || _fiatCurrencies is AsyncLoading || _fiatCurrencies is AsyncError || user.data?.value == null;

  String? get photoUrl => user.data?.value?.photoUrl;
  String? get displayName => user.data?.value?.displayName;
  String? get email => user.data?.value?.email;

  Currency? get fiatCurrency => user.data?.value?.fiatCurrency;
  Map<String, Currency>? get fiatCurrencies => _fiatCurrencies.data?.value;
}
