import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/toll_gate_response.dart';
import '../../domain/models/wifi_network.dart';
import '../../core/providers/wallet_provider.dart';
import '../../core/providers/wifi_connection_provider.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? networkData;

  const ConnectionScreen({
    super.key,
    this.networkData,
  });

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  bool _isRefreshing = false;
  bool _isConnected = false;
  bool _autoPayEnabled = false;
  final int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    // Simulate connection process
    _connectToNetwork();
  }

  Future<void> _connectToNetwork() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network connection
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _isConnected = true;
    });
  }

  Future<void> _refreshStatus() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate status refresh
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });
  }

  void _toggleAutoPay(bool value) {
    setState(() {
      _autoPayEnabled = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Auto-pay enabled. Your session will be extended automatically.'
              : 'Auto-pay disabled.',
        ),
        backgroundColor: value ? Colors.green : Colors.blueGrey,
      ),
    );
  }

  String _formatRemainingTime() {
    if (_remainingSeconds <= 0) {
      return 'No time remaining';
    }

    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final networkData = widget.networkData ??
        {
          'ssid': 'Unknown Network',
          'price': 'N/A',
          'strength': 0,
          'verified': false,
          'isTollGate': false,
        };

    final bool isVerified = networkData['verified'] ?? false;
    final String ssid = networkData['ssid'] ?? 'Unknown Network';
    final String price = networkData['price'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Connection Status'),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshStatus,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
          } else if (index == 2) {
            context.push('/wallet');
          } else if (index == 3) {
            context.push('/settings');
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Network details card
                Card(
                  color: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: _isConnected
                          ? Colors.green.withOpacity(0.5)
                          : Colors.orange.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _isConnected
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _isConnected ? Icons.wifi : Icons.wifi_off,
                                color:
                                    _isConnected ? Colors.green : Colors.orange,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        ssid,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (isVerified) ...[
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.verified,
                                          size: 16,
                                          color: _isConnected
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _isConnected
                                        ? 'Connected'
                                        : 'Connecting...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _isConnected
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          height: 32,
                          color: Colors.white24,
                        ),
                        // Network details
                        _buildInfoRow('Current Price', price),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Remaining Time',
                          _remainingSeconds > 0
                              ? _formatRemainingTime()
                              : 'No active session',
                        ),
                        if (_remainingSeconds > 0) ...[
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value:
                                  _remainingSeconds / 300, // Assuming 5 min max
                              minHeight: 8,
                              backgroundColor: Colors.white12,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF65D36E),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Auto-pay toggle
                Card(
                  color: Colors.white.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _autoPayEnabled
                                ? const Color(0xFF65D36E).withOpacity(0.1)
                                : Colors.blueGrey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.schedule,
                            color: _autoPayEnabled
                                ? const Color(0xFF65D36E)
                                : Colors.blueGrey,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Auto-Pay',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Automatically extend your session when it expires',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _autoPayEnabled,
                          onChanged: _toggleAutoPay,
                          activeColor: const Color(0xFF65D36E),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Buy internet button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        context.push('/payment', extra: networkData),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF65D36E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text(
                      'Buy Internet',
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
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
