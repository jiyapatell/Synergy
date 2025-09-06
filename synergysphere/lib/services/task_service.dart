import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskService {
  static const String _tasksKey = 'tasks';

  static Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_tasksKey) ?? [];
    return tasksJson.map((json) => Task.fromJson(jsonDecode(json))).toList();
  }

  static Future<List<Task>> getProjectTasks(String projectId) async {
    final tasks = await getTasks();
    return tasks.where((task) => task.projectId == projectId).toList();
  }

  static Future<List<Task>> getUserTasks(String userId) async {
    final tasks = await getTasks();
    return tasks.where((task) => task.assigneeId == userId).toList();
  }

  static Future<Task?> getTask(String taskId) async {
    final tasks = await getTasks();
    try {
      return tasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  static Future<Task> createTask({
    required String title,
    required String description,
    required String projectId,
    required String assigneeId,
    required String creatorId,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    List<String> tags = const [],
  }) async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      projectId: projectId,
      assigneeId: assigneeId,
      creatorId: creatorId,
      status: TaskStatus.todo,
      priority: priority,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      tags: tags,
    );

    await _saveTask(task);
    return task;
  }

  static Future<Task> updateTask(Task task) async {
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    await _saveTask(updatedTask);
    return updatedTask;
  }

  static Future<Task> updateTaskStatus(String taskId, TaskStatus status) async {
    final task = await getTask(taskId);
    if (task == null) throw Exception('Task not found');

    final updatedTask = task.copyWith(
      status: status,
      updatedAt: DateTime.now(),
      completedAt: status == TaskStatus.done ? DateTime.now() : null,
    );

    await _saveTask(updatedTask);
    return updatedTask;
  }

  static Future<Task> assignTask(String taskId, String assigneeId) async {
    final task = await getTask(taskId);
    if (task == null) throw Exception('Task not found');

    final updatedTask = task.copyWith(
      assigneeId: assigneeId,
      updatedAt: DateTime.now(),
    );

    await _saveTask(updatedTask);
    return updatedTask;
  }

  static Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((task) => task.id == taskId);
    await _saveTasks(tasks);
  }

  static Future<Map<TaskStatus, int>> getTaskStatusCounts(String projectId) async {
    final tasks = await getProjectTasks(projectId);
    final counts = <TaskStatus, int>{};
    
    for (final status in TaskStatus.values) {
      counts[status] = tasks.where((task) => task.status == status).length;
    }
    
    return counts;
  }

  static Future<List<Task>> getOverdueTasks(String projectId) async {
    final tasks = await getProjectTasks(projectId);
    return tasks.where((task) => task.isOverdue).toList();
  }

  static Future<List<Task>> getTasksByPriority(String projectId, TaskPriority priority) async {
    final tasks = await getProjectTasks(projectId);
    return tasks.where((task) => task.priority == priority).toList();
  }

  static Future<void> _saveTask(Task task) async {
    final tasks = await getTasks();
    final existingIndex = tasks.indexWhere((t) => t.id == task.id);
    
    if (existingIndex >= 0) {
      tasks[existingIndex] = task;
    } else {
      tasks.add(task);
    }
    
    await _saveTasks(tasks);
  }

  static Future<void> _saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList(_tasksKey, tasksJson);
  }
}
