import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/project.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../services/demo_data_service.dart';
import 'task_board_screen.dart';
import 'project_settings_screen.dart';
import 'trello_board_screen.dart';
import 'board_templates_screen.dart';
import 'power_ups_screen.dart';
import 'enhanced_card_detail_screen.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with TickerProviderStateMixin {
  int _currentTabIndex = 1; // Start with Board tab instead of Tasks tab
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      TaskBoardScreen(projectId: widget.project.id),
      TrelloBoardScreen(projectId: widget.project.id),
      ProjectSettingsScreen(project: widget.project),
    ];
    
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    _loadProjectData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProjectData() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      // Load demo data for demonstration
      await taskProvider.loadProjectTasks(widget.project.id);
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(int.parse(widget.project.color?.replaceAll('#', '0xFF') ?? '0xFF6366F1')),
              Color(int.parse(widget.project.color?.replaceAll('#', '0xFF') ?? '0xFF6366F1')).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.radiusXXL),
                      topRight: Radius.circular(AppConstants.radiusXXL),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _tabs[_currentTabIndex],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                onSelected: _handleMenuAction,
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white,
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'templates',
                    child: Row(
                      children: [
                        Icon(Icons.dashboard_customize),
                        SizedBox(width: 8),
                        Text('Board Templates'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'powerups',
                    child: Row(
                      children: [
                        Icon(Icons.extension),
                        SizedBox(width: 8),
                        Text('Power-Ups'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download),
                        SizedBox(width: 8),
                        Text('Export Board'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(Icons.archive),
                        SizedBox(width: 8),
                        Text('Archive Project'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Text(
                  widget.project.name,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            widget.project.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),
          Row(
            children: [
              _buildHeaderStat(
                Icons.people_outline_rounded,
                '${widget.project.totalMembers}',
                'Members',
              ),
              const SizedBox(width: AppConstants.spacingXL),
              _buildHeaderStat(
                Icons.calendar_today_outlined,
                _formatDate(widget.project.createdAt),
                'Created',
              ),
              if (widget.project.dueDate != null) ...[
                const SizedBox(width: AppConstants.spacingXL),
                _buildHeaderStat(
                  Icons.schedule_rounded,
                  _formatDate(widget.project.dueDate!),
                  'Due Date',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 16,
        ),
        const SizedBox(width: AppConstants.spacingXS),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              'Tasks',
              Icons.task_alt_outlined,
              0,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              'Board',
              Icons.dashboard_outlined,
              1,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              'Settings',
              Icons.settings_outlined,
              2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, IconData icon, int index) {
    final isSelected = _currentTabIndex == index;
    
    return GestureDetector(
      onTap: () => _onTabChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacingS,
          horizontal: AppConstants.spacingS,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.white,
              size: 18,
            ),
            const SizedBox(width: AppConstants.spacingXS),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'templates':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BoardTemplatesScreen(projectId: widget.project.id),
          ),
        );
        break;
      case 'powerups':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PowerUpsScreen(),
          ),
        );
        break;
      case 'export':
        _exportBoard();
        break;
      case 'archive':
        _archiveProject();
        break;
    }
  }

  void _exportBoard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Board'),
        content: const Text('Choose the format to export your board data:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Board exported as CSV successfully!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Board exported as JSON successfully!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('JSON'),
          ),
        ],
      ),
    );
  }

  void _archiveProject() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Project'),
        content: const Text('Are you sure you want to archive this project? You can restore it later from the archived projects section.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Project archived successfully!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
