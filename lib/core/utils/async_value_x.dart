import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'result.dart';

extension AsyncValueEither<T, E> on AsyncValue<Result<T, E>> {
  AsyncValue<T> get flatten {
    return when(
      data: (failureOrEntity) => failureOrEntity.fold(
        (failure) => AsyncValue.error(failure as Object, StackTrace.current),
        AsyncValue.data,
      ),
      error: AsyncError.new,
      loading: AsyncLoading.new,
    );
  }
}
