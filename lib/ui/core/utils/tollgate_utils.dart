import '../../../domain/models/tollgate_info.dart';

class TollgateMetrics {
  /// Convert raw metric values to human-readable format
  static String formatMetrics(TollgateInfo info) {
    final metric = info.metric.toLowerCase();
    final stepSize = info.stepSize;
    final pricePerStep = info.pricePerStep;

    // Handle time-based metrics
    if (['milliseconds', 'seconds', 'minutes', 'hours'].contains(metric)) {
      return _formatTimeMetrics(metric, stepSize, pricePerStep);
    }

    // Handle data-based metrics
    if (['bytes', 'kilobytes', 'megabytes', 'gigabytes'].contains(metric)) {
      return _formatDataMetrics(metric, stepSize, pricePerStep);
    }

    // Unknown metric type
    return '$pricePerStep sats per $stepSize $metric';
  }

  /// Format time-based metrics into human-readable form
  static String _formatTimeMetrics(
      String metric, int stepSize, int pricePerStep) {
    // Convert everything to minutes for display
    double minutes = switch (metric) {
      'milliseconds' => stepSize / (1000 * 60),
      'seconds' => stepSize / 60,
      'minutes' => stepSize.toDouble(),
      'hours' => stepSize * 60,
      _ => stepSize.toDouble(),
    };

    // If less than 1 minute, show in seconds
    if (minutes < 1) {
      final seconds = (minutes * 60).round();
      return '$pricePerStep sats/${seconds}s';
    }

    // If exactly 1 minute
    if (minutes == 1) {
      return '$pricePerStep sats/min';
    }

    // If more than 60 minutes, show in hours
    if (minutes >= 60) {
      final hours = (minutes / 60).toStringAsFixed(1);
      return '$pricePerStep sats/${hours}h';
    }

    // Show in minutes
    return '$pricePerStep sats/${minutes.round()}min';
  }

  /// Format data-based metrics into human-readable form
  static String _formatDataMetrics(
      String metric, int stepSize, int pricePerStep) {
    // Convert everything to MB for display
    double megabytes = switch (metric) {
      'bytes' => stepSize / (1024 * 1024),
      'kilobytes' => stepSize / 1024,
      'megabytes' => stepSize.toDouble(),
      'gigabytes' => stepSize * 1024,
      _ => stepSize.toDouble(),
    };

    // If less than 1 MB, show in KB
    if (megabytes < 1) {
      final kilobytes = (megabytes * 1024).round();
      return '$pricePerStep sats/${kilobytes}KB';
    }

    // If more than 1024 MB, show in GB
    if (megabytes >= 1024) {
      final gigabytes = (megabytes / 1024).toStringAsFixed(1);
      return '$pricePerStep sats/${gigabytes}GB';
    }

    // Show in MB
    return '$pricePerStep sats/${megabytes.round()}MB';
  }

  /// Calculate price for a given amount
  static int calculatePrice(
    TollgateInfo info, {
    int? minutes,
    int? megabytes,
  }) {
    if (minutes != null &&
        ['milliseconds', 'seconds', 'minutes', 'hours']
            .contains(info.metric.toLowerCase())) {
      // Convert minutes to the appropriate metric
      final amount = switch (info.metric.toLowerCase()) {
        'milliseconds' => minutes * 60 * 1000,
        'seconds' => minutes * 60,
        'minutes' => minutes,
        'hours' => minutes / 60,
        _ => minutes,
      };

      // Calculate steps needed
      final steps = (amount / info.stepSize).ceil();
      return steps * info.pricePerStep;
    }

    if (megabytes != null &&
        ['bytes', 'kilobytes', 'megabytes', 'gigabytes']
            .contains(info.metric.toLowerCase())) {
      // Convert MB to the appropriate metric
      final amount = switch (info.metric.toLowerCase()) {
        'bytes' => megabytes * 1024 * 1024,
        'kilobytes' => megabytes * 1024,
        'megabytes' => megabytes,
        'gigabytes' => megabytes / 1024,
        _ => megabytes,
      };

      // Calculate steps needed
      final steps = (amount / info.stepSize).ceil();
      return steps * info.pricePerStep;
    }

    return 0; // Invalid metric type or parameters
  }
}
