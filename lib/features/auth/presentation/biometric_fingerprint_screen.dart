import 'package:flutter/material.dart';

import 'biometric_prompt_screen.dart';

class BiometricFingerprintScreen extends StatelessWidget {
  const BiometricFingerprintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BiometricPromptScreen(
      title: 'Fingerprint',
      subtitle:
          'Unlock Kora with your fingerprint for quick and secure access.',
      primaryLabel: 'Setup Fingerprint',
      icon: Icons.fingerprint,
      primaryRoute: '/app/home',
    );
  }
}
