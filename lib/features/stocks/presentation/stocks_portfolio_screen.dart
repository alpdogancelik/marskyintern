import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import 'stocks_market_controller.dart';

class StocksPortfolioScreen extends ConsumerWidget {
  const StocksPortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holdingsState = ref.watch(stocksHoldingsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.pageHorizontalPadding,
            AppTokens.space3,
            AppTokens.pageHorizontalPadding,
            AppTokens.space4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTopBar(
                leading: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                ),
                title: 'Stock Portfolio',
                trailing: IconButton(
                  onPressed: () => context.push('/stocks/history'),
                  icon: const Icon(Icons.history_rounded),
                ),
              ),
              const SizedBox(height: AppTokens.space4),
              holdingsState.when(
                loading: () => const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => Expanded(
                  child: Center(
                    child: PrimaryButton(
                      label: 'Retry',
                      onPressed: () => ref.invalidate(stocksHoldingsProvider),
                    ),
                  ),
                ),
                data: (holdings) {
                  final total = holdings.fold<double>(
                    0,
                    (sum, item) => sum + item.marketValue,
                  );
                  return Expanded(
                    child: ListView(
                      children: [
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total portfolio value',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: AppTokens.space2),
                              Text(
                                '\$${total.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: AppTokens.space4),
                              SizedBox(
                                height: 110,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _AllocationRing(
                                        values: holdings
                                            .map((item) =>
                                                item.allocationPercent)
                                            .toList(growable: false),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: holdings.take(3).map((item) {
                                          return Text(
                                            '${item.symbol} ${item.allocationPercent.toStringAsFixed(0)}%',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTokens.space5),
                        Text(
                          'Holdings',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        const SizedBox(height: AppTokens.space3),
                        ...holdings.map((item) {
                          final pnlColor = item.pnlValue >= 0
                              ? const Color(0xFF11B26A)
                              : const Color(0xFFD9435A);
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppTokens.space3),
                            child: AppCard(
                              padding: const EdgeInsets.all(AppTokens.space3),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item.symbol,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '\$${item.marketValue.toStringAsFixed(2)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.quantity.toStringAsFixed(2)} shares',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: item.allocationPercent / 100,
                                    minHeight: 6,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'PnL ${item.pnlValue >= 0 ? '+' : ''}\$${item.pnlValue.toStringAsFixed(2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: pnlColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: AppTokens.space3),
                        PrimaryButton(
                          label: 'Buy Stock',
                          onPressed: () => context.push('/stocks'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AllocationRing extends StatelessWidget {
  const _AllocationRing({
    required this.values,
  });

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RingPainter(values: values),
      child: const SizedBox(width: 96, height: 96),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.values});

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;
    const palette = [
      Color(0xFF6D4DFF),
      Color(0xFF4F8DFF),
      Color(0xFF11B26A),
      Color(0xFFFFB545),
    ];

    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / 100) * math.pi * 2;
      final paint = Paint()
        ..color = palette[i % palette.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep + 0.04;
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
