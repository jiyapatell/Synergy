import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../services/demo_data_service.dart';
import '../auth/login_screen.dart';
import 'project_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = [
    const ProjectListScreen(),
    const ProfileScreen(),
  ];

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
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      // Load demo data for demonstration
      await projectProvider.loadProjects(authProvider.currentUser!.id);
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!authProvider.isLoggedIn) {
          return const LoginScreen();
        }

        return Scaffold(
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: _screens[_currentIndex],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppTheme.surfaceColor,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: AppTheme.textTertiary,
              selectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.normal,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  activeIcon: Icon(Icons.dashboard_rounded),
                  label: 'Projects',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
