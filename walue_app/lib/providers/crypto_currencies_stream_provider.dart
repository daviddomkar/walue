import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crypto_currency.dart';
import '../providers.dart';
import '../repositories/crypto_repository.dart';

final cryptoCurrenciesStreamProvider =
    StreamProvider.autoDispose<List<CryptoCurrency>>((ref) {
  final _firestore = FirebaseFirestore.instance;

  final cryptoRepository = ref.watch(cryptoRepositoryProvider);
  final user = ref.watch(userStreamProvider);

  return _firestore
      .collection('system')
      .doc('crypto')
      .snapshots()
      .asyncMap((snapshot) async {
    if (snapshot.exists) {
      final currencyIds = snapshot.data()!['currencies'] as List<dynamic>;

      final cryptoCurrencies = await cryptoRepository.getCryptoCurrencies(
          currencyIds.map((e) => e as String).toList(),
          user.data!.value!.fiatCurrency!,
          cache: true);

      return cryptoCurrencies;
    }

    throw 'Crypto currency data are not available!';
  });
});
