import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final double elevation;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.elevation = 2.0,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.textInputAction,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),

          // ── TEXTFormField LAYERED LAYOUT ───────────────────────────────────
          FormField<String>(
            validator: validator,
            autovalidateMode: autovalidateMode,
            builder: (FormFieldState<String> fieldState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // This Material container stays isolated! No expansion when errors occur.
                  Material(
                    elevation: elevation,
                    borderRadius: BorderRadius.circular(8),
                    color: AppTheme.cardWhite,
                    child: TextField(
                      controller: controller,
                      obscureText: obscureText,
                      keyboardType: keyboardType,
                      style: theme.textTheme.bodyMedium,
                      textInputAction: textInputAction,
                      onChanged: (value) {
                        fieldState.didChange(value);
                        if (onChanged != null) onChanged!(value);
                      },
                      decoration: InputDecoration(
                        hintText: hintText,
                        suffixIcon: suffixIcon,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        filled: false,
                        // Cleanly stripped borders so the input card relies on Material clipping
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  // Render error message cleanly underneath the isolated visual container
                  if (fieldState.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                      child: Text(
                        fieldState.errorText!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
