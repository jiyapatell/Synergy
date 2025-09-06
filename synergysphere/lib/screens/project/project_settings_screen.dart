import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../providers/project_provider.dart';
import '../../models/project.dart';
import 'team_members_screen.dart';

class ProjectSettingsScreen extends StatefulWidget {
  final Project? project;
  
  const ProjectSettingsScreen({super.key, this.project});

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
                    _showEditProjectDialog();
                  },
                ),
                _buildMenuItem(
                  icon: Icons.palette_outlined,
                  title: 'Project Color',
                  subtitle: 'Change project color theme',
                  onTap: () {
                    _showColorPickerDialog();
                  },
                ),
                _buildMenuItem(
                  icon: Icons.calendar_today_outlined,
                  title: 'Due Date',
                  subtitle: 'Set or update project deadline',
                  onTap: () {
                    _showDatePickerDialog();
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
                    _showInviteMembersDialog();
                  },
                ),
                _buildMenuItem(
                  icon: Icons.people_outline_rounded,
                  title: 'Manage Members',
                  subtitle: 'View and manage existing members',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamMembersScreen(projectId: widget.project?.id ?? ''),
                      ),
                    );
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
              final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
              if (widget.project != null) {
                final updatedProject = widget.project!.copyWith(
                  status: ProjectStatus.onHold,
                  updatedAt: DateTime.now(),
                );
                projectProvider.updateProject(updatedProject);
              }
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
              final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
              if (widget.project != null) {
                projectProvider.deleteProject(widget.project!.id);
                Navigator.of(context).pop(); // Go back to project list
              }
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

  void _showEditProjectDialog() {
    final nameController = TextEditingController(text: widget.project?.name ?? '');
    final descriptionController = TextEditingController(text: widget.project?.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Project'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Project Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Update project in provider
              final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
              if (widget.project != null) {
                final updatedProject = widget.project!.copyWith(
                  name: nameController.text,
                  description: descriptionController.text,
                );
                projectProvider.updateProject(updatedProject);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Project updated successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showColorPickerDialog() {
    final colors = [
      const Color(0xFF6366F1), // Purple
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Yellow
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF84CC16), // Lime
      const Color(0xFFF97316), // Orange
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Project Color'),
        content: Wrap(
          spacing: AppConstants.spacingM,
          runSpacing: AppConstants.spacingM,
          children: colors.map((color) => GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              // Update project color in provider
              final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
              if (widget.project != null) {
                final updatedProject = widget.project!.copyWith(
                  color: '#${color.value.toRadixString(16).substring(2)}',
                );
                projectProvider.updateProject(updatedProject);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Project color updated successfully'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
              ),
            ),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDatePickerDialog() async {
    final date = await showDatePicker(
      context: context,
      initialDate: widget.project?.dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      // Update project due date in provider
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      if (widget.project != null) {
        final updatedProject = widget.project!.copyWith(
          dueDate: date,
        );
        projectProvider.updateProject(updatedProject);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Due date set to ${date.day}/${date.month}/${date.year}'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  void _showInviteMembersDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Team Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter member\'s email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppConstants.spacingM),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'member', child: Text('Member')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
              ],
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invitation sent to ${emailController.text}'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }
}
