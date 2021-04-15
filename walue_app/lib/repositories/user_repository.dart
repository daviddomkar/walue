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
    await _firestore.runTransaction((transaction) async {
      final currencyDocumentReference = _firestore.collection('users').doc(read(userStreamProvider).data?.value?.id).collection('portfolio').doc(currency.id);

      final currencyDocument = await transaction.get(currencyDocumentReference);

      if (!currencyDocument.exists) {
        transaction.set(currencyDocumentReference, {
          'average_amount_in_fiat_currency_when_bought': buyPrice * amount,
          'total_amount': amount,
          'amount_of_records': 1,
        });
      } else {
        final data = currencyDocument.data()!;

        final averageAmountInFiatCurrencyWhenBought = data['average_amount_in_fiat_currency_when_bought'] as num;
        final totalAmount = data['total_amount'] as num;
        final amountOfRecords = data['amount_of_records'] as num;

        transaction.update(currencyDocumentReference, {
          'average_amount_in_fiat_currency_when_bought': (amountOfRecords * averageAmountInFiatCurrencyWhenBought + buyPrice * amount) / (amountOfRecords + 1),
          'total_amount': totalAmount + amount,
          'amount_of_records': amountOfRecords + 1,
        });
      }

      transaction.set(_firestore.collection('users').doc(read(userStreamProvider).data?.value?.id).collection('portfolio').doc(currency.id).collection('buy_records').doc(), {
        'buy_price': buyPrice,
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> editCryptoCurrencyBuyRecord(CryptoCurrency currency, String id, double? buyPrice, double? amount) async {
    await _firestore.runTransaction((transaction) async {
      final currencyDocumentReference = _firestore.collection('users').doc(read(userStreamProvider).data?.value?.id).collection('portfolio').doc(currency.id);
      final currencyRecordDocumentReference = _firestore.collection('users').doc(read(userStreamProvider).data?.value?.id).collection('portfolio').doc(currency.id).collection('buy_records').doc(id);

      final currencyDocument = await transaction.get(currencyDocumentReference);
      final currencyRecordDocument = await transaction.get(currencyRecordDocumentReference);

      if (!currencyDocument.exists) {
        throw 'Currency document does not exist!';
      }

      if (!currencyRecordDocument.exists) {
        throw 'Currency record document does not exist!';
      }

      final currencyDocumentData = currencyDocument.data()!;
      final currencyRecordDocumentData = currencyRecordDocument.data()!;

      final oldBuyPrice = currencyRecordDocumentData['buy_price'] as num;
      final oldAmount = currencyRecordDocumentData['amount'] as num;

      final newBuyPrice = buyPrice ?? oldBuyPrice;
      final newAmount = amount ?? oldAmount;

      final oldAmountInFiatCurrencyWhenBought = oldBuyPrice * oldAmount;
      final newAmountInFiatCurrencyWhenBought = newBuyPrice * newAmount;

      final averageAmountInFiatCurrencyWhenBought = currencyDocumentData['average_amount_in_fiat_currency_when_bought'] as num;
      final totalAmount = currencyDocumentData['total_amount'] as num;
      final amountOfRecords = currencyDocumentData['amount_of_records'] as num;

      transaction.update(currencyDocumentReference, {
        'average_amount_in_fiat_currency_when_bought': (amountOfRecords * averageAmountInFiatCurrencyWhenBought - oldAmountInFiatCurrencyWhenBought + newAmountInFiatCurrencyWhenBought) / amountOfRecords,
        'total_amount': totalAmount - oldAmount + newAmount,
      });

      transaction.update(currencyRecordDocumentReference, {
        'buy_price': newBuyPrice,
        'amount': newAmount,
      });
    });
  }

  @override
  Future<void> deleteCryptoCurrencyBuyRecord(CryptoCurrency currency, String id) async {
    await _firestore.runTransaction((transaction) async {
      final currencyDocumentReference = _firestore.collection('users').doc(read(userStreamProvider).data?.value?.id).collection('portfolio').doc(currency.id);
      final currencyRecordDocumentReference = _firestore.collection('users').doc(read(userStreamProvider).data?.value?.id).collection('portfolio').doc(currency.id).collection('buy_records').doc(id);

      final currencyDocument = await transaction.get(currencyDocumentReference);
      final currencyRecordDocument = await transaction.get(currencyRecordDocumentReference);

      if (!currencyDocument.exists) {
        throw 'Currency document does not exist!';
      }

      if (!currencyRecordDocument.exists) {
        throw 'Currency record document does not exist!';
      }

      final currencyDocumentData = currencyDocument.data()!;
      final currencyRecordDocumentData = currencyRecordDocument.data()!;

      final averageAmountInFiatCurrencyWhenBought = currencyDocumentData['average_amount_in_fiat_currency_when_bought'] as num;
      final totalAmount = currencyDocumentData['total_amount'] as num;
      final amountOfRecords = currencyDocumentData['amount_of_records'] as num;

      final buyPrice = currencyRecordDocumentData['buy_price'] as num;
      final amount = currencyRecordDocumentData['amount'] as num;

      if (amountOfRecords == 1) {
        transaction.delete(currencyDocumentReference);
      } else {
        final amountInFiatCurrencyWhenBought = buyPrice * amount;

        transaction.update(currencyDocumentReference, {
          'average_amount_in_fiat_currency_when_bought': (amountOfRecords * averageAmountInFiatCurrencyWhenBought - amountInFiatCurrencyWhenBought) / (amountOfRecords - 1),
          'total_amount': totalAmount - amount,
          'amount_of_records': amountOfRecords - 1,
        });
      }

      transaction.delete(currencyRecordDocumentReference);
    });
  }
}
