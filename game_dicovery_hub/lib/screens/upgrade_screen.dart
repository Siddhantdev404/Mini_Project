// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:game_dicovery_hub/services/firestore_service.dart';
import 'package:provider/provider.dart';
import 'package:game_dicovery_hub/models/user_model.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});

  // This is the "one-tap" upgrade function
 // In lib/screens/upgrade_screen.dart

// This is the "one-tap" upgrade function
Future<void> _upgradeToPremium(BuildContext context) async {
  final firestoreService = Provider.of<FirestoreService>(context, listen: false);

  // Show a loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const Dialog(
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text("Upgrading..."),
        ]),
      ),
    ),
  );

  try {
    // Call the function in firestore_service.dart
    await firestoreService.upgradeToPremium();
    
    // Close loading dialog
    Navigator.of(context).pop();
    
    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Congratulations! You are now a Premium Member!'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    Navigator.of(context).pop(); // Close loading dialog
    
    String errorMessage = 'An unexpected error occurred.';

    // --- FIX: Check for the specific Firebase Permission Denied Error ---
    if (e.toString().contains('permission-denied')) {
      errorMessage = "Upgrade Failed: You must be an Admin to grant Premium status directly.";
    } else if (e.toString().contains('already a premium member')) {
      errorMessage = "You are already a Premium Member!";
    }
    // --- END FIX ---

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    // Get the user's role from the "brain"
    final user = Provider.of<UserModel?>(context);
    final bool isPremium = user?.isPremium ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Premium'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Icon(Icons.star_rounded, size: 100, color: Colors.amber),
            ),
            const SizedBox(height: 20),
            Text(
              isPremium ? 'You are a Premium Member!' : 'Upgrade to Premium',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isPremium 
                ? 'Thank you for supporting us. You have unlocked all features!' 
                : 'Unlock all features with a one-tap upgrade.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            const Divider(color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'PREMIUM FEATURES:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureTile(
              Icons.search, 
              'Full Search Access', 
              'Unlock the "Search" tab to find any game.'
            ),
            _buildFeatureTile(
              Icons.bookmark, 
              'Unlimited Backlog', 
              'Save unlimited games to your backlog (Guests/Free users are limited to 4).'
            ),
            _buildFeatureTile(
              Icons.explore, 
              'All Game Carousels', 
              'Unlock all 8+ carousels on the Explore page.'
            ),
            _buildFeatureTile(
              Icons.new_releases, 
              'Exclusive "Indie Gems" Carousel', 
              'Get a special curated list of hidden indie gems.'
            ),
            const SizedBox(height: 40),
            
            // Show the button ONLY if they are not already premium
            if (!isPremium)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  _upgradeToPremium(context);
                },
                child: const Text(
                  'Upgrade Now (Free)',
                  style: TextStyle(
                    color: Colors.black, 
                    fontSize: 18, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.deepPurpleAccent, size: 30),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
    );
  }
}