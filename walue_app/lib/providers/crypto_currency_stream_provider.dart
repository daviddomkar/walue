import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stream_transform/stream_transform.dart';

import '../models/crypto_currency.dart';
import '../providers.dart';
import '../repositories/crypto_repository.dart';

final cryptoCurrencyStreamProvider = StreamProvider.autoDispose.family<CryptoCurrency?, String>((ref, id) {
  final cryptoRepository = ref.watch(cryptoRepositoryProvider);

  final fiatCurrency = ref.watch(fiatCurrencyStreamProvider);

  return fiatCurrency == null
      ? Stream.value(null)
      : Stream.periodic(const Duration(minutes: 1))
          .asyncMap(
            (_) => cryptoRepository.getCryptoCurrency(id, fiatCurrency),
          )
          .startWithStream(
            Stream.fromFuture(cryptoRepository.getCryptoCurrency(id, fiatCurrency)),
          )
          .handleError((Object e, StackTrace s) {
          FirebaseCrashlytics.instance.recordError(
            e,
            s,
            reason: 'Crypto currency stream provider error',
          );

          throw e;
        });
});
