import 'card.dart';

class ProjectList {
  final String id;
  final String name;
  final String projectId;
  final int position;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectList({
    required this.id,
    required this.name,
    required this.projectId,
    required this.position,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectList.fromJson(Map<String, dynamic> json) {
    return ProjectList(
      id: json['id'],
      name: json['name'],
      projectId: json['projectId'],
      position: json['position'],
      isArchived: json['isArchived'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'projectId': projectId,
      'position': position,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ProjectList copyWith({
    String? id,
    String? name,
    String? projectId,
    int? position,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectList(
      id: id ?? this.id,
      name: name ?? this.name,
      projectId: projectId ?? this.projectId,
      position: position ?? this.position,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
