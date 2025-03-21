enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  verifying,
  verified,
  failed,
}

/// Represents the current state of Wi-Fi connection
class ConnectionState {
  final ConnectionStatus status;
  final String? ssid;
  final String? bssid;
  final String? error;
  final bool isTollGate;
  final String? routerIp;
  final double? price;
  final String? priceUnit;
  final int? timeLimit; // in minutes
  final int? dataLimit; // in MB

  const ConnectionState({
    this.status = ConnectionStatus.disconnected,
    this.ssid,
    this.bssid,
    this.error,
    this.isTollGate = false,
    this.routerIp,
    this.price,
    this.priceUnit,
    this.timeLimit,
    this.dataLimit,
  });

  /// Initial disconnected state
  factory ConnectionState.initial() {
    return const ConnectionState();
  }

  /// Create a copy with updated values
  ConnectionState copyWith({
    ConnectionStatus? status,
    String? ssid,
    String? bssid,
    String? error,
    bool? isTollGate,
    String? routerIp,
    double? price,
    String? priceUnit,
    int? timeLimit,
    int? dataLimit,
  }) {
    return ConnectionState(
      status: status ?? this.status,
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      error: error ?? this.error,
      isTollGate: isTollGate ?? this.isTollGate,
      routerIp: routerIp ?? this.routerIp,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,
      timeLimit: timeLimit ?? this.timeLimit,
      dataLimit: dataLimit ?? this.dataLimit,
    );
  }

  /// Check if the connection is to a verified TollGate network
  bool get isVerifiedTollGate =>
      status == ConnectionStatus.verified && isTollGate;

  /// Check if the internet is ready to use
  bool get isInternetReady =>
      status == ConnectionStatus.connected ||
      status == ConnectionStatus.verified;
}

/// Represents a response from a TollGate router verification request
class TollGateResponse {
  final bool isTollGate;
  final double? price;
  final String? priceUnit;
  final int? timeLimit;
  final int? dataLimit;
  final String? sessionId;
  final bool? internetEnabled;

  const TollGateResponse({
    required this.isTollGate,
    this.price,
    this.priceUnit,
    this.timeLimit,
    this.dataLimit,
    this.sessionId,
    this.internetEnabled,
  });

  /// Create a response from JSON returned by the router
  factory TollGateResponse.fromJson(Map<String, dynamic> json) {
    return TollGateResponse(
      isTollGate: json['tollgate'] as bool? ?? false,
      price: (json['price_per_mb'] as num?)?.toDouble(),
      priceUnit: json['unit'] as String?,
      timeLimit: json['time_limit'] as int?,
      dataLimit: json['data_limit'] as int?,
      sessionId: json['session_id'] as String?,
      internetEnabled: json['internet_enabled'] as bool?,
    );
  }

  /// Default response for when the router is not a TollGate
  factory TollGateResponse.notTollGate() {
    return const TollGateResponse(isTollGate: false);
  }

  /// Default response for when the verification fails
  factory TollGateResponse.error() {
    return const TollGateResponse(isTollGate: false);
  }
}
