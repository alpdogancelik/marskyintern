import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/kit/ui_kit.dart';
import '../../../ui/theme/app_tokens.dart';
import '../widgets/sector_widgets.dart';
import 'stocks_market_controller.dart';

class StocksSectorsScreen extends ConsumerWidget {
  const StocksSectorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectorsState = ref.watch(stocksSectorsProvider);

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
                title: 'Market Sectors',
              ),
              const SizedBox(height: AppTokens.space4),
              Expanded(
                child: sectorsState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                    child: PrimaryButton(
                      label: 'Retry',
                      onPressed: () => ref.invalidate(stocksSectorsProvider),
                    ),
                  ),
                  data: (sectors) => ListView(
                    children: [
                      Text(
                        'Top Sectors',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      Wrap(
                        spacing: AppTokens.space2,
                        runSpacing: AppTokens.space2,
                        children: sectors.take(4).map((sector) {
                          return SectorChip(
                            label: sector,
                            onTap: () => context.go('/stocks?sector=$sector'),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppTokens.space5),
                      Text(
                        'All Market Sectors',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: AppTokens.space3),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sectors.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppTokens.space3,
                          mainAxisSpacing: AppTokens.space3,
                          childAspectRatio: 1.5,
                        ),
                        itemBuilder: (context, index) {
                          final sector = sectors[index];
                          return SectorGridItem(
                            label: sector,
                            onTap: () => context.go('/stocks?sector=$sector'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
