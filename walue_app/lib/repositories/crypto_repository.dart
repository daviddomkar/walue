import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiver/iterables.dart' as quiver;

import '../models/crypto_currency.dart';
import '../models/currency.dart';

final cryptoRepositoryProvider =
    Provider<CryptoRepository>((ref) => throw UnimplementedError());

abstract class CryptoRepository {
  Future<CryptoCurrency> getCryptoCurrency(String id, Currency versusCurrency);
  Future<List<CryptoCurrency>> getCryptoCurrencies(
      List<String> ids, Currency versusCurrency,
      {bool cache = false});
}

class CoinGeckoCryptoRepository extends CryptoRepository {
  final Dio _dio;

  final CacheStore cacheStore;

  late CacheOptions _options;

  CoinGeckoCryptoRepository({required this.cacheStore})
      : _dio = Dio(BaseOptions(baseUrl: 'https://api.coingecko.com/api/v3')) {
    _options = CacheOptions(
      store: cacheStore,
      policy: CachePolicy.forceCache,
      maxStale: const Duration(minutes: 1),
    );

    _dio.interceptors.add(
      DioCacheInterceptor(
        options: _options,
      ),
    );
  }

  @override
  Future<List<CryptoCurrency>> getCryptoCurrencies(
      List<String> ids, Currency versusCurrency,
      {bool cache = false}) async {
    final partitionedIds = quiver.partition(ids, 100).toList();

    final requests = partitionedIds.asMap().entries.map(
          (entry) => _dio.get<List<dynamic>>(
            '/coins/markets',
            queryParameters: {
              'vs_currency': versusCurrency.symbol,
              'order': 'market_cap_desc',
              'ids': entry.value.join(','),
            },
            options: cache
                ? _options
                    .copyWith(maxStale: const Duration(days: 7))
                    .toOptions()
                : _options.toOptions(),
          ),
        );

    final responses = await Future.wait(requests);

    final currencies =
        quiver.concat(responses.map((response) => response.data!));

    return currencies.map((currency) {
      return CryptoCurrency(
        id: currency['id'] as String,
        name: currency['name'] as String,
        symbol: currency['symbol'] as String,
        imageUrl: currency['image'] as String,
        fiatPrice: (currency['current_price'] as num).toDouble(),
      );
    }).toList();
  }

  @override
  Future<CryptoCurrency> getCryptoCurrency(
      String id, Currency versusCurrency) async {
    final response =
        await _dio.get<Map<String, dynamic>>('/coins/$id', queryParameters: {
      'localization': false,
      'tickers': false,
      'market_data': true,
      'community_data': false,
      'developer_data': false,
      'sparkline': false,
    });

    final currency = response.data!;

    return CryptoCurrency(
      id: currency['id'] as String,
      name: currency['name'] as String,
      symbol: currency['symbol'] as String,
      imageUrl: currency['image']['large'] as String,
      fiatPrice: (currency['market_data']['current_price']
              [versusCurrency.symbol] as num)
          .toDouble(),
      additionalFiatPrices:
          (currency['market_data']['current_price'] as Map<String, dynamic>)
              .cast<String, double>(),
    );
  }
}
