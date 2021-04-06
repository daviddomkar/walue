import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/crypto_currency.dart';
import '../../providers/user_stream_provider.dart';
import '../../repositories/crypto_repository.dart';

class CurrencyScreen extends ConsumerWidget {
  final String id;

  const CurrencyScreen({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final cryptoRepository = watch(cryptoRepositoryProvider);
    final user = watch(userStreamProvider);

    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: cryptoRepository.getCryptoCurrency(id, user.data!.value!.fiatCurrency!),
          builder: (context, AsyncSnapshot<CryptoCurrency> snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.name);
            } else {
              return Text(id);
            }
          },
        ),
      ),
    );
  }
}
