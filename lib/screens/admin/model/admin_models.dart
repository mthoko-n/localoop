// lib/screens/admin/model/admin_models.dart

class SystemMetrics {
  final UserMetrics users;
  final ContentMetrics content;
  final LocationMetrics locations;
  final SessionMetrics sessions;

  SystemMetrics({
    required this.users,
    required this.content,
    required this.locations,
    required this.sessions,
  });

  factory SystemMetrics.fromJson(Map<String, dynamic> json) {
    return SystemMetrics(
      users: UserMetrics.fromJson(json['users'] ?? {}),
      content: ContentMetrics.fromJson(json['content'] ?? {}),
      locations: LocationMetrics.fromJson(json['locations'] ?? {}),
      sessions: SessionMetrics.fromJson(json['sessions'] ?? {}),
    );
  }
}

class UserMetrics {
  final int total;
  final int active;
  final int banned;
  final int admins;
  final int newThisWeek;

  UserMetrics({
    required this.total,
    required this.active,
    required this.banned,
    required this.admins,
    required this.newThisWeek,
  });

  factory UserMetrics.fromJson(Map<String, dynamic> json) {
    return UserMetrics(
      total: json['total'] ?? 0,
      active: json['active'] ?? 0,
      banned: json['banned'] ?? 0,
      admins: json['admins'] ?? 0,
      newThisWeek: json['new_this_week'] ?? 0,
    );
  }
}

class ContentMetrics {
  final int totalConversations;
  final int activeConversations;
  final int totalMessages;
  final int activeMessages;

  ContentMetrics({
    required this.totalConversations,
    required this.activeConversations,
    required this.totalMessages,
    required this.activeMessages,
  });

  factory ContentMetrics.fromJson(Map<String, dynamic> json) {
    return ContentMetrics(
      totalConversations: json['total_conversations'] ?? 0,
      activeConversations: json['active_conversations'] ?? 0,
      totalMessages: json['total_messages'] ?? 0,
      activeMessages: json['active_messages'] ?? 0,
    );
  }
}

class LocationMetrics {
  final int totalUserLocations;
  final int activeUserLocations;
  final int uniqueLocations;

  LocationMetrics({
    required this.totalUserLocations,
    required this.activeUserLocations,
    required this.uniqueLocations,
  });

  factory LocationMetrics.fromJson(Map<String, dynamic> json) {
    return LocationMetrics(
      totalUserLocations: json['total_user_locations'] ?? 0,
      activeUserLocations: json['active_user_locations'] ?? 0,
      uniqueLocations: json['unique_locations'] ?? 0,
    );
  }
}

class SessionMetrics {
  final int activeSessions;

  SessionMetrics({
    required this.activeSessions,
  });

  factory SessionMetrics.fromJson(Map<String, dynamic> json) {
    return SessionMetrics(
      activeSessions: json['active_sessions'] ?? 0,
    );
  }
}

class AdminUser {
  final String id;
  final String email;
  final String displayName;
  final String lastName;
  final bool isActive;
  final bool isAdmin;
  final String? deletedAt;
  final String? deletionReason;

  AdminUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.lastName,
    required this.isActive,
    required this.isAdmin,
    this.deletedAt,
    this.deletionReason,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['display_name'] ?? '',
      lastName: json['last_name'] ?? '',
      isActive: json['is_active'] ?? true,
      isAdmin: json['is_admin'] ?? false,
      deletedAt: json['deleted_at'],
      deletionReason: json['deletion_reason'],
    );
  }

  String get fullName => '$displayName $lastName'.trim();
  
  String get status {
    if (!isActive) return 'Banned';
    if (isAdmin) return 'Admin';
    return 'Active';
  }
}

class UsersListResponse {
  final bool success;
  final List<AdminUser> users;
  final PaginationInfo pagination;

  UsersListResponse({
    required this.success,
    required this.users,
    required this.pagination,
  });

  factory UsersListResponse.fromJson(Map<String, dynamic> json) {
    return UsersListResponse(
      success: json['success'] ?? false,
      users: (json['users'] as List? ?? [])
          .map((user) => AdminUser.fromJson(user))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int limit;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.limit,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalItems: json['total_users'] ?? json['total_locations'] ?? 0,
      limit: json['limit'] ?? 50,
    );
  }

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
}