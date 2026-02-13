import 'package:flutter/material.dart';

import '../../../ui/kit/app_buttons.dart';
import '../../../ui/theme/app_tokens.dart';
import '../presentation/activity_controller.dart';

class ActivityFilterResult {
  const ActivityFilterResult({
    required this.typeFilter,
    required this.statusFilter,
  });

  final ActivityTypeFilter typeFilter;
  final ActivityStatusFilter statusFilter;
}

class ActivityFilterSheet extends StatefulWidget {
  const ActivityFilterSheet({
    super.key,
    required this.initialType,
    required this.initialStatus,
  });

  final ActivityTypeFilter initialType;
  final ActivityStatusFilter initialStatus;

  @override
  State<ActivityFilterSheet> createState() => _ActivityFilterSheetState();
}

class _ActivityFilterSheetState extends State<ActivityFilterSheet> {
  late ActivityTypeFilter _type = widget.initialType;
  late ActivityStatusFilter _status = widget.initialStatus;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.68,
      minChildSize: 0.44,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: AppTokens.space4),
              Text(
                'Filter History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppTokens.space2),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppTokens.space4),
                  children: [
                    const _SectionTitle('Type'),
                    const SizedBox(height: AppTokens.space2),
                    Wrap(
                      spacing: AppTokens.space2,
                      runSpacing: AppTokens.space2,
                      children: ActivityTypeFilter.values.map((value) {
                        return ChoiceChip(
                          label: Text(_typeLabel(value)),
                          selected: _type == value,
                          onSelected: (_) => setState(() => _type = value),
                        );
                      }).toList(growable: false),
                    ),
                    const SizedBox(height: AppTokens.space5),
                    const _SectionTitle('Status'),
                    const SizedBox(height: AppTokens.space2),
                    Wrap(
                      spacing: AppTokens.space2,
                      runSpacing: AppTokens.space2,
                      children: ActivityStatusFilter.values.map((value) {
                        return ChoiceChip(
                          label: Text(_statusLabel(value)),
                          selected: _status == value,
                          onSelected: (_) => setState(() => _status = value),
                        );
                      }).toList(growable: false),
                    ),
                    const SizedBox(height: AppTokens.space8),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppTokens.space4,
                  AppTokens.space3,
                  AppTokens.space4,
                  AppTokens.space3 + inset,
                ),
                child: PrimaryButton(
                  label: 'Apply',
                  onPressed: () => Navigator.of(context).pop(
                    ActivityFilterResult(
                        typeFilter: _type, statusFilter: _status),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _typeLabel(ActivityTypeFilter filter) {
    return switch (filter) {
      ActivityTypeFilter.all => 'All',
      ActivityTypeFilter.buy => 'Buy',
      ActivityTypeFilter.sell => 'Sell',
      ActivityTypeFilter.deposit => 'Deposit',
      ActivityTypeFilter.withdraw => 'Withdraw',
    };
  }

  String _statusLabel(ActivityStatusFilter filter) {
    return switch (filter) {
      ActivityStatusFilter.all => 'All',
      ActivityStatusFilter.completed => 'Completed',
      ActivityStatusFilter.pending => 'Pending',
    };
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }
}
