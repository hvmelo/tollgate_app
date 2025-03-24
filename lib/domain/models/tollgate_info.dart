class TollgateInfo {
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

  TollgateInfo({
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

  factory TollgateInfo.fromJson(Map<String, dynamic> json) {
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
    final mintUrl = findTagValue('mint_url', defaultValue: '');
    final tips = findTagValue('tip',
        defaultValue: 'Pay for WiFi with Bitcoin Lightning ⚡');

    return TollgateInfo(
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
  int calculatePrice(int timeInSeconds) {
    // If time is not the metric, this calculation might differ
    if (metric != 'time') return 0;

    // Calculate how many steps needed
    final steps = (timeInSeconds / stepSize).ceil();
    return steps * pricePerStep;
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
