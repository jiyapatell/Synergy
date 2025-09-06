enum MemberRole {
  owner,
  admin,
  member,
  viewer,
}

extension MemberRoleExtension on MemberRole {
  String get displayName {
    switch (this) {
      case MemberRole.owner:
        return 'Owner';
      case MemberRole.admin:
        return 'Admin';
      case MemberRole.member:
        return 'Member';
      case MemberRole.viewer:
        return 'Viewer';
    }
  }

  String get description {
    switch (this) {
      case MemberRole.owner:
        return 'Full access to all project features';
      case MemberRole.admin:
        return 'Can manage members and project settings';
      case MemberRole.member:
        return 'Can create and edit cards, add comments';
      case MemberRole.viewer:
        return 'Can only view project content';
    }
  }

  bool get canManageMembers {
    return this == MemberRole.owner || this == MemberRole.admin;
  }

  bool get canEditProject {
    return this == MemberRole.owner || this == MemberRole.admin || this == MemberRole.member;
  }

  bool get canCreateCards {
    return this == MemberRole.owner || this == MemberRole.admin || this == MemberRole.member;
  }
}

class TeamMember {
  final String id;
  final String userId;
  final String projectId;
  final MemberRole role;
  final DateTime joinedAt;
  final String invitedBy;
  final bool isActive;

  const TeamMember({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.role,
    required this.joinedAt,
    required this.invitedBy,
    this.isActive = true,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['id'],
      userId: json['userId'],
      projectId: json['projectId'],
      role: MemberRole.values.firstWhere(
        (e) => e.toString() == 'MemberRole.${json['role']}',
        orElse: () => MemberRole.member,
      ),
      joinedAt: DateTime.parse(json['joinedAt']),
      invitedBy: json['invitedBy'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'projectId': projectId,
      'role': role.toString().split('.').last,
      'joinedAt': joinedAt.toIso8601String(),
      'invitedBy': invitedBy,
      'isActive': isActive,
    };
  }

  TeamMember copyWith({
    String? id,
    String? userId,
    String? projectId,
    MemberRole? role,
    DateTime? joinedAt,
    String? invitedBy,
    bool? isActive,
  }) {
    return TeamMember(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      invitedBy: invitedBy ?? this.invitedBy,
      isActive: isActive ?? this.isActive,
    );
  }
}
