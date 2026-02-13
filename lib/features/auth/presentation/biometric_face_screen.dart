import 'package:flutter/material.dart';

import 'biometric_prompt_screen.dart';

class BiometricFaceScreen extends StatelessWidget {
  const BiometricFaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BiometricPromptScreen(
      title: 'Enable Face ID',
      subtitle:
          'This helps check that only you can unlock your wallet experience.',
      primaryLabel: 'Enable Face ID',
      icon: Icons.face_retouching_natural,
      skipRoute: '/auth/biometric-fingerprint',
    );
  }
}
