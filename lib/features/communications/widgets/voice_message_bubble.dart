import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../ui/theme/app_tokens.dart';

class VoiceMessageBubble extends StatelessWidget {
  const VoiceMessageBubble({
    super.key,
    required this.isOutgoing,
    required this.durationLabel,
    this.onTapPlay,
  });

  final bool isOutgoing;
  final String durationLabel;
  final VoidCallback? onTapPlay;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final iconBg = isOutgoing
        ? Colors.white.withValues(alpha: 0.2)
        : colors.surfaceContainerLow;
    final iconColor = isOutgoing ? colors.onPrimary : colors.primary;
    final waveColor = isOutgoing
        ? colors.onPrimary.withValues(alpha: 0.72)
        : colors.onSurfaceVariant;
    final textColor = isOutgoing ? colors.onPrimary : colors.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTapPlay,
          borderRadius: BorderRadius.circular(99),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              size: 18,
              color: iconColor,
            ),
          ),
        ),
        const SizedBox(width: AppTokens.space2),
        SizedBox(
          width: 96,
          height: 18,
          child: CustomPaint(
            painter: _WaveformPainter(color: waveColor),
          ),
        ),
        const SizedBox(width: AppTokens.space2),
        Text(
          durationLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const bars = 18;
    final spacing = size.width / bars;
    for (var i = 0; i < bars; i += 1) {
      final x = (i + 0.5) * spacing;
      final amplitude = (math.sin(i * 0.65) * 0.4 + 0.6) * size.height;
      final top = (size.height - amplitude) / 2;
      final bottom = top + amplitude;
      canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
