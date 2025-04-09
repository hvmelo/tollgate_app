import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tollgate_app/presentation/common/extensions/build_context_x.dart';

import '../../../../../core/result/result.dart';
import '../../../../../domain/wallet/value_objects/send_amount.dart';
import '../controllers/send_screen_notifier.dart';

class SendAmountInputForm extends StatelessWidget {
  final SendScreenNotifier sendScreenNotifier;
  final SendScreenEditingState state;

  const SendAmountInputForm({
    super.key,
    required this.sendScreenNotifier,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    // We create a new FocusNode to manage the input field focus
    final amountFocusNode = FocusNode();

    return Card(
      elevation: 0,
      color: context.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: context.colorScheme.outline.withAlpha(178),
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          autovalidateMode: state.showErrorMessages
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount to Send',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Custom amount input field
              Container(
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_upward_rounded,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        focusNode: amountFocusNode,
                        initialValue: state.amount.value.toString(),
                        onChanged: (value) {
                          sendScreenNotifier.amountChanged(value);
                        },
                        validator: (_) {
                          final validationResult =
                              sendScreenNotifier.validateAmount();

                          return switch (validationResult) {
                            Ok() => null,
                            Failure(failure: final error) => switch (error) {
                                SendAmountTooLarge(:final maxAmount) =>
                                  context.l10n.mintScreenAmountTooLarge(
                                      maxAmount.toString()),
                                SendAmountNegativeOrZero() =>
                                  context.l10n.mintScreenAmountNegativeOrZero,
                              },
                          };
                        },
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: context.textTheme.headlineSmall?.copyWith(
                            color: context.colorScheme.onSurface.withAlpha(100),
                            fontWeight: FontWeight.bold,
                          ),
                          suffixText: 'sats',
                          suffixStyle: context.textTheme.titleMedium?.copyWith(
                            color: context.colorScheme.onSurface.withAlpha(100),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: state.isPreparingSend
                      ? null
                      : () {
                          sendScreenNotifier.prepareSend();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.isPreparingSend
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
