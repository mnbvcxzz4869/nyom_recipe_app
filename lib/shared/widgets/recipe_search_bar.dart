import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class RecipeSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  const RecipeSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search recipe.',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: AppTheme.cardWhite,
      borderRadius: BorderRadius.circular(8.0),
      clipBehavior: Clip.antiAlias,
      child: TextField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlignVertical: TextAlignVertical.center,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: Theme.of(context).textTheme.labelLarge,
          suffixIcon: const Icon(
            Icons.search_rounded,
            color: AppTheme.greyAccent,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18.0,
            horizontal: 12.0,
          ),
        ),
      ),
    );
  }
}