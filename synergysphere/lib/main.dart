import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'providers/auth_provider.dart';
import 'providers/project_provider.dart';
import 'providers/task_provider.dart';
import 'providers/trello_provider.dart';
import 'theme/app_theme.dart';
import 'constants/app_constants.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const SynergySphereApp());
}

class SynergySphereApp extends StatelessWidget {
  const SynergySphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => ProjectProvider()),
            ChangeNotifierProvider(create: (_) => TaskProvider()),
            ChangeNotifierProvider(create: (_) => TrelloProvider()),
          ],
          child: MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const AppInitializer(),
          ),
        );
      },
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initialize();
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return const HomeScreen();
  }
}
