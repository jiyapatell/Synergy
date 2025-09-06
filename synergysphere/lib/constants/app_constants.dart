class AppConstants {
  // App Information
  static const String appName = 'SynergySphere';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Collaborative project management and team communication platform';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusXS = 2.0;
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;

  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Task Status Colors
  static const Map<String, int> taskStatusColors = {
    'todo': 0xFF64748B,
    'inProgress': 0xFF3B82F6,
    'done': 0xFF10B981,
    'cancelled': 0xFFEF4444,
  };

  // Priority Colors
  static const Map<String, int> priorityColors = {
    'low': 0xFF10B981,
    'medium': 0xFFF59E0B,
    'high': 0xFFEF4444,
    'urgent': 0xFFDC2626,
  };

  // Project Status Colors
  static const Map<String, int> projectStatusColors = {
    'active': 0xFF10B981,
    'completed': 0xFF6B7280,
    'onHold': 0xFFF59E0B,
    'cancelled': 0xFFEF4444,
  };

  // Validation
  static const int minPasswordLength = 6;
  static const int maxProjectNameLength = 50;
  static const int maxTaskTitleLength = 100;
  static const int maxDescriptionLength = 500;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt', 'md'];

  // Notifications
  static const int maxNotificationHistory = 100;
  static const Duration notificationTimeout = Duration(seconds: 5);

  // Cache
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 50;

  // API
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;

  // Demo Data
  static const List<String> demoProjectNames = [
    'Website Redesign',
    'Mobile App Development',
    'Marketing Campaign',
    'Product Launch',
    'Customer Support',
    'Data Migration',
    'Security Audit',
    'Performance Optimization',
  ];

  static const List<String> demoTaskTitles = [
    'Create wireframes',
    'Set up development environment',
    'Design user interface',
    'Implement authentication',
    'Write unit tests',
    'Deploy to staging',
    'Code review',
    'Update documentation',
    'Fix bugs',
    'Performance testing',
  ];

  static const List<String> demoUserNames = [
    'Alex Johnson',
    'Sarah Chen',
    'Michael Rodriguez',
    'Emily Davis',
    'David Kim',
    'Lisa Wang',
    'James Wilson',
    'Maria Garcia',
    'Robert Brown',
    'Jennifer Taylor',
  ];
}
