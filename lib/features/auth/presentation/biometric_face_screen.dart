import 'package:flutter/material.dart';

import 'biometric_prompt_screen.dart';

class BiometricFaceScreen extends StatelessWidget {
  const BiometricFaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BiometricPromptScreen(
      title: 'Setup Face ID',
      subtitle:
          'Unlock Kora with your face ID for a faster and secure sign in.',
      primaryLabel: 'Scan my face',
      icon: Icons.face_retouching_natural,
      primaryRoute: '/auth/biometric-fingerprint',
      skipRoute: '/auth/biometric-fingerprint',
    );
  }
}
