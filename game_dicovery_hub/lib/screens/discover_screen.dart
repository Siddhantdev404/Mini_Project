// lib/screens/discover_screen.dart

// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:game_dicovery_hub/models/user_model.dart';
import 'package:game_dicovery_hub/services/api_service.dart';
import 'package:game_dicovery_hub/services/firestore_service.dart';
import 'package:game_dicovery_hub/widgets/game_carousel.dart';
import 'package:provider/provider.dart';
import 'admin_screen.dart'; // Import the Admin Screen

class DiscoverScreen extends StatefulWidget {
  final VoidCallback? onUpgradePressed;

  const DiscoverScreen({
    super.key,
    this.onUpgradePressed,
  });

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final ApiService _apiService = ApiService();
  
  // --- EXISTING CAROUSEL FUTURES ---
  late Future<List<dynamic>> _popularGamesFuture;
  late Future<List<dynamic>> _topRatedGamesFuture;
  late Future<List<dynamic>> _newReleasesFuture;
  late Future<List<dynamic>> _strategyGamesFuture;
  late Future<List<dynamic>> _arcadeGamesFuture;
  late Future<List<dynamic>> _trendingGamesFuture;
  late Future<List<dynamic>> _puzzleGamesFuture;
  late Future<List<dynamic>> _sportsGamesFuture;
  late Future<List<dynamic>> _indieGamesFuture;
  
  // --- NEW CAROUSEL FUTURES ---
  late Future<List<dynamic>> _shooterGamesFuture;
  late Future<List<dynamic>> _drivingGamesFuture;
  late Future<List<dynamic>> _multiplayerGamesFuture;
  late Future<List<dynamic>> _singlePlayerGamesFuture;
  // Removed: late Future<List<dynamic>> _battleRoyaleGamesFuture; 

  @override
  void initState() {
    super.initState();
    // --- EXISTING INITIALIZATION ---
    _popularGamesFuture = _apiService.fetchPopularGames();
    _topRatedGamesFuture = _apiService.fetchTopRatedGames();
    _newReleasesFuture = _apiService.fetchNewReleases();
    _strategyGamesFuture = _apiService.fetchStrategyGames();
    _arcadeGamesFuture = _apiService.fetchArcadeGames();
    _trendingGamesFuture = _apiService.fetchTrendingGames();
    _puzzleGamesFuture = _apiService.fetchPuzzleGames();
    _sportsGamesFuture = _apiService.fetchSportsGames();
    _indieGamesFuture = _apiService.fetchIndieGames();

    // --- NEW INITIALIZATION ---
    _shooterGamesFuture = _apiService.fetchShooterGames();
    _drivingGamesFuture = _apiService.fetchDrivingGames();
    _multiplayerGamesFuture = _apiService.fetchMultiplayerGames();
    _singlePlayerGamesFuture = _apiService.fetchSinglePlayerGames();
    // Removed: _battleRoyaleGamesFuture = _apiService.fetchBattleRoyaleGames();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context); 
    final user = Provider.of<UserModel?>(context);
    
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          // --- ADMIN BUTTON & BADGE ---
          if (user.isAdmin)
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Chip(
                    label: Text('Admin'),
                    backgroundColor: Colors.amber,
                    labelStyle: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings, color: Colors.amber),
                  tooltip: 'Admin Panel',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminScreen()),
                    );
                  },
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CAROUSELS FOR ALL USERS (GUESTS & NORMAL) ---
            GameCarousel(
              title: "Trending Games",
              gameFetchFuture: _trendingGamesFuture,
              firestoreService: firestoreService,
              onUpgradePressed: widget.onUpgradePressed,
            ),
            GameCarousel(
              title: "Popular Games",
              gameFetchFuture: _popularGamesFuture,
              firestoreService: firestoreService,
              onUpgradePressed: widget.onUpgradePressed,
            ),
            GameCarousel(
              title: "Top Rated",
              gameFetchFuture: _topRatedGamesFuture,
              firestoreService: firestoreService,
              onUpgradePressed: widget.onUpgradePressed,
            ),
            
            // --- NEW CAROUSELS FOR ALL USERS (General categories) ---
            GameCarousel(
              title: "Single Player Favorites",
              gameFetchFuture: _singlePlayerGamesFuture,
              firestoreService: firestoreService,
              onUpgradePressed: widget.onUpgradePressed,
            ),
            GameCarousel(
              title: "Multiplayer Madness",
              gameFetchFuture: _multiplayerGamesFuture,
              firestoreService: firestoreService,
              onUpgradePressed: widget.onUpgradePressed,
            ),
            
            // --- PREMIUM & ADMINS ONLY CAROUSELS ---
            if (user.isPremium || user.isAdmin) ...[
              
              // NEW ADDITIONS (Restricted)
              GameCarousel(
                title: "Shooter Games",
                gameFetchFuture: _shooterGamesFuture,
                firestoreService: firestoreService,
                onUpgradePressed: widget.onUpgradePressed,
              ),
              GameCarousel(
                title: "Driving & Racing",
                gameFetchFuture: _drivingGamesFuture,
                firestoreService: firestoreService,
                onUpgradePressed: widget.onUpgradePressed,
              ),
              // Removed: Battle Royale Carousel
              // GameCarousel(
              //   title: "Battle Royale",
              //   gameFetchFuture: _battleRoyaleGamesFuture,
              //   firestoreService: firestoreService,
              //   onUpgradePressed: widget.onUpgradePressed,
              // ),

              // EXISTING PREMIUM CAROUSELS
              GameCarousel(
                title: "Sports",
                gameFetchFuture: _sportsGamesFuture,
                firestoreService: firestoreService,
                onUpgradePressed: widget.onUpgradePressed,
              ),
              GameCarousel(
                title: "Puzzle",
                gameFetchFuture: _puzzleGamesFuture,
                firestoreService: firestoreService,
                onUpgradePressed: widget.onUpgradePressed,
              ),
              GameCarousel(
                title: "Strategy",
                gameFetchFuture: _strategyGamesFuture,
                firestoreService: firestoreService,
                onUpgradePressed: widget.onUpgradePressed,
              ),
              GameCarousel(
                title: "Arcade",
                gameFetchFuture: _arcadeGamesFuture,
                firestoreService: firestoreService,
                onUpgradePressed: widget.onUpgradePressed,
              ),
              GameCarousel(
                title: "New Releases",
                gameFetchFuture: _newReleasesFuture,
                firestoreService: firestoreService,
                onUpgradePressed: widget.onUpgradePressed,
              ),
              GameCarousel(
                title: "✨ Premium: Indie Gems",
                gameFetchFuture: _indieGamesFuture,
                firestoreService: firestoreService,
                onUpgradePressed: widget.onUpgradePressed,
              ),
            ],

            // --- "UPGRADE" PROMPT FOR GUESTS & NORMAL USERS ---
            if (!user.isPremium && !user.isAdmin)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.lock_outline,
                          size: 40, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Upgrade to Premium to unlock 5+ more carousels, Search, and Unlimited Backlog!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        child: const Text('Upgrade Now',
                            style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          widget.onUpgradePressed?.call();
                        },
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}