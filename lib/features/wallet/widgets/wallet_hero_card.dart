import 'package:flutter/material.dart';

import '../../../core/widgets/app_icon.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/wallet_balance.dart';
import 'wallet_formatters.dart';

class WalletHeroCard extends StatelessWidget {
  const WalletHeroCard({
    super.key,
    required this.balance,
    required this.onTapDeposit,
    required this.onTapWithdraw,
    required this.onTapSend,
    required this.onTapReceive,
  });

  final WalletBalance balance;
  final VoidCallback onTapDeposit;
  final VoidCallback onTapWithdraw;
  final VoidCallback onTapSend;
  final VoidCallback onTapReceive;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTokens.space5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF612EFF),
            const Color(0xFF6D4DFF),
            colors.primary.withValues(alpha: 0.86),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'USD Balance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                ),
          ),
          const SizedBox(height: AppTokens.space2),
          Text(
            formatUsd(balance.available),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            'Pending ${formatUsd(balance.pending)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.76),
                ),
          ),
          const SizedBox(height: AppTokens.space4),
          Row(
            children: [
              Expanded(
                child: _ActionIconButton(
                  iconName: 'wallet',
                  label: 'Deposit',
                  onTap: onTapDeposit,
                ),
              ),
              Expanded(
                child: _ActionIconButton(
                  iconName: 'bank',
                  label: 'Withdraw',
                  onTap: onTapWithdraw,
                ),
              ),
              Expanded(
                child: _ActionIconButton(
                  iconName: 'money-transfer-between-wallets',
                  label: 'Send',
                  onTap: onTapSend,
                ),
              ),
              Expanded(
                child: _ActionIconButton(
                  iconName: 'payment-machine',
                  label: 'Receive',
                  onTap: onTapReceive,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.iconName,
    required this.label,
    required this.onTap,
  });

  final String iconName;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTokens.space2),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                ),
                child: Center(
                  child: AppIcon(
                    name: iconName,
                    semanticLabel: label,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
