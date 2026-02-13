import 'package:flutter/material.dart';

import '../../../ui/theme/app_tokens.dart';

class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    super.key,
    required this.onKeyTap,
    required this.onBackspace,
  });

  final ValueChanged<String> onKeyTap;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final buttons = [
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
      itemCount: buttons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppTokens.space2,
        crossAxisSpacing: AppTokens.space2,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        final key = buttons[index];
        if (key == 'backspace') {
          return _KeyButton(
            onTap: onBackspace,
            semanticLabel: 'Backspace',
            child: const Icon(Icons.backspace_outlined),
          );
        }

        return _KeyButton(
          onTap: () => onKeyTap(key),
          semanticLabel: key == '.' ? 'Decimal point' : 'Number $key',
          child: Text(
            key,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        );
      },
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.child,
    required this.onTap,
    required this.semanticLabel,
  });

  final Widget child;
  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            border:
                Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: child,
        ),
      ),
    );
  }
}
