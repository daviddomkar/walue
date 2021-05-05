import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/currency.dart';

final fiatRepositoryProvider = Provider<FiatRepository>((ref) => throw UnimplementedError());

abstract class FiatRepository {
  Future<double> getExchangeRate(Currency from, Currency to);
  Future<double> exchange(Currency from, Currency to, double amount);
}

class ExchangeRateHostFiatRepository extends FiatRepository {
  final Dio _dio;

  final CacheStore cacheStore;

  late CacheOptions _options;

  ExchangeRateHostFiatRepository({required this.cacheStore}) : _dio = Dio() {
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
  Future<double> getExchangeRate(Currency from, Currency to) async {
    final options = RequestOptions(method: 'GET', baseUrl: 'https://api.exchangerate.host', path: '/convert', queryParameters: {
      'from': from.symbol.toUpperCase(),
      'to': to.symbol.toUpperCase(),
    });

    Response<dynamic>? response;

    final cache = await cacheStore.get(_options.keyBuilder(options));

    if (cache?.date != null && DateTime.now().difference(cache!.date!).inHours < 4) {
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

    final data = response.data as Map<String, dynamic>;

    return (data['result'] as num).toDouble();
  }

  @override
  Future<double> exchange(Currency from, Currency to, double amount) async {
    final exchangeRate = await getExchangeRate(from, to);

    return exchangeRate * amount;
  }
}
