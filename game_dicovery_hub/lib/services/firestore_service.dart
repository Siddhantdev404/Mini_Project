import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // --- ADD a game (Your existing code) ---
  Future<void> addGameToBacklog(Map<String, dynamic> gameData) async {
    if (_userId == null) return;

    final userDoc = await _db.collection('users').doc(_userId).get();
    if (!userDoc.exists) {
      throw Exception('User profile does not exist.');
    }

    final data = userDoc.data();
    final bool isPremium = data?['isPremium'] ?? false;
    final bool isAdmin = data?['isAdmin'] ?? false;
    final bool isGuest = data?['isGuest'] ?? false;
    final int currentCount = data?['backlogCount'] ?? 0;

    const int maxGuestLimit = 5;
    const int maxNormalLimit = 10;
    final int maxLimit = isGuest ? maxGuestLimit : maxNormalLimit;

    if (!(isPremium || isAdmin)) {
      if (currentCount >= maxLimit) {
        throw Exception('BACKLOG_LIMIT_REACHED:$maxLimit');
      }
    }

    final int gameId = gameData['id'];

    await _db
        .collection('users')
        .doc(_userId)
        .collection('backlog')
        .doc(gameId.toString())
        .set(gameData);

    await _db.collection('users').doc(_userId).update({
      'backlogCount': FieldValue.increment(1),
    });
  }

  // --- REMOVE a game (Your existing code) ---
  Future<void> removeGameFromBacklog(int gameId) async {
    if (_userId == null) return;

    await _db
        .collection('users')
        .doc(_userId)
        .collection('backlog')
        .doc(gameId.toString())
        .delete();

    await _db.collection('users').doc(_userId).update({
      'backlogCount': FieldValue.increment(-1),
    });
  }

  // --- UPGRADE (Your existing code) ---
  Future<void> upgradeToPremium() async {
    if (_userId == null) {
      throw Exception('You must be logged in to upgrade.');
    }
    
    final userDocRef = _db.collection('users').doc(_userId);
    await userDocRef.update({'isPremium': true});
  }

  // --- GET the backlog as a stream ---
  // --- THIS IS THE FIX FOR THE LOGOUT ERROR ---
  Stream<QuerySnapshot?> getBacklogStream() { // Return type changed to QuerySnapshot?
    // 1. Listen to auth state changes
    return _auth.idTokenChanges().asyncExpand((User? user) {
      if (user == null) {
        // 2. If user is null (logged out), return a stream of null.
        // This STOPS the query and prevents PERMISSION_DENIED.
        return Stream.value(null);
      } else {
        // 3. User is logged in, return their backlog stream.
        return _db
            .collection('users')
            .doc(user.uid)
            .collection('backlog')
            .snapshots();
      }
    });
  }
}