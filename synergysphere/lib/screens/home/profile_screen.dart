import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
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

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
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
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildProfileContent(),
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // Show settings or back
                    },
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _handleLogout,
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingL),
              _buildUserAvatar(authProvider.currentUser),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar(user) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 3,
        ),
      ),
      child: user?.avatarUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
              child: Image.network(
                user.avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildAvatarFallback(user);
                },
              ),
            )
          : _buildAvatarFallback(user),
    );
  }

  Widget _buildAvatarFallback(user) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.gradientDecoration.gradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
      ),
      child: Center(
        child: Text(
          user?.initials ?? 'U',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            children: [
              // User Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingL),
                  child: Column(
                    children: [
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingS),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingL),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            'Projects',
                            '5', // Demo data
                            Icons.folder_outlined,
                          ),
                          _buildStatItem(
                            'Tasks',
                            '15', // Demo data
                            Icons.task_alt_outlined,
                          ),
                          _buildStatItem(
                            'Teams',
                            '3', // Demo data
                            Icons.groups_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),

              // Menu Items
              _buildMenuSection([
                _buildMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  onTap: () {
                    // Navigate to edit profile
                  },
                ),
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage your notification preferences',
                  onTap: () {
                    // Navigate to notifications
                  },
                ),
                _buildMenuItem(
                  icon: Icons.security_outlined,
                  title: 'Privacy & Security',
                  subtitle: 'Control your privacy settings',
                  onTap: () {
                    // Navigate to privacy settings
                  },
                ),
                _buildMenuItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () {
                    // Navigate to help
                  },
                ),
                _buildMenuItem(
                  icon: Icons.info_outline_rounded,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () {
                    _showAboutDialog();
                  },
                ),
              ]),
              const SizedBox(height: AppConstants.spacingL),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                    side: const BorderSide(color: AppTheme.errorColor),
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(height: AppConstants.spacingS),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(List<Widget> items) {
    return Card(
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppConstants.spacingS),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
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

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          gradient: AppTheme.gradientDecoration.gradient,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: const Icon(
          Icons.group_work_rounded,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        Text(AppConstants.appDescription),
      ],
    );
  }
}
