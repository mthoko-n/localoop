class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String lastName;
  final String memberSince;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.lastName,
    required this.memberSince,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      memberSince: json['member_since'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'last_name': lastName,
      'member_since': memberSince,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? lastName,
    String? memberSince,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      lastName: lastName ?? this.lastName,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}