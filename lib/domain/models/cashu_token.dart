import 'dart:convert';

/// Represents a Cashu token with all necessary properties
class CashuToken {
  /// The encoded token string (in JSON)
  final String encodedToken;

  /// The token's amount in sats
  final int amount;

  /// The mint URL
  final String mintUrl;

  /// Creates a new CashuToken
  CashuToken({
    required this.encodedToken,
    required this.amount,
    required this.mintUrl,
  });

  /// Creates a token from JSON
  factory CashuToken.fromJson(Map<String, dynamic> json) {
    return CashuToken(
      encodedToken: json['encodedToken'],
      amount: json['amount'],
      mintUrl: json['mintUrl'],
    );
  }

  /// Converts token to JSON
  Map<String, dynamic> toJson() {
    return {
      'encodedToken': encodedToken,
      'amount': amount,
      'mintUrl': mintUrl,
    };
  }

  /// Parse the raw token data
  Map<String, dynamic> get tokenData {
    try {
      return json.decode(encodedToken) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  /// Creates a token from raw token data
  factory CashuToken.fromTokenData(
      String encodedToken, Map<String, dynamic> tokenData, String mintUrl) {
    // Calculate total amount from token data
    int totalAmount = 0;

    // Try to get amount from different possible structures
    try {
      // Check for direct amount property
      if (tokenData.containsKey('amount')) {
        totalAmount = (tokenData['amount'] as num).toInt();
      }
      // Check for tokens array with proofs
      else if (tokenData.containsKey('token')) {
        final List tokenList = tokenData['token'] as List;
        for (final tokenItem in tokenList) {
          if (tokenItem is Map && tokenItem.containsKey('proofs')) {
            final proofs = tokenItem['proofs'] as List;
            for (final proof in proofs) {
              if (proof is Map && proof.containsKey('amount')) {
                totalAmount += (proof['amount'] as num).toInt();
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error parsing token amount: $e');
    }

    return CashuToken(
      encodedToken: encodedToken,
      amount: totalAmount,
      mintUrl: mintUrl,
    );
  }
}
