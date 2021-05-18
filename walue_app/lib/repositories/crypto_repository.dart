import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiver/iterables.dart' as quiver;

import '../models/crypto_currency.dart';
import '../models/currency.dart';

final cryptoRepositoryProvider = Provider<CryptoRepository>((ref) => throw UnimplementedError());

abstract class CryptoRepository {
  Future<CryptoCurrency> getCryptoCurrency(String id, Currency versusCurrency);
  Future<List<CryptoCurrency>> getCryptoCurrencies(List<String> ids, Currency versusCurrency, {bool cache = false});
}

class CoinGeckoCryptoRepository extends CryptoRepository {
  final Dio _dio;

  final CacheStore cacheStore;

  late CacheOptions _options;

  CoinGeckoCryptoRepository({required this.cacheStore}) : _dio = Dio() {
    _options = CacheOptions(
      store: cacheStore,
      policy: CachePolicy.refreshForceCache,
      maxStale: const Duration(days: 365),
    );

    _dio.interceptors.add(
      DioCacheInterceptor(
        options: _options,
      ),
    );
  }

  @override
  Future<List<CryptoCurrency>> getCryptoCurrencies(List<String> ids, Currency versusCurrency, {bool cache = false}) async {
    final partitionedIds = quiver.partition(ids, 100).toList();

    final cacheEnabled = cache;

    final requests = partitionedIds.asMap().entries.map((entry) {
      return (() async {
        final options = RequestOptions(method: 'GET', baseUrl: 'https://api.coingecko.com/api/v3', path: '/coins/markets', queryParameters: {
          'vs_currency': versusCurrency.symbol,
          'order': 'market_cap_desc',
          'ids': entry.value.join(','),
        });

        Response<dynamic>? response;

        final cache = await cacheStore.get(_options.keyBuilder(options));

        if (cacheEnabled) {
          if (cache?.date != null && DateTime.now().difference(cache!.date!).inDays < 7) {
            response = cache.toResponse(options);
          }
        } else {
          if (cache?.date != null && DateTime.now().difference(cache!.date!).inSeconds < 30) {
            response = cache.toResponse(options);
          }
        }

        if (response == null) {
          try {
            response = await _dio.fetch(options);
          } catch (_) {
            response = cache?.toResponse(options);

            if (response == null) {
              rethrow;
            }
          }
        }

        return response;
      })();
    });

    final responses = await Future.wait(requests);

    final currencies = quiver.concat(responses.map((response) => response.data! as List<dynamic>));

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
  Future<CryptoCurrency> getCryptoCurrency(String id, Currency versusCurrency) async {
    final options = RequestOptions(method: 'GET', baseUrl: 'https://api.coingecko.com/api/v3', path: '/coins/$id', queryParameters: {
      'localization': false,
      'tickers': false,
      'market_data': true,
      'community_data': false,
      'developer_data': false,
      'sparkline': false,
    });

    Response<dynamic>? response;

    final cache = await cacheStore.get(_options.keyBuilder(options));

    if (cache?.date != null && DateTime.now().difference(cache!.date!).inSeconds < 30) {
      response = cache.toResponse(options);
    }

    if (response == null) {
      try {
        response = await _dio.fetch(options);
      } catch (_) {
        response = cache?.toResponse(options);

        if (response == null) {
          rethrow;
        }
      }
    }

    final currency = response.data;

    return CryptoCurrency(
      id: currency['id'] as String,
      name: currency['name'] as String,
      symbol: currency['symbol'] as String,
      imageUrl: currency['image']['large'] as String,
      fiatPrice: (currency['market_data']['current_price'][versusCurrency.symbol] as num).toDouble(),
      additionalFiatPrices: (currency['market_data']['current_price'] as Map<String, dynamic>).map((key, value) => MapEntry(key, (value as num).toDouble())).cast<String, double>(),
    );
  }
}
