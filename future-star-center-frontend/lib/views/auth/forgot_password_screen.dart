import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.requestPasswordReset(
      email: _emailController.text.trim(),
    );

    if (success && mounted) {
      setState(() {
        _emailSent = true;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Failed to send reset email',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return LoadingOverlay(
          isLoading: authProvider.isLoading,
          message: 'Sending reset email...',
          child: Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              title: const Text('Forgot Password'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.largePadding),
                child: _emailSent
                    ? _buildSuccessContent()
                    : _buildFormContent(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormContent() {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppConstants.extraLargePadding),

          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_reset,
                size: 40,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),

          const SizedBox(height: AppConstants.extraLargePadding),

          // Title
          Text(
            'Reset Password',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Description
          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.extraLargePadding),

          // Email field
          CustomTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            validator: Validators.email,
            prefixIcon: const Icon(Icons.email_outlined),
            onEditingComplete: _handleForgotPassword,
          ),

          const SizedBox(height: AppConstants.largePadding),

          // Send reset email button
          CustomButton(
            text: 'Send Reset Email',
            onPressed: _handleForgotPassword,
            isLoading: false,
            height: 56,
          ),

          const SizedBox(height: AppConstants.defaultPadding),

          // Back to login
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Back to Sign In',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppConstants.extraLargePadding * 2),

        // Success icon
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              size: 60,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),

        const SizedBox(height: AppConstants.extraLargePadding),

        // Success title
        Text(
          'Email Sent!',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Success message
        Text(
          'We\'ve sent a password reset link to:',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppConstants.smallPadding),

        Text(
          _emailController.text,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppConstants.extraLargePadding),

        // Instructions
        Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
          ),
          child: Text(
            'Please check your email and click on the link to reset your password. If you don\'t see the email, check your spam folder.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: AppConstants.extraLargePadding),

        // Resend email button
        CustomButton(
          text: 'Resend Email',
          onPressed: () {
            setState(() {
              _emailSent = false;
            });
          },
          isOutlined: true,
          height: 56,
        ),

        const SizedBox(height: AppConstants.defaultPadding),

        // Back to login
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Back to Sign In',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
