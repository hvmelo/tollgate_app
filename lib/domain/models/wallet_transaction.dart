class WalletTransaction {
  final String id;
  final int amount;
  final String description;
  final DateTime timestamp;
  final bool isIncoming;
  final String? networkSsid;
  final String? tokenId;

  WalletTransaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.timestamp,
    required this.isIncoming,
    this.networkSsid,
    this.tokenId,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      amount: json['amount'] as int,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isIncoming: json['isIncoming'] as bool,
      networkSsid: json['networkSsid'] as String?,
      tokenId: json['tokenId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'isIncoming': isIncoming,
      'networkSsid': networkSsid,
      'tokenId': tokenId,
    };
  }

  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
