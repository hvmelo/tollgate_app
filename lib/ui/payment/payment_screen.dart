import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  final TextEditingController _customAmountController = TextEditingController();
  int _walletBalance = 2500; // Mock wallet balance in sats

  // Package options
  final List<Map<String, dynamic>> _packages = [
    {
      'id': 0,
      'name': '5 mins',
      'price': 5,
      'icon': Icons.timer,
    },
    {
      'id': 1,
      'name': '30 mins',
      'price': 30,
      'icon': Icons.timer_10,
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

  Future<void> _processPayment() async {
    final selectedPackage = _packages[_selectedPackage];
    final int price = selectedPackage['id'] == 3
        ? int.tryParse(_customAmountController.text) ?? 0
        : selectedPackage['price'];

    // Check if user has sufficient balance
    if (price > _walletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Insufficient balance. Please add funds to your wallet.'),
          backgroundColor: Colors.red,
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

    // Show success message and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment successful! You are now connected.'),
        backgroundColor: Colors.green,
      ),
    );

    // Go back to connection screen
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final networkData = widget.networkData ??
        {
          'ssid': 'Unknown Network',
          'price': 'N/A',
        };

    final String ssid = networkData['ssid'] ?? 'Unknown Network';
    final currentPackage = _packages[_selectedPackage];

    final int packagePrice = currentPackage['id'] == 3
        ? int.tryParse(_customAmountController.text) ?? 0
        : currentPackage['price'];

    final bool hasEnoughBalance = _walletBalance >= packagePrice;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Buy Internet'),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1F38),
              Color(0xFF0F1225),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Network information
                Card(
                  color: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wifi,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Connecting to $ssid',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Package selection
                Text(
                  'Select Package',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
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
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _packages.length,
                  itemBuilder: (context, index) {
                    final package = _packages[index];
                    final bool isSelected = _selectedPackage == index;

                    return GestureDetector(
                      onTap: () => _selectPackage(index),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: isSelected
                              ? const Color(0xFF65D36E).withOpacity(0.2)
                              : Colors.white.withOpacity(0.1),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF65D36E)
                                : Colors.white.withOpacity(0.2),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              package['icon'],
                              color: isSelected
                                  ? const Color(0xFF65D36E)
                                  : Colors.white,
                              size: 28,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              package['name'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? const Color(0xFF65D36E)
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (index != 3)
                              Text(
                                '${package['price']} sats',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected
                                      ? const Color(0xFF65D36E).withOpacity(0.8)
                                      : Colors.white.withOpacity(0.7),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Custom amount input (visible only when custom package is selected)
                if (_selectedPackage == 3) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customAmountController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Enter amount in sats',
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const Text(
                            'sats',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Wallet balance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Wallet Balance:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '$_walletBalance sats',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: hasEnoughBalance ? Colors.white : Colors.red,
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Payment summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Cost:',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '$packagePrice sats',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: !hasEnoughBalance || _isProcessing
                              ? null
                              : _processPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF65D36E),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                Colors.grey.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Confirm & Pay',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
