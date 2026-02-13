import 'package:flutter/material.dart';

import '../../../ui/kit/app_buttons.dart';
import '../../../ui/theme/app_tokens.dart';

Future<void> showDownloadReportSheet(BuildContext context) async {
  String selected = 'PDF';

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      final inset = MediaQuery.of(context).viewInsets.bottom;
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              AppTokens.space4,
              AppTokens.space2,
              AppTokens.space4,
              AppTokens.space4 + inset,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTokens.space2),
                Text(
                  'Download Reports',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppTokens.space2),
                Text(
                  'Choose format for your transaction report.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppTokens.space4),
                Wrap(
                  spacing: AppTokens.space2,
                  children: ['PDF', 'CSV'].map((format) {
                    return ChoiceChip(
                      label: Text(format),
                      selected: selected == format,
                      onSelected: (_) => setState(() => selected = format),
                    );
                  }).toList(growable: false),
                ),
                const SizedBox(height: AppTokens.space5),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppTokens.space3),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Download',
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                  content:
                                      Text('$selected report coming soon')),
                            );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
