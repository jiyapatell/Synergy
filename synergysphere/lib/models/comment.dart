import 'user.dart';

class Comment {
  final String id;
  final String content;
  final String authorId;
  final String projectId;
  final String? taskId; // null if it's a project-level comment
  final String? parentCommentId; // for threaded discussions
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> childCommentIds;

  Comment({
    required this.id,
    required this.content,
    required this.authorId,
    required this.projectId,
    this.taskId,
    this.parentCommentId,
    required this.createdAt,
    this.updatedAt,
    this.childCommentIds = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      authorId: json['authorId'] ?? '',
      projectId: json['projectId'] ?? '',
      taskId: json['taskId'],
      parentCommentId: json['parentCommentId'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      childCommentIds: List<String>.from(json['childCommentIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'authorId': authorId,
      'projectId': projectId,
      'taskId': taskId,
      'parentCommentId': parentCommentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'childCommentIds': childCommentIds,
    };
  }

  Comment copyWith({
    String? id,
    String? content,
    String? authorId,
    String? projectId,
    String? taskId,
    String? parentCommentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? childCommentIds,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      projectId: projectId ?? this.projectId,
      taskId: taskId ?? this.taskId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      childCommentIds: childCommentIds ?? this.childCommentIds,
    );
  }

  bool get isReply => parentCommentId != null;
  bool get hasReplies => childCommentIds.isNotEmpty;
}
