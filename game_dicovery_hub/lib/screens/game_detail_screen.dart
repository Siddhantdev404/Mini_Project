import 'package:flutter/material.dart';

class GameDetailScreen extends StatelessWidget {
  final Map<String, dynamic> game;

  const GameDetailScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final String title = game['name'] ?? 'No Title';
    final String imageUrl = game['cover']?['url'] ?? '';
    final String summary = game['summary'] ?? 'No summary available.';
    final double rating = (game['rating'] as num?)?.toDouble() ?? 0.0;
    
    // --- 1. FIX: Format rating to be / 10 ---
    final String formattedRating = (rating / 10).toStringAsFixed(1);
    
    final String posterUrl = imageUrl
        .replaceFirst('t_thumb', 't_720p') 
        .replaceFirst('//', 'https://');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Image Poster is the same) ...
            Image.network(
              posterUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  height: 250,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 250,
                  child: Icon(Icons.image_not_supported, color: Colors.grey),
                );
              },
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... (Title is the same) ...
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- 2. FIX: Update the Chip text ---
                  if (rating > 0)
                    Chip(
                      label: Text(
                        'Rating: $formattedRating / 10', // <-- THE FIX
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                  
                  const SizedBox(height: 24),

                  // ... (Summary is the same) ...
                  const Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                      height: 1.5, 
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}