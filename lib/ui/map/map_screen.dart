import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:tollgate_app/ui/core/utils/extensions/build_context_x.dart';

import 'models/tollgate_point.dart';

class MapScreen extends HookConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Funchal, Madeira coordinates
    const LatLng funchalCenter = LatLng(32.6496, -16.9086);

    // Controller for the map
    final mapController = useMapController();

    // State to track if the map has loaded
    final isMapLoaded = useState(false);

    // Simple timer to detect if map is loading
    useEffect(() {
      Future.delayed(const Duration(seconds: 2), () {
        isMapLoaded.value = true;
      });
      return null;
    }, []);

    // Mock TollGate points
    final tollgatePoints = useState<List<TollgatePoint>>([
      TollgatePoint(
        id: '1',
        name: 'Marina TollGate',
        location: const LatLng(32.6456, -16.9104),
        description: 'Fast WiFi near the marina',
        speedMbps: 100,
        pricePerMb: 10,
      ),
      TollgatePoint(
        id: '2',
        name: 'Jardim Municipal TollGate',
        location: const LatLng(32.6496, -16.9136),
        description: 'Public garden hotspot',
        speedMbps: 50,
        pricePerMb: 5,
      ),
      TollgatePoint(
        id: '3',
        name: 'Monte TollGate',
        location: const LatLng(32.6662, -16.8998),
        description: 'Mountain cable car station',
        speedMbps: 75,
        pricePerMb: 8,
      ),
      TollgatePoint(
        id: '4',
        name: 'Forum Madeira TollGate',
        location: const LatLng(32.6384, -16.9274),
        description: 'Shopping mall high-speed connection',
        speedMbps: 200,
        pricePerMb: 15,
      ),
      TollgatePoint(
        id: '5',
        name: 'Lido TollGate',
        location: const LatLng(32.6363, -16.9366),
        description: 'Beach area WiFi',
        speedMbps: 80,
        pricePerMb: 7,
      ),
      TollgatePoint(
        id: '6',
        name: 'Ponta Gorda TollGate',
        location: const LatLng(32.6386, -16.9443),
        description: 'Oceanfront coverage',
        speedMbps: 120,
        pricePerMb: 12,
      ),
      TollgatePoint(
        id: '7',
        name: 'Airport TollGate',
        location: const LatLng(32.6944, -16.7780),
        description: 'Airport terminal hotspot',
        speedMbps: 150,
        pricePerMb: 14,
      ),
      TollgatePoint(
        id: '8',
        name: 'Cowork Funchal TollGate',
        location: const LatLng(32.6464, -16.9086),
        description: 'Premium coworking space connection',
        speedMbps: 300,
        pricePerMb: 20,
      ),
    ]);

    // Selected point for displaying info
    final selectedPoint = useState<TollgatePoint?>(null);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TollGate Points',
          style: context.textTheme.titleMedium,
        ),
        centerTitle: true,
        backgroundColor: context.colorScheme.surface,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: funchalCenter,
              initialZoom: 15.5,
              onTap: (tapPosition, point) {
                // Clear selection when tapping elsewhere
                selectedPoint.value = null;
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.tollgate.app',
              ),
              MarkerLayer(
                markers: tollgatePoints.value
                    .map((point) => Marker(
                          point: point.location,
                          width: 80,
                          height: 80,
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () {
                              selectedPoint.value = point;
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.black
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: SvgPicture.asset(
                                      'assets/images/icons/tollgate_icon.svg',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    point.name.split(' ')[0],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),

          // Show loading indicator when map is not loaded
          if (!isMapLoaded.value)
            const Center(
              child: CircularProgressIndicator(),
            ),

          // Show info popup when a point is selected
          if (selectedPoint.value != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedPoint.value!.name,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(selectedPoint.value!.description),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.speed, size: 16),
                            label:
                                Text('${selectedPoint.value!.speedMbps} Mbps'),
                          ),
                          Chip(
                            avatar: const Icon(Icons.bolt, size: 16),
                            label: Text(
                                '${selectedPoint.value!.pricePerMb} sats/MB'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Here you would connect to this TollGate point
                            // For demo purposes, just close the info window
                            selectedPoint.value = null;
                          },
                          child: const Text('Connect'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.my_location),
        onPressed: () {
          mapController.move(funchalCenter, 14.0);
        },
      ),
    );
  }
}

// Custom hook for map controller
MapController useMapController() {
  return use(_MapControllerHook());
}

class _MapControllerHook extends Hook<MapController> {
  @override
  _MapControllerHookState createState() => _MapControllerHookState();
}

class _MapControllerHookState
    extends HookState<MapController, _MapControllerHook> {
  late final _controller = MapController();

  @override
  MapController build(BuildContext context) => _controller;

  @override
  void dispose() {
    super.dispose();
  }
}
