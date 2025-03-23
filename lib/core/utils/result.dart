// lib/core/common/sealed_result.dart

sealed class Result<T, E> {
  const Result();

  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;

  T? getOrNull() => switch (this) {
        Success(value: final value) => value,
        Failure() => null,
      };

  E? getErrorOrNull() => switch (this) {
        Failure(error: final error) => error,
        Success() => null,
      };

  T getOrElse(T Function() fallback) => switch (this) {
        Success(value: final value) => value,
        Failure() => fallback(),
      };

  Result<R, E> map<R>(R Function(T value) transform) => switch (this) {
        Success(value: final value) => Success(transform(value)),
        Failure(error: final error) => Failure(error),
      };

  Result<T, F> mapError<F>(F Function(E error) transform) => switch (this) {
        Success(value: final value) => Success(value),
        Failure(error: final error) => Failure(transform(error)),
      };

  Result<R, E> flatMap<R>(Result<R, E> Function(T value) transform) =>
      switch (this) {
        Success(value: final value) => transform(value),
        Failure(error: final error) => Failure(error),
      };

  R fold<R>(R Function(E error) onFailure, R Function(T value) onSuccess) =>
      switch (this) {
        Success(value: final value) => onSuccess(value),
        Failure(error: final error) => onFailure(error),
      };

  void when({
    required void Function(T value) onSuccess,
    required void Function(E error) onFailure,
  }) =>
      switch (this) {
        Success(value: final value) => onSuccess(value),
        Failure(error: final error) => onFailure(error),
      };
}

final class Success<T, E> extends Result<T, E> {
  final T value;
  const Success(this.value);
}

final class Failure<T, E> extends Result<T, E> {
  final E error;
  const Failure(this.error);
}

extension ResultExtension<T, E> on Result<T, E> {
  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;

  R? whenOrNull<R>({
    R Function(T value)? onSuccess,
    R Function(E error)? onFailure,
  }) {
    if (this is Success<T, E>) {
      return onSuccess?.call((this as Success<T, E>).value);
    } else if (this is Failure<T, E>) {
      return onFailure?.call((this as Failure<T, E>).error);
    }
    return null;
  }

  void inspect({
    void Function(T value)? onSuccess,
    void Function(E error)? onFailure,
  }) {
    if (this is Success<T, E> && onSuccess != null) {
      onSuccess((this as Success<T, E>).value);
    } else if (this is Failure<T, E> && onFailure != null) {
      onFailure((this as Failure<T, E>).error);
    }
  }
}
