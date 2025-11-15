// In test/helpers_test.dart

// ignore_for_file: depend_on_referenced_packages, duplicate_import

import 'package:flutter_test/flutter_test.dart';
import 'package:game_dicovery_hub/utils/helpers.dart';
// Import the file we want to test using your project's name
// !! REPLACE 'game_discovery_hub' with your project's actual name from pubspec.yaml !!
import 'package:game_dicovery_hub/utils/helpers.dart';
void main() {
  // We use `group` to organize related tests
  group('Image URL Formatting', () {
    
    // We use `test` to define a single unit test
    test('formatImageUrl should replace t_thumb and add https', () {
      // 1. ARRANGE
      const String inputUrl = '//images.igdb.com/igdb/image/upload/t_thumb/my_image.jpg';
      const String expectedOutput = 'https://images.igdb.com/igdb/image/upload/t_cover_big/my_image.jpg';

      // 2. ACT
      final String result = formatImageUrl(inputUrl);

      // 3. ASSERT
      // `expect` checks if the result is what we expected.
      expect(result, equals(expectedOutput));
    });

    test('formatImageUrl should only add https if t_thumb is not present', () {
      // 1. ARRANGE
      const String inputUrl = '//images.igdb.com/igdb/image/upload/t_cover_big/my_image.jpg';
      const String expectedOutput = 'https://images.igdb.com/igdb/image/upload/t_cover_big/my_image.jpg';

      // 2. ACT
      final String result = formatImageUrl(inputUrl);

      // 3. ASSERT
      expect(result, equals(expectedOutput));
    });

  });
}