import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/portfolio_record.dart';
import '../providers.dart';
import '../repositories/fiat_repository.dart';

final portfolioRecordsStreamProvider = StreamProvider.autoDispose<List<PortfolioRecord>>((ref) {
  final _firestore = FirebaseFirestore.instance;

  final fiatRepository = ref.watch(fiatRepositoryProvider);

  final fiatCurrenciesAsyncValue = ref.watch(fiatCurrenciesStreamProvider);

  final userAsyncValue = ref.watch(userStreamProvider);

  final uuid = userAsyncValue.data?.value?.id;
  final fiatCurrency = userAsyncValue.data?.value?.fiatCurrency;

  final symbol = fiatCurrency?.symbol;

  final fiatCurrencies = fiatCurrenciesAsyncValue.data?.value;

  return _firestore.collection('users').doc(uuid).collection('portfolio').snapshots().asyncMap((snapshot) {
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
          amountFutures.add(fiatRepository.exchange(fiatCurrencies![entry.key]!, fiatCurrency!, amount));
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
  }).handleError((e, _) => {});
});
