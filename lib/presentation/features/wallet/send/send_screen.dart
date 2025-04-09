import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tollgate_app/presentation/common/extensions/build_context_x.dart';
import 'package:tollgate_app/presentation/router/routes.dart';

import '../widgets/balance_card.dart';
import 'controllers/send_screen_notifier.dart';
import 'widgets/widgets.dart'; // Import the barrel file

class SendScreen extends ConsumerWidget {
  const SendScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sendScreenStateAsync = ref.watch(sendScreenNotifierProvider);

    void handleCloseToken() {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(Routes.wallet);
      }
    }

    return Scaffold(
      backgroundColor: context.colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Send',
          style: TextStyle(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: context.colorScheme.onSurface,
        ),
      ),
      extendBodyBehindAppBar: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: switch (sendScreenStateAsync) {
              AsyncData(:final value) => _buildUI(
                  sendScreenNotifier:
                      ref.read(sendScreenNotifierProvider.notifier),
                  value: value,
                  handleCloseToken: handleCloseToken,
                ),
              AsyncError(:final error) => ErrorWidget(error),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUI({
    required SendScreenNotifier sendScreenNotifier,
    required SendScreenState value,
    required void Function() handleCloseToken,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display the current balance card
        const BalanceCard(),
        const SizedBox(height: 24),
        // Display the correct widget based on the state
        switch (value) {
          SendScreenEditingState() => SendAmountInputForm(
              sendScreenNotifier: sendScreenNotifier,
              state: value,
            ),
          SendScreenConfirmingState() => SendConfirmationDisplay(
              state: value,
              sendScreenNotifier: sendScreenNotifier, // Pass the notifier
            ),
          SendScreenTokenState() => TokenDisplay(
              token: value.token,
              onClose: handleCloseToken,
            ),
        },
      ],
    );
  }
}
