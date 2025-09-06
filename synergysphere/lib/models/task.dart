import 'user.dart';

enum TaskStatus {
  todo,
  inProgress,
  done,
  cancelled,
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

class Task {
  final String id;
  final String title;
  final String description;
  final String projectId;
  final String assigneeId;
  final String creatorId;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final List<String> tags;
  final List<String> commentIds;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.projectId,
    required this.assigneeId,
    required this.creatorId,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.updatedAt,
    this.dueDate,
    this.completedAt,
    this.tags = const [],
    this.commentIds = const [],
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      projectId: json['projectId'] ?? '',
      assigneeId: json['assigneeId'] ?? '',
      creatorId: json['creatorId'] ?? '',
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      tags: List<String>.from(json['tags'] ?? []),
      commentIds: List<String>.from(json['commentIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'projectId': projectId,
      'assigneeId': assigneeId,
      'creatorId': creatorId,
      'status': status.name,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'tags': tags,
      'commentIds': commentIds,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? projectId,
    String? assigneeId,
    String? creatorId,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? dueDate,
    DateTime? completedAt,
    List<String>? tags,
    List<String>? commentIds,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      assigneeId: assigneeId ?? this.assigneeId,
      creatorId: creatorId ?? this.creatorId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
      commentIds: commentIds ?? this.commentIds,
    );
  }

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.done) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isCompleted => status == TaskStatus.done;

  Duration? get timeUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now());
  }

  String get statusDisplayName {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }
}
