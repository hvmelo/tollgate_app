import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tollgate_app/ui/core/utils/extensions/build_context_x.dart';
import 'package:tollgate_app/ui/core/router/routes.dart';

import '../../../core/providers/wifi_connection_provider.dart';
import '../../../domain/models/wifi_network.dart';
import '../../../domain/models/toll_gate_response.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? networkData;

  const PaymentScreen({
    super.key,
    this.networkData,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  int _selectedPackage = 1;
  bool _isProcessing = false;
  bool _autoRenew = false;
  final TextEditingController _customAmountController = TextEditingController();
  int _walletBalance = 2500; // Mock wallet balance in sats

  // Package options
  final List<Map<String, dynamic>> _packages = [
    {
      'id': 0,
      'name': '5 mins',
      'price': 5,
      'icon': Icons.timelapse,
    },
    {
      'id': 1,
      'name': '21 mins',
      'price': 21,
      'icon': Icons.timer,
    },
    {
      'id': 2,
      'name': '1 hour',
      'price': 50,
      'icon': Icons.hourglass_bottom,
    },
    {
      'id': 3,
      'name': 'Custom',
      'price': 0, // Will be determined by user input
      'icon': Icons.edit,
    },
  ];

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  void _selectPackage(int packageId) {
    setState(() {
      _selectedPackage = packageId;
    });
  }

  void _toggleAutoRenew() {
    setState(() {
      _autoRenew = !_autoRenew;
    });
  }

  Future<void> _processPayment() async {
    final selectedPackage = _packages[_selectedPackage];
    final int price = selectedPackage['id'] == 3
        ? int.tryParse(_customAmountController.text) ?? 0
        : selectedPackage['price'];

    // Check if user has sufficient balance
    if (price > _walletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Insufficient balance. Please add funds to your wallet.',
          ),
          backgroundColor: context.colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // Update wallet balance
    setState(() {
      _walletBalance -= price;
      _isProcessing = false;
    });

    if (!mounted) return;

    // Get the network data
    final networkData = widget.networkData ??
        {
          'ssid': 'Unknown Network',
          'price': 0,
        };

    final String ssid = networkData['ssid'] ?? 'Unknown Network';
    final int pricePerMin = networkData['price'] ?? 0;

    // Generate a mock network ID
    final String networkId = 'toll-${DateTime.now().millisecondsSinceEpoch}';

    // Calculate time based on payment and price per minute
    final int minutesPurchased = pricePerMin > 0
        ? price ~/ pricePerMin
        : 30; // Default to 30 mins if price is 0

    // Create a TollGateResponse for the connection
    final tollGateResponse = TollGateResponse(
      providerName: 'TollGate Provider',
      satsPerMin: pricePerMin,
      initialCost: price,
      description: 'Pay-as-you-go Internet Access',
      networkId: networkId,
      ssid: ssid,
    );

    // Update the connection state in the provider
    final connectionNotifier = ref.read(wifiConnectionProvider.notifier);

    // Simulate a connection with the payment
    await connectionNotifier.connectWithPayment(tollGateResponse);

    // Show success message and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Payment successful! You are now connected.'),
        backgroundColor: context.colorScheme.primary,
      ),
    );

    // Go back to home screen
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final networkData = widget.networkData ??
        {
          'ssid': 'Unknown Network',
          'price': 0,
        };

    final String ssid = networkData['ssid'] ?? 'Unknown Network';
    final int price = networkData['price'] ?? 0;
    final currentPackage = _packages[_selectedPackage];

    final int packagePrice = currentPackage['id'] == 3
        ? int.tryParse(_customAmountController.text) ?? 0
        : currentPackage['price'];

    final bool hasEnoughBalance = _walletBalance >= packagePrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Network information
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color:
                                  context.colorScheme.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.wifi,
                              color: context.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ssid,
                                  style:
                                      context.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'TollGate Network - $price sats/min',
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Package selection
              Text(
                'Select Time Package',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Package grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _packages.length,
                itemBuilder: (context, index) {
                  final package = _packages[index];
                  final bool isSelected = _selectedPackage == index;

                  return InkWell(
                    onTap: () => _selectPackage(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? context.colorScheme.primary
                              : context.colorScheme.outline.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            package['icon'],
                            color: isSelected
                                ? context.colorScheme.primary
                                : context.colorScheme.onSurfaceVariant,
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            package['name'],
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? context.colorScheme.primary
                                  : context.colorScheme.onSurface,
                            ),
                          ),
                          if (index != 3) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${package['price']} sats',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: isSelected
                                    ? context.colorScheme.primary
                                    : context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Custom amount input (visible only when custom package is selected)
              if (_selectedPackage == 3) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _customAmountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Enter amount in sats',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    suffixText: 'sats',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],

              const SizedBox(height: 24),

              // Auto-renew option
              SwitchListTile(
                title: Text(
                  'Auto-renew',
                  style: context.textTheme.titleSmall,
                ),
                subtitle: Text(
                  'Automatically pay for more time when current package expires',
                  style: context.textTheme.bodySmall,
                ),
                value: _autoRenew,
                onChanged: (_) => _toggleAutoRenew(),
                activeColor: context.colorScheme.primary,
              ),

              const SizedBox(height: 8),

              // Divider
              Divider(
                color: context.colorScheme.outline.withOpacity(0.3),
              ),

              const SizedBox(height: 8),

              // Wallet balance and payment button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wallet Balance',
                        style: context.textTheme.titleSmall,
                      ),
                      Text(
                        '$_walletBalance sats',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: hasEnoughBalance
                              ? context.colorScheme.primary
                              : context.colorScheme.error,
                        ),
                      ),
                      if (!hasEnoughBalance)
                        Text(
                          'Not enough balance',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: !hasEnoughBalance || _isProcessing
                        ? null
                        : _processPayment,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Pay $packagePrice sats',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              OutlinedButton(
                onPressed: () {
                  context.push('/wallet');
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Add funds to wallet',
                  style: TextStyle(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
