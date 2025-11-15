// ignore_for_file: prefer_const_declarations

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // --- ADD a game to the backlog ---
  // In lib/services/firestore_service.dart

// In lib/services/firestore_service.dart

// ... (Your existing imports and class definition) ...

// --- ADD a game to the backlog (UPDATED WITH LIMITS) ---
// In lib/services/firestore_service.dart

Future<void> addGameToBacklog(Map<String, dynamic> gameData) async {
  if (_userId == null) return; 

  final userDoc = await _db.collection('users').doc(_userId).get();
  final data = userDoc.data();
  
  // Fetch current user roles and count
  final bool isPremium = data?['isPremium'] ?? false;
  final bool isAdmin = data?['isAdmin'] ?? false;
  final bool isGuest = data?['isGuest'] ?? false;
  final int currentCount = data?['backlogCount'] ?? 0;

  // --- LIMIT LOGIC ---
  final int maxGuestLimit = 5; // Guest Limit
  final int maxNormalLimit = 10; // Normal User Limit
  
  // Determine the limit based on user type
  final int maxLimit = isGuest ? maxGuestLimit : maxNormalLimit;

  // PREMIUM/ADMIN CHECK: Skip limits
  if (!(isPremium || isAdmin)) {
    // If user is NOT Premium/Admin, check the limit
    if (currentCount >= maxLimit) {
      // Throw a specific exception that the UI can catch
      throw Exception('BACKLOG_LIMIT_REACHED:$maxLimit');
    }
  }
  // --- END OF LIMIT LOGIC ---
  
  final int gameId = gameData['id'];
  // ... (rest of the save logic: add document and increment count) ...
  await _db.collection('users').doc(_userId).collection('backlog').doc(gameId.toString()).set(gameData);
  await _db.collection('users').doc(_userId).update({'backlogCount': FieldValue.increment(1)});
}
  // --- REMOVE a game from the backlog ---
  Future<void> removeGameFromBacklog(int gameId) async {
    if (_userId == null) return;

    // 1. Delete the game document
    await _db
        .collection('users')
        .doc(_userId)
        .collection('backlog')
        .doc(gameId.toString())
        .delete();
        
    // 2. Decrement the count on the user's profile
    await _db.collection('users').doc(_userId).update({
      'backlogCount': FieldValue.increment(-1),
    });
  }

  // --- GET the backlog count (for Problem 2) ---
  Future<int> getBacklogCount() async {
    if (_userId == null) return 0;
    try {
      final doc = await _db.collection('users').doc(_userId).get();
      return doc.data()?['backlogCount'] as int? ?? 0;
    } catch (e) {
      return 0; // Return 0 if doc doesn't exist
    }
  }

  // --- NEW: UPGRADE TO PREMIUM FUNCTION (for Problem 4) ---
// In lib/services/firestore_service.dart

Future<void> upgradeToPremium() async {
  if (_userId == null) {
    throw Exception('You must be logged in to upgrade.');
  }

  // --- NEW: Add logic to check if user is already premium or admin ---
  final userDoc = await _db.collection('users').doc(_userId).get();
  final bool isPremium = userDoc.data()?['isPremium'] ?? false;
  final bool isAdmin = userDoc.data()?['isAdmin'] ?? false;

  if (isPremium || isAdmin) {
    throw Exception('You are already a premium member.');
  }
  // --- END NEW LOGIC ---
  
  // NOTE: You are not allowed to update 'isPremium' directly from the client 
  // due to the security rules. The line below will fail if not done by Admin.
  
  // *** If you are using this for testing only, you need to be an Admin to run this. ***
  final userDocRef = _db.collection('users').doc(_userId);
  await userDocRef.update({'isPremium': true});
}
  // --- GET the backlog as a stream ---
  Stream<QuerySnapshot> getBacklogStream() {
    if (_userId == null) {
      // ignore: prefer_const_constructors
      return Stream.empty();
    }
    return _db
        .collection('users')
        .doc(_userId)
        .collection('backlog')
        .snapshots();
  }
}