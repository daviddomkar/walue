import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_transform/stream_transform.dart';

import '../models/buy_record.dart';
import '../models/currency.dart';
import '../models/portfolio_record.dart';
import '../providers.dart';
import '../repositories/fiat_repository.dart';

final portfolioRecordStreamProvider = StreamProvider.autoDispose.family<PortfolioRecord?, String>((ref, id) {
  final _firestore = FirebaseFirestore.instance;

  final fiatCurrenciesAsyncValue = ref.watch(fiatCurrenciesStreamProvider);
  final fiatRepository = ref.watch(fiatRepositoryProvider);

  final uuid = ref.watch(uuidStreamProvider);
  final fiatCurrency = ref.watch(fiatCurrencyStreamProvider);
  final symbol = fiatCurrency?.symbol;

  final fiatCurrencies = fiatCurrenciesAsyncValue.data?.value;

  return uuid == null || fiatCurrency == null || fiatCurrencies == null
      ? Stream.value(null)
      : _firestore.collection('users').doc(uuid).collection('portfolio').doc(id).snapshots().combineLatest<List<BuyRecord>, PortfolioRecord>(
          _firestore.collection('users').doc(uuid).collection('portfolio').doc(id).collection('buy_records').orderBy('timestamp').snapshots().map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();

              return BuyRecord(
                id: doc.id,
                buyPrice: data['buy_price'] as double,
                amount: data['amount'] as double,
                fiatCurrency: fiatCurrencies[data['fiat_currency_symbol']! as String] ?? Currency(symbol: data['fiat_currency_symbol']! as String, name: data['fiat_currency_symbol']! as String),
              );
            }).toList();
          }), (snapshot, buyRecords) async {
          if (snapshot.exists) {
            final data = snapshot.data()!;

            final buyRecordsDataByFiat = data['buy_records_data_by_fiat'] as Map<String, dynamic>;

            final buyRecordsDataByFiatEntries = buyRecordsDataByFiat.entries.toList();

            final amountFutures = <Future<double>>[];

            for (var i = 0; i < buyRecordsDataByFiatEntries.length; i++) {
              final entry = buyRecordsDataByFiatEntries[i];

              final entryData = entry.value as Map<String, dynamic>;

              final amount = (entryData['total_amount_in_fiat_currency_when_bought'] as num).toDouble();

              if (entry.key == symbol) {
                amountFutures.add((() async => amount)());
              } else {
                amountFutures.add(fiatRepository.exchange(fiatCurrencies[entry.key]!, fiatCurrency, amount));
              }
            }

            final amounts = await Future.wait(amountFutures);

            final totalAmountInFiatCurrencyWhenBought = amounts.reduce((a, b) => a + b);

            return PortfolioRecord(
              id: id,
              amountOfRecords: (data['amount_of_records'] as num).toInt(),
              totalAmountInFiatCurrencyWhenBought: totalAmountInFiatCurrencyWhenBought,
              totalAmount: (data['total_amount'] as num).toDouble(),
              buyRecords: buyRecords,
            );
          }

          return PortfolioRecord(id: id, buyRecords: buyRecords);
        }).handleError((Object e, StackTrace s) {
          FirebaseCrashlytics.instance.recordError(
            e,
            s,
            reason: 'Portfolio record stream provider error',
          );

          throw e;
        });
});
