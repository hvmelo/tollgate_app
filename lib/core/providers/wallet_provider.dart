import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/cashu_token.dart';
import '../../domain/models/wallet_transaction.dart';
import '../../data/services/cashu_wallet/cashu_service.dart';
import '../../data/services/service_factory.dart';

part 'wallet_provider.g.dart';

// Wallet state
class WalletState {
  final int balance;
  final List<WalletTransaction> transactions;
  final bool isLoading;
  final String? error;
  final String? mintUrl;

  WalletState({
    this.balance = 0,
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.mintUrl,
  });

  WalletState copyWith({
    int? balance,
    List<WalletTransaction>? transactions,
    bool? isLoading,
    String? error,
    String? mintUrl,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      mintUrl: mintUrl ?? this.mintUrl,
    );
  }
}

@Riverpod(keepAlive: true)
class Wallet extends _$Wallet {
  late final CashuService _cashuService;
  final _uuid = const Uuid();

  @override
  WalletState build() {
    // Get the appropriate service implementation
    _cashuService = ServiceFactory().getCashuService();

    _initialize();
    return WalletState(isLoading: true);
  }

  Future<void> _initialize() async {
    try {
      await _loadWalletData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize wallet: $e',
      );
    }
  }

  Future<void> _loadWalletData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load mint URL
    final mintUrl = prefs.getString('mintUrl');

    // Load transactions
    final transactionsJson = prefs.getString('transactions') ?? '[]';
    final List<dynamic> transactionsData = jsonDecode(transactionsJson);
    final transactions = transactionsData
        .map((data) => WalletTransaction.fromJson(data))
        .toList();

    // Calculate balance
    final balance = transactions.fold(
      0,
      (sum, tx) => tx.isIncoming ? sum + tx.amount : sum - tx.amount,
    );

    // Sort transactions by timestamp (newest first)
    transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    state = state.copyWith(
      balance: balance,
      transactions: transactions,
      isLoading: false,
      mintUrl: mintUrl,
    );
  }

  Future<void> _saveWalletData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save transactions
    final transactionsJson = jsonEncode(
      state.transactions.map((tx) => tx.toJson()).toList(),
    );
    await prefs.setString('transactions', transactionsJson);

    // Save mint URL
    if (state.mintUrl != null) {
      await prefs.setString('mintUrl', state.mintUrl!);
    }
  }

  Future<void> refreshWallet() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _loadWalletData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to refresh wallet: $e',
      );
    }
  }

  Future<void> connectToMint(String mintUrl) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Check if the mint is accessible
      await _cashuService.checkMintStatus(mintUrl);

      // Save the mint URL
      state = state.copyWith(mintUrl: mintUrl, isLoading: false);

      await _saveWalletData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to connect to mint: $e',
      );
      rethrow;
    }
  }

  Future<void> importToken(String encodedToken) async {
    if (state.mintUrl == null) {
      throw Exception('No mint connected. Please connect to a mint first.');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Validate the token
      final tokenInfo = await _cashuService.validateToken(
        encodedToken,
        state.mintUrl!,
      );

      // Create a transaction record
      final transaction = WalletTransaction(
        id: _uuid.v4(),
        amount: tokenInfo.amount,
        description: 'Token import',
        timestamp: DateTime.now(),
        isIncoming: true,
        tokenId: encodedToken,
      );

      // Update state with new transaction
      final newTransactions = [transaction, ...state.transactions];

      state = state.copyWith(
        balance: state.balance + tokenInfo.amount,
        transactions: newTransactions,
        isLoading: false,
      );

      await _saveWalletData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to import token: $e',
      );
      rethrow;
    }
  }

  Future<CashuToken> createToken(int amount) async {
    if (state.mintUrl == null) {
      throw Exception('No mint connected. Please connect to a mint first.');
    }

    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    if (amount > state.balance) {
      throw Exception('Insufficient balance');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Create token
      final token = await _cashuService.createToken(amount, state.mintUrl!);

      // Create a transaction record
      final transaction = WalletTransaction(
        id: _uuid.v4(),
        amount: amount,
        description: 'Token sent',
        timestamp: DateTime.now(),
        isIncoming: false,
        tokenId: token.encodedToken,
      );

      // Update state with new transaction
      final newTransactions = [transaction, ...state.transactions];

      state = state.copyWith(
        balance: state.balance - amount,
        transactions: newTransactions,
        isLoading: false,
      );

      await _saveWalletData();

      return token;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create token: $e',
      );
      rethrow;
    }
  }

  Future<bool> makePayment(int amount) async {
    if (state.mintUrl == null) {
      throw Exception('No mint connected');
    }

    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    if (amount > state.balance) {
      throw Exception('Insufficient balance');
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 1));

      // Create a transaction record
      final transaction = WalletTransaction(
        id: _uuid.v4(),
        amount: amount,
        description: 'Wi-Fi access payment',
        timestamp: DateTime.now(),
        isIncoming: false,
      );

      // Update state with new transaction
      final newTransactions = [transaction, ...state.transactions];

      state = state.copyWith(
        balance: state.balance - amount,
        transactions: newTransactions,
        isLoading: false,
      );

      await _saveWalletData();

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Payment failed: $e');
      return false;
    }
  }
}
