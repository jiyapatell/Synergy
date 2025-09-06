import 'package:flutter/material.dart';

enum CardStatus {
  todo,
  inProgress,
  review,
  done,
}

extension CardStatusExtension on CardStatus {
  String get displayName {
    switch (this) {
      case CardStatus.todo:
        return 'To Do';
      case CardStatus.inProgress:
        return 'In Progress';
      case CardStatus.review:
        return 'Review';
      case CardStatus.done:
        return 'Done';
    }
  }

  Color get color {
    switch (this) {
      case CardStatus.todo:
        return const Color(0xFF6B7280);
      case CardStatus.inProgress:
        return const Color(0xFF3B82F6);
      case CardStatus.review:
        return const Color(0xFFF59E0B);
      case CardStatus.done:
        return const Color(0xFF10B981);
    }
  }
}

class CardLabel {
  final String id;
  final String name;
  final Color color;

  const CardLabel({
    required this.id,
    required this.name,
    required this.color,
  });

  factory CardLabel.fromJson(Map<String, dynamic> json) {
    return CardLabel(
      id: json['id'],
      name: json['name'],
      color: Color(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
    };
  }
}

class ChecklistItem {
  final String id;
  final String text;
  final bool isCompleted;
  final DateTime createdAt;

  const ChecklistItem({
    required this.id,
    required this.text,
    required this.isCompleted,
    required this.createdAt,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'],
      text: json['text'],
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ChecklistItem copyWith({
    String? id,
    String? text,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class CardAttachment {
  final String id;
  final String name;
  final String url;
  final String type; // 'image', 'document', 'link'
  final DateTime uploadedAt;
  final String uploadedBy;

  const CardAttachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  factory CardAttachment.fromJson(Map<String, dynamic> json) {
    return CardAttachment(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      type: json['type'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
      uploadedBy: json['uploadedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'type': type,
      'uploadedAt': uploadedAt.toIso8601String(),
      'uploadedBy': uploadedBy,
    };
  }
}

class CardComment {
  final String id;
  final String text;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final List<String> mentions;

  const CardComment({
    required this.id,
    required this.text,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.mentions = const [],
  });

  factory CardComment.fromJson(Map<String, dynamic> json) {
    return CardComment(
      id: json['id'],
      text: json['text'],
      authorId: json['authorId'],
      authorName: json['authorName'],
      createdAt: DateTime.parse(json['createdAt']),
      mentions: List<String>.from(json['mentions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt.toIso8601String(),
      'mentions': mentions,
    };
  }
}

class ProjectCard {
  final String id;
  final String title;
  final String description;
  final String projectId;
  final String listId;
  final CardStatus status;
  final List<String> assigneeIds;
  final List<CardLabel> labels;
  final List<ChecklistItem> checklist;
  final List<CardAttachment> attachments;
  final List<CardComment> comments;
  final DateTime? dueDate;
  final int position;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;

  const ProjectCard({
    required this.id,
    required this.title,
    required this.description,
    required this.projectId,
    required this.listId,
    required this.status,
    this.assigneeIds = const [],
    this.labels = const [],
    this.checklist = const [],
    this.attachments = const [],
    this.comments = const [],
    this.dueDate,
    required this.position,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,
  });

  factory ProjectCard.fromJson(Map<String, dynamic> json) {
    return ProjectCard(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      projectId: json['projectId'],
      listId: json['listId'],
      status: CardStatus.values.firstWhere(
        (e) => e.toString() == 'CardStatus.${json['status']}',
        orElse: () => CardStatus.todo,
      ),
      assigneeIds: List<String>.from(json['assigneeIds'] ?? []),
      labels: (json['labels'] as List<dynamic>?)
          ?.map((label) => CardLabel.fromJson(label))
          .toList() ?? [],
      checklist: (json['checklist'] as List<dynamic>?)
          ?.map((item) => ChecklistItem.fromJson(item))
          .toList() ?? [],
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((attachment) => CardAttachment.fromJson(attachment))
          .toList() ?? [],
      comments: (json['comments'] as List<dynamic>?)
          ?.map((comment) => CardComment.fromJson(comment))
          .toList() ?? [],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      position: json['position'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isArchived: json['isArchived'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'projectId': projectId,
      'listId': listId,
      'status': status.toString().split('.').last,
      'assigneeIds': assigneeIds,
      'labels': labels.map((label) => label.toJson()).toList(),
      'checklist': checklist.map((item) => item.toJson()).toList(),
      'attachments': attachments.map((attachment) => attachment.toJson()).toList(),
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'dueDate': dueDate?.toIso8601String(),
      'position': position,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  ProjectCard copyWith({
    String? id,
    String? title,
    String? description,
    String? projectId,
    String? listId,
    CardStatus? status,
    List<String>? assigneeIds,
    List<CardLabel>? labels,
    List<ChecklistItem>? checklist,
    List<CardAttachment>? attachments,
    List<CardComment>? comments,
    DateTime? dueDate,
    int? position,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return ProjectCard(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      listId: listId ?? this.listId,
      status: status ?? this.status,
      assigneeIds: assigneeIds ?? this.assigneeIds,
      labels: labels ?? this.labels,
      checklist: checklist ?? this.checklist,
      attachments: attachments ?? this.attachments,
      comments: comments ?? this.comments,
      dueDate: dueDate ?? this.dueDate,
      position: position ?? this.position,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  double get checklistProgress {
    if (checklist.isEmpty) return 0.0;
    final completedItems = checklist.where((item) => item.isCompleted).length;
    return completedItems / checklist.length;
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return DateTime.now().isAfter(dueDate!) && status != CardStatus.done;
  }
}
