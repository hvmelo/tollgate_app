import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/core_providers.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeMode = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: theme.textTheme.titleLarge),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Theme Settings
            _buildSectionHeader(context, 'Appearance'),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Theme Mode', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 16),
                    RadioListTile<ThemeMode>(
                      title: Text('System Default',
                          style: theme.textTheme.bodyMedium),
                      value: ThemeMode.system,
                      groupValue: themeMode,
                      activeColor: colorScheme.primary,
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(themeNotifierProvider.notifier)
                              .setThemeMode(value);
                        }
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text('Light', style: theme.textTheme.bodyMedium),
                      value: ThemeMode.light,
                      groupValue: themeMode,
                      activeColor: colorScheme.primary,
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(themeNotifierProvider.notifier)
                              .setThemeMode(value);
                        }
                      },
                    ),
                    RadioListTile<ThemeMode>(
                      title: Text('Dark', style: theme.textTheme.bodyMedium),
                      value: ThemeMode.dark,
                      groupValue: themeMode,
                      activeColor: colorScheme.primary,
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(themeNotifierProvider.notifier)
                              .setThemeMode(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Auto-payment settings
            _buildSectionHeader(context, 'Payment Settings'),
            const SizedBox(height: 16),

            // Auto-pay toggle card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Auto-Pay',
                          style: theme.textTheme.titleMedium,
                        ),
                        Switch(
                          value: _autoPayEnabled,
                          onChanged: _toggleAutoPay,
                          activeColor: colorScheme.primary,
                        ),
                      ],
                    ),
                    if (_autoPayEnabled) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Spending Cap',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${_minSpendingCap.toInt()}',
                            style: theme.textTheme.bodySmall,
                          ),
                          Expanded(
                            child: Slider(
                              value: _spendingCap,
                              min: _minSpendingCap,
                              max: _maxSpendingCap,
                              divisions: 9,
                              activeColor: colorScheme.primary,
                              onChanged: (value) {
                                setState(() {
                                  _spendingCap = value;
                                });
                              },
                            ),
                          ),
                          Text(
                            '${_maxSpendingCap.toInt()}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Center(
                        child: Text(
                          '${_spendingCap.toInt()} sats per session',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_spendingCap > 500) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colorScheme.error.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: colorScheme.error,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Setting a high spending cap may deplete your wallet quickly.',
                                  style: TextStyle(
                                    color: colorScheme.error,
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
            _buildSectionHeader(context, 'Cashu Settings'),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: colorScheme.primary,
                      ),
                    ),
                    title:
                        Text('Change Mint', style: theme.textTheme.bodyMedium),
                    trailing: Icon(Icons.chevron_right,
                        color: colorScheme.onSurface.withOpacity(0.5)),
                    onTap: () {
                      // Navigate to mint settings
                    },
                  ),
                  Divider(height: 1, color: theme.dividerColor),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.security,
                        color: colorScheme.primary,
                      ),
                    ),
                    title: Text('Backup Wallet',
                        style: theme.textTheme.bodyMedium),
                    trailing: Icon(Icons.chevron_right,
                        color: colorScheme.onSurface.withOpacity(0.5)),
                    onTap: () {
                      // Navigate to backup settings
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleLarge,
      ),
    );
  }
}
