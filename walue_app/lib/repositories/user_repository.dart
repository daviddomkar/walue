import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/currency.dart';
import '../providers.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) => FirebaseUserRepository(ref.read));

abstract class UserRepository {
  Future<void> chooseFiatCurrency(Currency currency);
  Future<void> changeFiatCurrency(Currency currency);
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
}
