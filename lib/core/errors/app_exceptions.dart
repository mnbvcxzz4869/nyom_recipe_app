class RecipeNotFoundException implements Exception {
  final String id;
  const RecipeNotFoundException(this.id);
  @override
  String toString() => 'Recipe not found: $id';
}

class ImageUploadException implements Exception {
  final String message;
  const ImageUploadException(this.message);
  @override
  String toString() => 'Image upload failed: $message';
}

class GoogleAuthException implements Exception {
  final String message;
  const GoogleAuthException(this.message);
  @override
  String toString() => 'Google sign-in failed: $message';
}

class UnauthenticatedException implements Exception {
  const UnauthenticatedException();
  @override
  String toString() => 'User is not authenticated';
}

class RecipeParseException implements Exception {
  final String message;
  const RecipeParseException(this.message);
  @override
  String toString() => 'Recipe parsing failed: $message';
}

class IngredientCategorizationException implements Exception {
  final String message;
  const IngredientCategorizationException(this.message);
  @override
  String toString() => 'Ingredient categorization failed: $message';
}