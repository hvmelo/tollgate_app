import 'package:flutter/material.dart';
import 'package:tollgate_app/presentation/common/widgets/cards/app_card.dart';

class CurrentBalanceCard extends StatelessWidget {
  const CurrentBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.primary,
      showBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Balance',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '100,000', // TODO: Replace with actual balance
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 4),
              Text(
                'sats',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
