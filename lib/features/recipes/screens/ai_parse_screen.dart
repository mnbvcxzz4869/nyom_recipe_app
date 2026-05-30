import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:nyom_recipe_app/shared/widgets/custom_text_field.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_button.dart';

// Simple data class to hold ingredient rows
class _IngredientEntry {
  final TextEditingController nameController;
  final TextEditingController qtyController;

  _IngredientEntry()
    : nameController = TextEditingController(),
      qtyController = TextEditingController();

  void dispose() {
    nameController.dispose();
    qtyController.dispose();
  }
}

class AiParseScreen extends StatefulWidget {
  const AiParseScreen({super.key});

  @override
  State<AiParseScreen> createState() => _AiParseScreenState();
}

class _AiParseScreenState extends State<AiParseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Tab 1: AI Parse ---
  final _textInputController = TextEditingController();

  // --- Tab 2: From URL ---
  final _urlInputController = TextEditingController();

  // --- Tab 3: Manual ---
  final _manualTitleController = TextEditingController();
  final _manualTimeController = TextEditingController();
  String? _selectedCategory;

  // Start with 1 ingredient row and 1 step row
  final List<_IngredientEntry> _ingredients = [_IngredientEntry()];
  final List<TextEditingController> _steps = [TextEditingController()];

  final List<String> _categories = [
    'Rice',
    'Noodle',
    'Meat',
    'Seafood',
    'Vegetables',
    'Snacks',
    'Desserts',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

  void _addIngredient() {
    setState(() => _ingredients.add(_IngredientEntry()));
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients[index].dispose();
      _ingredients.removeAt(index);
    });
  }

  void _addStep() {
    setState(() => _steps.add(TextEditingController()));
  }

  void _removeStep(int index) {
    setState(() {
      _steps[index].dispose();
      _steps.removeAt(index);
    });
  }

  void _handleManualSave() {
    if (_manualTitleController.text.trim().isEmpty) return;
    debugPrint('Saving manual recipe...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.baseBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Add Recipe',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            // ── Tab Bar ──────────────────────────────────────────────────
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

  // ── TAB 1 — AI Parse ──────────────────────────────────────────────────────
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
                      'Paste recipe text from TikTok caption, YouTube description , or anywhere!',
                  hintStyle: Theme.of(context).textTheme.labelLarge,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16.0),
                ),
              ),
            ),
          ),
          CustomButton(
            text: 'Parse with AI',
            type: CustomButtonType.primary,
            onPressed: () {},
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── TAB 2 — From URL ──────────────────────────────────────────────────────
  Widget _buildFromUrlTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Using CustomTextField for consistent styling
          CustomTextField(
            label: 'Paste URL',
            hintText: 'Paste a YouTube link or article URL',
            controller: _urlInputController,
            keyboardType: TextInputType.url,
          ),
          CustomButton(
            text: 'Parse with AI',
            type: CustomButtonType.primary,
            onPressed: () {},
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
              // Estimated Time
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
              // Category
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
                              'Select Category',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppTheme.greyAccent,
                            ),
                            items: _categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
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

          // ── Ingredients List ──
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
                child: Column(
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
          const SizedBox(height: 16),

          CustomButton(
            text: 'Save',
            type: CustomButtonType.primary,
            onPressed: _handleManualSave,
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // ── Ingredient row with swipe-to-delete ───────────────────────────────────
  Widget _buildIngredientRow(int index) {
    // Don't allow deleting the last remaining row
    final canDelete = _ingredients.length > 1;

    return Dismissible(
      key: ValueKey(_ingredients[index]),
      direction: canDelete
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => _removeIngredient(index),
      // Red delete background revealed on swipe
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.greyAccent.withValues(alpha: 0.25),
          borderRadius: index == 0 && _ingredients.length == 1
              ? BorderRadius.circular(8)
              : index == 0
              ? const BorderRadius.vertical(top: Radius.circular(14))
              : index == _ingredients.length - 1
              ? const BorderRadius.vertical(bottom: Radius.circular(0))
              : BorderRadius.zero,
        ),
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
                      hintText: 'Ingredients name',
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

  // ── Step row with swipe-to-delete ─────────────────────────────────────────
  Widget _buildStepRow(int index) {
    final canDelete = _steps.length > 1;

    return Dismissible(
      key: ValueKey(_steps[index]),
      direction: canDelete
          ? DismissDirection.endToStart
          : DismissDirection.none,
      onDismissed: (_) => _removeStep(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.greyAccent.withValues(alpha: 0.25),
          borderRadius: index == 0 && _ingredients.length == 1
              ? BorderRadius.circular(8)
              : index == 0
              ? const BorderRadius.vertical(top: Radius.circular(14))
              : index == _ingredients.length - 1
              ? const BorderRadius.vertical(bottom: Radius.circular(0))
              : BorderRadius.zero,
        ),
        child: Icon(Icons.delete_outline, color: AppTheme.greyAccent),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _steps[index],
              builder: (context, value, _) {
                final isMultiLine =
                    value.text.contains('\n') || value.text.length > 40;
                return Row(
                  crossAxisAlignment: isMultiLine
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 30,
                      margin: EdgeInsets.only(
                        right: 12,
                        top: isMultiLine ? 0 : 0,
                      ),
                      child: Center(
                        child: Text(
                          (index + 1).toString().padLeft(2, '0'),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppTheme.greyAccent,
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                              ),
                        ),
                      ),
                    ),
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
                );
              },
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

  // ── Dashed "Add" button at the bottom of a card ───────────────────────────
  Widget _buildDashedAddButton(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
            child: Container(
              width: double.infinity,
              height: 48,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      color: AppTheme.crossedOutGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
