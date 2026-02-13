import 'package:flutter/material.dart';

class BrandAssets {
  static const String _assetsMediaRoot = 'assets/media';
  static const String _legacyMediaRoot = 'lib/media/svg';

  static String illustration(String fileName) =>
      '$_assetsMediaRoot/illustrations/$fileName';
  static String icon(String fileName) => '$_assetsMediaRoot/icons/$fileName';
  static String coinIcon(String fileName) =>
      '$_assetsMediaRoot/coin_icons/$fileName';

  static List<String> resolveAssetCandidates(String assetRelativePath) {
    final normalized = assetRelativePath.replaceAll('\\', '/');
    final fileName = normalized.split('/').last;
    return <String>[
      '$_assetsMediaRoot/$normalized',
      '$_legacyMediaRoot/$fileName',
    ];
  }
}

Widget safeAssetImage({
  required String assetRelativePath,
  double? width,
  double? height,
  BoxFit? fit,
  Widget? fallback,
}) {
  final candidates = BrandAssets.resolveAssetCandidates(assetRelativePath);
  return _SafeAssetImage(
    candidates: candidates,
    width: width,
    height: height,
    fit: fit,
    fallback: fallback ?? const SizedBox.shrink(),
  );
}

class _SafeAssetImage extends StatelessWidget {
  const _SafeAssetImage({
    required this.candidates,
    required this.fallback,
    this.width,
    this.height,
    this.fit,
  });

  final List<String> candidates;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    return _buildCandidate(0);
  }

  Widget _buildCandidate(int index) {
    if (index >= candidates.length) {
      return fallback;
    }
    return Image.asset(
      candidates[index],
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _buildCandidate(index + 1),
    );
  }
}
