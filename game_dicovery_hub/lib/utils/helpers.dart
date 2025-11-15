// In lib/utils/helpers.dart

// This is a "top-level" function
String formatImageUrl(String url) {
  return url
      .replaceFirst('t_thumb', 't_cover_big') // Use a bigger image size
      .replaceFirst('//', 'https://'); // Add https protocol
}