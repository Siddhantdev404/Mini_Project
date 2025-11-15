import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isGuest;
  
  // These are our new roles
  final bool isPremium;
  final bool isAdmin;
  final int backlogCount; // For the 4-game limit

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.isGuest = false,
    this.isPremium = false,
    this.isAdmin = false,
    this.backlogCount = 0,
  });

  // A factory to create a UserModel from a Firebase User and their Firestore document
  factory UserModel.fromFirestore(User firebaseUser, DocumentSnapshot<Map<String, dynamic>>? firestoreDoc) {
    
    // Default roles (if doc doesn't exist yet)
    bool isPremium = false;
    bool isAdmin = false;
    int backlogCount = 0;

    // Read roles from the Firestore document if it exists
    if (firestoreDoc != null && firestoreDoc.exists) {
      isPremium = firestoreDoc.data()?['isPremium'] as bool? ?? false;
      isAdmin = firestoreDoc.data()?['isAdmin'] as bool? ?? false;
      backlogCount = firestoreDoc.data()?['backlogCount'] as int? ?? 0;
    }

    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      isGuest: firebaseUser.isAnonymous,
      isPremium: isPremium,
      isAdmin: isAdmin,
      backlogCount: backlogCount,
    );
  }

  static fromDocument(DocumentSnapshot<Map<String, dynamic>> snap) {}
}