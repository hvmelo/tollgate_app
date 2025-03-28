/// Represents a response from a TollGate network after connecting
class TollGateResponse {
  final String? providerName;
  final int? satsPerMin;
  final int? initialCost;
  final String? description;
  final String? mintUrl;
  final String? paymentUrl;
  final String networkId;
  final String ssid;

  TollGateResponse({
    this.providerName,
    this.satsPerMin,
    this.initialCost,
    this.description,
    this.mintUrl,
    this.paymentUrl,
    required this.networkId,
    required this.ssid,
  });

  factory TollGateResponse.fromJson(Map<String, dynamic> json) {
    return TollGateResponse(
      providerName: json['provider_name'] as String?,
      satsPerMin: json['sats_per_min'] != null
          ? (json['sats_per_min'] as num).toInt()
          : null,
      initialCost: json['initial_cost'] as int?,
      description: json['description'] as String?,
      mintUrl: json['mint_url'] as String?,
      paymentUrl: json['payment_url'] as String?,
      networkId: json['network_id'] as String,
      ssid: json['ssid'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider_name': providerName,
      'sats_per_min': satsPerMin,
      'initial_cost': initialCost,
      'description': description,
      'mint_url': mintUrl,
      'payment_url': paymentUrl,
      'network_id': networkId,
      'ssid': ssid,
    };
  }
}
