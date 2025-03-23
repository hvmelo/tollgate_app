import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/cashu_token.dart';

/// Service to interact with Cashu mints
class CashuService {
  static const String _mintsKey = 'cashu_mints';
  static const String _tokensKey = 'cashu_tokens';
  final _uuid = const Uuid();
  final Map<String, String> _mints = {}; // mintUrl -> keysetId

  /// Initialize the service and load any saved mints
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mintsJson = prefs.getString(_mintsKey);

      if (mintsJson != null) {
        final mintsList = jsonDecode(mintsJson) as List;
        for (final mintData in mintsList) {
          final mintUrl = mintData['url'] as String;
          if (mintData.containsKey('keysetId')) {
            _mints[mintUrl] = mintData['keysetId'] as String;
          } else {
            await _fetchMintKeys(mintUrl);
          }
        }
      }
    } catch (e) {
      debugPrint('Error initializing Cashu service: $e');
    }
  }

  /// Check if a mint is accessible
  Future<bool> checkMintStatus(String mintUrl) async {
    try {
      final response = await http.get(Uri.parse('$mintUrl/keys'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Fetch keys from a mint
  Future<String?> _fetchMintKeys(String mintUrl) async {
    try {
      final response = await http.get(Uri.parse('$mintUrl/keys'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('keysets')) {
          final keysets = data['keysets'] as List;
          if (keysets.isNotEmpty) {
            final keysetId = keysets[0] as String;
            _mints[mintUrl] = keysetId;
            await _saveMints();
            return keysetId;
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error fetching mint keys: $e');
      return null;
    }
  }

  /// Connect to a mint and return its keyset ID
  Future<String?> connectToMint(String mintUrl) async {
    try {
      // Check if mint is accessible
      final isAvailable = await checkMintStatus(mintUrl);
      if (!isAvailable) {
        throw Exception('Mint is not available');
      }

      // Get or fetch the keyset ID
      if (_mints.containsKey(mintUrl)) {
        return _mints[mintUrl];
      } else {
        return await _fetchMintKeys(mintUrl);
      }
    } catch (e) {
      throw Exception('Failed to connect to mint: $e');
    }
  }

  /// Save the current list of mints
  Future<void> _saveMints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mintsList = _mints.entries
          .map((entry) => {
                'url': entry.key,
                'keysetId': entry.value,
              })
          .toList();

      await prefs.setString(_mintsKey, jsonEncode(mintsList));
    } catch (e) {
      debugPrint('Error saving mints: $e');
    }
  }

  /// Validate a token
  Future<CashuToken> validateToken(String encodedToken, String mintUrl) async {
    try {
      // Connect to mint if not already connected
      final keysetId = await connectToMint(mintUrl);
      if (keysetId == null) {
        throw Exception('Failed to connect to mint');
      }

      // In a real implementation, we would validate with the mint
      // For this demo, we'll parse the token and trust it

      try {
        // Parse token data
        final tokenData = json.decode(encodedToken);

        // Create a CashuToken
        return CashuToken.fromTokenData(encodedToken, tokenData, mintUrl);
      } catch (e) {
        debugPrint('Error parsing token: $e');
        throw Exception('Failed to parse token');
      }
    } catch (e) {
      throw Exception('Failed to validate token: $e');
    }
  }

  /// Create a new token
  Future<CashuToken> createToken(int amount, String mintUrl) async {
    try {
      // Connect to mint if not already connected
      final keysetId = await connectToMint(mintUrl);
      if (keysetId == null) {
        throw Exception('Failed to connect to mint');
      }

      // In a real implementation, we would request blind signatures from the mint
      // For this demo, we'll create a mock token structure

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
      final encodedToken = json.encode(tokenData);

      // Create a CashuToken
      return CashuToken.fromTokenData(encodedToken, tokenData, mintUrl);
    } catch (e) {
      throw Exception('Failed to create token: $e');
    }
  }

  /// Redeem a token
  Future<bool> redeemToken(CashuToken token) async {
    try {
      // In a real implementation, we would send the token to the mint for redemption
      // For this demo, we'll just simulate success

      await Future.delayed(const Duration(milliseconds: 500));

      // Return success (95% of the time for realism)
      return (DateTime.now().millisecondsSinceEpoch % 100) < 95;
    } catch (e) {
      debugPrint('Error redeeming token: $e');
      return false;
    }
  }

  /// Get saved tokens
  Future<List<CashuToken>> getSavedTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokensJson = prefs.getString(_tokensKey);

      if (tokensJson != null) {
        final tokensList = jsonDecode(tokensJson) as List;
        return tokensList
            .map((tokenData) =>
                CashuToken.fromJson(Map<String, dynamic>.from(tokenData)))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error getting saved tokens: $e');
      return [];
    }
  }

  /// Save a token
  Future<bool> saveToken(CashuToken token) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing tokens
      final tokens = await getSavedTokens();

      // Add the new token
      tokens.add(token);

      // Save all tokens
      final tokensList = tokens.map((t) => t.toJson()).toList();
      await prefs.setString(_tokensKey, jsonEncode(tokensList));

      return true;
    } catch (e) {
      debugPrint('Error saving token: $e');
      return false;
    }
  }

  /// Remove a token
  Future<bool> removeToken(CashuToken token) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing tokens
      final tokens = await getSavedTokens();

      // Remove the token
      tokens.removeWhere((t) => t.encodedToken == token.encodedToken);

      // Save the remaining tokens
      final tokensList = tokens.map((t) => t.toJson()).toList();
      await prefs.setString(_tokensKey, jsonEncode(tokensList));

      return true;
    } catch (e) {
      debugPrint('Error removing token: $e');
      return false;
    }
  }
}
