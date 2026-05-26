import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 12,
              ), // Slightly smaller top padding to fit the extra fields
              SvgPicture.asset(
                'assets/nyom-logo.svg',
                height: 180,
              ), // Slightly smaller logo for the longer form
              // Email Field
              CustomTextField(
                label: 'Email Address',
                hintText: 'Enter your email address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              CustomTextField(
                label: 'Username',
                hintText: 'Choose a username',
                controller: _usernameController,
                keyboardType: TextInputType.name,
              ),
              // Password Field
              CustomTextField(
                label: 'Password',
                hintText: 'Create a password',
                controller: _passwordController,
                obscureText: _isPasswordObscured,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordObscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordObscured = !_isPasswordObscured;
                    });
                  },
                ),
              ),
              // Confirm Password Field
              CustomTextField(
                label: 'Confirm Password',
                hintText: 'Re-enter your password',
                controller: _confirmPasswordController,
                obscureText: _isConfirmPasswordObscured,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordObscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                    });
                  },
                ),
              ),
              const SizedBox(height: 4),
              CustomButton(
                text: 'Register',
                type: CustomButtonType.primary,
                onPressed: () {
                  // Execute manual registration
                },
              ),
              const SizedBox(height: 4),

              // Visual Separator Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.tertiary,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'OR',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: theme.colorScheme.tertiary,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              CustomButton(
                text: 'Continue with Google',
                type: CustomButtonType.secondary,
                icon: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Google_Favicon_2025.svg/250px-Google_Favicon_2025.svg.png?utm_source=commons.wikimedia.org&utm_campaign=index&utm_content=thumbnail',
                  height: 22,
                  width: 22,
                  fit: BoxFit.contain,
                ),
                onPressed: () {
                  // Execute federated identity single sign-on
                },
              ),
              // Dynamic Navigation Footer Interface
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: theme.textTheme.bodySmall,
                  ),
                  // Note: Removed the extra GestureDetector since TextButton handles taps natively!
                  TextButton(
                    onPressed: () {
                      // Navigate back to LoginScreen
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                    child: const Text('Log In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
