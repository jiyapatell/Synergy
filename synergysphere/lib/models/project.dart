import 'user.dart';

enum ProjectStatus {
  active,
  completed,
  onHold,
  cancelled,
}

class Project {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final List<String> memberIds;
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? dueDate;
  final String? color;

  Project({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.memberIds,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.color,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      ownerId: json['ownerId'] ?? '',
      memberIds: List<String>.from(json['memberIds'] ?? []),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProjectStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'color': color,
    };
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    List<String>? memberIds,
    ProjectStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    String? color,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      color: color ?? this.color,
    );
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && status != ProjectStatus.completed;
  }

  int get totalMembers => memberIds.length + 1; // +1 for owner
}
