class AppConstants {
  AppConstants._();

  // Recipe categories shown in the add/edit form dropdown
  static const List<String> recipeCategories = [
    'Rice',
    'Noodle',
    'Meat',
    'Seafood',
    'Vegetables',
    'Snacks',
    'Desserts',
  ];

  // Supabase storage bucket for recipe images
  static const String recipeImagesBucket = 'recipe-images';
}