import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_errors.freezed.dart';

@freezed
class AddMintFailure with _$AddMintFailure {
  const factory AddMintFailure.alreadyExists() = AddMintAlreadyExists;
  const factory AddMintFailure.unexpected(Object error,
      {StackTrace? stackTrace}) = AddMintUnexpected;
}

@freezed
class UpdateMintFailure with _$UpdateMintFailure {
  const factory UpdateMintFailure.unexpected(Object error,
      {StackTrace? stackTrace}) = UpdateMintUnexpected;
}

@freezed
class RemoveMintFailure with _$RemoveMintFailure {
  const factory RemoveMintFailure.unexpected(Object error,
      {StackTrace? stackTrace}) = RemoveMintUnexpected;
}

@freezed
class GetMintFailure with _$GetMintFailure {
  const factory GetMintFailure.mintNotFound(String mintUrl) =
      GetMintMintNotFound;
  const factory GetMintFailure.unexpected(Object error,
      {StackTrace? stackTrace}) = GetMintUnexpected;
}

@freezed
class ListMintsFailure with _$ListMintsFailure {
  const factory ListMintsFailure.unexpected(Object error,
      {StackTrace? stackTrace}) = ListMintsUnexpected;
}

@freezed
class SaveCurrentMintFailure with _$SaveCurrentMintFailure {
  const factory SaveCurrentMintFailure.unexpected(Object error,
      {StackTrace? stackTrace}) = SaveCurrentMintUnexpected;
}

@freezed
class RemoveCurrentMintFailure with _$RemoveCurrentMintFailure {
  const factory RemoveCurrentMintFailure.unexpected(Object error,
      {StackTrace? stackTrace}) = RemoveCurrentMintUnexpected;
}

@freezed
class MintBalanceStreamFailure with _$MintBalanceStreamFailure {
  const factory MintBalanceStreamFailure.unexpected(Object error,
      {StackTrace? stackTrace}) = MintBalanceStreamUnexpected;
}

@freezed
class MeltQuoteFailure with _$MeltQuoteFailure {
  const factory MeltQuoteFailure.mintNotFound(String mintUrl) =
      MeltQuoteMintNotFound;
  const factory MeltQuoteFailure.unexpected(Object error,
      {StackTrace? stackTrace}) = MeltQuoteUnexpected;
}

@freezed
class MeltFailure with _$MeltFailure {
  const factory MeltFailure.mintNotFound(String mintUrl) = MeltMintNotFound;
  const factory MeltFailure.unexpected(Object error, {StackTrace? stackTrace}) =
      MeltUnexpected;
}

@freezed
class SendFailure with _$SendFailure {
  const factory SendFailure.mintNotFound(String mintUrl) = SendMintNotFound;
  const factory SendFailure.unexpected(Object error, {StackTrace? stackTrace}) =
      SendUnexpected;
}

@freezed
class ReceiveFailure with _$ReceiveFailure {
  const factory ReceiveFailure.unexpected(Object error,
      {StackTrace? stackTrace}) = ReceiveUnexpected;
}

@freezed
class MintQuoteStreamFailure with _$MintQuoteStreamFailure {
  const factory MintQuoteStreamFailure.mintNotFound(String mintUrl) =
      MintQuoteStreamMintNotFound;
  const factory MintQuoteStreamFailure.unexpected(Object error,
      {StackTrace? stackTrace}) = MintQuoteStreamUnexpected;
}

@freezed
class PrepareSendFailure with _$PrepareSendFailure {
  const factory PrepareSendFailure.mintNotFound(String mintUrl) =
      PrepareSendMintNotFound;
  const factory PrepareSendFailure.unexpected(Object error,
      {StackTrace? stackTrace}) = PrepareSendUnexpected;
}
