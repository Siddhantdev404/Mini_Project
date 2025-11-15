
// In lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  // Helper function to show snackbars
  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackbar('Please enter both email and password.');
      return;
    }

    setState(() { _isLoading = true; });

    try {
      await _authService.signUpWithEmail(email, password);
      
      // If sign-up is successful, the AuthWrapper in main.dart
      // will automatically handle navigation.
      if (mounted) {
        // Pop this screen off the navigation stack
        Navigator.of(context).pop();
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showErrorSnackbar('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _showErrorSnackbar('The account already exists for that email.');
      } else {
        _showErrorSnackbar(e.message ?? 'An unknown error occurred.');
      }
    } catch (e) {
      _showErrorSnackbar('An unexpected error occurred. Please try again.');
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _handleSignUp,
                      child: const Text('Sign Up'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}