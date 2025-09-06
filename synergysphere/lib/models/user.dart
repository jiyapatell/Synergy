class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  String get initials {
    return name.split(' ').map((word) => word.isNotEmpty ? word[0].toUpperCase() : '').join('');
  }
}
