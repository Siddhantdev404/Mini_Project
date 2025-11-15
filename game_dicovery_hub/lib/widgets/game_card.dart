import 'package:flutter/material.dart';
import '../utils/helpers.dart';

class GameCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double rating; // --- NEW: Add rating field ---
  final VoidCallback onSavePressed;
  final VoidCallback onCardTapped;

  const GameCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.rating, // --- NEW: Add to constructor ---
    required this.onSavePressed,
    required this.onCardTapped,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedUrl = formatImageUrl(imageUrl);
    // --- NEW: Format the rating to be out of 10 ---
    final String formattedRating = (rating / 10).toStringAsFixed(1);

    return SizedBox(
      width: 140,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onCardTapped,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Column with Image and Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 180,
                    child: Image.network(
                      formattedUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported,
                            color: Colors.grey);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
        
              // The "Save" button
              Positioned(
                top: 4,
                right: 4,
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: IconButton(
                    icon: const Icon(Icons.add_circle_outline,
                        color: Colors.white),
                    onPressed: onSavePressed,
                    tooltip: 'Add to backlog',
                  ),
                ),
              ),

              // --- NEW: Rating Badge ---
              if (rating > 0)
                Positioned(
                  bottom: 40, // Position it just above the text
                  left: 8,
                  child: Chip(
                    label: Text(
                      "$formattedRating / 10",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    // ignore: deprecated_member_use
                    backgroundColor: Colors.black.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                    visualDensity: VisualDensity.compact, // Makes it smaller
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}