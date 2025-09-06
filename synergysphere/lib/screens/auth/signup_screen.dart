import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';
import '../home/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;
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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Conditions'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registration failed'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(AppConstants.spacingXXL),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo and Title
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: AppTheme.gradientDecoration.gradient,
                                borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                              ),
                              child: const Icon(
                                Icons.group_work_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingL),
                            Text(
                              'Create Account',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingS),
                            Text(
                              'Join SynergySphere and start collaborating',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppConstants.spacingXXL),

                            // Name Field
                            TextFormField(
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                hintText: 'Enter your full name',
                                prefixIcon: Icon(Icons.person_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                if (value.trim().split(' ').length < 2) {
                                  return 'Please enter your first and last name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppConstants.spacingL),

                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'Enter your email',
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppConstants.spacingL),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Create a password',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                if (value.length < AppConstants.minPasswordLength) {
                                  return 'Password must be at least ${AppConstants.minPasswordLength} characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppConstants.spacingL),

                            // Confirm Password Field
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleSignUp(),
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                hintText: 'Confirm your password',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppConstants.spacingL),

                            // Terms and Conditions
                            Row(
                              children: [
                                Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeToTerms = value ?? false;
                                    });
                                  },
                                  activeColor: AppTheme.primaryColor,
                                ),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'I agree to the ',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Terms and Conditions',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const TextSpan(text: ' and '),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spacingL),

                            // Sign Up Button
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: authProvider.isLoading ? null : _handleSignUp,
                                    child: authProvider.isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                        : const Text('Create Account'),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: AppConstants.spacingL),

                            // Divider
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
                                  child: Text(
                                    'OR',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textTertiary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spacingL),

                            // Sign In Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Sign In'),
                                ),
                              ],
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
