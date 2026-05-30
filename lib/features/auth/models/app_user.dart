class AppUser {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final DateTime signupDate;

  const AppUser({
    required this.id,
    required this.email,
    required this.username,
    required this.signupDate,
    this.avatarUrl,
  });
}
