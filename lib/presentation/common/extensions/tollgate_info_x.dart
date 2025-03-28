import 'package:tollgate_app/domain/models/tollgate/tollgate_info.dart';

extension TollgateInfoX on TollGateInfo {
  String humanReadablePrice() {
    final metric = this.metric.toLowerCase();
    final stepSize = this.stepSize;
    final pricePerStep = this.pricePerStep;

    // Handle time-based metrics
    if (['milliseconds', 'seconds', 'minutes', 'hours'].contains(metric)) {
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

    // Handle data-based metrics
    if (['bytes', 'kilobytes', 'megabytes', 'gigabytes'].contains(metric)) {
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

    // Unknown metric type
    return '$pricePerStep sats per $stepSize $metric';
  }
}
