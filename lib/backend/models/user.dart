class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarInitials;
  final DateTime createdAt;
  final int streakDays;
  final int totalTaken;
  final int totalMissed;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarInitials,
    required this.createdAt,
    this.streakDays = 0,
    this.totalTaken = 0,
    this.totalMissed = 0,
  });

  String get initials {
    if (avatarInitials != null) return avatarInitials!;
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  double get adherenceRate {
    final total = totalTaken + totalMissed;
    if (total == 0) return 0;
    return totalTaken / total;
  }

  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarInitials,
    int? streakDays,
    int? totalTaken,
    int? totalMissed,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      createdAt: createdAt,
      streakDays: streakDays ?? this.streakDays,
      totalTaken: totalTaken ?? this.totalTaken,
      totalMissed: totalMissed ?? this.totalMissed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatarInitials': avatarInitials,
        'createdAt': createdAt.toIso8601String(),
        'streakDays': streakDays,
        'totalTaken': totalTaken,
        'totalMissed': totalMissed,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        avatarInitials: json['avatarInitials'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        streakDays: json['streakDays'] as int? ?? 0,
        totalTaken: json['totalTaken'] as int? ?? 0,
        totalMissed: json['totalMissed'] as int? ?? 0,
      );

  static User get defaultUser => User(
        id: 'default_user',
        name: 'Alex Johnson',
        email: 'alex.johnson@example.com',
        phone: '+1 (555) 123-4567',
        createdAt: DateTime.now(),
        streakDays: 5,
        totalTaken: 42,
        totalMissed: 3,
      );
}
