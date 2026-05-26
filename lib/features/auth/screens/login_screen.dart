import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // 1. Import the SVG package
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
              const SizedBox(height: 64),
              SvgPicture.asset('assets/nyom-logo.svg', height: 180),
              CustomTextField(
                label: 'Email Address',
                hintText: 'Enter your email address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              CustomTextField(
                label: 'Password',
                hintText: 'Enter your password',
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
              // Inline Actions
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Navigate to password recovery
                  },
                  child: const Text('Forgot Password?'),
                ),
              ),
              CustomButton(
                text: 'Sign In',
                type: CustomButtonType.primary,
                onPressed: () {
                  // Execute manual login authentication
                },
              ),
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
              // Alternative Third-Party Provider Entry
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: theme.textTheme.bodySmall,
                  ),
                  GestureDetector(
                    onTap: () {
                      // Redirect flow to register screen state
                    },
                    child: TextButton(
                      onPressed: () {
                        // Navigate to password recovery
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                      ),
                      child: const Text('Register'),
                    ),
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
