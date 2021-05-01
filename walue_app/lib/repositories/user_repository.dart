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
  Future<void> addCryptoCurrencyToFavourites(CryptoCurrency currency);
  Future<void> deleteCryptoCurrencyFromFavourites(CryptoCurrency currency);
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
  Future<void> addCryptoCurrencyToFavourites(CryptoCurrency currency) async {
    await _firestore.runTransaction((transaction) async {
      final uuid = read(userStreamProvider).data?.value?.id;
      final userDocumentReference = _firestore.collection('users').doc(uuid);

      final userDocument = await transaction.get(userDocumentReference);

      final userDocumentData = userDocument.data()!;

      if (userDocumentData.containsKey('favourite_currency_ids')) {
        transaction.update(userDocumentReference, {
          'favourite_currency_ids': FieldValue.arrayUnion([currency.id]),
        });
      } else {
        transaction.update(userDocumentReference, {
          'favourite_currency_ids': [currency.id],
        });
      }
    });
  }

  @override
  Future<void> deleteCryptoCurrencyFromFavourites(CryptoCurrency currency) async {
    await _firestore.runTransaction((transaction) async {
      final uuid = read(userStreamProvider).data?.value?.id;
      final userDocumentReference = _firestore.collection('users').doc(uuid);

      final userDocument = await transaction.get(userDocumentReference);

      final userDocumentData = userDocument.data()!;

      final favouriteCurrencyIds = userDocumentData['favourite_currency_ids'] as List<dynamic>;

      favouriteCurrencyIds.remove(currency.id);

      if (favouriteCurrencyIds.isEmpty) {
        transaction.update(userDocumentReference, {
          'favourite_currency_ids': FieldValue.delete(),
        });
      } else {
        transaction.update(userDocumentReference, {
          'favourite_currency_ids': FieldValue.arrayRemove([currency.id]),
        });
      }
    });
  }

  @override
  Future<void> addCryptoCurrencyBuyRecord(CryptoCurrency currency, double buyPrice, double amount) async {
    await _firestore.runTransaction((transaction) async {
      final uuid = read(userStreamProvider).data?.value?.id;
      final fiatCurrency = read(userStreamProvider).data?.value?.fiatCurrency;
      final symbol = fiatCurrency?.symbol;

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
              'average_amount_in_fiat_currency_when_bought': buyPrice * amount,
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
          final symbolAverageAmountInFiatCurrencyWhenBought = (data['buy_records_data_by_fiat'][symbol]['average_amount_in_fiat_currency_when_bought'] as num).toDouble();
          final symbolTotalAmount = (data['buy_records_data_by_fiat'][symbol]['total_amount'] as num).toDouble();
          final symbolAmountOfRecords = (data['buy_records_data_by_fiat'][symbol]['amount_of_records'] as num).toInt();

          transaction.update(currencyDocumentReference, {
            'total_amount': (Decimal.parse(totalAmount.toString()) + Decimal.parse(amount.toString())).toDouble(),
            'amount_of_records': amountOfRecords + 1,
            'buy_records_data_by_fiat.$symbol.average_amount_in_fiat_currency_when_bought': (symbolAmountOfRecords * symbolAverageAmountInFiatCurrencyWhenBought + buyPrice * amount) / (symbolAmountOfRecords + 1),
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
                  'average_amount_in_fiat_currency_when_bought': buyPrice * amount,
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
        'fiat_currency': {
          'name': fiatCurrency?.name,
          'symbol': symbol,
        },
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
      final symbol = currencyRecordDocumentData['fiat_currency']['symbol'] as String;

      final newBuyPrice = buyPrice ?? oldBuyPrice;
      final newAmount = amount ?? oldAmount;

      final oldAmountInFiatCurrencyWhenBought = oldBuyPrice * oldAmount;
      final newAmountInFiatCurrencyWhenBought = newBuyPrice * newAmount;

      final totalAmount = (currencyDocumentData['total_amount'] as num).toDouble();

      final symbolAverageAmountInFiatCurrencyWhenBought = (currencyDocumentData['buy_records_data_by_fiat'][symbol]['average_amount_in_fiat_currency_when_bought'] as num).toDouble();
      final symbolTotalAmount = (currencyDocumentData['buy_records_data_by_fiat'][symbol]['total_amount'] as num).toDouble();
      final symbolAmountOfRecords = (currencyDocumentData['buy_records_data_by_fiat'][symbol]['amount_of_records'] as num).toInt();

      final newAverageAmountInFiatCurrencyWhenBought = (symbolAmountOfRecords * symbolAverageAmountInFiatCurrencyWhenBought - oldAmountInFiatCurrencyWhenBought + newAmountInFiatCurrencyWhenBought) / symbolAmountOfRecords;

      transaction.update(currencyDocumentReference, {
        'total_amount': (Decimal.parse(totalAmount.toString()) + (Decimal.parse(newAmount.toString()) - Decimal.parse(oldAmount.toString()))).toDouble(),
        'buy_records_data_by_fiat.$symbol.average_amount_in_fiat_currency_when_bought': newAverageAmountInFiatCurrencyWhenBought,
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
      final symbol = currencyRecordDocumentData['fiat_currency']['symbol'] as String;

      final symbolAverageAmountInFiatCurrencyWhenBought = (currencyDocumentData['buy_records_data_by_fiat'][symbol]['average_amount_in_fiat_currency_when_bought'] as num).toDouble();
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
          'buy_records_data_by_fiat.$symbol.average_amount_in_fiat_currency_when_bought': (symbolAmountOfRecords * symbolAverageAmountInFiatCurrencyWhenBought - amountInFiatCurrencyWhenBought) / (symbolAmountOfRecords - 1),
          'buy_records_data_by_fiat.$symbol.total_amount': (Decimal.parse(symbolTotalAmount.toString()) - Decimal.parse(amount.toString())).toDouble(),
          'buy_records_data_by_fiat.$symbol.amount_of_records': symbolAmountOfRecords - 1,
        });
      }

      transaction.delete(currencyRecordDocumentReference);
    });
  }
}
