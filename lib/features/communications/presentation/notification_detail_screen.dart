import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/empty_state.dart';
import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/notification_item.dart';
import '../widgets/notification_detail_card.dart';
import 'notifications_controller.dart';

class NotificationDetailScreen extends ConsumerStatefulWidget {
  const NotificationDetailScreen({
    super.key,
    required this.notificationId,
  });

  final String notificationId;

  @override
  ConsumerState<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends ConsumerState<NotificationDetailScreen> {
  NotificationItem? _item;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final controller = ref.read(notificationsControllerProvider.notifier);
    await controller.markRead(widget.notificationId);
    final item = await controller.getById(widget.notificationId);
    if (!mounted) {
      return;
    }
    setState(() {
      _item = item;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final item = _item;
    if (item == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        body: SafeArea(
          child: EmptyState(
            title: 'Notification not found',
            description: 'This notification may have been removed.',
            illustrationName: 'managing-money',
            primaryAction: EmptyStateAction(
              label: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.pageHorizontalPadding,
            AppTokens.space3,
            AppTokens.pageHorizontalPadding,
            AppTokens.space6,
          ),
          child: Column(
            children: [
              AppTopBar(
                leading: IconButton(
                  tooltip: 'Back',
                  constraints: const BoxConstraints.tightFor(
                    width: AppTokens.minTapTarget,
                    height: AppTokens.minTapTarget,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                title: 'Notifications',
                trailing: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert_rounded),
                ),
              ),
              const SizedBox(height: AppTokens.space6),
              NotificationDetailCard(
                title: _titleFor(item),
                body: _bodyFor(item),
                buttonLabel: 'Verify Email',
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('Verification sent')),
                    );
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  String _titleFor(NotificationItem item) {
    return item.type == NotificationType.emailVerified
        ? 'Verify your email'
        : item.title;
  }

  String _bodyFor(NotificationItem item) {
    if (item.type == NotificationType.emailVerified) {
      return 'Hi, your registration is almost complete. Verify your email to continue with secure account access.';
    }
    return item.body;
  }
}
