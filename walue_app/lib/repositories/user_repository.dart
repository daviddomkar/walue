import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crypto_currency.dart';
import '../models/currency.dart';
import '../providers.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) => FirebaseUserRepository(ref.read));

abstract class UserRepository {
  Future<void> chooseFiatCurrency(Currency currency);
  Future<void> changeFiatCurrency(Currency currency);
  Future<void> completeGuide();
  Future<void> addCryptoCurrencyToFavourites(String id);
  Future<void> deleteCryptoCurrencyFromFavourites(String id);
  Future<void> addCryptoCurrencyBuyRecord(CryptoCurrency currency, double buyPrice, double amount, Currency fiatCurrency);
  Future<void> editCryptoCurrencyBuyRecord(CryptoCurrency currency, String id, double? buyPrice, double? amount);
  Future<void> deleteCryptoCurrencyBuyRecord(CryptoCurrency currency, String id);
}

class FirebaseUserRepository extends UserRepository {
  final _firestore = FirebaseFirestore.instance;

  final Reader read;

  FirebaseUserRepository(this.read);

  @override
  Future<void> chooseFiatCurrency(Currency currency) async {
    await _firestore.runTransaction((transaction) async {
      final userDocumentReference = _firestore.collection('users').doc(read(userStreamProvider).data?.value?.id);
      final userDocument = await transaction.get(userDocumentReference);

      if (!userDocument.exists) {
        transaction.set(userDocumentReference, {
          'fiat_currency_symbol': currency.symbol,
        });

        return;
      }

      final userDocumentData = userDocument.data()!;

      if (!userDocumentData.containsKey('fiat_currency_symbol')) {
        transaction.update(userDocumentReference, {
          'fiat_currency_symbol': currency.symbol,
        });
      } else {
        throw 'Fiat currency already choosen';
      }
    });
  }

  @override
  Future<void> changeFiatCurrency(Currency currency) async {
    await _firestore.collection('users').doc(read(userStreamProvider).data?.value?.id).update({
      'fiat_currency_symbol': currency.symbol,
    });
  }

  @override
  Future<void> completeGuide() async {
    await _firestore.collection('users').doc(read(userStreamProvider).data?.value?.id).update({
      'has_completed_guide': true,
    });
  }

  @override
  Future<void> addCryptoCurrencyToFavourites(String id) async {
    await _firestore.runTransaction((transaction) async {
      final uuid = read(userStreamProvider).data?.value?.id;
      final userDocumentReference = _firestore.collection('users').doc(uuid);

      final userDocument = await transaction.get(userDocumentReference);

      final userDocumentData = userDocument.data()!;

      if (userDocumentData.containsKey('favourite_currency_ids')) {
        transaction.update(userDocumentReference, {
          'favourite_currency_ids': FieldValue.arrayUnion([id]),
        });
      } else {
        transaction.update(userDocumentReference, {
          'favourite_currency_ids': [id],
        });
      }
    });
  }

  @override
  Future<void> deleteCryptoCurrencyFromFavourites(String id) async {
    await _firestore.runTransaction((transaction) async {
      final uuid = read(userStreamProvider).data?.value?.id;
      final userDocumentReference = _firestore.collection('users').doc(uuid);

      final userDocument = await transaction.get(userDocumentReference);

      final userDocumentData = userDocument.data()!;

      final favouriteCurrencyIds = userDocumentData['favourite_currency_ids'] as List<dynamic>;

      favouriteCurrencyIds.remove(id);

      if (favouriteCurrencyIds.isEmpty) {
        transaction.update(userDocumentReference, {
          'favourite_currency_ids': FieldValue.delete(),
        });
      } else {
        transaction.update(userDocumentReference, {
          'favourite_currency_ids': FieldValue.arrayRemove([id]),
        });
      }
    });
  }

  @override
  Future<void> addCryptoCurrencyBuyRecord(CryptoCurrency currency, double buyPrice, double amount, Currency fiatCurrency) async {
    await _firestore.runTransaction((transaction) async {
      final uuid = read(userStreamProvider).data?.value?.id;
      final symbol = fiatCurrency.symbol;

      final currencyDocumentReference = _firestore.collection('users').doc(uuid).collection('portfolio').doc(currency.id);
      final currencyRecordDocumentReference = _firestore.collection('users').doc(uuid).collection('portfolio').doc(currency.id).collection('buy_records').doc();

      final currencyDocument = await transaction.get(currencyDocumentReference);

      if (!currencyDocument.exists) {
        transaction.set(currencyDocumentReference, {
          'total_amount': amount,
          'amount_of_records': 1,
          'buy_records_data_by_fiat': {
            // ignore: unnecessary_string_interpolations
            '$symbol': {
              'total_amount_in_fiat_currency_when_bought': buyPrice * amount,
              'total_amount': amount,
              'amount_of_records': 1,
            },
          }
        });
      } else {
        final data = currencyDocument.data()!;

        final totalAmount = (data['total_amount'] as num).toDouble();
        final amountOfRecords = (data['amount_of_records'] as num).toInt();

        if ((data['buy_records_data_by_fiat'] as Map<String, dynamic>).containsKey(symbol)) {
          final symbolTotalAmountInFiatCurrencyWhenBought = (data['buy_records_data_by_fiat'][symbol]['total_amount_in_fiat_currency_when_bought'] as num).toDouble();
          final symbolTotalAmount = (data['buy_records_data_by_fiat'][symbol]['total_amount'] as num).toDouble();
          final symbolAmountOfRecords = (data['buy_records_data_by_fiat'][symbol]['amount_of_records'] as num).toInt();

          transaction.update(currencyDocumentReference, {
            'total_amount': (Decimal.parse(totalAmount.toString()) + Decimal.parse(amount.toString())).toDouble(),
            'amount_of_records': amountOfRecords + 1,
            'buy_records_data_by_fiat.$symbol.total_amount_in_fiat_currency_when_bought': (Decimal.parse(symbolTotalAmountInFiatCurrencyWhenBought.toString()) + Decimal.parse((buyPrice * amount).toString())).toDouble(),
            'buy_records_data_by_fiat.$symbol.total_amount': (Decimal.parse(symbolTotalAmount.toString()) + Decimal.parse(amount.toString())).toDouble(),
            'buy_records_data_by_fiat.$symbol.amount_of_records': symbolAmountOfRecords + 1,
          });
        } else {
          transaction.set(
            currencyDocumentReference,
            {
              'total_amount': (Decimal.parse(totalAmount.toString()) + Decimal.parse(amount.toString())).toDouble(),
              'amount_of_records': amountOfRecords + 1,
              'buy_records_data_by_fiat': {
                // ignore: unnecessary_string_interpolations
                '$symbol': {
                  'total_amount_in_fiat_currency_when_bought': buyPrice * amount,
                  'total_amount': amount,
                  'amount_of_records': 1,
                }
              },
            },
            SetOptions(merge: true),
          );
        }
      }

      transaction.set(currencyRecordDocumentReference, {
        'buy_price': buyPrice,
        'amount': amount,
        'timestamp': FieldValue.serverTimestamp(),
        'fiat_currency_symbol': symbol,
      });
    });
  }

  @override
  Future<void> editCryptoCurrencyBuyRecord(CryptoCurrency currency, String id, double? buyPrice, double? amount) async {
    await _firestore.runTransaction((transaction) async {
      final uuid = read(userStreamProvider).data?.value?.id;

      final currencyDocumentReference = _firestore.collection('users').doc(uuid).collection('portfolio').doc(currency.id);
      final currencyRecordDocumentReference = _firestore.collection('users').doc(uuid).collection('portfolio').doc(currency.id).collection('buy_records').doc(id);

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

      final oldBuyPrice = (currencyRecordDocumentData['buy_price'] as num).toDouble();
      final oldAmount = (currencyRecordDocumentData['amount'] as num).toDouble();
      final symbol = currencyRecordDocumentData['fiat_currency_symbol'] as String;

      final newBuyPrice = buyPrice ?? oldBuyPrice;
      final newAmount = amount ?? oldAmount;

      final oldTotalInFiatCurrencyWhenBought = oldBuyPrice * oldAmount;
      final newTotaltInFiatCurrencyWhenBought = newBuyPrice * newAmount;

      final totalAmount = (currencyDocumentData['total_amount'] as num).toDouble();

      final symbolTotalAmountInFiatCurrencyWhenBought = (currencyDocumentData['buy_records_data_by_fiat'][symbol]['total_amount_in_fiat_currency_when_bought'] as num).toDouble();
      final symbolTotalAmount = (currencyDocumentData['buy_records_data_by_fiat'][symbol]['total_amount'] as num).toDouble();

      final newTotalAmountInFiatCurrencyWhenBought =
          Decimal.parse(symbolTotalAmountInFiatCurrencyWhenBought.toString()) - Decimal.parse(oldTotalInFiatCurrencyWhenBought.toString()) + Decimal.parse(newTotaltInFiatCurrencyWhenBought.toString());

      transaction.update(currencyDocumentReference, {
        'total_amount': (Decimal.parse(totalAmount.toString()) + (Decimal.parse(newAmount.toString()) - Decimal.parse(oldAmount.toString()))).toDouble(),
        'buy_records_data_by_fiat.$symbol.total_amount_in_fiat_currency_when_bought': newTotalAmountInFiatCurrencyWhenBought.toDouble(),
        'buy_records_data_by_fiat.$symbol.total_amount': (Decimal.parse(symbolTotalAmount.toString()) + (Decimal.parse(newAmount.toString()) - Decimal.parse(oldAmount.toString()))).toDouble(),
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
      final uuid = read(userStreamProvider).data?.value?.id;

      final currencyDocumentReference = _firestore.collection('users').doc(uuid).collection('portfolio').doc(currency.id);
      final currencyRecordDocumentReference = _firestore.collection('users').doc(uuid).collection('portfolio').doc(currency.id).collection('buy_records').doc(id);

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

      final totalAmount = (currencyDocumentData['total_amount'] as num).toDouble();
      final amountOfRecords = (currencyDocumentData['amount_of_records'] as num).toInt();
      final symbol = currencyRecordDocumentData['fiat_currency_symbol'] as String;

      final symbolTotalAmountInFiatCurrencyWhenBought = (currencyDocumentData['buy_records_data_by_fiat'][symbol]['total_amount_in_fiat_currency_when_bought'] as num).toDouble();
      final symbolTotalAmount = (currencyDocumentData['buy_records_data_by_fiat'][symbol]['total_amount'] as num).toDouble();
      final symbolAmountOfRecords = (currencyDocumentData['buy_records_data_by_fiat'][symbol]['amount_of_records'] as num).toInt();

      final buyPrice = (currencyRecordDocumentData['buy_price'] as num).toDouble();
      final amount = (currencyRecordDocumentData['amount'] as num).toDouble();

      if (amountOfRecords == 1) {
        transaction.delete(currencyDocumentReference);
      } else if (symbolAmountOfRecords == 1) {
        transaction.update(currencyDocumentReference, {
          'total_amount': (Decimal.parse(totalAmount.toString()) - Decimal.parse(amount.toString())).toDouble(),
          'amount_of_records': amountOfRecords - 1,
          'buy_records_data_by_fiat.$symbol': FieldValue.delete(),
        });
      } else {
        final amountInFiatCurrencyWhenBought = buyPrice * amount;

        transaction.update(currencyDocumentReference, {
          'total_amount': (Decimal.parse(totalAmount.toString()) - Decimal.parse(amount.toString())).toDouble(),
          'amount_of_records': amountOfRecords - 1,
          'buy_records_data_by_fiat.$symbol.total_amount_in_fiat_currency_when_bought': (Decimal.parse(symbolTotalAmountInFiatCurrencyWhenBought.toString()) - Decimal.parse(amountInFiatCurrencyWhenBought.toString())).toDouble(),
          'buy_records_data_by_fiat.$symbol.total_amount': (Decimal.parse(symbolTotalAmount.toString()) - Decimal.parse(amount.toString())).toDouble(),
          'buy_records_data_by_fiat.$symbol.amount_of_records': symbolAmountOfRecords - 1,
        });
      }

      transaction.delete(currencyRecordDocumentReference);
    });
  }
}
