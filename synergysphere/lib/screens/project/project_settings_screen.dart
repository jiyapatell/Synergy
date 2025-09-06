import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';

class ProjectSettingsScreen extends StatefulWidget {
  const ProjectSettingsScreen({super.key});

  @override
  State<ProjectSettingsScreen> createState() => _ProjectSettingsScreenState();
}

class _ProjectSettingsScreenState extends State<ProjectSettingsScreen> with TickerProviderStateMixin {
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Overview
            _buildSection(
              'Project Overview',
              Icons.info_outlined,
              [
                _buildMenuItem(
                  icon: Icons.edit_outlined,
                  title: 'Edit Project',
                  subtitle: 'Update project name and description',
                  onTap: () {
                    // Navigate to edit project
                  },
                ),
                _buildMenuItem(
                  icon: Icons.palette_outlined,
                  title: 'Project Color',
                  subtitle: 'Change project color theme',
                  onTap: () {
                    // Show color picker
                  },
                ),
                _buildMenuItem(
                  icon: Icons.calendar_today_outlined,
                  title: 'Due Date',
                  subtitle: 'Set or update project deadline',
                  onTap: () {
                    // Show date picker
                  },
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Team Management
            _buildSection(
              'Team Management',
              Icons.people_outlined,
              [
                _buildMenuItem(
                  icon: Icons.person_add_outlined,
                  title: 'Invite Members',
                  subtitle: 'Add new team members to the project',
                  onTap: () {
                    // Show invite dialog
                  },
                ),
                _buildMenuItem(
                  icon: Icons.people_outline_rounded,
                  title: 'Manage Members',
                  subtitle: 'View and manage existing members',
                  onTap: () {
                    // Navigate to members list
                  },
                ),
                _buildMenuItem(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Permissions',
                  subtitle: 'Configure member permissions',
                  onTap: () {
                    // Navigate to permissions
                  },
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Project Settings
            _buildSection(
              'Project Settings',
              Icons.settings_outlined,
              [
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Configure project notifications',
                  onTap: () {
                    // Navigate to notifications
                  },
                ),
                _buildMenuItem(
                  icon: Icons.security_outlined,
                  title: 'Privacy',
                  subtitle: 'Control project visibility and access',
                  onTap: () {
                    // Navigate to privacy settings
                  },
                ),
                _buildMenuItem(
                  icon: Icons.archive_outlined,
                  title: 'Archive Project',
                  subtitle: 'Archive this project',
                  onTap: () {
                    _showArchiveDialog();
                  },
                  isDestructive: true,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Danger Zone
            _buildSection(
              'Danger Zone',
              Icons.warning_outlined,
              [
                _buildMenuItem(
                  icon: Icons.delete_outline_rounded,
                  title: 'Delete Project',
                  subtitle: 'Permanently delete this project',
                  onTap: () {
                    _showDeleteDialog();
                  },
                  isDestructive: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
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
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppConstants.spacingS),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppTheme.errorColor.withOpacity(0.1)
              : AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Icon(
          icon,
          color: isDestructive ? AppTheme.errorColor : AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppTheme.errorColor : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppTheme.textTertiary,
      ),
      onTap: onTap,
    );
  }

  void _showArchiveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Project'),
        content: const Text(
          'Are you sure you want to archive this project? You can restore it later from the archived projects section.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Archive project logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Project archived successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningColor,
            ),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text(
          'Are you sure you want to permanently delete this project? This action cannot be undone and all data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Delete project logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Project deleted successfully'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
