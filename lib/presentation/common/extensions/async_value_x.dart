import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/result/result.dart';

extension AsyncValueEither<T, E> on AsyncValue<Result<T, E>> {
  AsyncValue<T> get flatten {
    return when(
      data: (result) => result.fold(
        onSuccess: (data) => AsyncValue.data(data),
        onFailure: (error) =>
            AsyncValue.error(error as Object, StackTrace.current),
      ),
      error: AsyncError.new,
      loading: AsyncLoading.new,
    );
  }
}
