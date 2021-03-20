enum ResourceState {
  empty,
  loading,
  finished,
}

class Resource<T extends Object, E extends Object> {
  final ResourceState state;

  final T? data;
  final E? error;

  const Resource._(this.state, this.data, this.error);

  const Resource.empty() : this._(ResourceState.empty, null, null);
  const Resource.loading() : this._(ResourceState.loading, null, null);
  const Resource.finishWithData(T data) : this._(ResourceState.finished, data, null);
  const Resource.finish() : this._(ResourceState.finished, null, null);
  const Resource.finishWithError(E error) : this._(ResourceState.finished, null, error);

  bool get isEmpty => state == ResourceState.empty;
  bool get isLoading => state == ResourceState.loading;

  bool get isFinished => state == ResourceState.finished;
  bool get hasError => state == ResourceState.finished && error != null;
  bool get hasData => state == ResourceState.finished && data != null;

  bool get isNotFinished => state != ResourceState.finished;
}
