import 'package:intl/intl.dart';
import '../../features/recipes/models/recipe.dart';
import '../../features/recipes/models/ingredient_item.dart';
import '../../features/grocery/models/grocery_item.dart';
import '../../features/planner/models/meal_plan.dart';
import '../../features/auth/models/app_user.dart';

// ─── USER ────────────────────────────────────────────────────

final mockCurrentUser = AppUser(
  id: 'usr_001',
  email: 'chef@nyom.app',
  username: 'Chef Nyom',
  signupDate: DateTime.parse('2026-05-28'),
);

// ─── RECIPES ─────────────────────────────────────────────────

final mockRecipes = <Recipe>[
  Recipe(
    id: 'rec_001',
    title: 'Fluffy Strawberry Pancakes',
    durationMinutes: 15,
    ingredients: [
      IngredientItem(
        id: 'i001',
        name: 'All-purpose Flour',
        quantity: '200g',
        category: IngredientCategory.dairy,
      ),
      IngredientItem(
        id: 'i002',
        name: 'Fresh Strawberries',
        quantity: '150g',
        category: IngredientCategory.dairy,
      ),
      IngredientItem(
        id: 'i003',
        name: 'Eggs',
        quantity: '2 pcs',
        category: IngredientCategory.protein,
      ),
      IngredientItem(
        id: 'i004',
        name: 'Milk',
        quantity: '200ml',
        category: IngredientCategory.dairy,
      ),
      IngredientItem(
        id: 'i005',
        name: 'Butter',
        quantity: '30g',
        category: IngredientCategory.dairy,
      ),
    ],
    steps: [
      'Mix dry ingredients: flour, sugar, baking powder, and a pinch of salt.',
      'Whisk eggs, milk, and melted butter together in a separate bowl.',
      'Fold wet into dry — small lumps are fine, do not over-mix.',
      'Cook on a medium-hot non-stick pan for 2 minutes per side.',
      'Top with sliced strawberries and a drizzle of honey.',
    ],
    category: Category.desserts,
  ),

  Recipe(
    id: 'rec_002',
    title: 'Creamy Garlic Mushroom Pasta',
    durationMinutes: 25,
    ingredients: [
      IngredientItem(
        id: 'i006',
        name: 'Spaghetti',
        quantity: '200g',
        category: IngredientCategory.pantry,
      ),
      IngredientItem(
        id: 'i007',
        name: 'Mushrooms',
        quantity: '200g',
        category: IngredientCategory.produce,
      ),
      IngredientItem(
        id: 'i008',
        name: 'Heavy Cream',
        quantity: '200ml',
        category: IngredientCategory.dairy,
      ),
      IngredientItem(
        id: 'i009',
        name: 'Garlic Cloves',
        quantity: '4 pcs',
        category: IngredientCategory.produce,
      ),
      IngredientItem(
        id: 'i010',
        name: 'Parmesan',
        quantity: '50g',
        category: IngredientCategory.dairy,
      ),
    ],
    steps: [
      'Boil spaghetti in salted water until al dente, reserve 1 cup pasta water.',
      'Sauté minced garlic in butter for 1 minute until fragrant.',
      'Add mushrooms and cook until golden, about 5 minutes.',
      'Pour in cream and simmer for 3 minutes until slightly thickened.',
      'Toss with drained pasta, adding pasta water to loosen if needed.',
      'Finish with grated parmesan and cracked pepper.',
    ],
    category: Category.rice,
  ),

  Recipe(
    id: 'rec_003',
    title: 'Grilled Salmon with Avocado',
    durationMinutes: 30,
    ingredients: [
      IngredientItem(
        id: 'i011',
        name: 'Salmon Fillets',
        quantity: '2 portions',
        category: IngredientCategory.protein,
      ),
      IngredientItem(
        id: 'i012',
        name: 'Avocado',
        quantity: '2 pcs',
        category: IngredientCategory.produce,
      ),
      IngredientItem(
        id: 'i013',
        name: 'Lemon',
        quantity: '1 pc',
        category: IngredientCategory.produce,
      ),
      IngredientItem(
        id: 'i014',
        name: 'Olive Oil',
        quantity: '2 tbsp',
        category: IngredientCategory.pantry,
      ),
    ],
    steps: [
      'Pat salmon dry and season with salt, pepper, and lemon zest., lorem ipsum dolori sdfjs heloo wrold apa kjabar semua hihihih,kita masak masak amasak',
      'Grill on high heat for 4 minutes per side until skin is crisp.',
      'While salmon rests, slice.',
      'Squeeze fresh lemon over everything and drizzle olive oil.',
    ],
    category: Category.noodle,
  ),

  Recipe(
    id: 'rec_004',
    title: 'Ramen Pork-Broth Bowl',
    durationMinutes: 45,
    ingredients: [
      IngredientItem(
        id: 'i015',
        name: 'Ramen Noodles',
        quantity: '200g',
        category: IngredientCategory.pantry,
      ),
      IngredientItem(
        id: 'i016',
        name: 'Pork Belly',
        quantity: '300g',
        category: IngredientCategory.protein,
      ),
      IngredientItem(
        id: 'i017',
        name: 'Soft-boiled Egg',
        quantity: '2 pcs',
        category: IngredientCategory.protein,
      ),
      IngredientItem(
        id: 'i018',
        name: 'Spring Onion',
        quantity: '3 stalks',
        category: IngredientCategory.produce,
      ),
    ],
    steps: [
      'Simmer broth with soy sauce, mirin, and garlic for 30 minutes.',
      'Slice pork belly thinly and sear in a hot pan until caramelised.',
      'Cook ramen noodles according to package instructions.',
      'Assemble: noodles → broth → pork → halved egg → spring onion.',
    ],
    category: Category.seafood,
  ),

  Recipe(
    id: 'rec_005',
    title: 'Steamed Jasmine Rice',
    durationMinutes: 20,
    ingredients: [
      IngredientItem(
        id: 'i019',
        name: 'Jasmine Rice',
        quantity: '2 cups',
        category: IngredientCategory.pantry,
      ),
      IngredientItem(
        id: 'i020',
        name: 'Water',
        quantity: '3 cups',
        category: IngredientCategory.pantry,
      ),
      IngredientItem(
        id: 'i021',
        name: 'Salt',
        quantity: '1 pinch',
        category: IngredientCategory.pantry,
      ),
    ],
    steps: [
      'Rinse rice under cold water until water runs clear.',
      'Add rice, water, and salt to a pot. Bring to a boil.',
      'Reduce to the lowest heat, cover, and cook for 15 minutes.',
      'Remove from heat and rest covered for 5 minutes before fluffing.',
    ],
    category: Category.snacks,
  ),
];

// ─── GROCERY ITEMS ────────────────────────────────────────────

final List<GroceryItem> mockGroceryItems = [
  // Existing items
  GroceryItem(
    ingredient: IngredientItem(
      id: 'i021',
      name: 'Salt',
      quantity: '1 pinch',
      category: IngredientCategory.pantry,
    ),
  ),
  GroceryItem(
    ingredient: IngredientItem(
      id: 'i020',
      name: 'Water',
      quantity: '3 cups',
      category: IngredientCategory.pantry,
    ),
  ),
  // 7 New items
  GroceryItem(
    ingredient: IngredientItem(
      id: 'i022',
      name: 'Chicken Breast',
      quantity: '2 lbs',
      category: IngredientCategory.protein,
    ),
  ),
  GroceryItem(
    ingredient: IngredientItem(
      id: 'i023',
      name: 'Spinach',
      quantity: '1 bunch',
      category: IngredientCategory.produce,
    ),
  ),
  GroceryItem(
    ingredient: IngredientItem(
      id: 'i024',
      name: 'Greek Yogurt',
      quantity: '1 container',
      category: IngredientCategory.dairy,
    ),
  ),
  GroceryItem(
    ingredient: IngredientItem(
      id: 'i025',
      name: 'Olive Oil',
      quantity: '1 bottle',
      category: IngredientCategory.pantry,
    ),
  ),
  GroceryItem(
    ingredient: IngredientItem(
      id: 'i026',
      name: 'Carrots',
      quantity: '5 count',
      category: IngredientCategory.produce,
    ),
  ),
  GroceryItem(
    ingredient: IngredientItem(
      id: 'i027',
      name: 'Cheddar Cheese',
      quantity: '8 oz',
      category: IngredientCategory.dairy,
    ),
  ),
  GroceryItem(
    ingredient: IngredientItem(
      id: 'i028',
      name: 'Salmon Fillet',
      quantity: '2 count',
      category: IngredientCategory.protein,
    ),
  ),
];

// ─── MEAL PLANS ───────────────────────────────────────────────

String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

MealPlan mockMealPlanForDate(DateTime date) =>
    _mockMealPlans[_dateKey(date)] ?? MealPlan(dateKey: _dateKey(date));

final _mockMealPlans = <String, MealPlan>{
  // Today: breakfast + dinner planned, lunch empty
  _dateKey(DateTime.now()): MealPlan(
    dateKey: _dateKey(DateTime.now()),
    breakfast: [mockRecipes[0]], // Strawberry Pancakes
    lunch: [], // empty → dashed add button
    dinner: [mockRecipes[2], mockRecipes[4]], // Salmon + Steamed Rice
  ),
  // Tomorrow: only lunch
  _dateKey(DateTime.now().add(const Duration(days: 1))): MealPlan(
    dateKey: _dateKey(DateTime.now().add(const Duration(days: 1))),
    breakfast: [],
    lunch: [mockRecipes[1]], // Garlic Mushroom Pasta
    dinner: [],
  ),
};
