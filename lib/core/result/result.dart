// Copyright 2024 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Utility class to wrap result data
///
/// Evaluate the result using a switch statement:
/// ```dart
/// switch (result) {
///   case Ok(): {
///     print(result.value);
///   }
///   case Failure(): {
///     print(result.failure);
///   }
/// }
/// ```
sealed class Result<T, E> {
  const Result();

  /// Creates a successful [Result], completed with the specified [value].
  const factory Result.ok(T value) = Ok<T, E>._;

  /// Creates an error [Result], completed with the specified [failure].
  const factory Result.failure(
    E failure, {
    StackTrace? stackTrace,
  }) = Failure<T, E>._;

  bool get isOk => this is Ok;
  bool get isFailure => this is Failure;

  /// Returns the contained [Ok] value, or null if the result is an [Failure]
  T? get value {
    return switch (this) {
      Ok(value: final v) => v,
      Failure() => null,
    };
  }

  /// Returns the contained [Failure] value, or null if the result is [Ok]
  E? get failure {
    return switch (this) {
      Ok() => null,
      Failure(failure: final e) => e,
    };
  }

  /// Maps a Result<`T`, `E`> to Result<`R`, `E`> by applying a function to the
  /// contained [Ok] value, leaving an [Failure] value untouched.
  ///
  /// This function can be used to compose the results of two functions.
  Result<R, E> map<R>(R Function(T) mapper) {
    return switch (this) {
      Ok(value: final v) => Result.ok(mapper(v)),
      Failure(failure: final e, stackTrace: final st) =>
        Result.failure(e, stackTrace: st),
    };
  }

  Result<T, F> mapFailure<F>(F Function(E error) transform) => switch (this) {
        Ok(value: final value) => Result.ok(value),
        Failure(failure: final error) => Result.failure(transform(error)),
      };

  Result<R, E> flatMap<R>(Result<R, E> Function(T value) transform) =>
      switch (this) {
        Ok(value: final value) => transform(value),
        Failure(failure: final error) => Result.failure(error),
      };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(E error) onFailure,
  }) =>
      switch (this) {
        Ok(value: final value) => onSuccess(value),
        Failure(failure: final error) => onFailure(error),
      };

  /// Maps a Result<T, E> to Result<R, E> by applying a function that returns
  /// a Result to the contained [Ok] value, leaving an [Failure] value untouched.
  ///
  /// Alias for flatMap() method.
  Result<R, E> andThen<R>(Result<R, E> Function(T) mapper) => flatMap(mapper);
}

/// Subclass of Result for values
final class Ok<T, E> extends Result<T, E> {
  const Ok._(this.value);

  /// Returned value in result
  @override
  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// Subclass of Result for errors
final class Failure<T, E> extends Result<T, E> {
  const Failure._(
    this.failure, {
    this.stackTrace,
  });

  /// Returned error in result
  @override
  final E failure;
  final StackTrace? stackTrace;

  @override
  String toString() =>
      'Result<$T>.failure($failure, ${stackTrace?.toString() ?? 'no stack trace'})';
}
