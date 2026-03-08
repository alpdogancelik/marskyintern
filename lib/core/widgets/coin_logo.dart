import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../media/asset_resolver.dart';

enum CoinLogoVariant { primary, v2, v3 }

class CoinLogo extends StatefulWidget {
  const CoinLogo({
    super.key,
    required this.symbol,
    this.iconUrl,
    this.size = 24,
    this.variant = CoinLogoVariant.primary,
    this.semanticLabel,
  });

  final String symbol;
  final String? iconUrl;
  final double size;
  final CoinLogoVariant variant;
  final String? semanticLabel;

  static const List<double> supportedSizes = <double>[16, 20, 24, 32, 48];

  @override
  State<CoinLogo> createState() => _CoinLogoState();
}

class _CoinLogoState extends State<CoinLogo> {
  static final Map<String, Future<String?>> _resolvedPathCache =
      <String, Future<String?>>{};
  static final Map<String, Future<bool>> _assetExistsCache =
      <String, Future<bool>>{};

  Future<String?> _resolvePath() {
    final variantNumber = widget.variant.index + 1;
    final symbolKey = widget.symbol.trim().toUpperCase();
    final cacheKey = '$symbolKey#$variantNumber';

    return _resolvedPathCache.putIfAbsent(cacheKey, () async {
      final resolver = AssetResolver.cached ?? await AssetResolver.load();
      final primary = resolver.resolveCoin(widget.symbol);
      final fallback = resolver.resolveIcon('coin');
      final requested = resolver.resolveCoinVariant(
        widget.symbol,
        variant: variantNumber,
      );

      final candidates = <String>{
        if (variantNumber > 1) requested,
        primary,
        fallback,
      };

      for (final candidate in candidates) {
        if (await _assetExists(candidate)) {
          return candidate;
        }
      }

      return null;
    });
  }

  static Future<bool> _assetExists(String path) {
    return _assetExistsCache.putIfAbsent(path, () async {
      try {
        await rootBundle.load(path);
        return true;
      } catch (_) {
        return false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final resolvedSize = _normalizeSize(widget.size);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.35);
    final semanticLabel = widget.semanticLabel ?? '${widget.symbol} logo';
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    return SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.surface,
          border: isDark ? Border.all(color: borderColor, width: 0.8) : null,
        ),
        child: ClipOval(
          child: FutureBuilder<String?>(
            future: _resolvePath(),
            builder: (context, snapshot) {
              final loaded = snapshot.connectionState == ConnectionState.done;
              final child = loaded
                  ? _ResolvedAsset(
                      path: snapshot.data,
                      networkUrl: widget.iconUrl,
                      size: resolvedSize,
                      semanticLabel: semanticLabel,
                    )
                  : _CoinSkeleton(size: resolvedSize);

              return AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 160),
                child: child,
              );
            },
          ),
        ),
      ),
    );
  }

  double _normalizeSize(double value) {
    var best = CoinLogo.supportedSizes.first;
    var bestDelta = (value - best).abs();
    for (final candidate in CoinLogo.supportedSizes.skip(1)) {
      final delta = (value - candidate).abs();
      if (delta < bestDelta) {
        best = candidate;
        bestDelta = delta;
      }
    }
    return best;
  }
}

class _CoinSkeleton extends StatelessWidget {
  const _CoinSkeleton({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('coin-skeleton'),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
    );
  }
}

class _ResolvedAsset extends StatelessWidget {
  const _ResolvedAsset({
    required this.path,
    required this.networkUrl,
    required this.size,
    required this.semanticLabel,
  });

  final String? path;
  final String? networkUrl;
  final double size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      Icons.monetization_on_outlined,
      key: const ValueKey<String>('coin-fallback-icon'),
      size: size * 0.62,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    final localPath = path;
    final remoteUrl = networkUrl?.trim();
    final hasRemoteUrl = remoteUrl != null && remoteUrl.isNotEmpty;

    Widget child;
    if (localPath != null && localPath.toLowerCase().endsWith('.svg')) {
      child = SvgPicture.asset(
        localPath,
        key: ValueKey<String>('coin-svg:$localPath'),
        width: size,
        height: size,
        fit: BoxFit.cover,
        semanticsLabel: semanticLabel,
      );
    } else if (localPath != null) {
      child = Image.asset(
        localPath,
        key: ValueKey<String>('coin-raster:$localPath'),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    } else if (hasRemoteUrl) {
      child = Image.network(
        remoteUrl,
        key: ValueKey<String>('coin-network:$remoteUrl'),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    } else {
      child = fallback;
    }

    return Semantics(
      label: semanticLabel,
      image: true,
      child: child,
    );
  }
}
