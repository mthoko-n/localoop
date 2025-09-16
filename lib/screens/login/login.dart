import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'services/login_service.dart';
import 'services/google_login_service.dart';
import 'services/google_sign_in_helper.dart';
import 'model/login_request.dart';
import 'register.dart';
import '../../../services/api_client.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final ApiClient apiClient; 

  const LoginScreen({
    super.key,
    this.onLoginSuccess,
    required this.apiClient,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = LoginRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Use the ApiClient passed down from MainNavigation
      final response = await LoginService(api: widget.apiClient).login(request);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Welcome!')),
      );

      widget.onLoginSuccess?.call();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

void _googleLogin() async {
  setState(() => _isLoading = true);

  try {
    // Step 1: get Google ID token
    final idToken = await signInWithGoogle();

    if (idToken != null) {
      // Step 2: GoogleLoginService now handles token storage and AuthService notification
      final token = await GoogleLoginService(api: widget.apiClient)
          .signInWithGoogle(idToken);

      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in with Google!')),
      );

      // Step 3: callback to update MainNavigation
      widget.onLoginSuccess?.call();
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google login failed')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                child: Text(
                  'LocaLoop',
                  style: textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome back',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) =>
                              val!.isEmpty ? 'Please enter email' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (val) =>
                              val!.isEmpty ? 'Please enter password' : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : const Text('Login'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: Divider(color: colorScheme.outline)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: colorScheme.outline)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            icon: Image.asset('assets/google_logo.png', height: 20),
                            label: const Text('Sign in with Google'),
                            onPressed: _isLoading ? null : _googleLogin,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegisterScreen(apiClient: widget.apiClient),
                  ),
                ),
                child: const Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
