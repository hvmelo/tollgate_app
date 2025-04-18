import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tollgate_app/core/result/result.dart';
import 'package:tollgate_app/presentation/common/extensions/build_context_x.dart';

import '../../../../../domain/wallet/value_objects/mint_amount.dart';
import '../controllers/mint_screen_notifier.dart';

class AmountInputForm extends HookWidget {
  final MintScreenNotifier mintScreenNotifier;
  final MintScreenEditingState state;

  const AmountInputForm({
    super.key,
    required this.mintScreenNotifier,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final amountFocusNode = useFocusNode();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDarkMode
          ? context.colorScheme.primary.withAlpha(25)
          : const Color(0xFFFAFAFA),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          autovalidateMode: state.showErrorMessages
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    context.l10n.mintScreenAmountInSatsLabel,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(),
              // Custom amount input field
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? context.colorScheme.surface
                      : context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bolt,
                        color: Colors.green,
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
                        initialValue: state.amount.toString(),
                        onChanged: (value) {
                          mintScreenNotifier.amountChanged(value);
                        },
                        validator: (_) {
                          final validationResult =
                              mintScreenNotifier.validateAmount();

                          return switch (validationResult) {
                            Ok() => null,
                            Failure(failure: final error) => switch (error) {
                                MintAmountTooLarge(:final maxAmount) =>
                                  context.l10n.mintScreenAmountTooLarge(
                                      maxAmount.toString()),
                                MintAmountNegativeOrZero() =>
                                  context.l10n.mintScreenAmountNegativeOrZero,
                              },
                          };
                        },
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : null,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDarkMode
                              ? context.colorScheme.surface
                              : context.colorScheme.surfaceContainerHighest,
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
                  onPressed: () {
                    mintScreenNotifier.generateInvoice();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.primary,
                    foregroundColor: context.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.mintScreenCreateInvoice,
                    style: const TextStyle(
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
