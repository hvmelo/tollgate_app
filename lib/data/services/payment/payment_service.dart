import 'package:flutter/foundation.dart';

import '../../../core/utils/result.dart';
import '../../../domain/models/tollgate_info.dart';

class PaymentError {
  final String message;

  const PaymentError(this.message);

  @override
  String toString() => message;
}

class PaymentResponse {
  final DateTime expiresAt;
  final int amountPaid;
  final String receiptId;

  PaymentResponse({
    required this.expiresAt,
    required this.amountPaid,
    required this.receiptId,
  });
}

abstract class PaymentService {
  /// Make a payment for Tollgate access
  Future<Result<PaymentResponse, PaymentError>> payForAccess({
    required TollgateInfo tollgateInfo,
    required int timeMinutes,
  });

  /// Check if a payment is still valid
  Future<Result<bool, PaymentError>> verifyPayment(String receiptId);
}

class LivePaymentService implements PaymentService {
  @override
  Future<Result<PaymentResponse, PaymentError>> payForAccess({
    required TollgateInfo tollgateInfo,
    required int timeMinutes,
  }) async {
    try {
      // In a real implementation, this would:
      // 1. Generate a payment request from the Cashu mint
      // 2. Process payment via the wallet
      // 3. Submit payment proof to the Tollgate
      // 4. Receive confirmation of access

      // This is placeholder implementation
      throw UnimplementedError('LivePaymentService not yet implemented');
    } catch (e) {
      debugPrint('Payment error: $e');
      return Failure(PaymentError('Payment failed: ${e.toString()}'));
    }
  }

  @override
  Future<Result<bool, PaymentError>> verifyPayment(String receiptId) async {
    try {
      // In a real implementation, this would:
      // 1. Send the receipt ID to the Tollgate
      // 2. Verify if the payment is still valid

      // This is placeholder implementation
      throw UnimplementedError('LivePaymentService not yet implemented');
    } catch (e) {
      debugPrint('Verification error: $e');
      return Failure(PaymentError('Failed to verify payment: ${e.toString()}'));
    }
  }
}

class MockPaymentService implements PaymentService {
  final bool _shouldSucceed;
  final Duration _delay;

  MockPaymentService({
    bool shouldSucceed = true,
    Duration delay = const Duration(milliseconds: 500),
  })  : _shouldSucceed = shouldSucceed,
        _delay = delay;

  @override
  Future<Result<PaymentResponse, PaymentError>> payForAccess({
    required TollgateInfo tollgateInfo,
    required int timeMinutes,
  }) async {
    await Future.delayed(_delay);

    if (!_shouldSucceed) {
      return Failure(PaymentError('Payment failed (mock)'));
    }

    // Calculate price based on Tollgate info
    final priceInSats = tollgateInfo.calculatePrice(timeMinutes * 60);

    // Create a mock response
    final response = PaymentResponse(
      expiresAt: DateTime.now().add(Duration(minutes: timeMinutes)),
      amountPaid: priceInSats,
      receiptId: 'mock-receipt-${DateTime.now().millisecondsSinceEpoch}',
    );

    return Success(response);
  }

  @override
  Future<Result<bool, PaymentError>> verifyPayment(String receiptId) async {
    await Future.delayed(_delay);

    if (!_shouldSucceed) {
      return Failure(PaymentError('Verification failed (mock)'));
    }

    // In a mock implementation, we just assume the payment is valid
    return const Success(true);
  }
}
