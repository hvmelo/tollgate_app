import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:tollgate_app/domain/tollgate/errors/tollgate_errors.dart';

import '../../../core/result/result.dart';
import '../../../domain/tollgate/models/tollgate_info.dart';

class TollgateService {
  final String _defaultPort;

  TollgateService({String defaultPort = '2121'}) : _defaultPort = defaultPort;

  /// Fetches Tollgate information from the router
  ///
  /// [routerIp] is the IP address of the router, e.g., '192.168.1.1'
  /// [port] is optional and defaults to '2121'
  Future<Result<TollGateInfo, TollgateInfoRetrievalError>> getTollgateInfo(
      {required String routerIp, String? port = '2121'}) async {
    final targetPort = port ?? _defaultPort;
    final url = 'http://$routerIp:$targetPort';

    try {
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw Exception('Connection timed out'),
          );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Result.ok(TollGateInfo.fromJson(jsonData));
      } else {
        return Result.failure(
          TollgateInfoRetrievalError.failedToGetTollgateInfo(
              'Failed to load Tollgate info: HTTP ${response.statusCode}'),
        );
      }
    } catch (e) {
      debugPrint('Error fetching Tollgate info: $e');
      return Result.failure(
        TollgateInfoRetrievalError.failedToGetTollgateInfo(
            'Failed to connect to Tollgate: ${e.toString()}'),
      );
    }
  }

  /// Detects if the current WiFi is a Tollgate network by attempting to connect to the service
  ///
  /// [routerIp] is the default gateway IP address
  /// Returns true if a Tollgate service is detected
  Future<Result<bool, TollgateInfoRetrievalError>> detectTollgate(
      {required String routerIp, String? port = '2121'}) async {
    final result = await getTollgateInfo(routerIp: routerIp, port: port);

    return result
        .map(
      (info) => true, // If we got info, it's a Tollgate
    )
        .mapFailure(
      (error) {
        // If it's a connection error, it may not be a Tollgate
        return TollgateInfoRetrievalError.failedToGetTollgateInfo(
            'Not a Tollgate network');
      },
    );
  }
}
