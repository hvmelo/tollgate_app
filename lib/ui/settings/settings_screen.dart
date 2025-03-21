import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _autoPayEnabled = false;
  double _spendingCap = 500; // In sats
  final double _minSpendingCap = 100;
  final double _maxSpendingCap = 1000;

  // Mock transaction history
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 1,
      'network': 'TollGate-Cafe',
      'amount': 30,
      'date': '2023-06-01 14:23',
      'type': 'payment',
    },
    {
      'id': 2,
      'network': 'TollGate-Library',
      'amount': 15,
      'date': '2023-05-28 10:12',
      'type': 'payment',
    },
    {
      'id': 3,
      'network': 'Wallet Top-up',
      'amount': 1000,
      'date': '2023-05-25 18:45',
      'type': 'deposit',
    },
    {
      'id': 4,
      'network': 'TollGate-Park',
      'amount': 25,
      'date': '2023-05-22 12:30',
      'type': 'payment',
    },
  ];

  void _toggleAutoPay(bool value) {
    setState(() {
      _autoPayEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings'),
      ),
      extendBodyBehindAppBar: true,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        backgroundColor: const Color(0xFF1A1F38),
        selectedItemColor: const Color(0xFF65D36E),
        unselectedItemColor: Colors.white.withOpacity(0.5),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.link), label: 'Connection'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          if (index == 0) {
            context.go('/');
          } else if (index == 1) {
            context.push('/connection');
          } else if (index == 2) {
            context.push('/wallet');
          }
        },
      ),
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
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Auto-payment settings
              _buildSectionHeader('Payment Settings'),
              const SizedBox(height: 16),

              // Auto-pay toggle card
              Card(
                color: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Auto-Pay',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Switch(
                            value: _autoPayEnabled,
                            onChanged: _toggleAutoPay,
                            activeColor: const Color(0xFF65D36E),
                          ),
                        ],
                      ),
                      if (_autoPayEnabled) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Spending Cap',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${_minSpendingCap.toInt()}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                value: _spendingCap,
                                min: _minSpendingCap,
                                max: _maxSpendingCap,
                                divisions: 9,
                                activeColor: const Color(0xFF65D36E),
                                inactiveColor: Colors.white.withOpacity(0.2),
                                onChanged: (value) {
                                  setState(() {
                                    _spendingCap = value;
                                  });
                                },
                              ),
                            ),
                            Text(
                              '${_maxSpendingCap.toInt()}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Center(
                          child: Text(
                            '${_spendingCap.toInt()} sats per session',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (_spendingCap > 500) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Setting a high spending cap may deplete your wallet quickly.',
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Cashu Mint settings
              _buildSectionHeader('Cashu Settings'),
              const SizedBox(height: 16),
              Card(
                color: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance,
                          color: Colors.purple,
                        ),
                      ),
                      title: const Text(
                        'Change Mint',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Current: example.com/mint',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                      onTap: () {
                        // Navigate to mint selection screen
                      },
                    ),
                    const Divider(
                      height: 1,
                      color: Colors.white10,
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.security,
                          color: Colors.blue,
                        ),
                      ),
                      title: const Text(
                        'Backup Wallet',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Last backup: Never',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                      onTap: () {
                        // Backup wallet
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Transaction history
              _buildSectionHeader('Transaction History'),
              const SizedBox(height: 16),
              Card(
                color: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: _transactions.map((transaction) {
                    final bool isDeposit = transaction['type'] == 'deposit';

                    return Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDeposit
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isDeposit ? Icons.add : Icons.wifi,
                              color: isDeposit ? Colors.green : Colors.orange,
                            ),
                          ),
                          title: Text(
                            transaction['network'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            transaction['date'],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            '${isDeposit ? '+' : '-'}${transaction['amount']} sats',
                            style: TextStyle(
                              color: isDeposit ? Colors.green : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_transactions.last['id'] != transaction['id'])
                          const Divider(
                            height: 1,
                            indent: 64,
                            color: Colors.white10,
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // About section
              _buildSectionHeader('About'),
              const SizedBox(height: 16),
              Card(
                color: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.teal,
                        ),
                      ),
                      title: const Text(
                        'About TollGate',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                      onTap: () {
                        // Show about dialog
                      },
                    ),
                    const Divider(
                      height: 1,
                      color: Colors.white10,
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.privacy_tip_outlined,
                          color: Colors.red,
                        ),
                      ),
                      title: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                      onTap: () {
                        // Show privacy policy
                      },
                    ),
                    const Divider(
                      height: 1,
                      color: Colors.white10,
                    ),
                    ListTile(
                      title: Center(
                        child: Text(
                          'Version 0.1.0',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white.withOpacity(0.9),
      ),
    );
  }
}
