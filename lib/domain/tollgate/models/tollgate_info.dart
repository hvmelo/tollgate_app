class TollGateInfo {
  final int kind;
  final String id;
  final String pubkey;
  final int createdAt;
  final List<List<String>> tags;
  final String content;
  final String sig;

  // Parsed tags for easier access
  final String metric;
  final int stepSize;
  final int pricePerStep;
  final String mintUrl;
  final String tips;

  TollGateInfo({
    required this.kind,
    required this.id,
    required this.pubkey,
    required this.createdAt,
    required this.tags,
    required this.content,
    required this.sig,
    required this.metric,
    required this.stepSize,
    required this.pricePerStep,
    required this.mintUrl,
    required this.tips,
  });

  factory TollGateInfo.fromJson(Map<String, dynamic> json) {
    // Extract the tags for easier access
    final rawTags = (json['tags'] as List<dynamic>).map((tag) {
      return (tag as List<dynamic>).map((item) => item.toString()).toList();
    }).toList();

    // Helper to find a tag by name
    String findTagValue(String name, {String defaultValue = ''}) {
      for (final tag in rawTags) {
        if (tag.isNotEmpty && tag.first == name) {
          return tag.length > 1 ? tag[1] : defaultValue;
        }
      }
      return defaultValue;
    }

    // Parse tag values
    final metric = findTagValue('metric', defaultValue: 'time');
    final stepSizeStr = findTagValue('step_size', defaultValue: '60');
    final pricePerStepStr = findTagValue('price_per_step', defaultValue: '10');
    final mintUrl = findTagValue('mint', defaultValue: '');
    final tips = findTagValue('tip',
        defaultValue: 'Pay for WiFi with Bitcoin Lightning ⚡');

    return TollGateInfo(
      kind: json['kind'] as int,
      id: json['id'] as String,
      pubkey: json['pubkey'] as String,
      createdAt: json['created_at'] as int,
      tags: rawTags,
      content: json['content'] as String,
      sig: json['sig'] as String,
      metric: metric,
      stepSize: int.tryParse(stepSizeStr) ?? 60,
      pricePerStep: int.tryParse(pricePerStepStr) ?? 10,
      mintUrl: mintUrl,
      tips: tips,
    );
  }

  /// Calculate price for a given amount of time in seconds
  int calculatePrice({
    int? minutes,
    int? megabytes,
  }) {
    if (minutes != null &&
        ['milliseconds', 'seconds', 'minutes', 'hours']
            .contains(metric.toLowerCase())) {
      // Convert minutes to the appropriate metric
      final amount = switch (metric.toLowerCase()) {
        'milliseconds' => minutes * 60 * 1000,
        'seconds' => minutes * 60,
        'minutes' => minutes,
        'hours' => minutes / 60,
        _ => minutes,
      };

      // Calculate steps needed
      final steps = (amount / stepSize).ceil();
      return steps * pricePerStep;
    }

    if (megabytes != null &&
        ['bytes', 'kilobytes', 'megabytes', 'gigabytes']
            .contains(metric.toLowerCase())) {
      // Convert MB to the appropriate metric
      final amount = switch (metric.toLowerCase()) {
        'bytes' => megabytes * 1024 * 1024,
        'kilobytes' => megabytes * 1024,
        'megabytes' => megabytes,
        'gigabytes' => megabytes / 1024,
        _ => megabytes,
      };

      // Calculate steps needed
      final steps = (amount / stepSize).ceil();
      return steps * pricePerStep;
    }

    return -1; // Invalid metric type or parameters
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'id': id,
      'pubkey': pubkey,
      'created_at': createdAt,
      'tags': tags,
      'content': content,
      'sig': sig,
    };
  }

  @override
  String toString() {
    return 'TollgateInfo(metric: $metric, pricePerStep: $pricePerStep sats, stepSize: $stepSize seconds)';
  }
}
