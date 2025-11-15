import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _sendOtp() {
    // Add the country code (e.g., +91 for India)
    // You should use a country code picker in a real app
    String phoneNumber = "+91${_phoneController.text.trim()}";

    if (phoneNumber.length < 13) {
      // Simple validation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid 10-digit phone number.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // We pass the context to handle navigation from the service
    _authService.verifyPhoneNumber(context, phoneNumber);

    // We set loading to false here, but the service will navigate
    // on success, or show an error
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in with Phone')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter your phone number',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'We will send you a 6-digit verification code.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: '10-digit Phone Number',
                prefixText: '+91 ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _sendOtp,
                    child: const Text('Send OTP'),
                  ),
          ],
        ),
      ),
    );
  }
}
