import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDueDate;
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
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateTask() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    // For demo purposes, we'll use the current project ID
    // In a real app, this would be passed from the project screen
    final projectId = 'current_project_id';

    final task = await taskProvider.createTask(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      projectId: projectId,
      assigneeId: authProvider.currentUser!.id, // Self-assign for demo
      creatorId: authProvider.currentUser!.id,
      priority: _selectedPriority,
      dueDate: _selectedDueDate,
    );

    if (task != null && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task created successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: Container(
        decoration: AppTheme.gradientDecoration,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: const EdgeInsets.all(AppConstants.spacingXXL),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.gradientDecoration.gradient,
                                      borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                                    ),
                                    child: const Icon(
                                      Icons.task_alt_rounded,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: AppConstants.spacingL),
                                  Text(
                                    'Create New Task',
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: AppConstants.spacingS),
                                  Text(
                                    'Add a new task to your project',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingXXL),

                            // Task Title
                            TextFormField(
                              controller: _titleController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Task Title',
                                hintText: 'Enter task title',
                                prefixIcon: Icon(Icons.title_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a task title';
                                }
                                if (value.length > AppConstants.maxTaskTitleLength) {
                                  return 'Task title must be less than ${AppConstants.maxTaskTitleLength} characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppConstants.spacingL),

                            // Task Description
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 4,
                              textInputAction: TextInputAction.newline,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                hintText: 'Describe the task...',
                                prefixIcon: Icon(Icons.description_outlined),
                                alignLabelWithHint: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a task description';
                                }
                                if (value.length > AppConstants.maxDescriptionLength) {
                                  return 'Description must be less than ${AppConstants.maxDescriptionLength} characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppConstants.spacingL),

                            // Priority Selection
                            Text(
                              'Priority',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingM),
                            Wrap(
                              spacing: AppConstants.spacingM,
                              runSpacing: AppConstants.spacingM,
                              children: TaskPriority.values.map((priority) {
                                final isSelected = _selectedPriority == priority;
                                final color = _getPriorityColor(priority);
                                
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedPriority = priority;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppConstants.spacingM,
                                      vertical: AppConstants.spacingS,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected ? color : color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                      border: Border.all(
                                        color: isSelected ? color : color.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.white : color,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        const SizedBox(width: AppConstants.spacingS),
                                        Text(
                                          priority.name.toUpperCase(),
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                            color: isSelected ? Colors.white : color,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: AppConstants.spacingL),

                            // Due Date
                            Text(
                              'Due Date (Optional)',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingM),
                            InkWell(
                              onTap: _selectDueDate,
                              child: Container(
                                padding: const EdgeInsets.all(AppConstants.spacingM),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.borderColor),
                                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      color: AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: AppConstants.spacingM),
                                    Expanded(
                                      child: Text(
                                        _selectedDueDate != null
                                            ? '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                                            : 'Select due date',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: _selectedDueDate != null
                                              ? AppTheme.textPrimary
                                              : AppTheme.textTertiary,
                                        ),
                                      ),
                                    ),
                                    if (_selectedDueDate != null)
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedDueDate = null;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          color: AppTheme.textTertiary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingXXL),

                            // Create Button
                            Consumer<TaskProvider>(
                              builder: (context, taskProvider, child) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: taskProvider.isLoading ? null : _handleCreateTask,
                                    child: taskProvider.isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text('Create Task'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
}
