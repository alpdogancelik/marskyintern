import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/kit/coin_avatar.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/recipient.dart';
import 'wallet_controller.dart';
import '../widgets/wallet_flow_scaffold.dart';

class WalletTransferRecipientsScreen extends ConsumerWidget {
  const WalletTransferRecipientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletControllerProvider);

    return WalletFlowScaffold(
      title: 'Address Book',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (value) => ref
                .read(walletControllerProvider.notifier)
                .setRecipientQuery(value),
            decoration: InputDecoration(
              hintText: 'Search recipient',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          Text(
            'Favorites',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space2),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.recipients.length.clamp(0, 4),
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppTokens.space3),
              itemBuilder: (context, index) {
                final recipient = state.recipients[index];
                return _FavoriteRecipientChip(
                  recipient: recipient,
                  onTap: () {
                    ref
                        .read(walletControllerProvider.notifier)
                        .selectRecipient(recipient);
                    context.push('/wallet/transfer/preview');
                  },
                );
              },
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          Text(
            'All Contacts',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space2),
          ...state.filteredRecipients.map(
            (recipient) => Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: _RecipientRow(
                recipient: recipient,
                onTap: () {
                  ref
                      .read(walletControllerProvider.notifier)
                      .selectRecipient(recipient);
                  context.push('/wallet/transfer/preview');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteRecipientChip extends StatelessWidget {
  const _FavoriteRecipientChip({
    required this.recipient,
    required this.onTap,
  });

  final Recipient recipient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(AppTokens.space3),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colors.surfaceContainerLow,
              child: CoinAvatar(
                symbol: recipient.avatarSymbol ?? 'USDT',
                size: 24,
              ),
            ),
            const SizedBox(height: AppTokens.space2),
            Text(
              recipient.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipientRow extends StatelessWidget {
  const _RecipientRow({
    required this.recipient,
    required this.onTap,
  });

  final Recipient recipient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space3,
          vertical: AppTokens.space3,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: colors.surfaceContainerLow,
              child: Text(
                recipient.name.isNotEmpty ? recipient.name[0] : '?',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: AppTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipient.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    recipient.handle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
