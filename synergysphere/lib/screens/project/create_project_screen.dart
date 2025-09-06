import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../models/project.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedColor = '#6366F1';
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
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateProject() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    final project = await projectProvider.createProject(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      ownerId: authProvider.currentUser!.id,
      color: _selectedColor,
      dueDate: _selectedDueDate,
    );

    if (project != null && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project created successfully!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
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
        title: const Text('Create Project'),
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
                                      Icons.add_rounded,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: AppConstants.spacingL),
                                  Text(
                                    'Create New Project',
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: AppConstants.spacingS),
                                  Text(
                                    'Set up a new project to start collaborating with your team',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingXXL),

                            // Project Name
                            TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Project Name',
                                hintText: 'Enter project name',
                                prefixIcon: Icon(Icons.folder_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a project name';
                                }
                                if (value.length > AppConstants.maxProjectNameLength) {
                                  return 'Project name must be less than ${AppConstants.maxProjectNameLength} characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppConstants.spacingL),

                            // Project Description
                            TextFormField(
                              controller: _descriptionController,
                              maxLines: 3,
                              textInputAction: TextInputAction.newline,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                hintText: 'Describe your project...',
                                prefixIcon: Icon(Icons.description_outlined),
                                alignLabelWithHint: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a project description';
                                }
                                if (value.length > AppConstants.maxDescriptionLength) {
                                  return 'Description must be less than ${AppConstants.maxDescriptionLength} characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppConstants.spacingL),

                            // Color Selection
                            Text(
                              'Project Color',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingM),
                            Wrap(
                              spacing: AppConstants.spacingM,
                              runSpacing: AppConstants.spacingM,
                            children: AppTheme.projectColors.map((color) {
                              final colorString = '#${color.value.toRadixString(16).substring(2)}';
                              final isSelected = _selectedColor == colorString;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedColor = colorString;
                                  });
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                                    border: Border.all(
                                      color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        )
                                      : null,
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
                            Consumer<ProjectProvider>(
                              builder: (context, projectProvider, child) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: projectProvider.isLoading ? null : _handleCreateProject,
                                    child: projectProvider.isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text('Create Project'),
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
}
