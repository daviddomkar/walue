import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// useProviderCached returns the freshest non-loading [AsyncValue] from a
/// [ProviderListenable].
T? useProviderNotNull<T>(ProviderListenable<T?> provider) {
  final value = useProvider(provider);
  final cache = useState<T?>(value);

  if (value != null) {
    cache.value = value;
    return value;
  }

  if (cache.value != null) {
    return cache.value;
  }

  cache.value = value;
  return value;
}
