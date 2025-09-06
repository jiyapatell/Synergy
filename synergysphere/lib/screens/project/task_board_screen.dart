import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/task.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../services/demo_data_service.dart';
import 'create_task_screen.dart';
import 'task_detail_screen.dart';

class TaskBoardScreen extends StatefulWidget {
  const TaskBoardScreen({super.key});

  @override
  State<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends State<TaskBoardScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
    _loadDemoData();
  }

  Future<void> _loadDemoData() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      // Load demo data for demonstration
      await taskProvider.loadProjectTasks('current_project_id');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        if (taskProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(taskProvider),
              Expanded(
                child: _buildTaskBoard(taskProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(TaskProvider taskProvider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Board',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  '${taskProvider.tasks.length} tasks',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateTaskScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Task'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskBoard(TaskProvider taskProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildTaskColumn(
              'To Do',
              TaskStatus.todo,
              taskProvider.getTasksByStatus(TaskStatus.todo),
              AppTheme.textTertiary,
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: _buildTaskColumn(
              'In Progress',
              TaskStatus.inProgress,
              taskProvider.getTasksByStatus(TaskStatus.inProgress),
              AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: _buildTaskColumn(
              'Done',
              TaskStatus.done,
              taskProvider.getTasksByStatus(TaskStatus.done),
              AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskColumn(String title, TaskStatus status, List<Task> tasks, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.spacingS,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: AppConstants.spacingS),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppConstants.spacingS),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingS,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                ),
                child: Text(
                  '${tasks.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spacingM),
        Expanded(
          child: tasks.isEmpty
              ? _buildEmptyColumn(status)
              : AnimationLimiter(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: AppConstants.shortAnimation,
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildTaskCard(task),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyColumn(TaskStatus status) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: AppTheme.borderColor,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt_outlined,
            color: AppTheme.textTertiary,
            size: 48,
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'No tasks yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TaskDetailScreen(task: task),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildPriorityIndicator(task.priority),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.spacingS),
                  Text(
                    task.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppConstants.spacingM),
                Row(
                  children: [
                    _buildAssigneeAvatar(task.assigneeId),
                    const SizedBox(width: AppConstants.spacingS),
                    Expanded(
                      child: Text(
                        'Assigned to ${_getUserName(task.assigneeId)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (task.dueDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: task.isOverdue
                              ? AppTheme.errorColor.withOpacity(0.1)
                              : AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: Text(
                          _formatDate(task.dueDate!),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: task.isOverdue
                                ? AppTheme.errorColor
                                : AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(TaskPriority priority) {
    Color color;
    switch (priority) {
      case TaskPriority.low:
        color = AppTheme.successColor;
        break;
      case TaskPriority.medium:
        color = AppTheme.warningColor;
        break;
      case TaskPriority.high:
        color = AppTheme.errorColor;
        break;
      case TaskPriority.urgent:
        color = const Color(0xFFDC2626);
        break;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildAssigneeAvatar(String assigneeId) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          assigneeId.isNotEmpty ? assigneeId[0].toUpperCase() : 'U',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference > 0) {
      return '${date.day}/${date.month}';
    } else {
      return 'Overdue';
    }
  }

  String _getUserName(String userId) {
    final users = DemoDataService.getDemoUsers();
    final user = users.firstWhere(
      (user) => user.id == userId,
      orElse: () => users.first,
    );
    return user.name;
  }
}
