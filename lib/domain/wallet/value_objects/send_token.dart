import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_token.freezed.dart';

/// Value object representing a token for sending sats
@freezed
class SendToken with _$SendToken {
  const factory SendToken({
    required String token,
    required BigInt amount,
  }) = _SendToken;

  const SendToken._();

  /// Creates a SendToken from a string token and amount
  factory SendToken.fromData({
    required String token,
    required BigInt amount,
  }) {
    return SendToken(
      token: token,
      amount: amount,
    );
  }
}
