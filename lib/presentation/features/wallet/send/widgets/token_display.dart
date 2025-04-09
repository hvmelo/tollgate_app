import 'package:cdk_flutter/cdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tollgate_app/presentation/common/widgets/buttons/app_button.dart';
import 'package:tollgate_app/presentation/common/widgets/qr_code/qr_code_card.dart';
import 'package:tollgate_app/presentation/common/widgets/snackbar/app_snackbar.dart';

class TokenDisplay extends StatelessWidget {
  final Token token;
  final VoidCallback onClose;

  const TokenDisplay({
    super.key,
    required this.token,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Send ${token.amount.toString()} sats',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        QrCodeCard(data: token.encoded),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                token.encoded,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: token.encoded));
                AppSnackBar.showSuccess(
                  context,
                  message: 'Token copied to clipboard',
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        AppButton(
          label: 'Close',
          variant: AppButtonVariant.cancel,
          onPressed: onClose,
        ),
      ],
    );
  }
}
