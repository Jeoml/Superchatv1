import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/chat_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;
  int donesignup = 0;
  int donelogin = 0;

  Future<void> _handleAuth() async {
    try {
      final success = await _authService.authenticate(
        _emailController.text,
        _passwordController.text,
        _isLogin,
      );

      if (success && mounted) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ChatScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isLogin ? 'Welcome Back' : 'Create Account',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _isLogin 
                ? 'Please login to continue'
                : 'Please fill in the details to create your account',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Email field
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password field
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _handleAuth,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLogin 
                ? const Text('LogIn', style: TextStyle(fontSize: 16))
                : const Text('Sign Up', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),

            // Toggle button
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin
                    ? "Don't have an account? Sign Up"
                    : 'Already have an account? LogIn',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
