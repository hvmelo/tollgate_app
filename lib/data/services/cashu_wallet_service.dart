import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../domain/models/cashu_token.dart';
import '../../domain/models/cashu_wallet.dart';
import 'cashu_service.dart';

/// Service for managing Cashu wallet operations
class CashuWalletService {
  static const String _storageKey = 'cashu_wallet';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final CashuService _cashuService = CashuService();

  /// Initialize the wallet service
  Future<CashuWallet> initializeWallet([String? initialMintUrl]) async {
    try {
      // We've created a mock implementation that doesn't require loading from storage
      return CashuWallet(
        cashuService: _cashuService,
        mintUrl: initialMintUrl ?? 'https://8333.space:3338',
      );
    } catch (e) {
      // If any error occurs, return a new wallet
      return CashuWallet(
        cashuService: _cashuService,
        mintUrl: initialMintUrl ?? 'https://8333.space:3338',
      );
    }
  }

  /// Save the wallet to secure storage
  Future<void> saveWallet(CashuWallet wallet) async {
    // Our mock implementation handles saving tokens internally
    // This method is kept for API compatibility
  }

  /// Get a Lightning invoice for minting new tokens
  Future<MintingInfo> requestMintInvoice(String mintUrl, int amount) async {
    try {
      // Prepare the request URL
      final url = '$mintUrl/mint?amount=$amount';

      // Request the invoice from the mint
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to get mint invoice: ${response.statusCode}');
      }

      // Parse the response
      final Map<String, dynamic> data = json.decode(response.body);

      // Extract the invoice and offer ID
      final String invoice = data['pr'] as String;
      final String offerId = data['id'] as String;

      // Generate blinded secrets for later minting
      final blindedSecrets = _generateBlindedSecrets(amount);

      return MintingInfo(
        invoice: invoice,
        offerId: offerId,
        amount: amount,
        blindedSecrets: blindedSecrets,
      );
    } catch (e) {
      throw Exception('Error requesting mint invoice: $e');
    }
  }

  /// Mint tokens once the invoice has been paid
  Future<List<CashuToken>> mintTokens(
    String mintUrl,
    MintingInfo mintingInfo,
  ) async {
    try {
      // Prepare the request URL and data
      final url = '$mintUrl/mint';

      // Prepare the request body
      final body = {
        'id': mintingInfo.offerId,
        'outputs': mintingInfo.blindedSecrets,
      };

      // Send the minting request
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mint tokens: ${response.statusCode}');
      }

      // Parse the response
      final Map<String, dynamic> data = json.decode(response.body);

      // This is a simplified version - in a real implementation,
      // we would properly unblind the signatures from the mint
      // For now, we'll simulate tokens being created

      // Create tokens
      final List<CashuToken> tokens = [];

      // In a real implementation, we would use the proper denominations
      // based on the mint's response. Here we simplify with just one token
      // of the full amount.

      // Create mock token data
      final tokenData = _createMockTokenData(mintingInfo.amount, mintUrl);

      // Create the token using our CashuToken class
      final token = CashuToken(
        encodedToken: json.encode(tokenData),
        amount: mintingInfo.amount,
        mintUrl: mintUrl,
      );

      tokens.add(token);

      return tokens;
    } catch (e) {
      throw Exception('Error minting tokens: $e');
    }
  }

  /// Get token proofs for spending from the wallet
  List<String> prepareTokensForSpending(List<CashuToken> tokens) {
    // In a real implementation, we would prepare the tokens properly
    // For now, we'll just return the encoded token strings
    return tokens.map((token) => token.encodedToken).toList();
  }

  /// Check if an invoice has been paid
  Future<bool> checkInvoiceStatus(String mintUrl, String offerId) async {
    try {
      // Prepare the request URL
      final url = '$mintUrl/check?id=$offerId';

      // Check the status
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        return false;
      }

      // Parse the response
      final Map<String, dynamic> data = json.decode(response.body);

      // Return true if the invoice has been paid
      return data['paid'] as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Helper method to generate blinded secrets for minting
  /// This is a simplified placeholder for what would be real crypto operations
  List<Map<String, dynamic>> _generateBlindedSecrets(int amount) {
    // In a real implementation, this would use proper cryptography
    // For now, we'll just create dummy data
    final random = Random.secure();
    final secrets = <Map<String, dynamic>>[];

    // Generate a secret for the entire amount
    final secret = List<int>.generate(32, (_) => random.nextInt(256));
    final secretHex = _bytesToHex(secret);

    // In a real implementation, this would be properly blinded
    final blindedSecret = sha256.convert(utf8.encode(secretHex)).toString();

    secrets.add({'amount': amount, 'secret': blindedSecret});

    return secrets;
  }

  /// Helper method to create mock token data
  Map<String, dynamic> _createMockTokenData(int amount, String mintUrl) {
    // In a real implementation, this would be a proper token structure
    // For now, we'll just create a JSON object with some data
    final tokenData = {
      'token': [
        {
          'mint': mintUrl,
          'proofs': [
            {
              'id': const Uuid().v4(),
              'amount': amount,
              'secret': _bytesToHex(
                List<int>.generate(32, (_) => Random.secure().nextInt(256)),
              ),
            }
          ]
        }
      ]
    };

    return tokenData;
  }

  /// Helper method to convert bytes to hex string
  String _bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}

/// Class to hold information during the minting process
class MintingInfo {
  final String invoice;
  final String offerId;
  final int amount;
  final List<Map<String, dynamic>> blindedSecrets;

  MintingInfo({
    required this.invoice,
    required this.offerId,
    required this.amount,
    required this.blindedSecrets,
  });
}
