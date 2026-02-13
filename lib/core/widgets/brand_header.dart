import 'package:flutter/material.dart';

import '../brand/assets.dart';
import '../brand/brand.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    this.illustrationKey,
  });

  final String? illustrationKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (illustrationKey != null) ...[
          Center(
            child: safeAssetImage(
              assetRelativePath: illustrationKey!,
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: KoraBrand.spaceSm),
        ],
        Text(
          KoraBrand.appName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: KoraBrand.spaceXs),
        Text(
          KoraBrand.tagline,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black54,
              ),
        ),
      ],
    );
  }
}
