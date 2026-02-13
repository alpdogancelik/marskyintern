import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../media/asset_resolver.dart';

class Illustration extends StatefulWidget {
  const Illustration({
    super.key,
    required this.name,
    this.size = 176,
    this.semanticLabel,
  });

  final String name;
  final double size;
  final String? semanticLabel;

  static final Map<String, Future<String>> _pathCache = <String, Future<String>>{};

  @override
  State<Illustration> createState() => _IllustrationState();
}

class _IllustrationState extends State<Illustration> {
  bool _canLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_canLoad) {
      return;
    }

    final shouldDefer = Scrollable.recommendDeferredLoadingForContext(context);
    if (!shouldDefer) {
      _canLoad = true;
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _canLoad = true);
    });
  }

  Future<String> _resolvePath() {
    final key = widget.name.trim().toLowerCase();
    return Illustration._pathCache.putIfAbsent(key, () async {
      final resolver = AssetResolver.cached ?? await AssetResolver.load();
      return resolver.resolveIllustration(widget.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final semanticLabel = widget.semanticLabel ?? '${widget.name} illustration';

    if (!_canLoad) {
      return _IllustrationPlaceholder(size: widget.size);
    }

    return RepaintBoundary(
      child: FutureBuilder<String>(
        future: _resolvePath(),
        builder: (context, snapshot) {
          final content = switch (snapshot.connectionState) {
            ConnectionState.done => _ResolvedIllustration(
                path: snapshot.data ??
                    'lib/media/svg/illustrations/managing-money.svg',
                size: widget.size,
                semanticLabel: semanticLabel,
              ),
            _ => _IllustrationPlaceholder(size: widget.size),
          };

          return AnimatedSwitcher(
            duration:
                reduceMotion ? Duration.zero : const Duration(milliseconds: 180),
            child: content,
          );
        },
      ),
    );
  }
}

class _IllustrationPlaceholder extends StatelessWidget {
  const _IllustrationPlaceholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey<String>('illustration-skeleton'),
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}

class _ResolvedIllustration extends StatelessWidget {
  const _ResolvedIllustration({
    required this.path,
    required this.size,
    required this.semanticLabel,
  });

  final String path;
  final double size;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final lowerPath = path.toLowerCase();
    final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1;
    final cacheDimension = (size * dpr).round();

    final fallback = Icon(
      Icons.image_not_supported_outlined,
      key: const ValueKey<String>('illustration-fallback'),
      size: size * 0.3,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    final child = lowerPath.endsWith('.svg')
        ? SvgPicture.asset(
            path,
            key: ValueKey<String>('illustration-svg:$path'),
            width: size,
            height: size,
            fit: BoxFit.contain,
            semanticsLabel: semanticLabel,
          )
        : Image.asset(
            path,
            key: ValueKey<String>('illustration-raster:$path'),
            width: size,
            height: size,
            fit: BoxFit.contain,
            cacheWidth: cacheDimension,
            cacheHeight: cacheDimension,
            filterQuality: FilterQuality.low,
            errorBuilder: (_, __, ___) => fallback,
          );

    return SizedBox(
      width: size,
      height: size,
      child: Semantics(
        label: semanticLabel,
        image: true,
        child: child,
      ),
    );
  }
}
