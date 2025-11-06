import 'dart:async';
import 'package:app_links/app_links.dart';

class ReferralCodeHelper {
  static final ReferralCodeHelper _instance = ReferralCodeHelper._internal();

  factory ReferralCodeHelper() {
    return _instance;
  }

  ReferralCodeHelper._internal();

  String? _referrerCode;
  StreamSubscription? _deepLinkSubscription;
  final _appLinks = AppLinks();

  String? get referrerCode => _referrerCode;

  /// Initialize referral tracking when app starts
  Future<void> initializeReferralTracking() async {
    try {
      print("=== REFERRAL TRACKING INITIALIZED ===");

      // Listen for deep links (handles both initial and incoming)
      _deepLinkSubscription = _appLinks.uriLinkStream.listen(
            (Uri uri) {
          print("Deep link received: $uri");
          _extractReferrerCode(uri.toString());
        },
        onError: (err) {
          print("Deep link error: $err");
        },
      );

      print("=== REFERRAL TRACKING INITIALIZED SUCCESSFULLY ===");
    } catch (e) {
      print("Error initializing referral tracking: $e");
    }
  }

  /// Extract referrer code from deep link
  void _extractReferrerCode(String link) {
    try {
      print("Extracting referrer from: $link");

      final uri = Uri.parse(link);
      print("Parsed URI - Scheme: ${uri.scheme}, Host: ${uri.host}");
      print("Query Parameters: ${uri.queryParameters}");

      _referrerCode = uri.queryParameters['referrer'];

      if (_referrerCode != null && _referrerCode!.isNotEmpty) {
        print("✅ Extracted referrer code: $_referrerCode");
      } else {
        print("⚠️ No referrer code found in deep link");
      }
    } catch (e) {
      print("Error extracting referrer code: $e");
    }
  }

  /// Get registration URL with referrer code appended
  String getRegistrationUrlWithReferrer(String baseUrl) {
    try {
      print("=== BUILDING REGISTRATION URL ===");
      print("Base URL: $baseUrl");
      print("Referrer Code: $_referrerCode");

      if (_referrerCode == null || _referrerCode!.isEmpty) {
        print("⚠️ No referrer code to append");
        return baseUrl;
      }

      // Check if baseUrl already has query parameters
      if (baseUrl.contains('?')) {
        // Has existing params - append with &
        final finalUrl = "$baseUrl&referrer=$_referrerCode";
        print("✅ Final URL with referrer: $finalUrl");
        print("=== REGISTRATION URL BUILD COMPLETED ===");
        return finalUrl;
      } else {
        // No existing params - append with ?
        final finalUrl = "$baseUrl?referrer=$_referrerCode";
        print("✅ Final URL with referrer: $finalUrl");
        print("=== REGISTRATION URL BUILD COMPLETED ===");
        return finalUrl;
      }
    } catch (e) {
      print("Error building registration URL: $e");
      return baseUrl;
    }
  }

  /// Debug: Print all information
  void debugPrintReferralInfo() {
    print("=== REFERRAL CODE DEBUG INFO ===");
    print("Referrer Code Stored: $_referrerCode");
    print("Referrer Code is null: ${_referrerCode == null}");
    print("Referrer Code is empty: ${_referrerCode?.isEmpty}");
    print("=== END DEBUG INFO ===");
  }

  /// Cleanup
  void dispose() {
    print("Disposing ReferralCodeHelper");
    _deepLinkSubscription?.cancel();
  }
}