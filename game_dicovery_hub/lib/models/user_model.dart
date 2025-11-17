import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isGuest;
  final bool isAdmin;
  final bool isPremium;
  final int backlogCount;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.isGuest = false,
    this.isAdmin = false,
    this.isPremium = false,
    this.backlogCount = 0,
  });

  // Constructor that uses the Firestore document data
  factory UserModel.fromFirestore(User user, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return UserModel(
      uid: user.uid,
      email: user.email ?? data?['email'],
      displayName: user.displayName ?? data?['displayName'],
      photoURL: user.photoURL ?? data?['photoURL'],
      isGuest: user.isAnonymous,
      // Read roles from the database document
      isAdmin: data?['isAdmin'] ?? false,
      isPremium: data?['isPremium'] ?? false,
      backlogCount: data?['backlogCount'] ?? 0,
    );
  }

  // --- THIS IS THE FIX ---
  // This is the missing constructor that your user_service.dart needs.
  factory UserModel.fromAuthOnly(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      isGuest: user.isAnonymous,
      // Default all other values, as we don't have a doc to read from
      isAdmin: false,
      isPremium: false,
      backlogCount: 0,
    );
  }
}