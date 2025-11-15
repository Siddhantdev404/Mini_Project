import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../utils/helpers.dart';
import 'game_detail_screen.dart'; // Import this to make cards clickable

class BacklogScreen extends StatefulWidget {
  const BacklogScreen({super.key});

  @override
  State<BacklogScreen> createState() => _BacklogScreenState();
}

class _BacklogScreenState extends State<BacklogScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    // --- WRAP THE STREAMBUILDER IN A SAFEAREA ---
    return SafeArea(
      // The child of SafeArea will be placed below the status bar.
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getBacklogStream(),
        builder: (context, snapshot) {
          // ... (Loading, Error, and Empty states are the same) ...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            // FIX: This error is usually the PERMISSION_DENIED. Now that the rules are fixed, 
            // it should show up briefly, but the StreamProvider catchError will prevent crashing.
            return const Center(child: Text('An error occurred. Check Firebase connection.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Your backlog is empty.\nGo discover some games!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          // The GridView will now respect the SafeArea
          return GridView.builder(
            // We increase the vertical padding a bit for better separation.
            padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 games per row
              childAspectRatio: 0.7, // Same as our other cards
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final gameData = docs[index].data() as Map<String, dynamic>;
              final int gameId = gameData['id'];
              final String? imageUrl = gameData['cover']?['url'];

              // We make the whole card clickable to go to the detail page
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameDetailScreen(game: gameData),
                    ),
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Game Poster
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl != null
                          ? Image.network(formatImageUrl(imageUrl), fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                            ),
                    ),
                    // Delete button (overlay)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          // This fulfills the "update/delete" requirement
                          _firestoreService.removeGameFromBacklog(gameId);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}