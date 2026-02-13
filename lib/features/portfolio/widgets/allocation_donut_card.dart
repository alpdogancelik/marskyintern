import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../ui/kit/app_card.dart';
import '../../../ui/theme/app_tokens.dart';
import '../domain/entities/allocation_slice.dart';

class AllocationDonutCard extends StatelessWidget {
  const AllocationDonutCard({
    super.key,
    required this.slices,
    required this.totalValue,
  });

  final List<AllocationSlice> slices;
  final double totalValue;

  @override
  Widget build(BuildContext context) {
    final colors = _palette;
    return AppCard(
      padding: const EdgeInsets.all(AppTokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Allocation',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppTokens.space3),
          Row(
            children: [
              SizedBox(
                width: 138,
                height: 138,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 42,
                    sectionsSpace: 2,
                    sections: slices.asMap().entries.map((entry) {
                      final index = entry.key;
                      final slice = entry.value;
                      return PieChartSectionData(
                        color: colors[index % colors.length],
                        value: slice.value,
                        title: '${slice.percent.toStringAsFixed(0)}%',
                        titleStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        radius: 20,
                      );
                    }).toList(growable: false),
                  ),
                ),
              ),
              const SizedBox(width: AppTokens.space4),
              Expanded(
                child: Column(
                  children: slices.asMap().entries.map((entry) {
                    final index = entry.key;
                    final slice = entry.value;
                    final color = colors[index % colors.length];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppTokens.space2),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(width: AppTokens.space2),
                          Expanded(
                            child: Text(
                              slice.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          Text(
                            '${slice.percent.toStringAsFixed(1)}%',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                          ),
                        ],
                      ),
                    );
                  }).toList(growable: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _palette = [
    Color(0xFF5E5CE6),
    Color(0xFF0A84FF),
    Color(0xFF30B0C7),
    Color(0xFF34C759),
    Color(0xFFFF9F0A),
  ];
}
