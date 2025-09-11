class LocationStatus {
  final String locationId;
  final int unreadCount;
  final String status; // "new_messages" or "caught_up"
  final String lastActivity;
  final int activeUsers;

  LocationStatus({
    required this.locationId,
    required this.unreadCount,
    required this.status,
    required this.lastActivity,
    required this.activeUsers,
  });

  factory LocationStatus.fromJson(Map<String, dynamic> json) {
    return LocationStatus(
      locationId: json['location_id'],
      unreadCount: json['unread_count'],
      status: json['status'],
      lastActivity: json['last_activity'],
      activeUsers: json['active_users'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'unread_count': unreadCount,
      'status': status,
      'last_activity': lastActivity,
      'active_users': activeUsers,
    };
  }
}
