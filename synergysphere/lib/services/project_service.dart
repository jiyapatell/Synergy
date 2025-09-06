import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';
import '../models/user.dart';

class ProjectService {
  static const String _projectsKey = 'projects';

  static Future<List<Project>> getProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = prefs.getStringList(_projectsKey) ?? [];
    return projectsJson.map((json) => Project.fromJson(jsonDecode(json))).toList();
  }

  static Future<Project?> getProject(String projectId) async {
    final projects = await getProjects();
    try {
      return projects.firstWhere((project) => project.id == projectId);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Project>> getUserProjects(String userId) async {
    final projects = await getProjects();
    return projects.where((project) => 
      project.ownerId == userId || project.memberIds.contains(userId)).toList();
  }

  static Future<Project> createProject({
    required String name,
    required String description,
    required String ownerId,
    String? color,
    DateTime? dueDate,
  }) async {
    final project = Project(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      ownerId: ownerId,
      memberIds: [],
      status: ProjectStatus.active,
      createdAt: DateTime.now(),
      color: color ?? _getRandomColor(),
      dueDate: dueDate,
    );

    await _saveProject(project);
    return project;
  }

  static Future<Project> updateProject(Project project) async {
    final updatedProject = project.copyWith(updatedAt: DateTime.now());
    await _saveProject(updatedProject);
    return updatedProject;
  }

  static Future<void> deleteProject(String projectId) async {
    final projects = await getProjects();
    projects.removeWhere((project) => project.id == projectId);
    await _saveProjects(projects);
  }

  static Future<Project> addMemberToProject(String projectId, String userId) async {
    final project = await getProject(projectId);
    if (project == null) throw Exception('Project not found');

    final updatedProject = project.copyWith(
      memberIds: [...project.memberIds, userId],
      updatedAt: DateTime.now(),
    );

    await _saveProject(updatedProject);
    return updatedProject;
  }

  static Future<Project> removeMemberFromProject(String projectId, String userId) async {
    final project = await getProject(projectId);
    if (project == null) throw Exception('Project not found');

    final updatedMemberIds = List<String>.from(project.memberIds);
    updatedMemberIds.remove(userId);

    final updatedProject = project.copyWith(
      memberIds: updatedMemberIds,
      updatedAt: DateTime.now(),
    );

    await _saveProject(updatedProject);
    return updatedProject;
  }

  static Future<void> _saveProject(Project project) async {
    final projects = await getProjects();
    final existingIndex = projects.indexWhere((p) => p.id == project.id);
    
    if (existingIndex >= 0) {
      projects[existingIndex] = project;
    } else {
      projects.add(project);
    }
    
    await _saveProjects(projects);
  }

  static Future<void> _saveProjects(List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final projectsJson = projects.map((project) => jsonEncode(project.toJson())).toList();
    await prefs.setStringList(_projectsKey, projectsJson);
  }

  static String _getRandomColor() {
    final colors = [
      '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4', '#FFEAA7',
      '#DDA0DD', '#98D8C8', '#F7DC6F', '#BB8FCE', '#85C1E9'
    ];
    return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
  }
}
