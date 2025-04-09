import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tollgate_app/presentation/common/extensions/build_context_x.dart';
import 'package:tollgate_app/presentation/common/widgets/buttons/app_button.dart';

import '../controllers/send_screen_notifier.dart';

class SendConfirmationDisplay extends StatelessWidget {
  final SendScreenConfirmingState state;
  final SendScreenNotifier sendScreenNotifier;

  const SendConfirmationDisplay({
    super.key,
    required this.state,
    required this.sendScreenNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount = state.preparedSend.amount + state.preparedSend.fee;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm Send',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(context, 'Amount:',
                '${state.preparedSend.amount.toString()} sats'),
            const SizedBox(height: 8),
            _buildDetailRow(
                context, 'Fee:', '${state.preparedSend.fee.toString()} sats'),
            const Divider(height: 32),
            _buildDetailRow(
              context,
              'Total:',
              '${totalAmount.toString()} sats',
              isTotal: true,
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Generate Token',
              onPressed: () {
                sendScreenNotifier.generateToken();
              },
              isLoading: state.isGeneratingToken,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Cancel',
              variant: AppButtonVariant.cancel,
              onPressed: () {
                context.pop(); // Go back to editing state
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value,
      {bool isTotal = false}) {
    final textStyle = isTotal
        ? context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : context.textTheme.bodyLarge;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text(value, style: textStyle),
      ],
    );
  }
}
