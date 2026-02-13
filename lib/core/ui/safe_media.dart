import 'package:flutter/material.dart';

class SafeAssetImage extends StatelessWidget {
  const SafeAssetImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit,
    this.fallback,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => fallback ?? const SizedBox.shrink(),
    );
  }
}

class SafeCoinAvatar extends StatelessWidget {
  const SafeCoinAvatar({
    super.key,
    required this.iconUrl,
    this.size = 40,
  });

  final String iconUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallbackIcon = Icon(
      Icons.currency_bitcoin,
      size: size * 0.55,
    );

    final fallbackAsset = SafeAssetImage(
      assetPath: 'assets/media/coin_icons/default_coin.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      fallback: fallbackIcon,
    );

    if (iconUrl.isEmpty) {
      return CircleAvatar(radius: size / 2, child: fallbackAsset);
    }

    return CircleAvatar(
      radius: size / 2,
      child: ClipOval(
        child: Image.network(
          iconUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallbackAsset,
        ),
      ),
    );
  }
}
