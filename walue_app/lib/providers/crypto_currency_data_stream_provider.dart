import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_transform/stream_transform.dart';

import '../models/buy_record.dart';
import '../models/currency.dart';
import '../models/portfolio_record.dart';
import '../providers.dart';

final cryptoCurrencyDataStreamProvider =
    StreamProvider.autoDispose.family<PortfolioRecord, String>((ref, id) {
  final _firestore = FirebaseFirestore.instance;

  final user = ref.watch(userStreamProvider);

  final uuid = user.data?.value?.id;
  final symbol = user.data?.value?.fiatCurrency?.symbol;

  return _firestore
      .collection('users')
      .doc(user.data?.value?.id)
      .collection('portfolio')
      .doc(id)
      .snapshots()
      .combineLatest<List<BuyRecord>, PortfolioRecord>(
          _firestore
              .collection('users')
              .doc(uuid)
              .collection('portfolio')
              .doc(id)
              .collection('buy_records')
              .orderBy('timestamp')
              .snapshots()
              .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();

              return BuyRecord(
                id: doc.id,
                buyPrice: data['buy_price'] as double,
                amount: data['amount'] as double,
                currency: Currency(
                  symbol: data['currency']['symbol'] as String,
                  name: data['currency']['name'] as String,
                ),
              );
            }).toList();
          }), (snapshot, buyRecords) {
    if (snapshot.exists) {
      final data =
          snapshot.data()!['buy_records_data_by_fiat'] as Map<String, dynamic>;

      data.entries.map((e) => null);

      if (data.containsKey(symbol)) {
        return PortfolioRecord(
          amountOfRecords: (data[symbol]['amount_of_records'] as num).toInt(),
          averageAmountInFiatCurrencyWhenBought: (data[symbol]
                  ['average_amount_in_fiat_currency_when_bought'] as num)
              .toDouble(),
          totalAmount: (data[symbol]['total_amount'] as num).toDouble(),
          buyRecords: buyRecords,
        );
      }
    }

    return PortfolioRecord(buyRecords: buyRecords);
  });
});
