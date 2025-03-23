import 'dart:async';

import 'cashu_token.dart';
import '../../data/services/cashu_wallet/cashu_service.dart';

/// A mock implementation of a Cashu wallet
class CashuWallet {
  final CashuService _cashuService;
  final String? mintUrl;
  final List<CashuToken> _tokens = [];
  int _balance = 0;

  /// StreamController for balance updates
  final _balanceController = StreamController<int>.broadcast();

  /// StreamController for tokens updates
  final _tokensController = StreamController<List<CashuToken>>.broadcast();

  /// Stream of balance updates
  Stream<int> get balanceStream => _balanceController.stream;

  /// Stream of tokens updates
  Stream<List<CashuToken>> get tokensStream => _tokensController.stream;

  /// Current balance
  int get balance => _balance;

  /// Current tokens
  List<CashuToken> get tokens => List.unmodifiable(_tokens);

  /// Creates a new CashuWallet
  CashuWallet({
    required CashuService cashuService,
    this.mintUrl,
  }) : _cashuService = cashuService {
    _initialize();
  }

  /// Initialize the wallet
  Future<void> _initialize() async {
    try {
      // Initialize the service
      await _cashuService.init();

      // Load tokens if mint URL is set
      if (mintUrl != null) {
        await refreshWallet();
      }
    } catch (e) {
      print('Error initializing wallet: $e');
    }
  }

  /// Refresh the wallet
  Future<void> refreshWallet() async {
    try {
      // Get saved tokens
      final savedTokens = await _cashuService.getSavedTokens();

      // Filter tokens by mint URL if provided
      final walletTokens = mintUrl != null
          ? savedTokens.where((token) => token.mintUrl == mintUrl).toList()
          : savedTokens;

      // Update tokens and balance
      _tokens.clear();
      _tokens.addAll(walletTokens);

      // Calculate balance
      _balance = _tokens.fold(0, (sum, token) => sum + token.amount);

      // Notify listeners
      _balanceController.add(_balance);
      _tokensController.add(_tokens);
    } catch (e) {
      print('Error refreshing wallet: $e');
    }
  }

  /// Add a token to the wallet
  Future<bool> addToken(CashuToken token) async {
    try {
      // Save token
      final success = await _cashuService.saveToken(token);

      if (success) {
        // Add to local tokens
        _tokens.add(token);
        _balance += token.amount;

        // Notify listeners
        _balanceController.add(_balance);
        _tokensController.add(_tokens);
      }

      return success;
    } catch (e) {
      print('Error adding token: $e');
      return false;
    }
  }

  /// Remove a token from the wallet
  Future<bool> removeToken(CashuToken token) async {
    try {
      // Remove token
      final success = await _cashuService.removeToken(token);

      if (success) {
        // Remove from local tokens
        _tokens.removeWhere((t) => t.encodedToken == token.encodedToken);
        _balance -= token.amount;

        // Notify listeners
        _balanceController.add(_balance);
        _tokensController.add(_tokens);
      }

      return success;
    } catch (e) {
      print('Error removing token: $e');
      return false;
    }
  }

  /// Validate and add a token to the wallet
  Future<bool> importToken(String encodedToken) async {
    if (mintUrl == null) {
      throw Exception('No mint URL set. Set a mint URL first.');
    }

    try {
      // Validate token
      final token = await _cashuService.validateToken(encodedToken, mintUrl!);

      // Add token to wallet
      return await addToken(token);
    } catch (e) {
      print('Error importing token: $e');
      return false;
    }
  }

  /// Create a new token
  Future<CashuToken?> createToken(int amount) async {
    if (mintUrl == null) {
      throw Exception('No mint URL set. Set a mint URL first.');
    }

    if (amount <= 0) {
      throw Exception('Amount must be greater than 0');
    }

    if (amount > _balance) {
      throw Exception('Insufficient balance');
    }

    try {
      // Create token
      final token = await _cashuService.createToken(amount, mintUrl!);

      // Remove amount from balance (token is being sent out)
      _balance -= amount;

      // Notify listeners
      _balanceController.add(_balance);

      return token;
    } catch (e) {
      print('Error creating token: $e');
      return null;
    }
  }

  /// Redeem a token
  Future<bool> redeemToken(CashuToken token) async {
    try {
      return await _cashuService.redeemToken(token);
    } catch (e) {
      print('Error redeeming token: $e');
      return false;
    }
  }

  /// Dispose the wallet
  void dispose() {
    _balanceController.close();
    _tokensController.close();
  }
}
