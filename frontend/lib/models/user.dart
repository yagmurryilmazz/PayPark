class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String phone;
  final String avatarUrl;

  AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.phone,
    required this.avatarUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final email = json['email'] ?? '';

    return AppUser(
      id: json['id'] ?? '',
      email: email,
      fullName: (json['full_name'] ?? '').toString().isNotEmpty
          ? json['full_name']
          : 'User',
      role: json['role'] ?? 'driver',
      phone: json['phone'] ?? 'Phone not set',
      avatarUrl: json['avatar_url'] ??
          'https://api.dicebear.com/7.x/identicon/svg?seed=$email',
    );
  }
}
