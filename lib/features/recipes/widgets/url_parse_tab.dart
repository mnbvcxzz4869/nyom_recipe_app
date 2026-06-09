import 'package:flutter/material.dart';
import 'package:nyom_recipe_app/core/theme/app_theme.dart';
import 'package:nyom_recipe_app/shared/widgets/custom_button.dart';
import 'package:nyom_recipe_app/shared/widgets/custom_text_field.dart';

class UrlParseTab extends StatelessWidget {
  final TextEditingController controller;
  final bool isParsing;
  final String? errorMessage;
  final VoidCallback onParse;

  const UrlParseTab({
    super.key,
    required this.controller,
    required this.isParsing,
    required this.onParse,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: 'Paste URL',
            hintText: 'Paste a YouTube link or article URL',
            controller: controller,
            keyboardType: TextInputType.url,
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                errorMessage!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.red),
              ),
            ),
          if (isParsing)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            CustomButton(
              text: 'Parse with AI',
              type: CustomButtonType.primary,
              onPressed: onParse,
            ),
          const SizedBox(height: 8),
          Text(
            'AI will pre-fill the Manual tab — you can review and edit before saving.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.greyAccent),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}