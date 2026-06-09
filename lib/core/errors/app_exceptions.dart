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