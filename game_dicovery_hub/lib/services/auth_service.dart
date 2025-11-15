// lib/services/auth_service.dart

// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:game_dicovery_hub/screens/otp_verify_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _db = FirebaseFirestore.instance;

// --- HELPER FUNCTION: Creates Firestore User Profile on sign-in (CORRECTED & SAFE) ---
// This function runs every time a user successfully logs in.
Future<void> _createFirestoreUser(User user) async {
  final userDocRef = _db.collection('users').doc(user.uid);
  final doc = await userDocRef.get();
  
  // 1. DETERMINE DEVELOPER STATUS (PERMANENT)
  final bool isDeveloperAdmin = (user.email == 'sidhkkr10@gmail.com');
  final bool isProfessorAdmin = (user.email == 'vpg@gmail.com'); // Professor admin check
  final bool isAdminUser = isDeveloperAdmin || isProfessorAdmin;

  // Fields common to all logins (used for merging)
  Map<String, dynamic> commonData = {
    'email': user.email,
    'displayName': user.displayName,
    'photoURL': user.photoURL,
    'isGuest': user.isAnonymous,
    'lastSignIn': FieldValue.serverTimestamp(),
    
    // Developer override for roles
    'isAdmin': isAdminUser,
    'isPremium': isAdminUser,
  };

  if (!doc.exists) {
    // 2. NEW USER: SET INITIAL DATA (Only runs once)
    Map<String, dynamic> initialData = {
      'uid': user.uid,
      'backlogCount': 0, // Starts at zero
      'createdAt': FieldValue.serverTimestamp(), // Written only once
    };

    // Merge initial and common data for the first write
    initialData.addAll(commonData);
    await userDocRef.set(initialData);

  } else {
    // 3. EXISTING USER: MERGE DATA SAFELY
    // This preserves existing 'backlogCount' and 'createdAt'.
    await userDocRef.set(
      commonData, 
      SetOptions(merge: true)
    );
  }
}


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '237697877135-0mpu9ra4njr0m09h9dl53vhr07393nmo.apps.googleusercontent.com',
  );

  // --- SIGN-IN METHODS ---

  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _createFirestoreUser(userCredential.user!); // Create/update role profile
      }
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<User?> signInWithPhoneCredential(String verificationId, String smsCode) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await _createFirestoreUser(userCredential.user!);
      }
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _createFirestoreUser(credential.user!);
      }
      return credential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _createFirestoreUser(credential.user!);
      }
      return credential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<User?> signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      if (userCredential.user != null) {
        await _createFirestoreUser(userCredential.user!);
      }
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> verifyPhoneNumber(BuildContext context, String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          UserCredential userCredential = await _auth.signInWithCredential(credential);
          if (userCredential.user != null) {
            await _createFirestoreUser(userCredential.user!);
          }
        },
        verificationFailed: (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to verify phone: ${e.message}")),
          );
        },
        codeSent: (id, token) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerifyScreen(verificationId: id),
            ),
          );
        },
        codeAutoRetrievalTimeout: (id) {},
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: ${e.message}")),
      );
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // --- SIGN OUT (FINAL ROBUST VERSION) ---
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}