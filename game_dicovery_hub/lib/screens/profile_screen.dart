// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:game_dicovery_hub/models/user_model.dart';
import 'package:game_dicovery_hub/services/auth_service.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final AuthService authService = AuthService();

  Widget buildProfileInfoRow(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    if (user == null) {
      // This can happen briefly during sign-out, it's normal.
      // A loading indicator is fine.
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: (user.photoURL != null && user.photoURL!.isNotEmpty)
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: (user.photoURL == null || user.photoURL!.isEmpty)
                  ? Icon(
                      user.isGuest ? Icons.person_off : Icons.person,
                      size: 50,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(height: 12),

            // --- ADMIN & PREMIUM BADGES ---
            if (user.isAdmin)
              const Chip(
                label: Text('Admin'),
                backgroundColor: Colors.amber,
                labelStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )
            else if (user.isPremium)
              const Chip(
                label: Text('✨ Premium Member'),
                backgroundColor: Colors.deepPurple,
                labelStyle:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),

            const SizedBox(height: 8),

            Text(
              user.isGuest ? 'Guest User' : user.displayName ?? 'Welcome!',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const Divider(color: Colors.grey),
            const SizedBox(height: 10),

            // User Details
            if (!user.isGuest) ...[
              if (user.email != null && user.email!.isNotEmpty)
                buildProfileInfoRow(
                  Icons.email_outlined,
                  'Email',
                  user.email!,
                ),
              if (FirebaseAuth.instance.currentUser?.phoneNumber != null &&
                  FirebaseAuth.instance.currentUser!.phoneNumber!.isNotEmpty)
                buildProfileInfoRow(
                  Icons.phone_outlined,
                  'Phone Number',
                  FirebaseAuth.instance.currentUser!.phoneNumber!,
                ),
              buildProfileInfoRow(
                Icons.badge_outlined,
                'User ID',
                user.uid,
              ),
            ] else ...[
              buildProfileInfoRow(
                Icons.info_outline,
                'Account Type',
                'You are browsing as a guest. Sign up to save your backlog permanently.',
              ),
            ],

            const SizedBox(height: 40),

            // --- LOGOUT BUTTON (FIXED) ---
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade800,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // --- START OF FIXED CODE ---
              onPressed: () async {
                try {
                  // 1. Make the function 'async'
                  // 2. 'await' the sign out to ensure it finishes
                  await authService.signOut();

                  // 3. Navigate AFTER it's done.
                  // This check just makes it safer.
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                  // The AuthWrapper will now correctly see the user is null
                  // and show the AuthScreen.

                } catch (e) {
                  // If it fails, show an error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to sign out: $e')),
                  );
                }
              },
              // --- END OF FIXED CODE ---
            ),
          ],
        ),
      ),
    );
  }
}