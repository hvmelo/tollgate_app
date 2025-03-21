import 'package:latlong2/latlong.dart';

/// Model representing a TollGate access point
class TollgatePoint {
  /// Unique identifier for the TollGate point
  final String id;

  /// Name of the TollGate point
  final String name;

  /// Geographic location (latitude and longitude)
  final LatLng location;

  /// Description of the TollGate point
  final String description;

  /// Speed in Mbps
  final int speedMbps;

  /// Price per MB in satoshis
  final int pricePerMb;

  /// Creates a new TollGate point
  const TollgatePoint({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.speedMbps,
    required this.pricePerMb,
  });
}
