import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tollgate_app/presentation/common/extensions/build_context_x.dart';
import 'package:tollgate_app/presentation/features/wifi/providers/connect_to_network_provider.dart';
import 'package:tollgate_app/presentation/router/routes.dart';

import '../../../../domain/tollgate/models/tollgate_response.dart';
import '../../../../domain/wifi/models/wifi_network.dart';

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
      description: 'Pay-as-You-Go Internet Access',
      networkId: networkId,
      ssid: ssid,
    );

    // Connect to network with payment
    final resultAsync = ref.read(connectToNetworkProvider(
      WiFiNetwork(
        ssid: ssid,
        bssid: networkData['bssid'] ?? '',
        securityType: networkData['securityType'] ?? '',
        frequency: networkData['frequency'] ?? 0,
        signalStrength: networkData['signalStrength'] ?? 0,
      ),
    ));

    resultAsync.when(
      data: (response) {
        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Payment successful! You are now connected.'),
            backgroundColor: context.colorScheme.primary,
          ),
        );
      },
      loading: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Connecting...'),
          backgroundColor: context.colorScheme.primary,
        ),
      ),
      error: (error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Connection failed'),
            backgroundColor: context.colorScheme.error,
          ),
        );
        // Go back to home screen
        context.go(Routes.home);
      },
    );
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Network information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary.withAlpha(50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.wifi,
                        color: context.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ssid,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'TollGate Network - $price sats/min',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Package selection
              Text(
                'Select Time Package',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Package grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.6,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
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
                        color: isSelected
                            ? context.colorScheme.primary.withOpacity(0.1)
                            : context.colorScheme.surface,
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
                            size: 24,
                          ),
                          const SizedBox(height: 6),
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
                            const SizedBox(height: 2),
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
                const SizedBox(height: 12),
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

              const SizedBox(height: 16),

              // Auto-renew option
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _autoRenew
                      ? context.colorScheme.primary.withOpacity(0.1)
                      : context.colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Auto-renew',
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _autoRenew
                          ? context.colorScheme.primary
                          : context.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Auto-pay when time expires',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: _autoRenew,
                  onChanged: (_) => _toggleAutoRenew(),
                  activeColor: context.colorScheme.primary,
                  dense: true,
                ),
              ),

              const SizedBox(height: 16),

              // Wallet balance and payment section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Colors.amber.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Wallet Balance',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                              Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: context.colorScheme.error,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Insufficient balance',
                                    style:
                                        context.textTheme.bodySmall?.copyWith(
                                      color: context.colorScheme.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: !hasEnoughBalance || _isProcessing
                              ? null
                              : _processPayment,
                          icon: _isProcessing
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(Icons.bolt, size: 14),
                          label: Text(
                            _isProcessing
                                ? 'Processing...'
                                : 'Pay $packagePrice sats',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Add funds button with updated color
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/wallet');
                },
                icon: const Icon(
                  Icons.add,
                  size: 14,
                ),
                label: const Text(
                  'Add funds to wallet',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colorScheme.secondary,
                  foregroundColor: context.colorScheme.onSecondary,
                  minimumSize: const Size(double.infinity, 42),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
