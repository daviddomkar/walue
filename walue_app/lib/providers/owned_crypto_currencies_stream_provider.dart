import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:quiver/iterables.dart' as quiver;

import '../models/crypto_currency.dart';
import '../providers.dart';
import '../repositories/crypto_repository.dart';

final ownedCryptoCurrenciesStreamProvider = StreamProvider.autoDispose<Map<String, CryptoCurrency>>((ref) {
  final cryptoRepository = ref.watch(cryptoRepositoryProvider);
  final portfolioRecords = ref.watch(portfolioRecordsStreamProvider);

  final fiatCurrency = ref.watch(fiatCurrencyStreamProvider)!;

  final favouriteCurrencyIds = ref.watch(favouriteCurrencyIdsStreamProvider)!;
  final cryptoCurrencyIds = portfolioRecords.data?.value.map((record) => record.id) ?? [];

  final currencyIds = quiver.concat([favouriteCurrencyIds, cryptoCurrencyIds]).toSet().toList();

  return Stream.periodic(const Duration(minutes: 1))
      .asyncMap(
        (_) => cryptoRepository.getCryptoCurrencies(currencyIds, fiatCurrency),
      )
      .startWithStream(
        Stream.fromFuture(cryptoRepository.getCryptoCurrencies(currencyIds, fiatCurrency)),
      )
      .map((currencies) => {for (final currency in currencies) currency.id: currency});
});
