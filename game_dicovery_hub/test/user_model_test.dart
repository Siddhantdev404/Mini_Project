// test/user_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:game_dicovery_hub/models/user_model.dart'; // Import the class to test

void main() {
  group('UserModel Constructor', () {
    
    test('should correctly assign admin status from constructor', () {
      // 1. Arrange: Create a user model with admin status
      final adminUser = UserModel(
        uid: 'admin123',
        email: 'admin@test.com',
        isAdmin: true, // Set the flag
        isPremium: true,
      );

      // 2. Assert: Check that the flags were set
      expect(adminUser.uid, 'admin123');
      expect(adminUser.isAdmin, isTrue);
      expect(adminUser.isPremium, isTrue);
    });

    test('should default to non-admin and non-premium', () {
      // 1. Arrange: Create a user model with no special roles
      final normalUser = UserModel(
        uid: 'user456',
        email: 'user@test.com',
        // Do not provide isAdmin or isPremium
      );

      // 2. Assert: Check that the defaults are correct
      expect(normalUser.uid, 'user456');
      expect(normalUser.isAdmin, isFalse);
      expect(normalUser.isPremium, isFalse);
      expect(normalUser.backlogCount, 0);
    });
  });
}