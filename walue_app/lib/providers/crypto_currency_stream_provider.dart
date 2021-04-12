import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walue_app/repositories/crypto_repository.dart';
import 'package:stream_transform/stream_transform.dart';

import '../models/crypto_currency.dart';
import '../providers.dart';

final cryptoCurrencyStreamProvider = StreamProvider.autoDispose.family<CryptoCurrency, String>((ref, id) {
  final cryptoRepository = ref.watch(cryptoRepositoryProvider);
  final user = ref.watch(userStreamProvider);

  return Stream.periodic(const Duration(minutes: 2))
      .asyncMap(
        (_) => cryptoRepository.getCryptoCurrency(id, user.data!.value!.fiatCurrency!),
      )
      .startWithStream(
        Stream.fromFuture(cryptoRepository.getCryptoCurrency(id, user.data!.value!.fiatCurrency!)),
      );
});
