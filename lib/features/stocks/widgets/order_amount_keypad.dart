import 'package:flutter/material.dart';

import '../../../ui/theme/app_tokens.dart';

class OrderAmountKeypad extends StatelessWidget {
  const OrderAmountKeypad({
    super.key,
    required this.onKeyTap,
    required this.onBackspace,
  });

  final ValueChanged<String> onKeyTap;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    const keys = <String>[
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '.',
      '0',
      'backspace',
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        final key = keys[index];
        final isBackspace = key == 'backspace';
        return Padding(
          padding: const EdgeInsets.all(6),
          child: InkWell(
            onTap: isBackspace ? onBackspace : () => onKeyTap(key),
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              alignment: Alignment.center,
              child: isBackspace
                  ? const Icon(Icons.backspace_outlined)
                  : Text(
                      key,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
