import 'package:flutter/material.dart';

import 'biometric_prompt_screen.dart';

class BiometricFingerprintScreen extends StatelessWidget {
  const BiometricFingerprintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BiometricPromptScreen(
      title: 'Enable Fingerprint',
      subtitle:
          'Protect your account with a fast and secure fingerprint check.',
      primaryLabel: 'Enable Fingerprint',
      icon: Icons.fingerprint,
    );
  }
}
