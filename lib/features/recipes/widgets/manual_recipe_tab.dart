import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:nyom_recipe_app/core/theme/app_theme.dart';
import 'package:nyom_recipe_app/features/recipes/widgets/ingredient_row.dart';
import 'package:nyom_recipe_app/features/recipes/widgets/recipe_step_row.dart';
import 'package:nyom_recipe_app/shared/widgets/custom_button.dart';
import 'package:nyom_recipe_app/shared/widgets/custom_text_field.dart';

class ManualRecipeTab extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController timeController;
  final String? selectedCategory;
  final List<String> categories;
  final List<IngredientEntry> ingredients;
  final List<TextEditingController> steps;
  final File? pickedImage;
  final String? uploadedImageUrl;
  final bool isSaving;
  final VoidCallback onPickImage;
  final VoidCallback onAddIngredient;
  final void Function(int index) onRemoveIngredient;
  final VoidCallback onAddStep;
  final void Function(int index) onRemoveStep;
  final void Function(String? value) onCategoryChanged;
  final VoidCallback onSave;

  const ManualRecipeTab({
    super.key,
    required this.titleController,
    required this.timeController,
    required this.selectedCategory,
    required this.categories,
    required this.ingredients,
    required this.steps,
    required this.pickedImage,
    required this.uploadedImageUrl,
    required this.isSaving,
    required this.onPickImage,
    required this.onAddIngredient,
    required this.onRemoveIngredient,
    required this.onAddStep,
    required this.onRemoveStep,
    required this.onCategoryChanged,
    required this.onSave,
  });

  Widget _buildDashedAddButton(BuildContext context, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: AppTheme.crossedOutGreen,
          strokeWidth: 1,
          radius: const Radius.circular(8),
          dashPattern: const [6, 2],
        ),
        child: Material(
          color: AppTheme.cardWhite,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: Center(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        color: AppTheme.crossedOutGreen,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Name ──
          CustomTextField(
            label: 'Name',
            hintText: 'Insert recipe name',
            controller: titleController,
          ),
          const SizedBox(height: 8),

          // ── Estimated Time + Category ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estimated Time', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.cardWhite,
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Icon(Icons.timer_outlined, size: 20, color: AppTheme.greyAccent),
                          ),
                          Expanded(
                            child: TextField(
                              controller: timeController,
                              keyboardType: TextInputType.number,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration(
                                hintText: '00',
                                hintStyle: Theme.of(context).textTheme.labelLarge,
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Text(
                              'Min',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppTheme.greyAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Category', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.cardWhite,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            hint: Text('Select', style: Theme.of(context).textTheme.labelLarge),
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.greyAccent,
                            ),
                            style: Theme.of(context).textTheme.bodyMedium,
                            dropdownColor: AppTheme.cardWhite,
                            items: categories
                                .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c, style: Theme.of(context).textTheme.bodyMedium),
                                    ))
                                .toList(),
                            onChanged: onCategoryChanged,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Ingredients ──
          Text('Ingredients List', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  ...List.generate(
                    ingredients.length,
                    (i) => IngredientRow(
                      entry: ingredients[i],
                      canDelete: ingredients.length > 1,
                      onDelete: () => onRemoveIngredient(i),
                      showDivider: i < ingredients.length - 1,
                    ),
                  ),
                  _buildDashedAddButton(context, 'Add Ingredients', onAddIngredient),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Steps ──
          Text('Steps', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  ...List.generate(
                    steps.length,
                    (i) => RecipeStepRow(
                      index: i,
                      controller: steps[i],
                      canDelete: steps.length > 1,
                      onDelete: () => onRemoveStep(i),
                      showDivider: i < steps.length - 1,
                    ),
                  ),
                  _buildDashedAddButton(context, 'Add Steps', onAddStep),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Recipe Photo ──
          Text('Recipe Photo', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent,
            child: GestureDetector(
              onTap: onPickImage,
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color: AppTheme.crossedOutGreen,
                  strokeWidth: 1,
                  radius: const Radius.circular(8),
                  dashPattern: const [6, 2],
                ),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: pickedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(pickedImage!, fit: BoxFit.cover),
                        )
                      : uploadedImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: uploadedImageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                placeholder: (context, url) =>
                                    const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.broken_image, color: AppTheme.greyAccent),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 32, color: AppTheme.greyAccent),
                                const SizedBox(height: 8),
                                Text(
                                  'Add a photo',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontSize: 16, color: AppTheme.greyAccent),
                                ),
                                Text(
                                  'Tap to upload or take a picture',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Save ──
          if (isSaving)
            const Center(child: CircularProgressIndicator())
          else
            CustomButton(
              text: 'Save Recipe',
              type: CustomButtonType.primary,
              onPressed: onSave,
            ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}