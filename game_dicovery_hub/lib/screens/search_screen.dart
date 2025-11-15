import 'package:flutter/material.dart';
import 'package:game_dicovery_hub/screens/game_detail_screen.dart';
import 'package:game_dicovery_hub/services/api_service.dart';
import 'package:game_dicovery_hub/services/firestore_service.dart';
import 'package:game_dicovery_hub/widgets/game_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();

  Future<List<dynamic>>? _searchFuture;
  List<String> _searchHistory = [];
  static const String _historyKey = 'search_history';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // --- HISTORY LOGIC & HELPERS ---

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList(_historyKey) ?? [];
    });
  }

  void _saveQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory.remove(query);
    _searchHistory.insert(0, query);
    if (_searchHistory.length > 5) {
      _searchHistory = _searchHistory.sublist(0, 5);
    }
    await prefs.setStringList(_historyKey, _searchHistory);
  }

  void _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    setState(() {
      _searchHistory = [];
    });
  }
  
  void _removeSingleQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory.remove(query);
    });
    await prefs.setStringList(_historyKey, _searchHistory);
  }

  // --- SEARCH EXECUTION ---

  void _performSearch(String query) {
    query = query.trim();
    if (query.isEmpty) return;
    
    _saveQuery(query); 
    
    setState(() {
      _searchFuture = _apiService.searchGames(query);
    });
  }

  void _searchFromHistory(String query) {
    _searchController.text = query;
    _performSearch(query);
  }

  // --- WIDGET IMPLEMENTATIONS ---

  // NOTE: This widget was previously missing its implementation in the final block.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Search Bar 
        Padding(
          padding: const EdgeInsets.only(
              top: 40.0, left: 16.0, right: 16.0, bottom: 16.0),
          child: TextField(
            controller: _searchController,
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'Search for any game...',
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.white70),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchFuture = null;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.grey[800],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            onSubmitted: _performSearch,
          ),
        ),

        // 2. Search History Display
        if (_searchFuture == null && _searchHistory.isNotEmpty)
          _buildHistoryContainer(),

        // 3. The Results
        Expanded(
          child: _buildResults(),
        ),
      ],
    );
  }

  // --- NEW WIDGET TO DISPLAY HISTORY (Spotify/ListTile Style) ---
  Widget _buildHistoryContainer() {
    // Only show history if there is no active search result below.
    if (_searchFuture != null || _searchHistory.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Searches",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70),
              ),
              TextButton(
                onPressed: _clearHistory,
                child: const Text('Clear All', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ),
        Column(
            children: _searchHistory.map((query) => ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  leading: const Icon(Icons.history, color: Colors.grey),
                  title: Text(query, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  trailing: IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => _removeSingleQuery(query),
                  ),
                  onTap: () => _searchFromHistory(query),
                )).toList(),
          ),
      ],
    );
  }
  // --- END NEW WIDGET ---

  Widget _buildResults() {
    if (_searchFuture == null) {
      return const Center(
        child: Text(
          'Start typing to find a game.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return FutureBuilder<List<dynamic>>(
      future: _searchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'An error occurred. Please try again.',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No results found for "${_searchController.text}"',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final games = snapshot.data!;
        return GridView.builder(
          padding: const EdgeInsets.all(10.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.7,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            final title = game['name'] as String?;
            final imageUrl = game['cover']?['url'] as String?;
            final int gameId = game['id'] ?? 0;
            final double rating = (game['rating'] as num?)?.toDouble() ?? 0.0;

            if (title == null || imageUrl == null || gameId == 0) {
              return const SizedBox.shrink();
            }

            return GameCard(
              imageUrl: imageUrl,
              title: title,
              rating: rating,
              onSavePressed: () async {
                try {
                  await _firestoreService.addGameToBacklog(game);
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$title added to your backlog!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (e.toString().contains('BACKLOG_LIMIT_REACHED')) {
                    final limit = e.toString().split(':')[1];
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Limit of $limit games reached. Upgrade to Premium!'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              onCardTapped: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameDetailScreen(game: game),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}