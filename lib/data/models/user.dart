class User {
  final String id;
  final String email;
  final String? name;
  final String role;
  final String? avatarUrl;

  User({
    required this.id,
    required this.email,
    this.name,
    this.role = 'buyer',
    this.avatarUrl,
  });

  factory User.fromTokenPayload(Map<String, dynamic> payload, {String? name}) {
    return User(
      id: payload['user_id']?.toString() ?? '0',
      email: payload['email'] ?? '',
      role: payload['role'] ?? 'buyer',
      name: name ?? 'Имя',
    );
  }
}