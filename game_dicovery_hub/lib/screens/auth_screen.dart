// lib/screens/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_dicovery_hub/screens/phone_login_screen.dart';
import 'package:game_dicovery_hub/screens/signup_screen.dart';
import '../services/auth_service.dart';
// Note: Removed unused import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // Helper to show errors
  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Helper to show success
  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // --- Handle Email/Password Login (CLEANED) ---
  void _handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackbar('Please enter both email and password.');
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // The _createFirestoreUser logic runs inside signInWithEmail now
      await _authService.signInWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar(e.message ?? 'An unknown error occurred.');
    } catch (e) {
      _showErrorSnackbar('An unexpected error occurred.');
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  // --- Handle Google Sign-In (CLEANED) ---
  void _handleGoogleSignIn() async {
    setState(() { _isLoading = true; });
    try {
      // The _createFirestoreUser logic runs inside signInWithGoogle now
      await _authService.signInWithGoogle();
    } catch (e) {
      _showErrorSnackbar('Google Sign-In failed. Please try again.');
    }
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  // --- Handle Guest Sign-In (CLEANED) ---
  void _handleGuestSignIn() async {
    setState(() { _isLoading = true; });
    try {
      // The _createFirestoreUser logic runs inside signInAnonymously now
      await _authService.signInAnonymously();
    } catch (e) {
      _showErrorSnackbar('Guest sign-in failed. Please try again.');
    }
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  // --- NEW: Handle Forgot Password ---
  void _handleForgotPassword() {
    final TextEditingController forgotEmailController = TextEditingController();
    forgotEmailController.text = _emailController.text.trim();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email to receive a password reset link.'),
              const SizedBox(height: 20),
              TextField(
                controller: forgotEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Send Link'),
              onPressed: () async {
                final email = forgotEmailController.text.trim();
                if (email.isEmpty) {
                  _showErrorSnackbar('Please enter an email address.');
                  return;
                }
                
                try {
                  await _authService.sendPasswordResetEmail(email);
                  // Close the dialog
                  // ignore: use_build_context_synchronously
                  if (mounted) Navigator.of(context).pop();
                  _showSuccessSnackbar('Password reset link sent to $email');
                } on FirebaseAuthException catch (e) {
                  // ignore: use_build_context_synchronously
                  if (mounted) Navigator.of(context).pop();
                  _showErrorSnackbar(e.message ?? 'Failed to send link.');
                }
              },
            ),
          ],
        );
      },
    );
  }


  // --- UI Helper Methods (for clean build method) ---

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        prefixIcon: Icon(Icons.email),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        prefixIcon: Icon(Icons.lock),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: _handleEmailLogin,
      child: const Text('Sign In', style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildGoogleButton() {
    return OutlinedButton.icon(
      icon: Image.asset('assets/google_logo.png', height: 24, width: 24),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: _handleGoogleSignIn,
      label: Text(
        'Sign In with Google',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
      ),
    );
  }

  Widget _buildPhoneButton() {
    return OutlinedButton.icon(
      icon: const Icon(Icons.phone, color: Colors.green),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PhoneLoginScreen()),
        );
      },
      label: Text(
        'Sign In with Phone',
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // --- Loading Indicator ---
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _handleForgotPassword, // --- CONNECTED ---
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLoginButton(),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Sign Up",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('OR', style: TextStyle(color: Colors.grey)),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildGoogleButton(),
                    const SizedBox(height: 16),
                    _buildPhoneButton(),
                    const SizedBox(height: 30),
                    
                    TextButton(
                      onPressed: _handleGuestSignIn,
                      child: const Text(
                        'Continue as Guest',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
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