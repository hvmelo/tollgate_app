import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/services/payment/payment_service.dart';
import '../../data/services/service_factory.dart';
import '../../domain/models/tollgate_info.dart';
import '../utils/result.dart';
import 'tollgate_provider.dart';

// Provider for the payment service
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return ServiceFactory().getPaymentService();
});

// State for payment process
enum PaymentStatus {
  initial,
  processing,
  success,
  failure,
}

class PaymentState {
  final PaymentStatus status;
  final String? errorMessage;
  final PaymentResponse? paymentResponse;

  const PaymentState({
    this.status = PaymentStatus.initial,
    this.errorMessage,
    this.paymentResponse,
  });

  PaymentState copyWith({
    PaymentStatus? status,
    String? errorMessage,
    PaymentResponse? paymentResponse,
  }) {
    return PaymentState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      paymentResponse: paymentResponse ?? this.paymentResponse,
    );
  }

  bool get isProcessing => status == PaymentStatus.processing;
  bool get isSuccess => status == PaymentStatus.success;
  bool get isFailure => status == PaymentStatus.failure;
}

// Provider for handling payment process
final paymentStateProvider =
    StateNotifierProvider<PaymentStateNotifier, PaymentState>((ref) {
  return PaymentStateNotifier(ref);
});

class PaymentStateNotifier extends StateNotifier<PaymentState> {
  final Ref _ref;

  PaymentStateNotifier(this._ref) : super(const PaymentState());

  /// Process payment for Tollgate access
  Future<void> processPayment(
      {required TollgateInfo tollgateInfo, required int timeMinutes}) async {
    state = state.copyWith(status: PaymentStatus.processing);

    final paymentService = _ref.read(paymentServiceProvider);
    final result = await paymentService.payForAccess(
      tollgateInfo: tollgateInfo,
      timeMinutes: timeMinutes,
    );

    result.when(
      onSuccess: (response) {
        state = state.copyWith(
          status: PaymentStatus.success,
          paymentResponse: response,
          errorMessage: null,
        );

        // Update Tollgate state with payment information
        _ref.read(tollgateStateNotifierProvider.notifier).setPayment(
              isPaid: true,
              expiresAt: response.expiresAt,
              amountPaidSats: response.amountPaid,
            );
      },
      onFailure: (error) {
        state = state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: error.message,
        );
      },
    );
  }

  /// Reset payment state
  void reset() {
    state = const PaymentState();
  }

  /// Verify if a payment is still valid
  Future<bool> verifyPayment() async {
    if (state.paymentResponse == null) {
      return false;
    }

    final paymentService = _ref.read(paymentServiceProvider);
    final result =
        await paymentService.verifyPayment(state.paymentResponse!.receiptId);

    return result.fold(
      (isValid) => isValid,
      (_) => false, // On failure, return false
    );
  }
}
