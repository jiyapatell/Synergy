import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../models/project.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../services/demo_data_service.dart';
import '../project/project_detail_screen.dart';
import '../project/create_project_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> with TickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
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
                  child: _buildProjectList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateProjectScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Project'),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    ),
                    child: const Icon(
                      Icons.group_work_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Text(
                          authProvider.currentUser?.name ?? 'User',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Show notifications or settings
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingL),
              Text(
                'Your Projects',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectList() {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        if (projectProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (projectProvider.projects.isEmpty) {
          return _buildEmptyState();
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              itemCount: projectProvider.projects.length,
              itemBuilder: (context, index) {
                final project = projectProvider.projects[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: AppConstants.mediumAnimation,
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildProjectCard(project),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectCard(Project project) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProjectDetailScreen(project: project),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(int.parse(project.color?.replaceAll('#', '0xFF') ?? '0xFF6366F1')),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: Text(
                        project.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingS,
                        vertical: AppConstants.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(project.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                      ),
                      child: Text(
                        _getStatusText(project.status),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getStatusColor(project.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  project.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacingM),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 16,
                      color: AppTheme.textTertiary,
                    ),
                    const SizedBox(width: AppConstants.spacingXS),
                    Text(
                      '${project.totalMembers} members',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingL),
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppTheme.textTertiary,
                    ),
                    const SizedBox(width: AppConstants.spacingXS),
                    Text(
                      _formatDate(project.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    if (project.dueDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingS,
                          vertical: AppConstants.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: project.isOverdue ? AppTheme.errorColor.withOpacity(0.1) : AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        ),
                        child: Text(
                          _formatDate(project.dueDate!),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: project.isOverdue ? AppTheme.errorColor : AppTheme.primaryColor,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            Text(
              'No Projects Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'Create your first project to start collaborating with your team',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXXL),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateProjectScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Project'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return AppTheme.successColor;
      case ProjectStatus.completed:
        return AppTheme.textTertiary;
      case ProjectStatus.onHold:
        return AppTheme.warningColor;
      case ProjectStatus.cancelled:
        return AppTheme.errorColor;
    }
  }

  String _getStatusText(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
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
