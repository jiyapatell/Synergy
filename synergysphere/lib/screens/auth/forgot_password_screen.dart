import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;
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
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.forgotPassword(_emailController.text.trim());

    if (success && mounted) {
      setState(() {
        _emailSent = true;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to send reset email'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(AppConstants.spacingXXL),
                      child: _emailSent ? _buildEmailSentView() : _buildForgotPasswordForm(),
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

  Widget _buildForgotPasswordForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              size: 40,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.spacingL),
          
          // Title
          Text(
            'Forgot Password?',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          
          // Description
          Text(
            'No worries! Enter your email address and we\'ll send you a link to reset your password.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingXXL),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleForgotPassword(),
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email address',
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
          const SizedBox(height: AppConstants.spacingXXL),

          // Send Reset Link Button
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleForgotPassword,
                  child: authProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Send Reset Link'),
                ),
              );
            },
          ),
          const SizedBox(height: AppConstants.spacingL),

          // Back to Login
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Back to Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSentView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Success Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 40,
            color: AppTheme.successColor,
          ),
        ),
        const SizedBox(height: AppConstants.spacingL),
        
        // Title
        Text(
          'Check Your Email',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: AppConstants.spacingS),
        
        // Description
        Text(
          'We\'ve sent a password reset link to ${_emailController.text}. Please check your email and follow the instructions to reset your password.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppConstants.spacingXXL),

        // Resend Button
        OutlinedButton(
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          child: const Text('Resend Email'),
        ),
        const SizedBox(height: AppConstants.spacingM),

        // Back to Login
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Back to Sign In'),
        ),
      ],
    );
  }
}
