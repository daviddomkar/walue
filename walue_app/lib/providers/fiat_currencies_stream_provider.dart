import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/currency.dart';

final fiatCurrenciesStreamProvider = StreamProvider.autoDispose<Map<String, Currency>>((ref) {
  final _firestore = FirebaseFirestore.instance;

  return _firestore.collection('system').doc('fiat').snapshots().map((snapshot) {
    if (snapshot.exists) {
      final currencies = snapshot.data()!['currencies'] as Map<String, dynamic>;

      return currencies.entries.fold<Map<String, Currency>>({}, (previousValue, element) {
        previousValue[element.key] = Currency(name: element.value as String, symbol: element.key);
        return previousValue;
      });
    }

    throw 'Fiat currency data are not available!';
  });
});
