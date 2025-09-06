import 'dart:math';
import '../models/project.dart';
import '../models/task.dart';
import '../models/user.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

class DemoDataService {
  static final Random _random = Random();

  static List<User> getDemoUsers() {
    return AppConstants.demoUserNames.map((name) {
      final email = name.toLowerCase().replaceAll(' ', '.') + '@example.com';
      return User(
        id: DateTime.now().millisecondsSinceEpoch.toString() + _random.nextInt(1000).toString(),
        name: name,
        email: email,
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(365))),
        lastLoginAt: DateTime.now().subtract(Duration(hours: _random.nextInt(24))),
      );
    }).toList();
  }

  static List<Project> getDemoProjects(String ownerId) {
    final users = getDemoUsers();
    final projects = <Project>[];
    
    for (int i = 0; i < 5; i++) {
      final projectName = AppConstants.demoProjectNames[i % AppConstants.demoProjectNames.length];
      final memberIds = users.take(_random.nextInt(4) + 1).map((user) => user.id).toList();
      
      projects.add(Project(
        id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
        name: projectName,
        description: _getProjectDescription(projectName),
        ownerId: ownerId,
        memberIds: memberIds,
        status: ProjectStatus.values[_random.nextInt(ProjectStatus.values.length)],
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(90))),
        updatedAt: DateTime.now().subtract(Duration(days: _random.nextInt(7))),
        dueDate: _random.nextBool() ? DateTime.now().add(Duration(days: _random.nextInt(30))) : null,
        color: '#${AppTheme.projectColors[_random.nextInt(AppTheme.projectColors.length)].value.toRadixString(16).substring(2)}',
      ));
    }
    
    return projects;
  }

  static List<Task> getDemoTasks(String projectId, String creatorId) {
    final users = getDemoUsers();
    final tasks = <Task>[];
    
    for (int i = 0; i < 15; i++) {
      final taskTitle = AppConstants.demoTaskTitles[i % AppConstants.demoTaskTitles.length];
      final assignee = users[_random.nextInt(users.length)];
      
      tasks.add(Task(
        id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
        title: taskTitle,
        description: _getTaskDescription(taskTitle),
        projectId: projectId,
        assigneeId: assignee.id,
        creatorId: creatorId,
        status: TaskStatus.values[_random.nextInt(TaskStatus.values.length)],
        priority: TaskPriority.values[_random.nextInt(TaskPriority.values.length)],
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
        updatedAt: DateTime.now().subtract(Duration(days: _random.nextInt(3))),
        dueDate: _random.nextBool() ? DateTime.now().add(Duration(days: _random.nextInt(14))) : null,
        completedAt: _random.nextBool() ? DateTime.now().subtract(Duration(days: _random.nextInt(7))) : null,
        tags: _getRandomTags(),
      ));
    }
    
    return tasks;
  }

  static String _getProjectDescription(String projectName) {
    final descriptions = {
      'Website Redesign': 'Complete redesign of the company website with modern UI/UX principles and improved performance.',
      'Mobile App Development': 'Development of a cross-platform mobile application for iOS and Android platforms.',
      'Marketing Campaign': 'Launch a comprehensive marketing campaign to increase brand awareness and customer engagement.',
      'Product Launch': 'Coordinate the launch of our new product with marketing, sales, and development teams.',
      'Customer Support': 'Improve customer support processes and implement new tools for better customer satisfaction.',
      'Data Migration': 'Migrate legacy data to new systems while ensuring data integrity and minimal downtime.',
      'Security Audit': 'Conduct a comprehensive security audit and implement necessary security improvements.',
      'Performance Optimization': 'Optimize application performance and improve user experience across all platforms.',
    };
    
    return descriptions[projectName] ?? 'A collaborative project to achieve our team goals and deliver exceptional results.';
  }

  static String _getTaskDescription(String taskTitle) {
    final descriptions = {
      'Create wireframes': 'Design low-fidelity wireframes for the main user interface components.',
      'Set up development environment': 'Configure development tools, dependencies, and project structure.',
      'Design user interface': 'Create high-fidelity UI designs following the design system guidelines.',
      'Implement authentication': 'Build secure user authentication and authorization system.',
      'Write unit tests': 'Create comprehensive unit tests for all core functionality.',
      'Deploy to staging': 'Deploy the application to staging environment for testing.',
      'Code review': 'Review code changes and provide feedback for improvements.',
      'Update documentation': 'Update project documentation and API references.',
      'Fix bugs': 'Identify and resolve bugs found during testing.',
      'Performance testing': 'Conduct performance testing and optimization.',
    };
    
    return descriptions[taskTitle] ?? 'Complete this task according to the project requirements and specifications.';
  }

  static List<String> _getRandomTags() {
    final allTags = ['frontend', 'backend', 'design', 'testing', 'documentation', 'urgent', 'feature', 'bugfix'];
    final numTags = _random.nextInt(3) + 1;
    return allTags..shuffle()..take(numTags).toList();
  }
}
