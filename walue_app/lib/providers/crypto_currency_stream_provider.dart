import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_transform/stream_transform.dart';

import '../models/crypto_currency.dart';
import '../providers.dart';
import '../repositories/crypto_repository.dart';

final cryptoCurrencyStreamProvider = StreamProvider.autoDispose.family<CryptoCurrency?, String>((ref, id) {
  final cryptoRepository = ref.watch(cryptoRepositoryProvider);
  final user = ref.watch(userStreamProvider);

  final fiatCurrency = user.data?.value?.fiatCurrency;

  return fiatCurrency == null
      ? Stream.value(null)
      : Stream.periodic(const Duration(minutes: 1))
          .asyncMap(
            (_) => cryptoRepository.getCryptoCurrency(id, fiatCurrency),
          )
          .startWithStream(
            Stream.fromFuture(cryptoRepository.getCryptoCurrency(id, fiatCurrency)),
          );
});
