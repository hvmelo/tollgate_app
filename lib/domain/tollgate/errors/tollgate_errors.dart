import 'package:freezed_annotation/freezed_annotation.dart';

part 'tollgate_errors.freezed.dart';

@freezed
class TollgateInfoRetrievalError with _$TollgateInfoRetrievalError {
  const factory TollgateInfoRetrievalError.failedToGetTollgateInfo(
      String? message) = FailedToGetTollgateInfo;
}
