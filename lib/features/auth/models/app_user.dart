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

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    email: json['email'] as String? ?? '',
    username: json['username'] as String,
    avatarUrl: json['avatar_url'] as String?,
    signupDate: DateTime.parse(json['created_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'avatar_url': avatarUrl,
  };
}
