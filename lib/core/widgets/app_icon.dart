import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../media/asset_resolver.dart';

enum AppIconTone { defaultTone, secondary, success, danger }

class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.name,
    required this.semanticLabel,
    this.size = 24,
    this.tone = AppIconTone.defaultTone,
  });

  final String name;
  final String semanticLabel;
  final double size;
  final AppIconTone tone;

  static const List<double> supportedSizes = <double>[20, 24];
  static final Map<String, Future<String>> _pathCache = <String, Future<String>>{};

  Future<String> _resolvePath() {
    final key = name.trim().toLowerCase();
    return _pathCache.putIfAbsent(key, () async {
      final resolver = AssetResolver.cached ?? await AssetResolver.load();
      return resolver.resolveIcon(name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final resolvedSize = _normalizeSize(size);
    final color = _toneColor(context, tone);
    return FutureBuilder<String>(
      future: _resolvePath(),
      builder: (context, snapshot) {
        final content = switch (snapshot.connectionState) {
          ConnectionState.done => _ResolvedIconAsset(
              path: snapshot.data ?? 'lib/media/svg/icons/icon.svg',
              color: color,
              size: resolvedSize,
            ),
          _ => SizedBox(
              key: const ValueKey<String>('app-icon-skeleton'),
              width: resolvedSize,
              height: resolvedSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(resolvedSize * 0.2),
                ),
              ),
            ),
        };

        return Semantics(
          label: semanticLabel,
          image: true,
          child: AnimatedSwitcher(
            duration:
                reduceMotion ? Duration.zero : const Duration(milliseconds: 120),
            child: content,
          ),
        );
      },
    );
  }

  double _normalizeSize(double value) {
    var best = supportedSizes.first;
    var bestDelta = (value - best).abs();
    for (final candidate in supportedSizes.skip(1)) {
      final delta = (value - candidate).abs();
      if (delta < bestDelta) {
        best = candidate;
        bestDelta = delta;
      }
    }
    return best;
  }

  Color _toneColor(BuildContext context, AppIconTone tone) {
    final scheme = Theme.of(context).colorScheme;
    return switch (tone) {
      AppIconTone.defaultTone => scheme.onSurface,
      AppIconTone.secondary => scheme.onSurfaceVariant,
      AppIconTone.success => Colors.green.shade700,
      AppIconTone.danger => scheme.error,
    };
  }
}

class _ResolvedIconAsset extends StatelessWidget {
  const _ResolvedIconAsset({
    required this.path,
    required this.color,
    required this.size,
  });

  final String path;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        key: ValueKey<String>('app-icon-svg:$path'),
        width: size,
        height: size,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    }

    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: Image.asset(
        path,
        key: ValueKey<String>('app-icon-raster:$path'),
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.image_not_supported_outlined,
          size: size,
          color: color,
        ),
      ),
    );
  }
}
