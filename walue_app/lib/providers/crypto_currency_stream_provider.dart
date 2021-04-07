import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walue_app/repositories/crypto_repository.dart';
import 'package:stream_transform/stream_transform.dart';

import '../models/crypto_currency.dart';
import '../providers.dart';

final cryptoCurrencyStreamProvider = StreamProvider.autoDispose.family<CryptoCurrency, String>((ref, id) {
  final cryptoRepository = ref.watch(cryptoRepositoryProvider);
  final user = ref.watch(userStreamProvider);

  return Stream.value(null)
      .asyncMap((event) => cryptoRepository.getCryptoCurrency(id, user.data!.value!.fiatCurrency!))
      .merge(Stream.periodic(const Duration(minutes: 1)).asyncMap((_) => cryptoRepository.getCryptoCurrency(id, user.data!.value!.fiatCurrency!)));
});
