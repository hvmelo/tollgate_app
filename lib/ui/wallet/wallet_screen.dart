import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/cashu_token.dart';
import '../../core/providers/wallet_provider.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  final TextEditingController _tokenController = TextEditingController();
  bool _isImporting = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshWallet,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(walletState),
    );
  }

  Widget _buildBody(WalletState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBalanceCard(state),
            const SizedBox(height: 24),
            _buildActions(),
            const SizedBox(height: 32),
            _buildTransactionHistory(state),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WalletState state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Current Balance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              '${state.balance}',
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const Text(
              'sats',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 16),
              Text(
                state.error!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.add,
                  label: 'Add Funds',
                  onTap: _showAddFundsDialog,
                ),
                _buildActionButton(
                  icon: Icons.send,
                  label: 'Send',
                  onTap: _showSendDialog,
                ),
                _buildActionButton(
                  icon: Icons.qr_code,
                  label: 'Scan',
                  onTap: () => context.push('/mint'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(WalletState state) {
    if (state.transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transaction History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.transactions.length,
          itemBuilder: (context, index) {
            final transaction = state.transactions[index];
            return ListTile(
              leading: Icon(
                transaction.isIncoming
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: transaction.isIncoming ? Colors.green : Colors.red,
              ),
              title: Text(transaction.description),
              subtitle: Text(transaction.formattedDate),
              trailing: Text(
                '${transaction.isIncoming ? '+' : '-'}${transaction.amount} sats',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: transaction.isIncoming ? Colors.green : Colors.red,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _showAddFundsDialog() async {
    _tokenController.clear();

    return showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Funds'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Paste a Cashu token to redeem:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tokenController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'cashuABC123...',
                        labelText: 'Cashu Token',
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                    const SizedBox(height: 16),
                    if (_isImporting)
                      const Center(child: CircularProgressIndicator())
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isImporting = true;
                              });
                              _importToken().then((_) {
                                Navigator.of(context).pop();
                              }).catchError((_) {
                                setState(() {
                                  _isImporting = false;
                                });
                              });
                            },
                            child: const Text('Import'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showSendDialog() async {
    final walletState = ref.read(walletProvider);
    if (walletState.balance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have no funds to send'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final TextEditingController amountController = TextEditingController();
    CashuToken? token;
    bool isCreating = false;

    return showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Send Sats'),
              content: token == null
                  ? SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'How many sats do you want to send?',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: amountController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Amount (sats)',
                              hintText: '100',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (isCreating)
                            const Center(child: CircularProgressIndicator())
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (amountController.text.isEmpty) return;
                                    final amount = int.parse(
                                      amountController.text,
                                    );
                                    if (amount <= 0 ||
                                        amount > walletState.balance) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Invalid amount. Please try again.',
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      isCreating = true;
                                    });

                                    try {
                                      final generatedToken = await ref
                                          .read(walletProvider.notifier)
                                          .createToken(amount);
                                      setState(() {
                                        token = generatedToken;
                                        isCreating = false;
                                      });
                                    } catch (e) {
                                      setState(() {
                                        isCreating = false;
                                      });
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Create Token'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Token Created!'),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(
                              token!.encodedToken,
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: token!.encodedToken),
                                  ).then((_) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Token copied to clipboard',
                                        ),
                                      ),
                                    );
                                  });
                                },
                                icon: const Icon(Icons.copy),
                                label: const Text('Copy'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Done'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            );
          },
        );
      },
    ).then((_) {
      amountController.dispose();
    });
  }

  Future<void> _refreshWallet() async {
    final walletNotifier = ref.read(walletProvider.notifier);
    await walletNotifier.refreshWallet();
  }

  Future<void> _importToken() async {
    final walletNotifier = ref.read(walletProvider.notifier);

    if (_tokenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a token'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await walletNotifier.importToken(_tokenController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token successfully imported!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }
}
