import '../../../core/utils/result.dart';
import '../../../domain/errors/tollgate_errors.dart';
import '../../../domain/models/tollgate_info.dart';
import 'tollgate_service.dart';

class MockTollgateService extends TollgateService {
  final bool _shouldSucceed;
  final Duration _delay;

  MockTollgateService({
    bool shouldSucceed = true,
    Duration delay = const Duration(milliseconds: 500),
  })  : _shouldSucceed = shouldSucceed,
        _delay = delay,
        super();

  @override
  Future<Result<TollgateInfo, TollgateInfoRetrievalError>> getTollgateInfo(
      {required String routerIp, String? port = '2121'}) async {
    // Simulate network delay
    await Future.delayed(_delay);

    if (!_shouldSucceed) {
      return Failure(TollgateInfoRetrievalError.failedToGetTollgateInfo(
          'Failed to connect to Tollgate'));
    }

    // Sample response based on the provided JSON structure
    final mockResponse = {
      "kind": 21021,
      "id": "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2",
      "pubkey":
          "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2",
      "created_at": 0,
      "tags": [
        ["metric", "time"],
        ["step_size", "60"],
        ["price_per_step", "10"],
        ["mint_url", "https://mint.example.com"],
        ["tip", "Pay for WiFi with Bitcoin Lightning ⚡"]
      ],
      "content": "",
      "sig":
          "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2"
    };

    return Success(TollgateInfo.fromJson(mockResponse));
  }

  @override
  Future<Result<bool, TollgateInfoRetrievalError>> detectTollgate(
      {required String routerIp, String? port = '2121'}) async {
    await Future.delayed(_delay);

    return _shouldSucceed
        ? const Success(true)
        : Failure(TollgateInfoRetrievalError.failedToGetTollgateInfo(
            'Not a Tollgate network'));
  }
}
