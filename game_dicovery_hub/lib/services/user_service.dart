import 'dart:async';
// --- THIS IS THE FIX ---
// It's 'package:cloud_firestore', not 'package-cloud_firestore'
import 'package:cloud_firestore/cloud_firestore.dart';
// --- END OF FIX ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:game_dicovery_hub/models/user_model.dart'; // Make sure this path is correct

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<UserModel?> streamUserModel() async* {
    // Listen for auth token changes
    await for (final firebaseUser in _auth.idTokenChanges()) {
      if (firebaseUser == null) {
        // user signed out -> emit null and continue listening for sign-in
        yield null;
        continue;
      }

      final docRef = _db.collection('users').doc(firebaseUser.uid);

      // Try to read the doc first to check permissions and existence.
      // If read fails with PERMISSION_DENIED, we retry with backoff.
      const int maxAttempts = 6;
      int attempt = 0;
      bool ok = false;

      // This loop will retry if it gets a permission error
      while (attempt < maxAttempts && !ok) {
        attempt++;
        try {
          final snapshot = await docRef.get();
          // if we get here without exception, we have permission to read
          ok = true;

          // If the doc doesn't exist yet, return a default UserModel created from firebaseUser
          // This happens for brand new users while auth_service creates the doc
          if (!snapshot.exists) {
            // This is the new constructor we must add to your UserModel
            yield UserModel.fromAuthOnly(firebaseUser);
            // still listen for later creation/updates
          }

          // Now switch to snapshots stream for real-time updates
          // This will run if the doc *does* exist
          await for (final docSnap in docRef.snapshots()) {
            // Check for existence again in case it's deleted mid-stream
            if (docSnap.exists) {
              yield UserModel.fromFirestore(firebaseUser, docSnap);
            } else {
              // If doc is deleted, behave like it doesn't exist yet
              yield UserModel.fromAuthOnly(firebaseUser);
            }
          }
        } on FirebaseException catch (e) {
          // Firestore returns code 'permission-denied' when rules block the read
          if (e.code == 'permission-denied') {
            // yield null so the app can remain usable and show a loading state
            yield null;
            // exponential backoff retry (short)
            final delay = Duration(milliseconds: 500 * attempt);
            await Future.delayed(delay);
            // then loop and retry
          } else {
            // other firestore errors: yield null and break
            yield null;
            break;
          }
        } catch (_) {
          // non-FirebaseException, yield null and break
          yield null;
          break;
        }
      } // end retry loop

      if (!ok) {
        // after retries we still couldn't read — yield null and continue to wait for next idTokenChanges
        yield null;
      }
    } // end auth idTokenChanges
  }
}