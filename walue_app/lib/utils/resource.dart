enum ResourceState {
  empty,
  loading,
  finished,
}

class Resource<T, E> {
  final ResourceState state;

  final T? data;
  final E? error;

  const Resource._(this.state, this.data, this.error);

  const Resource.empty() : this._(ResourceState.empty, null, null);
  const Resource.loading() : this._(ResourceState.loading, null, null);
  const Resource.withData(T data) : this._(ResourceState.finished, data, null);
  const Resource.withError(E error) : this._(ResourceState.finished, null, error);

  bool get hasError => state == ResourceState.finished && error != null;
  bool get hasData => state == ResourceState.finished && data != null;
}
