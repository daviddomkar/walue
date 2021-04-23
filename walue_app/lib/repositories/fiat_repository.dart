import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/currency.dart';

final fiatRepositoryProvider =
    Provider<FiatRepository>((ref) => throw UnimplementedError());

abstract class FiatRepository {
  Future<double> getExchangeRate(Currency from, Currency to);
  Future<double> exchange(Currency from, Currency to, double amount);
}

class ExchangeRateHostFiatRepository extends FiatRepository {
  final Dio _dio;

  final CacheStore cacheStore;

  late CacheOptions _options;

  ExchangeRateHostFiatRepository({required this.cacheStore})
      : _dio = Dio(BaseOptions(baseUrl: 'https://api.exchangerate.host')) {
    _options = CacheOptions(
      store: cacheStore,
      policy: CachePolicy.forceCache,
      maxStale: const Duration(hours: 4),
    );

    _dio.interceptors.add(
      DioCacheInterceptor(
        options: _options,
      ),
    );
  }

  @override
  Future<double> getExchangeRate(Currency from, Currency to) async {
    final response = await _dio.get('/convert', queryParameters: {
      'from': from.symbol.toUpperCase(),
      'to': to.symbol.toUpperCase(),
    });

    final data = response.data! as Map<String, dynamic>;

    return (data['result'] as num).toDouble();
  }

  @override
  Future<double> exchange(Currency from, Currency to, double amount) async {
    final exchangeRate = await getExchangeRate(from, to);

    return double.parse((exchangeRate * amount).toStringAsFixed(2));
  }
}
