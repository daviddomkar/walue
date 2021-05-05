import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/portfolio_record.dart';
import '../providers.dart';
import '../repositories/fiat_repository.dart';

final portfolioRecordsStreamProvider = StreamProvider.autoDispose<List<PortfolioRecord>?>((ref) {
  final _firestore = FirebaseFirestore.instance;

  final fiatRepository = ref.watch(fiatRepositoryProvider);

  final fiatCurrenciesAsyncValue = ref.watch(fiatCurrenciesStreamProvider);

  final uuid = ref.watch(uuidStreamProvider);
  final fiatCurrency = ref.watch(fiatCurrencyStreamProvider);

  final symbol = fiatCurrency?.symbol;

  final fiatCurrencies = fiatCurrenciesAsyncValue.data?.value;

  return uuid == null || fiatCurrency == null || fiatCurrencies == null
      ? Stream.value(null)
      : _firestore.collection('users').doc(uuid).collection('portfolio').snapshots().asyncMap((snapshot) {
          return Future.wait(snapshot.docs.map((document) async {
            final data = document.data();

            final buyRecordsDataByFiat = data['buy_records_data_by_fiat'] as Map<String, dynamic>;

            final buyRecordsDataByFiatEntries = buyRecordsDataByFiat.entries.toList();

            final amountFutures = <Future<double>>[];

            for (var i = 0; i < buyRecordsDataByFiatEntries.length; i++) {
              final entry = buyRecordsDataByFiatEntries[i];

              final entryData = entry.value as Map<String, dynamic>;

              final amount = (entryData['average_amount_in_fiat_currency_when_bought'] as num).toDouble();

              if (entry.key == symbol) {
                amountFutures.add((() async => amount)());
              } else {
                amountFutures.add(fiatRepository.exchange(fiatCurrencies[entry.key]!, fiatCurrency, amount));
              }
            }

            final amounts = await Future.wait(amountFutures);

            final averageAmountInFiatCurrencyWhenBought = amounts.reduce((a, b) => a + b);

            return PortfolioRecord(
              id: document.id,
              amountOfRecords: (data['amount_of_records'] as num).toInt(),
              averageAmountInFiatCurrencyWhenBought: averageAmountInFiatCurrencyWhenBought,
              totalAmount: (data['total_amount'] as num).toDouble(),
            );
          }));
        }).handleError((Object e, StackTrace s) {
          FirebaseCrashlytics.instance.recordError(
            e,
            s,
            reason: 'Portfolio records stream provider error',
          );

          throw e;
        });
  ;
});
