import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';

enum NotificationType {
  mention,
  comment,
  assignment,
  dueDate,
  cardMoved,
  cardCreated,
  cardArchived,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final String cardId;
  final String cardTitle;
  final String projectId;
  final String projectName;
  final String fromUserId;
  final String fromUserName;
  final DateTime createdAt;
  final bool isRead;
  final String? actionUrl;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.cardId,
    required this.cardTitle,
    required this.projectId,
    required this.projectName,
    required this.fromUserId,
    required this.fromUserName,
    required this.createdAt,
    this.isRead = false,
    this.actionUrl,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    String? cardId,
    String? cardTitle,
    String? projectId,
    String? projectName,
    String? fromUserId,
    String? fromUserName,
    DateTime? createdAt,
    bool? isRead,
    String? actionUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      cardId: cardId ?? this.cardId,
      cardTitle: cardTitle ?? this.cardTitle,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<AppNotification> _notifications = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadNotifications() {
    // Demo notifications
    _notifications = [
      AppNotification(
        id: 'notif_1',
        title: 'You were mentioned',
        message: 'John Doe mentioned you in a comment on "Design new homepage layout"',
        type: NotificationType.mention,
        cardId: 'card_1',
        cardTitle: 'Design new homepage layout',
        projectId: 'project_1',
        projectName: 'Website Redesign',
        fromUserId: 'user_1',
        fromUserName: 'John Doe',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      AppNotification(
        id: 'notif_2',
        title: 'Card assigned to you',
        message: 'Jane Smith assigned "Implement user authentication" to you',
        type: NotificationType.assignment,
        cardId: 'card_2',
        cardTitle: 'Implement user authentication',
        projectId: 'project_1',
        projectName: 'Website Redesign',
        fromUserId: 'user_2',
        fromUserName: 'Jane Smith',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      AppNotification(
        id: 'notif_3',
        title: 'Due date approaching',
        message: 'The card "Create mobile responsive design" is due tomorrow',
        type: NotificationType.dueDate,
        cardId: 'card_3',
        cardTitle: 'Create mobile responsive design',
        projectId: 'project_1',
        projectName: 'Website Redesign',
        fromUserId: 'system',
        fromUserName: 'System',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: true,
      ),
      AppNotification(
        id: 'notif_4',
        title: 'New comment',
        message: 'Mike Johnson commented on "Set up database schema"',
        type: NotificationType.comment,
        cardId: 'card_4',
        cardTitle: 'Set up database schema',
        projectId: 'project_2',
        projectName: 'Mobile App Development',
        fromUserId: 'user_3',
        fromUserName: 'Mike Johnson',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AppNotification(
        id: 'notif_5',
        title: 'Card moved',
        message: 'Sarah Wilson moved "Write API documentation" to Done',
        type: NotificationType.cardMoved,
        cardId: 'card_5',
        cardTitle: 'Write API documentation',
        projectId: 'project_2',
        projectName: 'Mobile App Development',
        fromUserId: 'user_4',
        fromUserName: 'Sarah Wilson',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
      AppNotification(
        id: 'notif_6',
        title: 'New card created',
        message: 'David Brown created "Conduct user testing" in Marketing Campaign',
        type: NotificationType.cardCreated,
        cardId: 'card_6',
        cardTitle: 'Conduct user testing',
        projectId: 'project_3',
        projectName: 'Marketing Campaign',
        fromUserId: 'user_5',
        fromUserName: 'David Brown',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: _markAllAsRead,
            tooltip: 'Mark All as Read',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearAllNotifications,
            tooltip: 'Clear All',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
            Tab(text: 'Mentions'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notifications...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Notifications List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationsList(_getFilteredNotifications()),
                _buildNotificationsList(_getFilteredNotifications().where((n) => !n.isRead).toList()),
                _buildNotificationsList(_getFilteredNotifications().where((n) => n.type == NotificationType.mention).toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'No notifications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'You\'re all caught up!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: notification.isRead 
                ? null 
                : Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    width: 1,
                  ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                
                // Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingXS),
                      Text(
                        notification.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppConstants.spacingS),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacingS,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppConstants.radiusS),
                            ),
                            child: Text(
                              notification.projectName,
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingS),
                          Text(
                            _formatTime(notification.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textTertiary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            notification.fromUserName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<AppNotification> _getFilteredNotifications() {
    if (_searchQuery.isEmpty) {
      return _notifications;
    }
    
    return _notifications.where((notification) {
      return notification.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             notification.message.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             notification.cardTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             notification.projectName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _handleNotificationTap(AppNotification notification) {
    // Mark as read
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        _notifications[index] = notification.copyWith(isRead: true);
      }
    });

    // Navigate to the card or project
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${notification.cardTitle}...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((notification) => 
          notification.copyWith(isRead: true)).toList();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text('Are you sure you want to clear all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.mention:
        return Icons.alternate_email;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.assignment:
        return Icons.person_add;
      case NotificationType.dueDate:
        return Icons.schedule;
      case NotificationType.cardMoved:
        return Icons.move_to_inbox;
      case NotificationType.cardCreated:
        return Icons.add_circle;
      case NotificationType.cardArchived:
        return Icons.archive;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.mention:
        return AppTheme.primaryColor;
      case NotificationType.comment:
        return const Color(0xFF10B981);
      case NotificationType.assignment:
        return const Color(0xFFF59E0B);
      case NotificationType.dueDate:
        return const Color(0xFFEF4444);
      case NotificationType.cardMoved:
        return const Color(0xFF8B5CF6);
      case NotificationType.cardCreated:
        return const Color(0xFF06B6D4);
      case NotificationType.cardArchived:
        return const Color(0xFF6B7280);
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
