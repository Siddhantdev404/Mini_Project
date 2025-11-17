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
    return SafeArea(
      child: StreamBuilder<QuerySnapshot?>( // <-- 1. Change type to QuerySnapshot?
        stream: _firestoreService.getBacklogStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text('An error occurred. Check Firebase connection.'));
          }
          
          // --- 2. This is the new, safer check ---
          // Check for null data (logged out) OR empty docs (logged in, empty backlog)
          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Your backlog is empty.\nGo discover some games!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          // --- End of new check ---

          final docs = snapshot.data!.docs;

          return GridView.builder(
            padding:
                const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final gameData = docs[index].data() as Map<String, dynamic>;
              final int gameId = gameData['id'];
              final String? imageUrl = gameData['cover']?['url'];

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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl != null
                          ? Image.network(formatImageUrl(imageUrl),
                              fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                            ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
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