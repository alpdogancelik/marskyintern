import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../ui/kit/app_card.dart';
import '../../../ui/theme/app_tokens.dart';
import 'activity_formatters.dart';

class ActivitySummaryCard extends StatelessWidget {
  const ActivitySummaryCard({
    super.key,
    required this.incoming,
    required this.outgoing,
  });

  final double incoming;
  final double outgoing;

  @override
  Widget build(BuildContext context) {
    final total = incoming + outgoing;
    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space4),
      child: Row(
        children: [
          SizedBox(
            width: 116,
            height: 116,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 30,
                sectionsSpace: 3,
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFF16B46E),
                    value: incoming <= 0 ? 0.0001 : incoming,
                    title: '',
                    radius: 18,
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFDA4159),
                    value: outgoing <= 0 ? 0.0001 : outgoing,
                    title: '',
                    radius: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppTokens.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppTokens.space2),
                Text(
                  'Total volume',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  formatUsd(total),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppTokens.space3),
                _LegendRow(
                  color: const Color(0xFF16B46E),
                  label: 'Incoming',
                  value: formatUsd(incoming),
                ),
                const SizedBox(height: 6),
                _LegendRow(
                  color: const Color(0xFFDA4159),
                  label: 'Outgoing',
                  value: formatUsd(outgoing),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppTokens.space2),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
