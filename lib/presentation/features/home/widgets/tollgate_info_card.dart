import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../tollgate/providers/tollgate_providers.dart';
import '../../../../domain/tollgate/models/tollgate_info.dart';

class TollgateInfoCard extends ConsumerWidget {
  final TollGateInfo tollgateInfo;

  const TollgateInfoCard({
    super.key,
    required this.tollgateInfo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wifi_lock, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'TollGate Network',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow(
              'Pricing',
              '${tollgateInfo.pricePerStep} sats per ${_formatStepSize(tollgateInfo.stepSize)}',
            ),
            _buildInfoRow(
              'Mint URL',
              tollgateInfo.mintUrl,
            ),
            _buildInfoRow(
              'Info',
              tollgateInfo.tips,
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => _showPaymentSheet(context, ref),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Pay for Access'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatStepSize(int seconds) {
    if (seconds >= 3600) {
      final hours = seconds / 3600;
      return '${hours.toStringAsFixed(1)} hour${hours != 1 ? 's' : ''}';
    }
    if (seconds >= 60) {
      final minutes = seconds ~/ 60;
      return '$minutes minute${minutes != 1 ? 's' : ''}';
    }
    return '$seconds second${seconds != 1 ? 's' : ''}';
  }

  void _showPaymentSheet(BuildContext context, WidgetRef ref) {
    // This method would be implemented to show payment options
    // and initiate the payment process
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PaymentSheet(tollgateInfo: tollgateInfo),
    );
  }
}

class _PaymentSheet extends ConsumerStatefulWidget {
  final TollGateInfo tollgateInfo;

  const _PaymentSheet({required this.tollgateInfo});

  @override
  ConsumerState<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<_PaymentSheet> {
  int _selectedMinutes = 10;
  bool _autoRenew = false;

  @override
  Widget build(BuildContext context) {
    final priceInSats = widget.tollgateInfo.calculatePrice(
      minutes: _selectedMinutes * 60,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pay for WiFi Access',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Select access time:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: _selectedMinutes.toDouble(),
            min: 5,
            max: 60,
            divisions: 11,
            label: '$_selectedMinutes minutes',
            onChanged: (value) {
              setState(() {
                _selectedMinutes = value.toInt();
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('5 min'),
              Text('${_selectedMinutes.toInt()} min'),
              const Text('60 min'),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Auto-renew before expiry'),
            value: _autoRenew,
            onChanged: (value) {
              setState(() {
                _autoRenew = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Price:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$priceInSats sats',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _processPayment(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Pay Now', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _processPayment(BuildContext context) {
    // Access the TollgateStateNotifier and set auto-renew preference
    final tollgateState = ref.read(tollgateStateNotifierProvider.notifier);
    if (_autoRenew) {
      tollgateState.toggleAutoRenew();
    }

    // For this example, we'll just close the sheet and show a processing message
    Navigator.pop(context); // Close the payment sheet

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Payment processing... This would connect to a real payment service.'),
        duration: Duration(seconds: 3),
      ),
    );

    // In a real implementation, you would:
    // 1. Call the payment provider to process payment
    // 2. Show a loading indicator
    // 3. Update UI based on payment success or failure
  }
}
