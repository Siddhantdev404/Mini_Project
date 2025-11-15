// lib/services/user_service.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_dicovery_hub/models/user_model.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // This provides a real-time stream of the user's roles
  Stream<UserModel?> streamUserModel() {
    // CRITICAL FIX: Use idTokenChanges() to wait for the Firestore security token to be ready.
    return _auth.idTokenChanges().asyncExpand((firebaseUser) {
    
      if (firebaseUser == null) {
        return Stream.value(null); // User is logged out
      }
      
      // User is logged in, now listen to their Firestore document
      return _db.collection('users').doc(firebaseUser.uid).snapshots()
        .map((firestoreDoc) {
          // Combine auth data with Firestore data
          return UserModel.fromFirestore(firebaseUser, firestoreDoc);
        });
    });
  }
}