// ignore_for_file: prefer_final_fields

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:nyom_recipe_app/core/services/supabase_service.dart';
import 'package:nyom_recipe_app/features/recipes/models/ingredient_item.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import 'package:nyom_recipe_app/features/recipes/providers/recipe_provider.dart';
import 'package:nyom_recipe_app/features/recipes/widgets/ai_parse_tab.dart';
import 'package:nyom_recipe_app/features/recipes/widgets/ingredient_row.dart';
import 'package:nyom_recipe_app/features/recipes/widgets/manual_recipe_tab.dart';
import 'package:nyom_recipe_app/features/recipes/widgets/url_parse_tab.dart';
import 'package:nyom_recipe_app/core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class AiParseScreen extends ConsumerStatefulWidget {
  final Recipe? initialRecipe;
  const AiParseScreen({super.key, this.initialRecipe, required recipeId});

  @override
  ConsumerState<AiParseScreen> createState() => _AiParseScreenState();
}

class _AiParseScreenState extends ConsumerState<AiParseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  File? _pickedImage;
  String? _uploadedImageUrl;

  // Tab 1 — AI Parse
  final _textInputController = TextEditingController();
  bool _isParsingText = false;
  String? _textParseError;

  // Tab 2 — From URL
  final _urlInputController = TextEditingController();
  bool _isParsingUrl = false;
  String? _urlParseError;

  // Tab 3 — Manual
  final _manualTitleController = TextEditingController();
  final _manualTimeController = TextEditingController();
  String? _selectedCategory;
  bool _isSaving = false;
  List<IngredientEntry> _ingredients = [IngredientEntry()];
  List<TextEditingController> _steps = [TextEditingController()];

  final List<String> _categories = AppConstants.recipeCategories;

  static const _uuid = Uuid();
  String? _editingId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.initialRecipe != null) {
      _editingId = widget.initialRecipe!.id;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _prefillManualTab(widget.initialRecipe!),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textInputController.dispose();
    _urlInputController.dispose();
    _manualTitleController.dispose();
    _manualTimeController.dispose();
    for (final e in _ingredients) {
      e.dispose();
    }
    for (final c in _steps) {
      c.dispose();
    }
    super.dispose();
  }

  void _prefillManualTab(Recipe recipe) {
    setState(() {
      _manualTitleController.text = recipe.title;
      _manualTimeController.text = recipe.durationMinutes.toString();
      _selectedCategory = recipe.category.label;
      _pickedImage = null;
      _uploadedImageUrl = recipe.imageUrl;

      final newIngredients = recipe.ingredients.isEmpty
          ? [IngredientItem(id: '', name: '', quantity: '')]
          : recipe.ingredients;

      for (int i = 0; i < newIngredients.length; i++) {
        if (i < _ingredients.length) {
          _ingredients[i].nameController.text = newIngredients[i].name;
          _ingredients[i].qtyController.text = newIngredients[i].quantity;
        } else {
          _ingredients.add(
            IngredientEntry(
              name: newIngredients[i].name,
              qty: newIngredients[i].quantity,
            ),
          );
        }
      }
      while (_ingredients.length > newIngredients.length) {
        _ingredients.removeLast().dispose();
      }

      final newSteps = recipe.steps.isEmpty ? [''] : recipe.steps;
      for (int i = 0; i < newSteps.length; i++) {
        if (i < _steps.length) {
          _steps[i].text = newSteps[i];
        } else {
          _steps.add(TextEditingController(text: newSteps[i]));
        }
      }
      while (_steps.length > newSteps.length) {
        _steps.removeLast().dispose();
      }
    });

    _tabController.animateTo(2);
  }

  Future<void> _handleParseText() async {
    final text = _textInputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _isParsingText = true;
      _textParseError = null;
    });
    try {
      final recipe = await ref.read(geminiServiceProvider).parseFromText(text);
      if (mounted) _prefillManualTab(recipe);
    } catch (e) {
      if (mounted) {
        setState(() => _textParseError = 'Parsing failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isParsingText = false);
    }
  }

  Future<void> _handleParseUrl() async {
    final url = _urlInputController.text.trim();
    if (url.isEmpty) return;
    setState(() {
      _isParsingUrl = true;
      _urlParseError = null;
    });
    try {
      final recipe = await ref.read(geminiServiceProvider).parseFromUrl(url);
      if (mounted) _prefillManualTab(recipe);
    } catch (e) {
      if (mounted) {
        setState(
          () =>
              _urlParseError = 'Could not parse that URL. Please try another.',
        );
      }
    } finally {
      if (mounted) setState(() => _isParsingUrl = false);
    }
  }

  Future<void> _handleSave() async {
    final title = _manualTitleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe name.')),
      );
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    if (_manualTimeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an estimated time.')),
      );
      return;
    }

    final hasIngredient = _ingredients.any(
      (e) => e.nameController.text.trim().isNotEmpty,
    );
    if (!hasIngredient) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one ingredient.')),
      );
      return;
    }

    final hasStep = _steps.any((c) => c.text.trim().isNotEmpty);
    if (!hasStep) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Add at least one step.')));
      return;
    }

    final categoryName = _selectedCategory?.toLowerCase();
    Category category;
    try {
      category = categoryName != null
          ? Category.values.byName(categoryName)
          : Category.values.first;
    } catch (_) {
      category = Category.values.first;
    }

    final rawIngredients = _ingredients
        .where((e) => e.nameController.text.trim().isNotEmpty)
        .toList();
    final names = rawIngredients
        .map((e) => _capitalize(e.nameController.text.trim()))
        .toList();

    Map<String, String> categories = {};
    try {
      categories = await ref
          .read(geminiServiceProvider)
          .categorizeIngredients(names);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Categorize error: $e')));
      }
      return;
    }

    final ingredients = rawIngredients.map((e) {
      final name = _capitalize(e.nameController.text.trim());
      return IngredientItem(
        id: _uuid.v4(),
        name: name,
        quantity: e.qtyController.text.trim(),
        category: IngredientCategory.values.byName(
          categories[name] ?? 'pantry',
        ),
      );
    }).toList();

    final steps = _steps
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    String? finalImageUrl = _uploadedImageUrl;
    if (_pickedImage != null) {
      finalImageUrl = await ref
          .read(recipesProvider.notifier)
          .uploadImage(_pickedImage!);
    }

    final recipe = Recipe(
      id: _editingId ?? '',
      title: title,
      durationMinutes: int.tryParse(_manualTimeController.text.trim()) ?? 0,
      category: category,
      ingredients: ingredients,
      steps: steps,
      imageUrl: finalImageUrl,
    );

    setState(() => _isSaving = true);
    try {
      if (_editingId != null && _editingId!.isNotEmpty) {
        await ref.read(recipesProvider.notifier).edit(recipe);
        ref.invalidate(recipeByIdProvider(_editingId!));
      } else {
        await ref.read(recipesProvider.notifier).add(recipe);
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Recipe saved!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handlePickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() => _pickedImage = File(picked.path));
  }

  void _addIngredient() => setState(() => _ingredients.add(IngredientEntry()));
  void _removeIngredient(int i) => setState(() {
    _ingredients[i].dispose();
    _ingredients.removeAt(i);
  });
  void _addStep() => setState(() => _steps.add(TextEditingController()));
  void _removeStep(int i) => setState(() {
    _steps[i].dispose();
    _steps.removeAt(i);
  });

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.baseBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- FIXED HEADER ZONE ---
            // Wrapping headers in a solid Container matching background prevents bleed-through
            Container(
              color: AppTheme.baseBackground,
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      bottom: 4,
                      left: 8,
                      right: 8,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          widget.initialRecipe != null
                              ? 'Edit Recipe'
                              : 'Add Recipe',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        color: AppTheme.crossedOutGreen,
                        strokeWidth: 1,
                        radius: const Radius.circular(8),
                        dashPattern: const [6, 2],
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.cardWhite,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: AppTheme.warmYellow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelColor: AppTheme.headingGreen,
                          unselectedLabelColor: AppTheme.crossedOutGreen,
                          labelStyle: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                          unselectedLabelStyle: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                          tabs: const [
                            Tab(text: 'AI Parse'),
                            Tab(text: 'From URL'),
                            Tab(text: 'Manual'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- END FIXED HEADER ZONE ---
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // FIXED ORDER: Matches your Tab sequence ('AI Parse', 'From URL', 'Manual')
                  AiParseTab(
                    controller: _textInputController,
                    isParsing: _isParsingText,
                    errorMessage: _textParseError,
                    onParse: _handleParseText,
                  ),
                  UrlParseTab(
                    controller: _urlInputController,
                    isParsing: _isParsingUrl,
                    errorMessage: _urlParseError,
                    onParse: _handleParseUrl,
                  ),
                  ManualRecipeTab(
                    titleController: _manualTitleController,
                    timeController: _manualTimeController,
                    selectedCategory: _selectedCategory,
                    categories: _categories,
                    ingredients: _ingredients,
                    steps: _steps,
                    pickedImage: _pickedImage,
                    uploadedImageUrl: _uploadedImageUrl,
                    isSaving: _isSaving,
                    onPickImage: _handlePickImage,
                    onAddIngredient: _addIngredient,
                    onRemoveIngredient: _removeIngredient,
                    onAddStep: _addStep,
                    onRemoveStep: _removeStep,
                    onCategoryChanged: (val) =>
                        setState(() => _selectedCategory = val),
                    onSave: _handleSave,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
