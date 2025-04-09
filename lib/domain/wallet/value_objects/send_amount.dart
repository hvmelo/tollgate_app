import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tollgate_app/core/result/result.dart';
import 'package:tollgate_app/core/result/unit.dart';

import '../constants/wallet_constants.dart';

part 'send_amount.freezed.dart';

/// Value object representing an amount to send
@freezed
class SendAmount with _$SendAmount {
  const SendAmount._(); // Private constructor to enforce validation rules

  const factory SendAmount._internal(BigInt value) = _SendAmount;

  /// Static method for validation + object creation
  static Result<SendAmount, SendAmountValidationFailure> create(BigInt value) {
    final validationResult = validate(value);
    return validationResult.map((_) => SendAmount._internal(value));
  }

  /// Static method for creating a [SendAmount] without validation.
  /// This is useful for creating a [SendAmount] from data that is already
  /// validated.
  static SendAmount fromData(BigInt data) {
    return SendAmount._internal(data);
  }

  /// Validation logic (single source of truth)
  static Result<Unit, SendAmountValidationFailure> validate(BigInt value) {
    if (value <= BigInt.zero) {
      return Result.failure(SendAmountValidationFailure.negativeOrZero());
    }
    if (value > kSendAmountMax) {
      return Result.failure(
          SendAmountValidationFailure.tooLarge(maxAmount: kSendAmountMax));
    }
    return Result.ok(unit);
  }
}

/// Failure class for SendAmount validation
@freezed
sealed class SendAmountValidationFailure with _$SendAmountValidationFailure {
  factory SendAmountValidationFailure.negativeOrZero() =
      SendAmountNegativeOrZero;
  factory SendAmountValidationFailure.tooLarge({
    required BigInt maxAmount,
  }) = SendAmountTooLarge;
}
