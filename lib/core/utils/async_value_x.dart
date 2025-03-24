import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'result.dart';

extension AsyncValueEither<T, E> on AsyncValue<Result<T, E>> {
  AsyncValue<T> get flatten {
    return when(
      data: (failureOrEntity) => failureOrEntity.fold(
        AsyncValue.data,
        (failure) => AsyncValue.error(failure as Object, StackTrace.current),
      ),
      error: AsyncError.new,
      loading: AsyncLoading.new,
    );
  }
}
