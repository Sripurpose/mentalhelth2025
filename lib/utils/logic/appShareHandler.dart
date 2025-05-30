import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class AppShareHandler {
  // Replace with your actual package names and URLs
  static const String androidPackageName = "com.numuapp.numuapp";
  static const String iosAppId = "com.numuapp.numuapp"; // From App Store Connect

  static const String appDeepLink = "numuapp://home"; // Must match your deep link scheme
  static const String playStoreUrl = "https://play.google.com/store/apps/details?id=$androidPackageName";
  static const String appStoreUrl = "https://apps.apple.com/app/$iosAppId";

  /// Method to handle opening or redirecting to store
  static Future<void> openOrRedirectToStore() async {
    try {
      final Uri deepLink = Uri.parse(appDeepLink);

      // Try launching deep link
      bool launched = await launchUrl(deepLink, mode: LaunchMode.externalApplication);

      // If launching fails, open store
      if (!launched) {
        final Uri storeUri = Uri.parse(Platform.isAndroid ? playStoreUrl : appStoreUrl);
        await launchUrl(storeUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error launching app: $e");
      final Uri storeUri = Uri.parse(Platform.isAndroid ? playStoreUrl : appStoreUrl);
      await launchUrl(storeUri, mode: LaunchMode.externalApplication);
    }
  }

  /// Method to share app link via WhatsApp, etc.
  static Future<void> shareApp() async {
    final storeLink = Platform.isAndroid ? playStoreUrl : appStoreUrl;
    await Share.share("Check out this app: $storeLink");
  }
}
