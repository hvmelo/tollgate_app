import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tollgate_app/presentation/common/extensions/build_context_x.dart';
import 'package:tollgate_app/presentation/router/routes.dart';

import '../widgets/balance_card.dart';
import 'controllers/reserve_screen_notifier.dart';
import 'widgets/widgets.dart';

class ReserveScreen extends ConsumerWidget {
  const ReserveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reserveScreenStateAsync = ref.watch(reserveScreenNotifierProvider);

    void handleReserveComplete() {
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
          'Reserve',
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
            child: switch (reserveScreenStateAsync) {
              AsyncData(:final value) => _buildUI(
                  reserveScreenNotifier:
                      ref.read(reserveScreenNotifierProvider.notifier),
                  value: value,
                  handleReserveComplete: handleReserveComplete,
                ),
              AsyncError(:final error) => ErrorWidget(error),
              _ => SizedBox(
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      AppBar().preferredSize.height -
                      32, // Account for padding
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUI({
    required ReserveScreenNotifier reserveScreenNotifier,
    required ReserveScreenState value,
    required VoidCallback handleReserveComplete,
  }) {
    return Column(
      children: [
        const BalanceCard(),
        const SizedBox(height: 24),
        switch (value) {
          ReserveScreenEditingState() => ReserveAmountInputForm(
              state: value,
              reserveScreenNotifier: reserveScreenNotifier,
            ),
          ReserveScreenConfirmingState() => ReserveConfirmationDisplay(
              state: value,
              reserveScreenNotifier: reserveScreenNotifier,
            ),
          ReserveScreenCompleteState(:final token) => ReserveCompleteDisplay(
              token: token,
              onClose: handleReserveComplete,
            ),
        },
      ],
    );
  }
}
