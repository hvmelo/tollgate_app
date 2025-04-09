import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tollgate_app/domain/wallet/constants/wallet_constants.dart';

import '../../../core/result/result.dart';
import '../../../core/result/unit.dart';

part 'mint_amount.freezed.dart';

@freezed
class MintAmount with _$MintAmount {
  const MintAmount._(); // Private constructor to enforce validation rules

  const factory MintAmount._internal(BigInt value) = _MintAmount;

  /// Static method for validation + object creation
  static Result<MintAmount, MintAmountValidationFailure> create(BigInt value) {
    final validationResult = validate(value);
    return validationResult.map((_) => MintAmount._internal(value));
  }

  /// Static method for creating a [MintAmount] without validation.
  /// This is useful for creating a [MintAmount] from data that is already
  /// validated.
  static MintAmount fromData(BigInt data) {
    return MintAmount._internal(data);
  }

  /// Validation logic (single source of truth)
  static Result<Unit, MintAmountValidationFailure> validate(BigInt value) {
    if (value <= BigInt.zero) {
      return Result.failure(MintAmountValidationFailure.negativeOrZero());
    }
    if (value > kMintAmountMax) {
      return Result.failure(
          MintAmountValidationFailure.tooLarge(maxAmount: kMintAmountMax));
    }
    return Result.ok(unit);
  }
}

/// Represents possible validation failures for a [MintAmount].
@freezed
sealed class MintAmountValidationFailure with _$MintAmountValidationFailure {
  factory MintAmountValidationFailure.negativeOrZero() =
      MintAmountNegativeOrZero;
  factory MintAmountValidationFailure.tooLarge({
    required BigInt maxAmount,
  }) = MintAmountTooLarge;
}
