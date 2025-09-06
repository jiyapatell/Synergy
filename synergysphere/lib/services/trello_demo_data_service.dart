import 'dart:math';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/project.dart';
import '../models/card.dart';
import '../models/project_list.dart';
import '../models/team_member.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

class TrelloDemoDataService {
  static final Random _random = Random();

  static List<User> getDemoUsers() {
    return [
      User(
        id: 'user_1',
        name: 'John Doe',
        email: 'john@example.com',
        avatarUrl: 'https://i.pravatar.cc/150?img=1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      User(
        id: 'user_2',
        name: 'Jane Smith',
        email: 'jane@example.com',
        avatarUrl: 'https://i.pravatar.cc/150?img=2',
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      User(
        id: 'user_3',
        name: 'Mike Johnson',
        email: 'mike@example.com',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      User(
        id: 'user_4',
        name: 'Sarah Wilson',
        email: 'sarah@example.com',
        avatarUrl: 'https://i.pravatar.cc/150?img=4',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      User(
        id: 'user_5',
        name: 'David Brown',
        email: 'david@example.com',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ];
  }

  static List<Project> getDemoProjects(String ownerId) {
    final users = getDemoUsers();
    final projects = <Project>[];

    final projectTitles = [
      'Website Redesign',
      'Mobile App Development',
      'Marketing Campaign',
      'Product Launch',
      'Customer Support',
    ];

    for (int i = 0; i < projectTitles.length; i++) {
      final projectName = projectTitles[i];
      final memberIds = users.take(_random.nextInt(3) + 2).map((u) => u.id).toList();
      
      projects.add(Project(
        id: 'project_${i + 1}',
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

  static List<ProjectList> getDemoProjectLists(String projectId) {
    final listNames = [
      'To Do',
      'In Progress',
      'Review',
      'Done',
    ];

    return listNames.asMap().entries.map((entry) {
      return ProjectList(
        id: 'list_${projectId}_${entry.key}',
        name: entry.value,
        projectId: projectId,
        position: entry.key,
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
        updatedAt: DateTime.now().subtract(Duration(days: _random.nextInt(7))),
      );
    }).toList();
  }

  static List<ProjectCard> getDemoCards(String projectId, String listId) {
    final users = getDemoUsers();
    final cards = <ProjectCard>[];

    final cardTitles = [
      'Design new homepage layout',
      'Implement user authentication',
      'Create mobile responsive design',
      'Set up database schema',
      'Write API documentation',
      'Conduct user testing',
      'Fix bug in payment system',
      'Optimize page loading speed',
      'Add dark mode support',
      'Integrate third-party services',
    ];

    final labels = [
      CardLabel(id: 'label_1', name: 'Frontend', color: const Color(0xFF3B82F6)),
      CardLabel(id: 'label_2', name: 'Backend', color: const Color(0xFF10B981)),
      CardLabel(id: 'label_3', name: 'Design', color: const Color(0xFFF59E0B)),
      CardLabel(id: 'label_4', name: 'Bug', color: const Color(0xFFEF4444)),
      CardLabel(id: 'label_5', name: 'Feature', color: const Color(0xFF8B5CF6)),
    ];

    for (int i = 0; i < _random.nextInt(5) + 3; i++) {
      final title = cardTitles[_random.nextInt(cardTitles.length)];
      final assigneeIds = users.take(_random.nextInt(3) + 1).map((u) => u.id).toList();
      final cardLabels = labels.take(_random.nextInt(3) + 1).toList();
      
      cards.add(ProjectCard(
        id: 'card_${projectId}_${listId}_${i}',
        title: title,
        description: _getCardDescription(title),
        projectId: projectId,
        listId: listId,
        status: _getCardStatusFromListId(listId),
        assigneeIds: assigneeIds,
        labels: cardLabels,
        checklist: _generateChecklist(),
        attachments: _generateAttachments(),
        comments: _generateComments(users),
        dueDate: _random.nextBool() ? DateTime.now().add(Duration(days: _random.nextInt(14))) : null,
        position: i,
        createdBy: users[_random.nextInt(users.length)].id,
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
        updatedAt: DateTime.now().subtract(Duration(days: _random.nextInt(7))),
      ));
    }

    return cards;
  }

  static List<TeamMember> getDemoTeamMembers(String projectId) {
    final users = getDemoUsers();
    final members = <TeamMember>[];

    for (int i = 0; i < users.length; i++) {
      final role = i == 0 ? MemberRole.owner : 
                   i == 1 ? MemberRole.admin : 
                   _random.nextBool() ? MemberRole.member : MemberRole.viewer;
      
      members.add(TeamMember(
        id: 'member_${projectId}_${i}',
        userId: users[i].id,
        projectId: projectId,
        role: role,
        joinedAt: DateTime.now().subtract(Duration(days: _random.nextInt(60))),
        invitedBy: users[0].id,
      ));
    }

    return members;
  }

  static String _getProjectDescription(String projectName) {
    final descriptions = {
      'Website Redesign': 'Complete overhaul of our company website with modern design and improved user experience.',
      'Mobile App Development': 'Building a cross-platform mobile application for iOS and Android.',
      'Marketing Campaign': 'Launching a comprehensive marketing campaign to increase brand awareness.',
      'Product Launch': 'Preparing for the launch of our new product with all necessary preparations.',
      'Customer Support': 'Improving customer support processes and implementing new tools.',
    };
    return descriptions[projectName] ?? 'A collaborative project to achieve our goals.';
  }

  static String _getCardDescription(String cardTitle) {
    final descriptions = {
      'Design new homepage layout': 'Create a modern, responsive homepage layout that showcases our products effectively.',
      'Implement user authentication': 'Set up secure user authentication system with login, registration, and password reset.',
      'Create mobile responsive design': 'Ensure all pages are fully responsive and work perfectly on mobile devices.',
      'Set up database schema': 'Design and implement the database structure for the application.',
      'Write API documentation': 'Create comprehensive documentation for all API endpoints.',
      'Conduct user testing': 'Organize and conduct user testing sessions to gather feedback.',
      'Fix bug in payment system': 'Resolve the issue with payment processing that users are experiencing.',
      'Optimize page loading speed': 'Improve performance and reduce page load times.',
      'Add dark mode support': 'Implement dark mode theme for better user experience.',
      'Integrate third-party services': 'Connect with external APIs and services as needed.',
    };
    return descriptions[cardTitle] ?? 'Complete this task to move the project forward.';
  }

  static CardStatus _getCardStatusFromListId(String listId) {
    if (listId.contains('todo')) return CardStatus.todo;
    if (listId.contains('progress')) return CardStatus.inProgress;
    if (listId.contains('review')) return CardStatus.review;
    if (listId.contains('done')) return CardStatus.done;
    return CardStatus.todo;
  }

  static List<ChecklistItem> _generateChecklist() {
    final checklistItems = [
      'Research requirements',
      'Create wireframes',
      'Get approval from stakeholders',
      'Implement solution',
      'Test functionality',
      'Deploy to production',
    ];

    return checklistItems.take(_random.nextInt(4) + 2).map((item) {
      return ChecklistItem(
        id: 'checklist_${_random.nextInt(1000)}',
        text: item,
        isCompleted: _random.nextBool(),
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(10))),
      );
    }).toList();
  }

  static List<CardAttachment> _generateAttachments() {
    if (_random.nextBool()) return [];

    final attachmentTypes = ['image', 'document', 'link'];
    final attachmentNames = [
      'design_mockup.png',
      'requirements.pdf',
      'reference_link',
      'user_feedback.docx',
    ];

    return attachmentTypes.take(_random.nextInt(2) + 1).map((type) {
      return CardAttachment(
        id: 'attachment_${_random.nextInt(1000)}',
        name: attachmentNames[_random.nextInt(attachmentNames.length)],
        url: 'https://example.com/${_random.nextInt(1000)}',
        type: type,
        uploadedAt: DateTime.now().subtract(Duration(days: _random.nextInt(5))),
        uploadedBy: 'user_${_random.nextInt(5) + 1}',
      );
    }).toList();
  }

  static List<CardComment> _generateComments(List<User> users) {
    if (_random.nextBool()) return [];

    final comments = [
      'Great work on this!',
      'I have some questions about the implementation.',
      'This looks good to me.',
      'Can we discuss this in the next meeting?',
      'I\'ll review this and get back to you.',
      'This needs some adjustments.',
    ];

    return comments.take(_random.nextInt(3) + 1).map((comment) {
      final user = users[_random.nextInt(users.length)];
      return CardComment(
        id: 'comment_${_random.nextInt(1000)}',
        text: comment,
        authorId: user.id,
        authorName: user.name,
        createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(7))),
      );
    }).toList();
  }
}
