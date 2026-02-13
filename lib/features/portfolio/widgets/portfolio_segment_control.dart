import 'package:flutter/material.dart';

import '../../../ui/kit/app_card.dart';
import '../../../ui/theme/app_tokens.dart';

class PortfolioSegmentControl extends StatelessWidget {
  const PortfolioSegmentControl({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space2),
      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment(value: 0, label: Text('Crypto')),
          ButtonSegment(value: 1, label: Text('Stocks')),
        ],
        selected: {selectedIndex},
        onSelectionChanged: (value) => onChanged(value.first),
      ),
    );
  }
}
