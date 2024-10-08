import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// useProviderCached returns the freshest non-loading [AsyncValue] from a
/// [ProviderListenable].
AsyncValue<T> useProviderCached<T>(ProviderListenable<AsyncValue<T>> provider) {
  final value = useProvider(provider);
  final cache = useState<AsyncValue<T>>(value);

  if (value is! AsyncLoading && value.data?.value != null) {
    cache.value = value;
    return value;
  }

  if (cache.value is! AsyncLoading && cache.value.data?.value != null) {
    return cache.value;
  }

  cache.value = value;
  return value;
}
