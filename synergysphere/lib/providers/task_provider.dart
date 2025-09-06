import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/demo_data_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  Task? _currentTask;
  bool _isLoading = false;
  String? _errorMessage;

  List<Task> get tasks => _tasks;
  Task? get currentTask => _currentTask;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProjectTasks(String projectId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // For demo purposes, load demo data instead of real data
      _tasks = DemoDataService.getDemoTasks(projectId, 'demo_user_id');
    } catch (e) {
      _errorMessage = 'Failed to load tasks';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserTasks(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await TaskService.getUserTasks(userId);
    } catch (e) {
      _errorMessage = 'Failed to load tasks';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTask(String taskId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentTask = await TaskService.getTask(taskId);
      if (_currentTask == null) {
        _errorMessage = 'Task not found';
      }
    } catch (e) {
      _errorMessage = 'Failed to load task';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Task?> createTask({
    required String title,
    required String description,
    required String projectId,
    required String assigneeId,
    required String creatorId,
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    List<String> tags = const [],
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final task = await TaskService.createTask(
        title: title,
        description: description,
        projectId: projectId,
        assigneeId: assigneeId,
        creatorId: creatorId,
        priority: priority,
        dueDate: dueDate,
        tags: tags,
      );
      
      _tasks.add(task);
      return task;
    } catch (e) {
      _errorMessage = 'Failed to create task';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTask(Task task) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTask = await TaskService.updateTask(task);
      
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index >= 0) {
        _tasks[index] = updatedTask;
      }
      
      if (_currentTask?.id == task.id) {
        _currentTask = updatedTask;
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update task';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTaskStatus(String taskId, TaskStatus status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTask = await TaskService.updateTaskStatus(taskId, status);
      
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index >= 0) {
        _tasks[index] = updatedTask;
      }
      
      if (_currentTask?.id == taskId) {
        _currentTask = updatedTask;
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update task status';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> assignTask(String taskId, String assigneeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTask = await TaskService.assignTask(taskId, assigneeId);
      
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index >= 0) {
        _tasks[index] = updatedTask;
      }
      
      if (_currentTask?.id == taskId) {
        _currentTask = updatedTask;
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to assign task';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTask(String taskId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await TaskService.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      
      if (_currentTask?.id == taskId) {
        _currentTask = null;
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete task';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<TaskStatus, int>> getTaskStatusCounts(String projectId) async {
    try {
      return await TaskService.getTaskStatusCounts(projectId);
    } catch (e) {
      _errorMessage = 'Failed to get task status counts';
      return {};
    }
  }

  Future<List<Task>> getOverdueTasks(String projectId) async {
    try {
      return await TaskService.getOverdueTasks(projectId);
    } catch (e) {
      _errorMessage = 'Failed to get overdue tasks';
      return [];
    }
  }

  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  List<Task> getTasksByPriority(TaskPriority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  void setCurrentTask(Task? task) {
    _currentTask = task;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
