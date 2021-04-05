import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiver/iterables.dart' as quiver;

import '../models/crypto_currency.dart';
import '../models/currency.dart';

final cryptoRepositoryProvider = Provider<CryptoRepository>((ref) => CoinGeckoCryptoRepository());

abstract class CryptoRepository {
  Future<CryptoCurrency> getCryptoCurrency(String id, Currency versusCurrency);
  Future<List<CryptoCurrency>> getCryptoCurrencies(List<String> ids, Currency versusCurrency);
}

class CoinGeckoCryptoRepository extends CryptoRepository {
  final Dio _dio;

  CoinGeckoCryptoRepository() : _dio = Dio(BaseOptions(baseUrl: 'https://api.coingecko.com/api/v3'));

  @override
  Future<List<CryptoCurrency>> getCryptoCurrencies(List<String> ids, Currency versusCurrency) async {
    final partitionedIds = quiver.partition(ids, 250).toList();

    final requests = partitionedIds.asMap().entries.map(
          (entry) => _dio.get<List<dynamic>>('/coins/markets', queryParameters: {
            'vs_currency': versusCurrency.symbol,
            'ids': entry.value.join(','),
            'per_page': 250,
            'page': entry.key + 1,
          }),
        );

    final responses = await Future.wait(requests);

    final currencies = quiver.concat(responses.map((response) => response.data!));

    return currencies.map((currency) {
      return CryptoCurrency(
        id: currency['id'] as String,
        name: currency['name'] as String,
        symbol: currency['symbol'] as String,
      );
    }).toList();
  }

  @override
  Future<CryptoCurrency> getCryptoCurrency(String id, Currency versusCurrency) async {
    final response = await _dio.get<List<dynamic>>('/coins/markets', queryParameters: {
      'vs_currency': versusCurrency.symbol,
      'ids': id,
    });

    final currency = response.data![0];

    return CryptoCurrency(
      id: currency['id'] as String,
      name: currency['name'] as String,
      symbol: currency['symbol'] as String,
    );
  }
}
