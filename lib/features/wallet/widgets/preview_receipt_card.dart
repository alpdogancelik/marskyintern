import 'package:flutter/material.dart';

import '../../../ui/kit/app_card.dart';
import '../../../ui/theme/app_tokens.dart';

class PreviewReceiptField {
  const PreviewReceiptField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class PreviewReceiptCard extends StatelessWidget {
  const PreviewReceiptCard({
    super.key,
    required this.title,
    required this.amountText,
    required this.fields,
    required this.totalText,
  });

  final String title;
  final String amountText;
  final List<PreviewReceiptField> fields;
  final String totalText;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppTokens.space3),
          Text(
            amountText,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space4),
          ...fields.map(
            (field) => Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      field.label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    field.value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTokens.space3),
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: AppTokens.space3),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total amount',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                totalText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
