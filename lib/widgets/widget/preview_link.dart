// Improved normalization + extraction helpers
import 'dart:convert';

String normalizeUrl(String url) {
  if (url == null || url.isEmpty) return '';

  url = url.trim();

  // Remove common Instagram share phrases
  url = url
      .replaceAll(RegExp(r'See this Instagram (post|profile|video|reel) by.*', caseSensitive: false), '')
      .replaceAll(RegExp(r'On Instagram.*', caseSensitive: false), '')
      .trim();

  // If it's an instagram redirect link like l.instagram.com/?u=ENCODED_URL
  if (url.contains('l.instagram.com')) {
    final uri = Uri.tryParse(url);
    final encoded = uri?.queryParameters['u'];
    if (encoded != null && encoded.isNotEmpty) {
      try {
        final decoded = Uri.decodeFull(encoded);
        return normalizeUrl(decoded); // recursively normalize decoded url
      } catch (e) {
        // fallback: continue
      }
    }
  }

  // If string contains "u=" anywhere (maybe pasted whole text), try to extract value
  final uMatch = RegExp(r'u=([^&\s]+)').firstMatch(url);
  if (uMatch != null) {
    final encoded = uMatch.group(1);
    if (encoded != null && encoded.isNotEmpty) {
      try {
        final decoded = Uri.decodeFull(encoded);
        return normalizeUrl(decoded);
      } catch (e) {
        // ignore
      }
    }
  }

  // Fix malformed "https://See this..." cases
  if (url.startsWith('https://See') || url.startsWith('http://See')) {
    // remove the leading "https://See" -> try to find real http inside
    final possible = url.replaceFirst(RegExp(r'https?://See', caseSensitive: false), '');
    final inner = extractFirstRealUrl(possible);
    if (inner.isNotEmpty) return inner;
  }

  // Remove spaces that break URL
  url = url.replaceAll(' ', '');

  // Ensure scheme
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    url = 'https://$url';
  }

  return url;
}

String extractFirstRealUrl(String text) {
  if (text == null || text.isEmpty) return '';

  final s = text.trim();

  // 1) Prefer explicit instagram urls with scheme
  final igExplicit = RegExp(r'https?://[^\s/]*instagram\.com[^\s]*', caseSensitive: false)
      .firstMatch(s);
  if (igExplicit != null) {
    return normalizeUrl(igExplicit.group(0)!);
  }

  // 2) l.instagram redirect links (explicit)
  final lIg = RegExp(r'https?://l\.instagram\.com/[^\s]*', caseSensitive: false).firstMatch(s);
  if (lIg != null) {
    return normalizeUrl(lIg.group(0)!);
  }

  // 3) Any http(s) link
  final generic = RegExp(r'https?://[^\s]+', caseSensitive: false).firstMatch(s);
  if (generic != null) {
    return normalizeUrl(generic.group(0)!);
  }

  // 4) Raw instagram.com without scheme (e.g. "www.instagram.com/p/...")
  final noSchemeIg = RegExp(r'(?:www\.|instagram\.com)[^\s]*instagram\.com[^\s]*|instagram\.com[^\s/]*[^\s]*', caseSensitive: false)
      .firstMatch(s);
  if (noSchemeIg != null) {
    var candidate = noSchemeIg.group(0)!;
    if (!candidate.startsWith('http')) candidate = 'https://$candidate';
    return normalizeUrl(candidate);
  }

  // 5) look for encoded u= param somewhere in the full text (even if not inside a URL)
  final uParam = RegExp(r'u=([^&\s]+)').firstMatch(s);
  if (uParam != null) {
    final encoded = uParam.group(1)!;
    try {
      final decoded = Uri.decodeFull(encoded);
      final extracted = extractFirstRealUrl(decoded);
      if (extracted.isNotEmpty) return extracted;
      return normalizeUrl(decoded);
    } catch (e) {
      // ignore
    }
  }

  return '';
}
