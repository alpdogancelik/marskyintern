import 'package:flutter/material.dart';

import '../../../ui/kit/app_buttons.dart';
import '../../../ui/theme/app_tokens.dart';

class FilterOption<T> {
  const FilterOption({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

class CommunicationsFilterSheet<T> extends StatefulWidget {
  const CommunicationsFilterSheet({
    super.key,
    required this.title,
    required this.options,
    required this.initialValue,
    this.confirmLabel = 'Done',
  });

  final String title;
  final List<FilterOption<T>> options;
  final T initialValue;
  final String confirmLabel;

  @override
  State<CommunicationsFilterSheet<T>> createState() =>
      _CommunicationsFilterSheetState<T>();
}

class _CommunicationsFilterSheetState<T>
    extends State<CommunicationsFilterSheet<T>> {
  late T _selected = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.of(context).viewInsets.bottom;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.52,
      minChildSize: 0.34,
      maxChildSize: 0.82,
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
                widget.title,
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
                  children: widget.options
                      .map(
                        (option) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppTokens.space2),
                          child: InkWell(
                            onTap: () =>
                                setState(() => _selected = option.value),
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusMd),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTokens.space3,
                                vertical: AppTokens.space3,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius:
                                    BorderRadius.circular(AppTokens.radiusMd),
                                border: Border.all(
                                  color: option.value == _selected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .outlineVariant,
                                  width: option.value == _selected ? 1.4 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Icon(
                                    option.value == _selected
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
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
                  label: widget.confirmLabel,
                  onPressed: () => Navigator.of(context).pop(_selected),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
