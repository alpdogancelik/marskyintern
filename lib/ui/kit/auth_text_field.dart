import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';
import 'inline_error_text.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasError = errorText != null && errorText!.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          autofillHints: autofillHints,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: enabled ? colors.surface : colors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTokens.space4,
              vertical: AppTokens.space4,
            ),
            prefixIcon: leading == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 8, right: 6),
                    child: leading,
                  ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: AppTokens.minTapTarget,
              minHeight: AppTokens.minTapTarget,
            ),
            suffixIcon: trailing,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              borderSide: BorderSide(color: colors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              borderSide: BorderSide(color: colors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              borderSide: BorderSide(color: colors.primary, width: 1.2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              borderSide: BorderSide(color: colors.outlineVariant),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              borderSide: BorderSide(color: colors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              borderSide: BorderSide(color: colors.error, width: 1.2),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          InlineErrorText(errorText!),
        ],
      ],
    );
  }
}
