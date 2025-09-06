import 'package:flutter/foundation.dart';
import '../models/project.dart';
import '../services/project_service.dart';
import '../services/demo_data_service.dart';

class ProjectProvider with ChangeNotifier {
  List<Project> _projects = [];
  Project? _currentProject;
  bool _isLoading = false;
  String? _errorMessage;

  List<Project> get projects => _projects;
  Project? get currentProject => _currentProject;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProjects(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // For demo purposes, load demo data instead of real data
      _projects = DemoDataService.getDemoProjects(userId);
    } catch (e) {
      _errorMessage = 'Failed to load projects';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProject(String projectId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentProject = await ProjectService.getProject(projectId);
      if (_currentProject == null) {
        _errorMessage = 'Project not found';
      }
    } catch (e) {
      _errorMessage = 'Failed to load project';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Project?> createProject({
    required String name,
    required String description,
    required String ownerId,
    String? color,
    DateTime? dueDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final project = await ProjectService.createProject(
        name: name,
        description: description,
        ownerId: ownerId,
        color: color,
        dueDate: dueDate,
      );
      
      _projects.add(project);
      _currentProject = project;
      return project;
    } catch (e) {
      _errorMessage = 'Failed to create project';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProject(Project project) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedProject = await ProjectService.updateProject(project);
      
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index >= 0) {
        _projects[index] = updatedProject;
      }
      
      if (_currentProject?.id == project.id) {
        _currentProject = updatedProject;
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update project';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteProject(String projectId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ProjectService.deleteProject(projectId);
      _projects.removeWhere((project) => project.id == projectId);
      
      if (_currentProject?.id == projectId) {
        _currentProject = null;
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete project';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMemberToProject(String projectId, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedProject = await ProjectService.addMemberToProject(projectId, userId);
      
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index >= 0) {
        _projects[index] = updatedProject;
      }
      
      if (_currentProject?.id == projectId) {
        _currentProject = updatedProject;
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add member to project';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeMemberFromProject(String projectId, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedProject = await ProjectService.removeMemberFromProject(projectId, userId);
      
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index >= 0) {
        _projects[index] = updatedProject;
      }
      
      if (_currentProject?.id == projectId) {
        _currentProject = updatedProject;
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove member from project';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentProject(Project? project) {
    _currentProject = project;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
