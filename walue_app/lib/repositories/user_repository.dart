import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crypto_currency.dart';
import '../models/currency.dart';
import '../providers.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) => FirebaseUserRepository(ref.read));

abstract class UserRepository {
  Future<void> chooseFiatCurrency(Currency currency);
  Future<void> changeFiatCurrency(Currency currency);
  Future<void> addCryptoCurrencyBuyRecord(CryptoCurrency currency, double buyPrice, double amount);
  Future<void> editCryptoCurrencyBuyRecord(CryptoCurrency currency, String id, double? buyPrice, double? amount);
  Future<void> deleteCryptoCurrencyBuyRecord(CryptoCurrency currency, String id);
}

class FirebaseUserRepository extends UserRepository {
  final _firestore = FirebaseFirestore.instance;

  final Reader read;

  FirebaseUserRepository(this.read);

  @override
  Future<void> chooseFiatCurrency(Currency currency) async {
    await _firestore.collection('users').doc(read(userStreamProvider).data?.value?.id).set({
      'fiat_currency': {
        'symbol': currency.symbol,
        'name': currency.name,
      },
    });
  }

  @override
  Future<void> changeFiatCurrency(Currency currency) async {
    await _firestore.collection('users').doc(read(userStreamProvider).data?.value?.id).update({
      'fiat_currency': {
        'symbol': currency.symbol,
        'name': currency.name,
      },
    });
  }

  @override
  Future<void> addCryptoCurrencyBuyRecord(CryptoCurrency currency, double buyPrice, double amount) async {
    // TODO: Change this to transaction

    await _firestore.collection('users').doc(read(userStreamProvider).data?.value?.id).collection('portfolio').doc(currency.id).collection('buy_records').add({
      'buy_price': buyPrice,
      'amount': amount,
    });
  }

  @override
  Future<void> editCryptoCurrencyBuyRecord(CryptoCurrency currency, String id, double? buyPrice, double? amount) async {
    // TODO: Change this to transaction

    final data = <String, double>{};

    if (buyPrice != null) {
      data['buy_price'] = buyPrice;
    }

    if (amount != null) {
      data['amount'] = amount;
    }

    await _firestore.collection('users').doc(read(userStreamProvider).data?.value?.id).collection('portfolio').doc(currency.id).collection('buy_records').doc(id).update(data);
  }

  @override
  Future<void> deleteCryptoCurrencyBuyRecord(CryptoCurrency currency, String id) async {
    await _firestore.collection('users').doc(read(userStreamProvider).data?.value?.id).collection('portfolio').doc(currency.id).collection('buy_records').doc(id).delete();
  }
}
