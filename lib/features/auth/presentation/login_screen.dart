import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _emailController =
      TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      await ref.read(authStateProvider.notifier).signInWithEmail(
            _emailController.text,
            _passwordController.text,
          );
      setState(() => _isLoading = false);
      if (mounted) {
        final authState = ref.read(authStateProvider);
        if (authState.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${authState.error}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (authState.valueOrNull != null) {
          context.go('/home');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Auto-redirect if session is restored (e.g. after app restart)
    ref.listen<AsyncValue<UserProfile?>>(authStateProvider, (prev, next) {
      final user = next.valueOrNull;
      if (user != null && mounted) {
        context.go('/home');
      }
    });

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Taskly Logo & Wordmark
                  const AppLogo(
                    size: 64,
                    showWordmark: true,
                    showTagline: true,
                    tagline: 'Get things done, together',
                  ),

                  const SizedBox(height: 36),

                  // Form Content
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email Field
                        CustomTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'you@company.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: Validators.email,
                        ),

                        const SizedBox(height: 18),

                        // Password Field
                        Text(
                          'Password',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: '••••••••',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          validator: Validators.password,
                          onFieldSubmitted: (_) => _handleEmailLogin(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: colors.textMuted,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Primary Purple Sign In Button
                        CustomButton(
                          text: 'Sign In',
                          isLoading: _isLoading,
                          onPressed: _handleEmailLogin,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
