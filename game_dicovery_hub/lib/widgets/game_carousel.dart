import 'package:flutter/material.dart';
import 'package:game_dicovery_hub/models/user_model.dart';
import 'package:game_dicovery_hub/screens/game_detail_screen.dart';
import 'package:game_dicovery_hub/services/auth_service.dart';
import 'package:game_dicovery_hub/services/firestore_service.dart';
import 'package:game_dicovery_hub/widgets/game_card.dart';
import 'package:provider/provider.dart';

class GameCarousel extends StatelessWidget {
  final String title;
  final Future<List<dynamic>> gameFetchFuture;
  final FirestoreService firestoreService;
  final VoidCallback? onUpgradePressed; // <-- 1. ADDED THIS

  const GameCarousel({
    super.key,
    required this.title,
    required this.gameFetchFuture,
    required this.firestoreService,
    this.onUpgradePressed, // <-- 2. ADDED THIS
  });

  // Helper to save game
  void _saveToBacklog(BuildContext context, Map<String, dynamic> game) {
    firestoreService.addGameToBacklog(game);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${game['name']} added to your backlog!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // --- NEW: Limit Check Logic (for Problem 2) ---
  Future<void> _handleSavePressed(
      BuildContext context, Map<String, dynamic> game, UserModel user) async {
    // Premium and Admins have no limits
    if (user.isPremium || user.isAdmin) {
      _saveToBacklog(context, game);
      return;
    }

    // --- Guest & Normal User Logic ---
    // We get the count from the user model
    final currentCount = user.backlogCount;

    if (currentCount >= 4) {
      // --- LIMIT REACHED ---
      _showLimitReachedDialog(context, user.isGuest);
    } else {
      // --- ALLOW SAVING (with a warning for guests) ---
      if (user.isGuest) {
        _showGuestBacklogDialog(context, game);
      } else {
        // Normal user is under the 4-game limit, just save it
        _saveToBacklog(context, game);
      }
    }
  }

  // Helper dialog for Guest Backlog
  void _showGuestBacklogDialog(
      BuildContext context, Map<String, dynamic> game) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Guest Mode'),
        content: const Text(
            'Your backlog is limited to 4 games and will be lost when you sign out. Create a free account to save your games forever!'),
        actions: [
          TextButton(
            child: const Text('Save Anyway'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _saveToBacklog(context, game); // Let them save
            },
          ),
          ElevatedButton(
            child: const Text('Sign Up'),
            onPressed: () {
              Navigator.of(ctx).pop();
              AuthService().signOut(); // Sign out the guest
            },
          ),
        ],
      ),
    );
  }

  // --- NEW: Limit Reached Dialog ---
  void _showLimitReachedDialog(BuildContext context, bool isGuest) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Backlog Limit Reached!'),
        content: Text(
            '${isGuest ? "Guests are" : "Free accounts are"} limited to saving 4 games. Please upgrade to Premium for an unlimited backlog!'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text('Upgrade'),
            onPressed: () {
              Navigator.of(ctx).pop();
              // --- 3. MODIFIED THIS ---
              // Instead of trying to find a specific state,
              // just call the function we were given.
              onUpgradePressed?.call();
              // --- END MODIFICATION ---
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    if (user == null) return const SizedBox.shrink(); // Hide if user data not ready

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 24.0, bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: FutureBuilder<List<dynamic>>(
            future: gameFetchFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('No games found.',
                        style: TextStyle(color: Colors.white70)));
              }

              final games = snapshot.data!;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  final title = game['name'] as String?;
                  final imageUrl = game['cover']?['url'] as String?;
                  final double rating =
                      (game['rating'] as num?)?.toDouble() ?? 0.0;

                  if (title == null || imageUrl == null) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: GameCard(
                      imageUrl: imageUrl,
                      title: title,
                      rating: rating,
                      onSavePressed: () {
                        // Use the new simplified handler
                        _handleSavePressed(context, game, user);
                      },
                      onCardTapped: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    GameDetailScreen(game: game)));
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- 4. REMOVED THE INCORRECT STUBS ---
// extension on _MainScreenState { ... }
// class _MainScreenState { ... }