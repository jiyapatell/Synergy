import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _updateTaskStatus(TaskStatus newStatus) async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    await taskProvider.updateTaskStatus(widget.task.id, newStatus);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Task status updated to ${_getStatusDisplayName(newStatus)}'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Show task options
            },
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getPriorityColor(widget.task.priority),
              _getPriorityColor(widget.task.priority).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
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
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildTaskContent(),
                    ),
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
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingS),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                ),
                child: const Icon(
                  Icons.task_alt_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Text(
                  widget.task.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          Row(
            children: [
              _buildStatusChip(),
              const SizedBox(width: AppConstants.spacingM),
              _buildPriorityChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    final statusColor = _getStatusColor(widget.task.status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Text(
        widget.task.statusDisplayName,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    final priorityColor = _getPriorityColor(widget.task.priority);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: priorityColor, width: 1),
      ),
      child: Text(
        widget.task.priorityDisplayName,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: priorityColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTaskContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          _buildSection(
            'Description',
            Icons.description_outlined,
            widget.task.description.isNotEmpty
                ? widget.task.description
                : 'No description provided',
          ),
          const SizedBox(height: AppConstants.spacingL),

          // Task Details
          _buildSection(
            'Details',
            Icons.info_outlined,
            null,
            child: Column(
              children: [
                _buildDetailRow('Created', _formatDate(widget.task.createdAt)),
                if (widget.task.updatedAt != null)
                  _buildDetailRow('Updated', _formatDate(widget.task.updatedAt!)),
                if (widget.task.dueDate != null)
                  _buildDetailRow('Due Date', _formatDate(widget.task.dueDate!)),
                if (widget.task.completedAt != null)
                  _buildDetailRow('Completed', _formatDate(widget.task.completedAt!)),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),

          // Status Actions
          if (widget.task.status != TaskStatus.done)
            _buildSection(
              'Actions',
              Icons.play_arrow_outlined,
              null,
              child: Column(
                children: [
                  if (widget.task.status == TaskStatus.todo)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _updateTaskStatus(TaskStatus.inProgress),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Start Task'),
                      ),
                    ),
                  if (widget.task.status == TaskStatus.inProgress) ...[
                    const SizedBox(height: AppConstants.spacingM),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _updateTaskStatus(TaskStatus.done),
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Mark as Done'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, String? content, {Widget? child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacingS),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            if (content != null)
              Text(
                content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            if (child != null) child,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return AppTheme.textTertiary;
      case TaskStatus.inProgress:
        return AppTheme.primaryColor;
      case TaskStatus.done:
        return AppTheme.successColor;
      case TaskStatus.cancelled:
        return AppTheme.errorColor;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return AppTheme.successColor;
      case TaskPriority.medium:
        return AppTheme.warningColor;
      case TaskPriority.high:
        return AppTheme.errorColor;
      case TaskPriority.urgent:
        return const Color(0xFFDC2626);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getStatusDisplayName(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }
}
