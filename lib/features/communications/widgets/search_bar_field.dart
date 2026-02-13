import 'package:flutter/material.dart';

import '../../../ui/theme/app_tokens.dart';

class SearchBarField extends StatelessWidget {
  const SearchBarField({
    super.key,
    this.hintText = 'Search',
    this.controller,
    this.onChanged,
    this.onTap,
    this.autofocus = false,
    this.readOnly = false,
  });

  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool autofocus;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        contentPadding: const EdgeInsets.symmetric(vertical: AppTokens.space3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}
