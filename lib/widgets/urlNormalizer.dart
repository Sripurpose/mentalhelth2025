import 'package:flutter/material.dart';

import '../screens/addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';

/// Normalizes URLs from different sources (apps vs browsers)
/// Handles Instagram, YouTube, and other social media platforms
class UrlNormalizer {

  /// Main normalization function
  static String normalizeUrl(String rawUrl) {
    // Remove any leading/trailing whitespace
    String url = rawUrl.trim();

    // Handle Instagram URLs
    if (url.contains('instagram.com')) {
      return _normalizeInstagramUrl(url);
    }

    // Handle YouTube URLs
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return _normalizeYoutubeUrl(url);
    }

    // Handle Twitter/X URLs
    if (url.contains('twitter.com') || url.contains('x.com')) {
      return _normalizeTwitterUrl(url);
    }

    // For other URLs, just ensure proper protocol
    return _ensureProtocol(url);
  }

  /// Normalize Instagram URLs
  static String _normalizeInstagramUrl(String url) {
    // Extract Instagram URL from malformed text like:
    // "See this Instagram post by @username https://www.instagram.com/p/ABC123/?utm_source=..."

    // Pattern to match Instagram URLs
    final instagramPattern = RegExp(
      r'https?://(?:www\.)?instagram\.com/(?:p|reel|tv)/([A-Za-z0-9_-]+)',
      caseSensitive: false,
    );

    final match = instagramPattern.firstMatch(url);

    if (match != null) {
      final postId = match.group(1);
      final urlType = url.contains('/reel/') ? 'reel' :
      url.contains('/tv/') ? 'tv' : 'p';

      // Return clean URL without tracking parameters
      return 'https://www.instagram.com/$urlType/$postId/';
    }

    // If no match, try to clean up the URL
    if (url.contains('instagram.com')) {
      // Remove everything before the actual URL
      final urlStart = url.indexOf('https://');
      if (urlStart > 0) {
        url = url.substring(urlStart);
      }

      // Remove tracking parameters
      url = _removeTrackingParams(url);
    }

    return _ensureProtocol(url);
  }

  /// Normalize YouTube URLs
  static String _normalizeYoutubeUrl(String url) {
    // Handle youtu.be short links
    if (url.contains('youtu.be/')) {
      final videoIdMatch = RegExp(r'youtu\.be/([A-Za-z0-9_-]{11})').firstMatch(url);
      if (videoIdMatch != null) {
        return 'https://www.youtube.com/watch?v=${videoIdMatch.group(1)}';
      }
    }

    // Clean up tracking parameters
    return _removeTrackingParams(url);
  }

  /// Normalize Twitter/X URLs
  static String _normalizeTwitterUrl(String url) {
    // Convert twitter.com to x.com or vice versa if needed
    // Remove tracking parameters
    return _removeTrackingParams(url);
  }

  /// Remove common tracking parameters
  static String _removeTrackingParams(String url) {
    try {
      final uri = Uri.parse(url);

      // List of tracking parameters to remove
      final trackingParams = [
        'utm_source',
        'utm_medium',
        'utm_campaign',
        'utm_content',
        'utm_term',
        'igsh',
        'igshid',
        'fbclid',
        'gclid',
        'ref',
        'ref_src',
      ];

      // Remove tracking parameters
      final cleanParams = Map<String, dynamic>.from(uri.queryParameters)
        ..removeWhere((key, value) => trackingParams.contains(key.toLowerCase()));

      // Rebuild URL without tracking params
      final cleanUri = uri.replace(
        queryParameters: cleanParams.isEmpty ? null : cleanParams,
      );

      return cleanUri.toString();
    } catch (e) {
      debugPrint('Error removing tracking params: $e');
      return url;
    }
  }

  /// Ensure URL has proper protocol
  static String _ensureProtocol(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return 'https://$url';
    }
    return url;
  }

  /// Extract all URLs from text and normalize them
  static List<String> extractAndNormalizeUrls(String text, RegExp urlRegex) {
    final matches = urlRegex.allMatches(text);

    return matches
        .map((match) => normalizeUrl(match.group(0)!))
        .toList();
  }
}


// Example usage in your provider
class LinkDetectionHelper {
  static final urlRegex = RegExp(
    r'(?:(?:https?|ftp):\/\/)?(?:www\.)?[a-zA-Z0-9-]+(?:\.[a-zA-Z]{2,})+(?:\/[^\s]*)?',
    caseSensitive: false,
  );

  /// Detect and normalize links from text
  static String? detectAndNormalizeLink(String text) {
    final matches = urlRegex.allMatches(text);

    if (matches.isEmpty) return null;

    // Get the first link and normalize it
    final firstMatch = matches.first.group(0)!;
    return UrlNormalizer.normalizeUrl(firstMatch);
  }
}

// Updated onChanged handler for your text field
void handleTextChanged(String value, AdDreamsGoalsProvider provider, Function setState) {
  final matches = provider.urlRegex
      .allMatches(value)
      .map((match) => match.group(0)!)
      .toList();

  if (matches.isNotEmpty) {
    // Get the raw link from text
    final firstRawLink = matches.first;

    // Normalize it (handles Instagram, YouTube, etc.)
    final normalizedLink = UrlNormalizer.normalizeUrl(firstRawLink);

    setState(() {
      provider.detectedLinks.clear();
      provider.detectedLinks = [normalizedLink];
    });

    // Remove the entire matched text (including malformed parts)
    final cleanedText = value.replaceAll(provider.urlRegex, '').trim();

    provider.commentEditTextController.text = cleanedText;
    provider.commentEditTextController.selection =
        TextSelection.fromPosition(TextPosition(offset: cleanedText.length));
  }
}