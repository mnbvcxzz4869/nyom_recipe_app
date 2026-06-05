import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:nyom_recipe_app/core/services/supabase_service.dart';
import 'package:nyom_recipe_app/features/recipes/models/ingredient_item.dart';
import 'package:nyom_recipe_app/features/recipes/models/recipe.dart';
import 'package:nyom_recipe_app/features/recipes/providers/recipe_provider.dart';
import 'package:nyom_recipe_app/features/recipes/screens/recipe_detail_screen.dart';
import 'package:nyom_recipe_app/shared/widgets/custom_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';

// ─── Ingredient row data ─────────────────────────────────────────────────────
class _IngredientEntry {
  final TextEditingController nameController;
  final TextEditingController qtyController;

  _IngredientEntry({String name = '', String qty = ''})
    : nameController = TextEditingController(text: name),
      qtyController = TextEditingController(text: qty);

  void dispose() {
    nameController.dispose();
    qtyController.dispose();
  }
}

// ─── Screen ──────────────────────────────────────────────────────────────────
class AiParseScreen extends ConsumerStatefulWidget {
  final Recipe? initialRecipe;
  const AiParseScreen({super.key, this.initialRecipe, required recipeId});

  @override
  ConsumerState<AiParseScreen> createState() => _AiParseScreenState();
}

File? _pickedImage;
String? _uploadedImageUrl;

class _AiParseScreenState extends ConsumerState<AiParseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab 1 — AI Parse
  final _textInputController = TextEditingController();
  bool _isParsingText = false;
  String? _textParseError;

  // Tab 2 — From URL
  final _urlInputController = TextEditingController();
  bool _isParsingUrl = false;
  String? _urlParseError;

  // Tab 3 — Manual (also receives pre-filled data from tabs 1 & 2)
  final _manualTitleController = TextEditingController();
  final _manualTimeController = TextEditingController();
  String? _selectedCategory;
  bool _isSaving = false;
  List<_IngredientEntry> _ingredients = [_IngredientEntry()];
  List<TextEditingController> _steps = [TextEditingController()];

  final List<String> _categories = [
    'Rice',
    'Noodle',
    'Meat',
    'Seafood',
    'Vegetables',
    'Snacks',
    'Desserts',
  ];

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
    for (final e in _ingredients) e.dispose();
    for (final c in _steps) c.dispose();
    super.dispose();
  }

  // ─── Pre-fill Manual tab from a parsed Recipe ──────────────────────────────
  void _prefillManualTab(Recipe recipe) {
    setState(() {
      _manualTitleController.text = recipe.title;
      _manualTimeController.text = recipe.durationMinutes.toString();
      _selectedCategory = recipe.category.label;
      _pickedImage = null;
      _uploadedImageUrl = recipe.imageUrl;

      // ── Ingredients: reuse existing controllers, add/remove rows as needed ──
      final newIngredients = recipe.ingredients.isEmpty
          ? [IngredientItem(id: '', name: '', quantity: '')]
          : recipe.ingredients;

      // Fill existing rows
      for (int i = 0; i < newIngredients.length; i++) {
        if (i < _ingredients.length) {
          _ingredients[i].nameController.text = newIngredients[i].name;
          _ingredients[i].qtyController.text = newIngredients[i].quantity;
        } else {
          _ingredients.add(
            _IngredientEntry(
              name: newIngredients[i].name,
              qty: newIngredients[i].quantity,
            ),
          );
        }
      }
      // Remove extra rows if new list is shorter
      while (_ingredients.length > newIngredients.length) {
        _ingredients.removeLast().dispose();
      }

      // ── Steps: reuse existing controllers, add/remove rows as needed ──
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

    // Jump to Manual tab so the user reviews the pre-filled data
    _tabController.animateTo(2);
  }

  // ─── Tab 1: Parse from text ────────────────────────────────────────────────
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

  // ─── Tab 2: Parse from URL ────────────────────────────────────────────────
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

  // ─── Tab 3: Save manual / validated recipe ────────────────────────────────
  Future<void> _handleSave() async {
    final title = _manualTitleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a recipe name.')),
      );
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
    } catch (_) {
      // categorization is best-effort — fall through with empty map
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
      try {
        final supabase = Supabase.instance.client;
        final fileName = '${_uuid.v4()}.jpg';
        await supabase.storage
            .from('recipe-images')
            .upload(fileName, _pickedImage!);
        finalImageUrl = supabase.storage
            .from('recipe-images')
            .getPublicUrl(fileName);
      } catch (e) {
        debugPrint('Image upload failed: $e');
        // non-critical — save without image
      }
    }

    final recipe = Recipe(
      id: _editingId ?? '',
      title: title,
      durationMinutes: int.tryParse(_manualTimeController.text.trim()) ?? 0,
      category: category,
      ingredients: ingredients,
      steps: steps,
      imageUrl: finalImageUrl, // add this
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

  // ─── Ingredient helpers ───────────────────────────────────────────────────
  void _addIngredient() => setState(() => _ingredients.add(_IngredientEntry()));

  void _removeIngredient(int index) {
    setState(() {
      _ingredients[index].dispose();
      _ingredients.removeAt(index);
    });
  }

  void _addStep() => setState(() => _steps.add(TextEditingController()));

  void _removeStep(int index) {
    setState(() {
      _steps[index].dispose();
      _steps.removeAt(index);
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.baseBackground,
      body: SafeArea(
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
                    widget.initialRecipe != null ? 'Edit Recipe' : 'Add Recipe',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // ── Tab Bar ─────────────────────────────────────────────────────
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
                        ?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                    unselectedLabelStyle: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                    tabs: const [
                      Tab(text: 'AI Parse'),
                      Tab(text: 'From URL'),
                      Tab(text: 'Manual'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAiParseTab(),
                  _buildFromUrlTab(),
                  _buildManualTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TAB 1 — AI Parse ───────────────────────────────────────────────────────
  Widget _buildAiParseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text('Paste Recipe', style: Theme.of(context).textTheme.titleMedium),
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
              child: TextField(
                controller: _textInputController,
                maxLines: 8,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText:
                      'Paste recipe text from TikTok caption, YouTube description, or anywhere!',
                  hintStyle: Theme.of(context).textTheme.labelLarge,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_textParseError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _textParseError!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.red),
              ),
            ),
          if (_isParsingText)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            CustomButton(
              text: 'Parse with AI',
              type: CustomButtonType.primary,
              onPressed: _handleParseText,
            ),
          const SizedBox(height: 8),
          Text(
            'AI will pre-fill the Manual tab — you can review and edit before saving.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.greyAccent),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── TAB 2 — From URL ───────────────────────────────────────────────────────
  Widget _buildFromUrlTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            label: 'Paste URL',
            hintText: 'Paste a YouTube link or article URL',
            controller: _urlInputController,
            keyboardType: TextInputType.url,
          ),
          if (_urlParseError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _urlParseError!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.red),
              ),
            ),
          if (_isParsingUrl)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            CustomButton(
              text: 'Parse with AI',
              type: CustomButtonType.primary,
              onPressed: _handleParseUrl,
            ),
          const SizedBox(height: 8),
          Text(
            'AI will pre-fill the Manual tab — you can review and edit before saving.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.greyAccent),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── TAB 3 — Manual ────────────────────────────────────────────────────────
  Widget _buildManualTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Name ──
          CustomTextField(
            label: 'Name',
            hintText: 'Insert recipe name',
            controller: _manualTitleController,
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
                    Text(
                      'Estimated Time',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.cardWhite,
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Icon(
                              Icons.timer_outlined,
                              size: 20,
                              color: AppTheme.greyAccent,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _manualTimeController,
                              keyboardType: TextInputType.number,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: InputDecoration(
                                hintText: '00',
                                hintStyle: Theme.of(
                                  context,
                                ).textTheme.labelLarge,
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
                              style: Theme.of(context).textTheme.bodyMedium
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
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(8),
                      color: AppTheme.cardWhite,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 2,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            hint: Text(
                              'Select',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.greyAccent,
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium, // fixes selected value color + font
                            dropdownColor: AppTheme
                                .cardWhite, // fixes dropdown menu background
                            items: _categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(
                                      c,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium, // fixes each option
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedCategory = val),
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
          Text(
            'Ingredients List',
            style: Theme.of(context).textTheme.titleMedium,
          ),
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
                    _ingredients.length,
                    (i) => _buildIngredientRow(i),
                  ),
                  _buildDashedAddButton('Add Ingredients', _addIngredient),
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
                  ...List.generate(_steps.length, (i) => _buildStepRow(i)),
                  _buildDashedAddButton('Add Steps', _addStep),
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
              onTap: _handlePickImage,
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
                  child: _pickedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_pickedImage!, fit: BoxFit.cover),
                        )
                      : _uploadedImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: _uploadedImageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.broken_image,
                              color: AppTheme.greyAccent,
                            ),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 32,
                              color: AppTheme.greyAccent,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add a photo',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontSize: 16,
                                    color: AppTheme.greyAccent,
                                  ),
                            ),
                            Text(
                              'Tap to upload or take a picture',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Save ──
          if (_isSaving)
            const Center(child: CircularProgressIndicator())
          else
            CustomButton(
              text: 'Save Recipe',
              type: CustomButtonType.primary,
              onPressed: _handleSave,
            ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // ── Ingredient row ────────────────────────────────────────────────────────
  Widget _buildIngredientRow(int index) {
    final canDelete = _ingredients.length > 1;
    return Dismissible(
      key: ValueKey(index),
      direction: canDelete
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => _removeIngredient(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.greyAccent.withValues(alpha: 0.25),
        child: Icon(Icons.delete_outline, color: AppTheme.greyAccent),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _ingredients[index].nameController,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Ingredient name',
                      hintStyle: Theme.of(context).textTheme.labelLarge,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      isDense: true,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _ingredients[index].qtyController,
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Qty',
                      hintStyle: Theme.of(context).textTheme.labelLarge,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (index < _ingredients.length - 1)
            Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.crossedOutGreen,
              indent: 16,
              endIndent: 16,
            ),
        ],
      ),
    );
  }

  // ── Step row ──────────────────────────────────────────────────────────────
  Widget _buildStepRow(int index) {
    final canDelete = _steps.length > 1;
    return Dismissible(
      key: ValueKey(index),
      direction: canDelete
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => _removeStep(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.greyAccent.withValues(alpha: 0.25),
        child: Icon(Icons.delete_outline, color: AppTheme.greyAccent),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 40,
                  height: 30,
                  child: Center(
                    child: Text(
                      (index + 1).toString().padLeft(2, '0'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.greyAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _steps[index],
                    maxLines: null,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Insert your recipe step',
                      hintStyle: Theme.of(context).textTheme.labelLarge,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (index < _steps.length - 1)
            Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.crossedOutGreen,
              indent: 16,
              endIndent: 16,
            ),
        ],
      ),
    );
  }

  // ── Dashed add button ─────────────────────────────────────────────────────
  Widget _buildDashedAddButton(String label, VoidCallback onTap) {
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

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
