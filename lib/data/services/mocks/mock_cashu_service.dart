import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/cashu_token.dart';
import '../cashu_wallet/cashu_service.dart';

/// Mock implementation of the CashuService for development environments
class MockCashuService implements CashuService {
  static const String _mockTokensKey = 'mock_cashu_tokens';
  static const String _mockBalanceKey = 'mock_cashu_balance';
  final _uuid = const Uuid();
  final Random _random = Random();
  final Map<String, String> _mints = {};

  int _balance = 0;
  final String _defaultMintUrl = 'https://test-mint.tollgate.network';

  @override
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load mock balance
      _balance = prefs.getInt(_mockBalanceKey) ??
          1000; // Start with 1000 sats in development

      // Register default mint
      _mints[_defaultMintUrl] = 'dev-keyset-${_uuid.v4().substring(0, 8)}';
    } catch (e) {
      debugPrint('Error initializing Mock Cashu service: $e');
    }
  }

  @override
  Future<bool> checkMintStatus(String mintUrl) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true; // Always succeed in dev mode
  }

  @override
  Future<String?> connectToMint(String mintUrl) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!_mints.containsKey(mintUrl)) {
      _mints[mintUrl] = 'dev-keyset-${_uuid.v4().substring(0, 8)}';
    }

    return _mints[mintUrl];
  }

  @override
  Future<CashuToken> validateToken(String encodedToken, String mintUrl) async {
    await Future.delayed(const Duration(milliseconds: 700));

    try {
      // Connect to mint if not already connected
      final keysetId = await connectToMint(mintUrl);
      if (keysetId == null) {
        throw Exception('Failed to connect to mint');
      }

      // Try to parse token - this will fail if the token is invalid
      Map<String, dynamic> tokenData;
      try {
        tokenData = jsonDecode(encodedToken);
      } catch (e) {
        throw Exception('Invalid token format');
      }

      // For mock, extract the amount from the token or generate a random one
      int amount = 0;
      if (tokenData.containsKey('token') &&
          tokenData['token'] is List &&
          tokenData['token'].isNotEmpty) {
        final token = tokenData['token'][0];
        if (token.containsKey('proofs') &&
            token['proofs'] is List &&
            token['proofs'].isNotEmpty) {
          amount = token['proofs'][0]['amount'] ?? _random.nextInt(500) + 100;
        } else {
          amount = _random.nextInt(500) + 100;
        }
      } else {
        amount = _random.nextInt(500) + 100;
      }

      // Update the balance
      await _updateBalance(amount);

      return CashuToken.fromTokenData(encodedToken, tokenData, mintUrl);
    } catch (e) {
      throw Exception('Failed to validate token: $e');
    }
  }

  @override
  Future<CashuToken> createToken(int amount, String mintUrl) async {
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Check balance
      if (amount > _balance) {
        throw Exception('Insufficient balance');
      }

      // Update balance
      await _updateBalance(-amount);

      // Create a mock token with a UUID
      final tokenId = _uuid.v4();
      final tokenData = {
        'token': [
          {
            'mint': mintUrl,
            'proofs': [
              {
                'id': tokenId,
                'amount': amount,
                'secret': '${_uuid.v4()}${_uuid.v4()}'.substring(0, 32),
              }
            ]
          }
        ]
      };

      // Encode the token
      final encodedToken = jsonEncode(tokenData);

      return CashuToken.fromTokenData(encodedToken, tokenData, mintUrl);
    } catch (e) {
      throw Exception('Failed to create token: $e');
    }
  }

  @override
  Future<bool> redeemToken(CashuToken token) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Always succeed in dev mode
  }

  @override
  Future<List<CashuToken>> getSavedTokens() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return []; // No saved tokens in mock mode
  }

  @override
  Future<bool> saveToken(CashuToken token) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true; // Always succeed
  }

  @override
  Future<bool> removeToken(CashuToken token) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true; // Always succeed
  }

  // Helper method to update the balance and save it
  Future<void> _updateBalance(int amount) async {
    _balance += amount;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_mockBalanceKey, _balance);
    } catch (e) {
      debugPrint('Error saving mock balance: $e');
    }
  }
}
