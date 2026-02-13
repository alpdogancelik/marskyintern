import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/illustration.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../widgets/settings_widgets.dart';
import 'settings_controller.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'About App',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTokens.space5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTokens.radiusXl),
              gradient: const LinearGradient(
                colors: [Color(0xFF5C30FF), Color(0xFF6D4DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All in one investment platform',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppTokens.space2),
                Text(
                  'Manage crypto, track portfolios, and move funds with a premium secure wallet experience.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marsky App',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppTokens.space2),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppTokens.space2),
                Text(
                  'Built for premium investing experiences with secure authentication and wallet flows.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'Help Center',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTokens.space5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTokens.radiusXl),
              gradient: const LinearGradient(
                colors: [Color(0xFF5C30FF), Color(0xFF6D4DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              'Hi, how can we help?',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(height: AppTokens.space3),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space3),
          SettingsSection(
            title: 'Community',
            children: [
              SettingsMenuTile(
                title: 'Discord',
                iconName: 'community',
                onTap: () => _comingSoon(context),
              ),
              SettingsMenuTile(
                title: 'Telegram',
                iconName: 'announcement',
                onTap: () => _comingSoon(context),
              ),
              SettingsMenuTile(
                title: 'Whatsapp',
                iconName: 'phone',
                onTap: () => _comingSoon(context),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space3),
          AppCard(
            child: Row(
              children: [
                const Expanded(
                  child: Illustration(
                    name: 'man-looking-for-someone-to-help-with-a-question',
                    size: 88,
                    semanticLabel: 'Join team',
                  ),
                ),
                const SizedBox(width: AppTokens.space3),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Join Our Team',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Help us build better finance products.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Coming soon')));
  }
}

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  static const _items = <({String q, String a})>[
    (
      q: 'Why didn\'t I receive the SMS OTP code?',
      a: 'Check your signal, wait 60 seconds, and retry. If still missing, use email verification.'
    ),
    (
      q: 'What is the minimum and maximum amount per sale and purchase?',
      a: 'Limits vary by asset and payment method. You can review exact limits in order preview.'
    ),
    (
      q: 'How long does it take for account verification?',
      a: 'Most verification checks complete within minutes, but some may take up to 24 hours.'
    ),
    (
      q: 'How much is the balance withdrawal fee?',
      a: 'Fees depend on destination and network conditions. The exact fee is shown before confirmation.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: 'FAQ',
      child: AppCard(
        padding: const EdgeInsets.all(AppTokens.space2),
        child: Column(
          children: _items
              .map(
                (item) => ExpansionTile(
                  title: Text(item.q),
                  childrenPadding: const EdgeInsets.fromLTRB(
                    AppTokens.space3,
                    0,
                    AppTokens.space3,
                    AppTokens.space3,
                  ),
                  children: [
                    Text(
                      item.a,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalTextScreen(
      title: 'Privacy Policy',
      content: _privacyText,
    );
  }
}

class TermsConditionScreen extends StatelessWidget {
  const TermsConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalTextScreen(
      title: 'Terms & Condition',
      content: _termsText,
    );
  }
}

class _LegalTextScreen extends StatelessWidget {
  const _LegalTextScreen({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: title,
      child: AppCard(
        child: Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
      ),
    );
  }
}

class ReferralCodeScreen extends ConsumerWidget {
  const ReferralCodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    return SettingsPageScaffold(
      title: 'Referral Program',
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          title: 'Unable to load referral code',
          description: error.toString(),
          illustrationName: 'man-with-a-wrench-can-fix-anything',
          primaryAction: EmptyStateAction(
            label: 'Retry',
            onPressed: () =>
                ref.read(settingsControllerProvider.notifier).load(),
          ),
        ),
        data: (data) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppTokens.space5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusXl),
            gradient: const LinearGradient(
              colors: [Color(0xFF131833), Color(0xFF3D2B9B)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              const Illustration(
                name: 'character-coin-is-the-winner',
                size: 140,
                semanticLabel: 'Referral illustration',
              ),
              const SizedBox(height: AppTokens.space3),
              Text(
                'Invite your friends and win up to 1 Million Dollar',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppTokens.space2),
              Text(
                'Share your referral code and start earning rewards.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
              ),
              const SizedBox(height: AppTokens.space4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.space3,
                  vertical: AppTokens.space2,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.referralCode,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _copyCode(context, data.referralCode),
                      child: const Text('Copy'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.space4),
              PrimaryButton(
                label: 'Invite My Friends',
                onPressed: () => context.push('/account/referral/share'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copyCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Referral code copied')));
  }
}

class ReferralShareScreen extends ConsumerWidget {
  const ReferralShareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);
    final code = state.valueOrNull?.referralCode ?? 'MARSKY-CODE';
    final shareText =
        ref.read(settingsControllerProvider.notifier).referralShareText();

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.32),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppTokens.space4,
                AppTokens.space4,
                AppTokens.space4,
                AppTokens.space5,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Invite your friends',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppTokens.space3),
                  AppCard(
                    padding: const EdgeInsets.all(AppTokens.space3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'I earned rewards using Marsky',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Use referral code $code',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppTokens.space2),
                        Text(
                          shareText,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTokens.space4),
                  PrimaryButton(
                    label: 'Copy Invite Text',
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: shareText));
                      if (!context.mounted) {
                        return;
                      }
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(const SnackBar(
                            content: Text('Invite text copied')));
                    },
                  ),
                  const SizedBox(height: AppTokens.space3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ShareOption(
                        label: 'Whatsapp',
                        icon: Icons.message_outlined,
                        onTap: () => _shareStub(context, 'Whatsapp'),
                      ),
                      _ShareOption(
                        label: 'Telegram',
                        icon: Icons.send_outlined,
                        onTap: () => _shareStub(context, 'Telegram'),
                      ),
                      _ShareOption(
                        label: 'Instagram',
                        icon: Icons.camera_alt_outlined,
                        onTap: () => _shareStub(context, 'Instagram'),
                      ),
                      _ShareOption(
                        label: 'More',
                        icon: Icons.more_horiz_rounded,
                        onTap: () => _shareStub(context, 'More'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareStub(BuildContext context, String target) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$target share coming soon')));
  }
}

class _ShareOption extends StatelessWidget {
  const _ShareOption({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Icon(icon),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

const _privacyText = '''
Last update: 12 October 2022

Marsky is committed to protecting your personal information and maintaining a secure investing environment. We collect account data such as name, email, and preferences to deliver wallet, portfolio, and transaction services.

We use your data to authenticate access, process activity records, and improve reliability. Your information is never sold. We only share data with essential service providers required to operate secure payment and authentication systems.

You can request updates or deletion of personal profile fields by contacting support. Some financial records may be retained to comply with legal obligations.
''';

const _termsText = '''
Last update: 12 October 2022

By using Marsky, you agree to these terms and acknowledge that market data and investment values can fluctuate. You are responsible for safeguarding your credentials and confirming transaction details before submission.

Marsky provides tools for portfolio tracking and simulated financial operations. Certain features may rely on third-party infrastructure and can be updated, limited, or discontinued to maintain security and compliance.

Use of the platform must comply with applicable laws. Misuse, fraud attempts, or unauthorized activity may result in access restrictions.
''';
