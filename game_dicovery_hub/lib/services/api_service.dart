// lib/services/api_service.dart
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiService {
  // --- PASTE YOUR KEYS HERE ---
  static const String _clientId = 'tyzgl71sh2wu0r8cxsln03061bg720';
  static const String _clientSecret = 'xb8u5bqb02ftgod3q74eapvqmdvp4q';
  // ------------------------------

  static const String _authUrl = 'https://id.twitch.tv/oauth2/token';
  static const String _gamesUrl = 'https://api.igdb.com/v4/games';

  // cached token + expiry
  static String? _accessToken;
  static DateTime? _tokenExpiry;

  // Protect concurrent token fetches
  static bool _isFetchingToken = false;

  // Timeout for HTTP calls
  static const Duration _httpTimeout = Duration(seconds: 10);

  /// Ensures we have a valid token. Returns true if a usable token is present.
  Future<bool> _ensureAccessToken() async {
    // If token exists and not expired (give a small buffer), reuse it
    if (_accessToken != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!.subtract(const Duration(seconds: 30)))) {
      return true;
    }

    // Prevent concurrent token fetches
    if (_isFetchingToken) {
      // wait until token fetch finishes (simple spin-wait with timeout)
      final end = DateTime.now().add(const Duration(seconds: 8));
      while (_isFetchingToken && DateTime.now().isBefore(end)) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      // either token fetched or timed out — check again
      return _accessToken != null;
    }

    _isFetchingToken = true;
    try {
      final uri = Uri.parse(_authUrl);
      // Twitch expects form-encoded body for client_credentials
      final response = await http
          .post(uri, body: {
            'client_id': _clientId,
            'client_secret': _clientSecret,
            'grant_type': 'client_credentials',
          })
          .timeout(_httpTimeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _accessToken = data['access_token'] as String?;
        final int expiresIn = (data['expires_in'] as int?) ?? 0;
        if (_accessToken == null) {
          print('ApiService: token response missing access_token');
          return false;
        }
        // set expiry
        _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
        print('ApiService: Access Token obtained (expires in $expiresIn s).');
        return true;
      } else {
        print('ApiService: Failed to get access token: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('ApiService: Error getting access token: $e');
      return false;
    } finally {
      _isFetchingToken = false;
    }
  }

  /// Core IGDB fetch helper.
  /// apiBody is the IGDB query language string (plain text).
  /// Will automatically ensure token and retry once on 401 (after refreshing token).
  Future<List<dynamic>> _fetchGamesFromApi(String apiBody) async {
    // Ensure we have a token
    final ok = await _ensureAccessToken();
    if (!ok) throw Exception('Failed to obtain access token');

    // Local helper to actually call IGDB
    Future<http.Response> callIgdb() {
      return http
          .post(
            Uri.parse(_gamesUrl),
            headers: {
              'Client-ID': _clientId,
              'Authorization': 'Bearer $_accessToken',
              // IGDB expects plain text body for the query language
              'Content-Type': 'text/plain',
              'Accept': 'application/json',
            },
            body: apiBody,
          )
          .timeout(_httpTimeout);
    }

    try {
      http.Response response = await callIgdb();

      // If unauthorized, try refreshing token once and retry
      if (response.statusCode == 401) {
        print('ApiService: IGDB returned 401. Refreshing token and retrying...');
        // clear token and fetch a new one
        _accessToken = null;
        final refreshed = await _ensureAccessToken();
        if (!refreshed) throw Exception('Failed to refresh access token');

        response = await callIgdb();
      }

      if (response.statusCode == 200) {
        // IGDB returns a JSON array
        final data = json.decode(response.body);
        if (data is List) {
          return data;
        } else {
          // sometimes IGDB returns object or empty string; normalize to empty list
          return [];
        }
      } else {
        print('ApiService: Failed to fetch games: ${response.statusCode} ${response.body}');
        throw Exception('Failed to fetch games (${response.statusCode})');
      }
    } catch (e) {
      print('ApiService: Error fetching games: $e');
      rethrow;
    }
  }

  // --- EXISTING CAROUSELS ---
  Future<List<dynamic>> fetchPopularGames() async {
    const body =
        'fields name, summary, cover.url, rating, id; sort popularity desc; where rating > 70 & cover != null; limit 10;';
    return await _fetchGamesFromApi(body);
  }

  Future<List<dynamic>> fetchTopRatedGames() async {
    const body =
        'fields name, summary, cover.url, rating, id; sort total_rating desc; where total_rating_count > 1000 & cover != null; limit 10;';
    return await _fetchGamesFromApi(body);
  }

  Future<List<dynamic>> fetchNewReleases() async {
    final int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final body =
        'fields name, summary, cover.url, rating, id; sort first_release_date desc; where first_release_date < $currentTimestamp & first_release_date > ${currentTimestamp - 2592000} & cover != null; limit 10;';
    return await _fetchGamesFromApi(body);
  }

  Future<List<dynamic>> fetchStrategyGames() async {
    const body =
        'fields name, summary, cover.url, rating, id; where genres = (15) & total_rating > 80 & cover != null; sort popularity desc; limit 10;';
    return await _fetchGamesFromApi(body);
  }

  Future<List<dynamic>> fetchArcadeGames() async {
    const body =
        'fields name, summary, cover.url, rating, id; where genres = (25) & total_rating > 70 & cover != null; sort popularity desc; limit 10;';
    return await _fetchGamesFromApi(body);
  }

  Future<List<dynamic>> fetchTrendingGames() async {
    const body =
        'fields name, summary, cover.url, rating, id; sort trending desc; where total_rating_count > 100 & cover != null; limit 10;';
    return await _fetchGamesFromApi(body);
  }

  Future<List<dynamic>> fetchPuzzleGames() async {
    const body =
        'fields name, summary, cover.url, rating, id; where genres = (9) & total_rating > 70 & cover != null; sort popularity desc; limit 10;';
    return await _fetchGamesFromApi(body);
  }

  Future<List<dynamic>> fetchSportsGames() async {
    const body =
        'fields name, summary, cover.url, rating, id; where genres = (14) & total_rating > 70 & cover != null; sort popularity desc; limit 10;';
    return await _fetchGamesFromApi(body);
  }

  Future<List<dynamic>> fetchIndieGames() async {
    const body =
        'fields name, summary, cover.url, rating, id; where genres = (32) & total_rating > 80 & cover != null; sort popularity desc; limit 10;';
    return await _fetchGamesFromApi(body);
  }

  // --- START OF NEW CAROUSEL FETCH METHODS ---

  // Shooter Games (Genre ID 5)
  Future<List<dynamic>> fetchShooterGames() async {
    const body =
        'fields name, summary, cover.url, rating, id; where genres = (5) & total_rating > 75 & cover != null; sort popularity desc; limit 10;';
    return await _fetchGamesFromApi(body);
  }

  // Driving Games / Car Racing (Genre ID 10)
  Future<List<dynamic>> fetchDrivingGames() async {
    const body =
        'fields name, summary, cover.url, rating, id; where genres = (10) & total_rating > 70 & cover != null; sort popularity desc; limit 10;';
    return await _fetchGamesFromApi(body);
  }

  // Multiplayer Games (Theme ID 34) - Note: Using Theme ID for better filtering
  Future<List<dynamic>> fetchMultiplayerGames() async {
    const body =
        'fields name, summary, cover.url, rating, id; where themes = (34) & total_rating_count > 50 & cover != null; sort popularity desc; limit 10;';
    return await _fetchGamesFromApi(body);
  }

  // Single Player Games (Theme ID 1)
  Future<List<dynamic>> fetchSinglePlayerGames() async {
    const body =
        'fields name, summary, cover.url, rating, id; where themes = (1) & total_rating_count > 50 & cover != null; sort popularity desc; limit 10;';
    return await _fetchGamesFromApi(body);
  }


  // --- Search Function ---
  Future<List<dynamic>> searchGames(String query) async {
    final body =
        'fields name, summary, cover.url, rating, id; search "$query"; where cover != null; limit 20;';
    return await _fetchGamesFromApi(body);
  }
}
