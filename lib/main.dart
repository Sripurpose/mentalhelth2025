
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mentalhelth/firebase_options.dart';
import 'package:mentalhelth/screens/SharePostView.dart';
import 'package:mentalhelth/screens/addactions_screen/model/alaram_info.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/add_goals_link_par_screen.dart';
import 'package:mentalhelth/screens/auth/sign_in/widget/referral_code_helper.dart';
import 'package:mentalhelth/screens/auth/signup_screen/provider/signup_provider.dart';
import 'package:mentalhelth/screens/auth/splash/splash.dart';
import 'package:mentalhelth/screens/auth/subscribe_plan_page/provider/subscribe_plan_provider.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/provider/goals_dreams_provider.dart';
import 'package:mentalhelth/screens/journal_list_screen/provider/journal_list_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/screens/reminder_push_view_screen/reminder_push_view_screen.dart';
import 'package:mentalhelth/utils/core/firebase_api.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'screens/actions_screen/provider/my_action_provider.dart';
import 'screens/addactions_screen/provider/add_actions_provider.dart';
import 'screens/addgoals_dreams_screen/provider/ad_goals_dreams_provider.dart';
import 'screens/auth/sign_in/provider/sign_in_provider.dart';
import 'screens/confirm_delete_screen/provider/delete_provider.dart';
import 'screens/confirm_plan_screen/provider/my_plan_provider.dart';
import 'screens/feedback_screen/provider/feed_back_provider.dart';
import 'screens/home_screen/provider/home_provider.dart';
import 'screens/phone_singin_screen/provider/phone_sign_in_provider.dart';
import 'screens/privacy_screen/provider/privacy_policy_provider.dart';

// ===== Globals =====
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const platform = MethodChannel('com.numuapp.numuapp/native');
String? oneSignalIdOriginal;

// ===== Global Deep Link Handler =====
class DeepLinkHandler {
  static final DeepLinkHandler _instance = DeepLinkHandler._internal();

  factory DeepLinkHandler() => _instance;

  DeepLinkHandler._internal();

  String? pendingUrl;
  String? pendingText;
  List<String>? pendingImages;
  bool hasPendingNavigation = false;
  bool _isNavigating = false;

  Future<void> handleDeepLink({
    String? url,
    String? text,
    List<String>? images,
  }) async {
    if (_isNavigating) {
      debugPrint('⚠️ Navigation already in progress, skipping');
      return;
    }

    pendingUrl = url;
    pendingText = text;
    pendingImages = images;
    hasPendingNavigation = true;

    debugPrint(
        '📌 Deep link queued: url=$url, text=$text, images=${images?.length ?? 0}');

    // Try to navigate immediately, if not possible it will be handled on resume
    _attemptNavigation();
  }

  void _attemptNavigation() {
    if (!hasPendingNavigation || _isNavigating) return;

    final ctx = navigatorKey.currentContext;
    if (ctx == null) {
      debugPrint('⚠️ Context not ready yet, will retry on resume');
      return;
    }

    debugPrint('✅ Navigating with pending deep link');
    _performNavigation(ctx, pendingUrl, pendingText, pendingImages);
    hasPendingNavigation = false;
  }

  void _performNavigation(
    BuildContext ctx,
    String? url,
    String? text,
    List<String>? images,
  ) {
    if (_isNavigating) {
      debugPrint('⚠️ Navigation already in progress');
      return;
    }

    try {
      _isNavigating = true;
      debugPrint(
          '🚀 Starting navigation to AddGoalsLinkParScreen with url=$url');

      // Delay slightly to ensure widget tree is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          final navigator = Navigator.of(ctx);
          debugPrint('📍 Navigator state: ${navigator.mounted}');

          final route = MaterialPageRoute(
            builder: (_) {
              debugPrint('🔨 Building AddGoalsLinkParScreen with url=$url');
              return AddGoalsLinkParScreen(
                sharedUrl: url,
                sharedText: text,
                sharedImages: images,
                onClose: () {
                  debugPrint('❌ AddGoalsLinkParScreen onClose called');
                  _isNavigating = false;
                },
              );
            },
            settings: RouteSettings(
              name: 'AddGoalsLinkParScreen',
              arguments: {'url': url, 'text': text, 'images': images},
            ),
          );

          navigator.push(route).then((result) {
            debugPrint('✅ Navigation completed with result: $result');
            _isNavigating = false;
          }).catchError((e) {
            debugPrint('❌ Navigation error: $e');
            _isNavigating = false;
          });

          debugPrint('✅ Navigation pushed successfully');
        } catch (e) {
          debugPrint(
              '❌ Navigation error in delayed: $e\n${StackTrace.current}');
          _isNavigating = false;
        }
      });
    } catch (e) {
      debugPrint('❌ Error in _performNavigation: $e\n${StackTrace.current}');
      _isNavigating = false;
    }
  }

  void resetNavigation() {
    _isNavigating = false;
    hasPendingNavigation = false;
    pendingUrl = null;
    pendingText = null;
    pendingImages = null;
  }
}

final deepLinkHandler = DeepLinkHandler();

// ===== YouTube URL Handler =====
class YouTubeUrlHandler {
  static String? getPlayableYouTubeUrl(String? urlString) {
    if (urlString == null || urlString.isEmpty) return null;

    try {
      var url = urlString.trim();

      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }

      final uri = Uri.parse(url);
      String? videoId;

      if ((uri.host.contains('youtube.com')) &&
          uri.queryParameters.containsKey('v')) {
        videoId = uri.queryParameters['v'];
      } else if (uri.host.contains('youtu.be')) {
        videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      } else if (uri.host.contains('youtube.com') &&
          uri.path.contains('/embed/')) {
        videoId = uri.pathSegments.where((e) => e.isNotEmpty).lastWhere(
              (_) => true,
              orElse: () => '',
            );
      } else if (uri.host.contains('youtube.com') && uri.path.contains('/v/')) {
        videoId = uri.pathSegments.where((e) => e.isNotEmpty).lastWhere(
              (_) => true,
              orElse: () => '',
            );
      }

      if (videoId != null && videoId.isNotEmpty) {
        final playableUrl = 'https://www.youtube.com/watch?v=$videoId';
        debugPrint('✅ YouTube Video ID extracted: $videoId → $playableUrl');
        return playableUrl;
      }

      return url;
    } catch (e) {
      debugPrint('❌ Error parsing YouTube URL: $e');
      return urlString;
    }
  }

  static bool isYouTubeUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('youtube.com') ||
        lowerUrl.contains('youtu.be') ||
        lowerUrl.contains('youtube.com/embed');
  }

  static bool looksLikeUrl(String text) {
    if (text.isEmpty) return false;
    return text.startsWith('http://') ||
        text.startsWith('https://') ||
        text.startsWith('www.') ||
        text.contains('youtube.com') ||
        text.contains('youtu.be') ||
        (text.contains('.') &&
            (text.contains('com') ||
                text.contains('io') ||
                text.contains('app') ||
                text.contains('org')));
  }
}

// ===== Background FCM handler =====
Future<void> _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    debugPrint("[BG] Notification title: ${message.notification!.title}");
  }
}

// ===== Referral init =====
Future<void> initializeReferralTracking() async {
  final referralHelper = ReferralCodeHelper();
  await referralHelper.initializeReferralTracking();
  debugPrint("Referral tracking initialized");
}

// ===== Share Receiver (Android) =====
class ShareReceiver {
  static const _channel = MethodChannel('com.numuapp.share/channel');

  static void init() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onShareReceived") {
        final type = call.arguments["type"];
        var data = call.arguments["data"] as String?;

        if (data != null) {
          data = data.trim();
          if (YouTubeUrlHandler.looksLikeUrl(data) &&
              !data.startsWith('http')) {
            data = 'https://$data';
          }
        }

        debugPrint("📩 Received shared data ($type): $data");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('shared_type', type);
        await prefs.setString('shared_data', data ?? '');

        _processAndNavigate(type, data);
      }
    });
  }

  static void _processAndNavigate(String type, String? data) {
    String? sharedUrl;
    String? sharedText;
    List<String>? sharedImages;

    try {
      if (type == "text") {
        var processedData = data?.trim() ?? '';
        debugPrint("📄 Processing Text: $processedData");

        if (YouTubeUrlHandler.looksLikeUrl(processedData)) {
          if (!processedData.startsWith('http')) {
            processedData = 'https://$processedData';
          }

          if (YouTubeUrlHandler.isYouTubeUrl(processedData)) {
            final playableUrl =
                YouTubeUrlHandler.getPlayableYouTubeUrl(processedData);
            sharedUrl = playableUrl;
            debugPrint("🎥 YouTube URL: $sharedUrl");
          } else {
            sharedUrl = processedData;
            debugPrint("🔗 Regular URL: $sharedUrl");
          }
        } else {
          sharedText = processedData;
          debugPrint("📝 Plain text: $sharedText");
        }
      } else if (type == "image") {
        sharedImages = [data ?? ''];
        debugPrint("🖼 Image: $data");
      } else if (type == "video") {
        sharedImages = [data ?? ''];
        debugPrint("🎥 Video: $data");
      } else if (type == "multiple") {
        sharedImages = (data ?? '')
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        debugPrint("📦 Multiple files: ${sharedImages.length}");
      }

      // Clear the stored data immediately after processing
      unawaited(clearSharedData());

      deepLinkHandler.handleDeepLink(
        url: sharedUrl,
        text: sharedText,
        images: sharedImages,
      );
    } catch (e) {
      debugPrint("❌ Error in _processAndNavigate: $e");
    }
  }

  static Future<void> checkAndNavigateOnResume() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final type = prefs.getString('shared_type');
      final data = prefs.getString('shared_data');

      if (type != null && data != null && data.isNotEmpty) {
        debugPrint("🔄 Found stored shared data: $type - $data");
        _processAndNavigate(type, data);
      }
    } catch (e) {
      debugPrint("❌ Error checking stored data: $e");
    }
  }

  static Future<void> clearSharedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('shared_type');
      await prefs.remove('shared_data');
      debugPrint("🧹 Cleared stored share data");
    } catch (e) {
      debugPrint("❌ Error clearing data: $e");
    }
  }
}

// ===== main() =====
void main() async {
  BindingBase.debugZoneErrorsAreFatal = true;
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    ShareExtensionService.initialize();
    ShareReceiver.init();
    await initializeReferralTracking();

    if (kIsWeb) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    } else if (Platform.isAndroid) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    } else if (Platform.isIOS) {
      await Firebase.initializeApp(
          name: 'numuapp', options: DefaultFirebaseOptions.currentPlatform);
    }

    if (!kIsWeb && Platform.isIOS) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize("2c9a2265-f0a5-45a8-8f88-9faa90a04040");
      OneSignal.Notifications.requestPermission(true);

      oneSignalIdOriginal = await OneSignal.User.getOnesignalId();
      debugPrint("OneSignal ID: $oneSignalIdOriginal");

      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        debugPrint(
            'Foreground Notification: ${event.notification.jsonRepresentation()}');
      });

      OneSignal.Notifications.addClickListener((event) {
        final data = event.notification.additionalData;
        if (data == null) return;
        final type = data['notification_type'];
        final ctx = navigatorKey.currentContext;
        if (ctx == null) return;
        if (type == 'actionreminder') {
          Navigator.push(
              ctx,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => ReminderPushViewScreen(
                    reminderData: Map<String, dynamic>.from(data)),
                transitionDuration: Duration.zero,
              ));
        } else if (type == 'subscription') {
          final url = data['url'] as String?;
          if (url != null && url.isNotEmpty)
            _launchInAppWithBrowserOptions(Uri.parse(url));
        }
      });
    }

    if (!kIsWeb && Platform.isAndroid) {
      await PushNotifications.init();
      await PushNotifications.localNotiInit();
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

    if (!kIsWeb && Platform.isAndroid) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final payloadData = jsonEncode(message.data);
        final imageUrl = message.notification?.android?.imageUrl ??
            message.notification?.apple?.imageUrl ??
            message.data['image'];
        if (message.notification != null) {
          PushNotifications.showSimpleNotification(
            title: message.notification!.title ?? '',
            body: message.notification!.body ?? '',
            payload: payloadData,
            imageUrl: imageUrl,
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final data = message.data;
        final ctx = navigatorKey.currentContext;
        if (ctx == null) return;
        if (data['notification_type'] == 'actionreminder') {
          Navigator.push(
              ctx,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => ReminderPushViewScreen(
                    reminderData: Map<String, dynamic>.from(data)),
                transitionDuration: Duration.zero,
              ));
        } else if (data['notification_type'] == 'subscription') {
          final url = data['url'];
          if (url != null && (url as String).isNotEmpty) {
            _launchInAppWithBrowserOptions(Uri.parse(url));
          }
        }
      });

      final initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = navigatorKey.currentContext;
          if (ctx == null) return;
          final data = initialMessage.data;
          if (data['notification_type'] == 'actionreminder') {
            Navigator.push(
                ctx,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ReminderPushViewScreen(
                      reminderData: Map<String, dynamic>.from(data)),
                  transitionDuration: Duration.zero,
                ));
          } else if (data['notification_type'] == 'subscription') {
            final url = data['url'];
            if (url != null && (url as String).isNotEmpty) {
              _launchInAppWithBrowserOptions(Uri.parse(url));
            }
          }
        });
      }
    }

    FlutterError.onError = (details) =>
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    await Hive.initFlutter();
    Hive.registerAdapter(AlarmInfoAdapter());
    await Hive.openBox<AlarmInfo>('alarm');
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignInProvider()),
        ChangeNotifierProvider(create: (_) => SignUpProvider()),
        ChangeNotifierProvider(create: (_) => SubScribePlanProvider()),
        ChangeNotifierProvider(create: (_) => PhoneSignInProvider()),
        ChangeNotifierProvider(create: (_) => EditProfileProvider()),
        ChangeNotifierProvider(create: (_) => DashBoardProvider()),
        ChangeNotifierProvider(create: (_) => GoalsDreamsProvider()),
        ChangeNotifierProvider(create: (_) => JournalListProvider()),
        ChangeNotifierProvider(create: (_) => ConfirmPlanProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => DeleteProvider()),
        ChangeNotifierProvider(create: (_) => PrivacyPolicyProvider()),
        ChangeNotifierProvider(create: (_) => FeedBackProvider()),
        ChangeNotifierProvider(create: (_) => AdDreamsGoalsProvider()),
        ChangeNotifierProvider(create: (_) => AddActionsProvider()),
        ChangeNotifierProvider(create: (_) => MentalStrengthEditProvider()),
        ChangeNotifierProvider(create: (_) => MyActionProvider()),
      ],
      child: const MyApp(),
    ));
  } catch (e, st) {
    debugPrint("❌ Error during main initialization: $e");
    FirebaseCrashlytics.instance.recordError(e, st);
  }
}

// ===== Launch URL function =====
Future<void> _launchInAppWithBrowserOptions(Uri url) async {
  try {
    String urlToLaunch = url.toString();

    if (urlToLaunch.isEmpty) {
      debugPrint("❌ URL is empty");
      return;
    }

    if (YouTubeUrlHandler.isYouTubeUrl(urlToLaunch)) {
      final playableUrl = YouTubeUrlHandler.getPlayableYouTubeUrl(urlToLaunch);
      if (playableUrl != null) {
        urlToLaunch = playableUrl;
      }
      debugPrint("🎥 Launching YouTube: $urlToLaunch");
    }

    if (urlToLaunch.startsWith('mental://')) {
      debugPrint("⚠️ Custom deep link not implemented");
      return;
    }

    if (!urlToLaunch.startsWith('http://') &&
        !urlToLaunch.startsWith('https://')) {
      urlToLaunch = 'https://$urlToLaunch';
    }

    final uri = Uri.parse(urlToLaunch);

    final ok = await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView,
      browserConfiguration: const BrowserConfiguration(showTitle: true),
    );

    if (!ok) {
      debugPrint("⚠️ In-app browser failed, trying external browser");
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  } catch (e) {
    debugPrint("❌ Error launching URL: $e");
  }
}

// ===== MyApp =====
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  PermissionStatus permissionStatus = PermissionStatus.denied;

  late DatabaseReference ref;
  String? baseUrlLiveIos;
  String? baseUrlLiveAndroid;
  String? baseUrlLive;
  String? baseUrlQA;
  String? baseUrlAppShareDownloads;
  bool isBaseUrlReady = false;

  String? oneSignalLive;
  String? oneSignalStaging;

  SharedContent? _sharedContent;
  String _shareStatus = 'Waiting for shared content...';

  @override
  void initState() {
    super.initState();
    debugPrint('🎯 MyApp initState called');
    WidgetsBinding.instance.addObserver(this);

    _checkPermissionStatus();
    _requestPermissions();
    _setupNotificationTapHandler();
    _setupMethodChannelHandler();

    if (!kIsWeb && Platform.isIOS) {
      _setupShareExtensionHandler();
      Future.delayed(const Duration(milliseconds: 500), _checkForSharedContent);
    }

    if (!kIsWeb && Platform.isAndroid) {
      Future.delayed(const Duration(milliseconds: 500), () async {
        debugPrint('🔍 Checking for Android shared data on init');
        await ShareReceiver.checkAndNavigateOnResume();
      });
    }

    ref = FirebaseDatabase.instance.ref().child('mentalHealth');
    _observeDatabase();
    // Delay fetchAppRegister even more to let navigation complete first
    Future.delayed(const Duration(seconds: 10), _fetchAppRegister);

    ShareExtensionService.onSharedContent = (data) {
      debugPrint('📱 ShareExtensionService received content');
      _openShareScreen(data);
    };

    _checkOnResume();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('🔄 App resumed');
      _checkOnResume();

      // Only try pending navigation if we have pending data
      if (deepLinkHandler.hasPendingNavigation) {
        deepLinkHandler._attemptNavigation();
      }
    }

    if (!kIsWeb && Platform.isAndroid) {
      if (state == AppLifecycleState.resumed) {
        ShareReceiver.checkAndNavigateOnResume();
      }
    }
  }

  Future<void> _checkOnResume() async {
    if (!kIsWeb && Platform.isIOS) {
      if (await ShareExtensionService.checkForSharedContent()) {
        final data = await ShareExtensionService.getSharedData();
        if (data != null) _openShareScreen(data);
        await ShareExtensionService.clearSharedData();
      }
    }
  }

  void _openShareScreen(Map<String, dynamic> data) {
    try {
      debugPrint('📲 _openShareScreen called with data: $data');
      final images =
          (data['imagePaths'] as List?)?.map((e) => e.toString()).toList();

      var sharedUrl = data['url'] as String?;
      var sharedText = data['text'] as String? ?? data['sharedText'] as String?;

      if (sharedText != null && YouTubeUrlHandler.isYouTubeUrl(sharedText)) {
        sharedUrl = YouTubeUrlHandler.getPlayableYouTubeUrl(sharedText);
        sharedText = null;
        debugPrint("🎥 YouTube from text: $sharedUrl");
      }

      if (sharedUrl != null && YouTubeUrlHandler.isYouTubeUrl(sharedUrl)) {
        sharedUrl = YouTubeUrlHandler.getPlayableYouTubeUrl(sharedUrl);
        debugPrint("🎥 YouTube normalized: $sharedUrl");
      }

      debugPrint(
          '🚀 Calling deepLinkHandler.handleDeepLink from _openShareScreen');
      deepLinkHandler.handleDeepLink(
        url: sharedUrl,
        text: sharedText,
        images: images,
      );
    } catch (e) {
      debugPrint("❌ Error in _openShareScreen: $e\n${StackTrace.current}");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _observeDatabase() {
    ref.onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.value is Map) {
        final value = Map<String, dynamic>.from(snapshot.value as Map);

        // Don't trigger setState if we're navigating
        if (deepLinkHandler._isNavigating ||
            deepLinkHandler.hasPendingNavigation) {
          debugPrint('⏸️ Skipping setState during navigation');
          baseUrlLive = value['base_url_live'] as String?;
          baseUrlQA = value['base_url_qa'] as String?;
          oneSignalLive = value['onesignal_live'] as String?;
          oneSignalStaging = value['onesignal_qa'] as String?;
          baseUrlLiveIos = value['base_url_live_ios'] as String?;
          baseUrlLiveAndroid = value['base_url_live_android'] as String?;
          baseUrlAppShareDownloads = value['app_share_url'] as String?;
          _setupRemoteConfig();
          return;
        }

        setState(() {
          baseUrlLive = value['base_url_live'] as String?;
          baseUrlQA = value['base_url_qa'] as String?;
          oneSignalLive = value['onesignal_live'] as String?;
          oneSignalStaging = value['onesignal_qa'] as String?;
          baseUrlLiveIos = value['base_url_live_ios'] as String?;
          baseUrlLiveAndroid = value['base_url_live_android'] as String?;
          baseUrlAppShareDownloads = value['app_share_url'] as String?;
        });
        _setupRemoteConfig();
      } else {
        debugPrint('❌ Remote config snapshot invalid');
      }
    }, onError: (error) {
      _hideLoader();
      debugPrint('❌ Remote config error: $error');
    });
  }

  void _setupRemoteConfig() {
    final deviceType = Platform.isAndroid ? 'android' : 'ios';
    if (kDebugMode) {
      if ((baseUrlQA ?? '').isNotEmpty) {
        UrlConstant.baseUrl = baseUrlQA ?? '';
        UrlConstant.oneSignalRemote = oneSignalStaging ?? '';
        UrlConstant.appShareDownloads = baseUrlAppShareDownloads ?? '';
        isBaseUrlReady = true;
        debugPrint('✅ QA Base URL: $baseUrlQA');
      }
    } else if (kReleaseMode) {
      if ((baseUrlLive ?? '').isNotEmpty) {
        UrlConstant.baseUrl = baseUrlLive ?? '';
        UrlConstant.oneSignalRemote = oneSignalStaging ?? '';
        UrlConstant.appShareDownloads = baseUrlAppShareDownloads ?? '';
        isBaseUrlReady = true;
        debugPrint('✅ Live Base URL ($deviceType): $baseUrlLive');
      }
    } else {
      debugPrint('📱 Profile mode');
    }
  }

  void _hideLoader() => debugPrint('Loader hidden');

  Future<void> _checkPermissionStatus() async {
    final status = await Permission.locationWhenInUse.status;
    setState(() => permissionStatus = status);
  }

  Future<void> _fetchAppRegister() async {
    // Don't fetch if we're navigating
    if (deepLinkHandler._isNavigating || deepLinkHandler.hasPendingNavigation) {
      debugPrint(
          '⏸️ Skipping fetchAppRegister during navigation, will retry later');
      Future.delayed(const Duration(seconds: 3), _fetchAppRegister);
      return;
    }

    final deviceType = Platform.isAndroid ? 'android' : 'ios';
    final signInProvider = Provider.of<SignInProvider>(context, listen: false);
    await signInProvider.fetchAppRegister(context, deviceType: deviceType);
  }

  Future<void> _requestPermissions() async {
    if (!kIsWeb && Platform.isAndroid) {
      await Permission.notification.request();
    }
    final locationStatus = await Permission.locationWhenInUse.status;
    setState(() => permissionStatus = locationStatus);
  }

  void _setupNotificationTapHandler() {
    if (!kIsWeb && Platform.isAndroid) {
      const androidInitSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final initSettings = InitializationSettings(android: androidInitSettings);

      flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          if (payload == null) return;
          try {
            final data = jsonDecode(payload) as Map<String, dynamic>;
            if (data['notification_type'] == 'actionreminder') {
              final ctx = navigatorKey.currentContext;
              if (ctx == null) return;
              Navigator.push(
                ctx,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => ReminderPushViewScreen(
                      reminderData: Map<String, dynamic>.from(data)),
                  transitionDuration: Duration.zero,
                ),
              );
            } else {
              final url = data['url'] as String?;
              if (url != null && url.isNotEmpty) {
                _launchInAppWithBrowserOptions(Uri.parse(url));
              }
            }
          } catch (e) {
            debugPrint('❌ Error decoding payload: $e');
          }
        },
      );
    } else {
      debugPrint('⏭️ Skipping flutter_local_notifications on non-Android');
    }
  }

  void _setupMethodChannelHandler() {
    if (kIsWeb) return;
    platform.setMethodCallHandler((call) async {
      if (call.method == 'showSharePost') {
        _navigateToSharePostPage();
      }
      return null;
    });
  }

  void _setupShareExtensionHandler() {
    ShareExtensionService.onSharedContent = (data) {
      setState(() {
        _sharedContent = ShareExtensionService.parseSharedData(data);
        _shareStatus = (_sharedContent?.hasContent ?? false)
            ? '✅ Received shared content'
            : '⚠️ No content in shared data';
      });
      if (_sharedContent?.hasContent ?? false) {
        _handleSharedContent();
      }
    };
    ShareExtensionService.onNoSharedContent = () {
      setState(() => _shareStatus = 'ℹ️ No shared content available');
    };
  }

  Future<void> _checkForSharedContent() async {
    if (kIsWeb || !Platform.isIOS) return;
    final hasData = await ShareExtensionService.checkForSharedContent();
    if (!hasData) {
      setState(() => _shareStatus = 'ℹ️ No shared content found');
      return;
    }
    final result = await ShareExtensionService.getSharedDataWithStatus();
    if (result.isSuccess && result.data != null) {
      setState(() {
        _sharedContent = ShareExtensionService.parseSharedData(result.data!);
        _shareStatus = '✅ ${result.message}';
      });
      if (_sharedContent?.hasContent ?? false) {
        _handleSharedContent();
      }
    } else {
      setState(() => _shareStatus = '❌ ${result.message}');
    }
  }

  void _handleSharedContent() {
    if (_sharedContent == null || !_sharedContent!.hasContent) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToSharePostPageWithData();
    });
  }

  void _navigateToSharePostPage() {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) {
      debugPrint('[ShareNav] ⚠️ Context is null');
      return;
    }
    Navigator.of(ctx).push(MaterialPageRoute(builder: (context) {
      return SharePostView(onClose: () => Navigator.of(context).pop());
    }));
  }

  void _navigateToSharePostPageWithData() {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) {
      debugPrint('[ShareNav] ⚠️ Context is null');
      return;
    }

    var sharedUrl = _sharedContent?.url;
    var sharedText = _sharedContent?.sharedText ?? _sharedContent?.text;

    if (sharedText != null && YouTubeUrlHandler.isYouTubeUrl(sharedText)) {
      sharedUrl = YouTubeUrlHandler.getPlayableYouTubeUrl(sharedText);
      sharedText = null;
      debugPrint("🎥 YouTube from text: $sharedUrl");
    }

    if (sharedUrl != null && YouTubeUrlHandler.isYouTubeUrl(sharedUrl)) {
      sharedUrl = YouTubeUrlHandler.getPlayableYouTubeUrl(sharedUrl);
      debugPrint("🎥 YouTube normalized: $sharedUrl");
    }

    Navigator.of(ctx).push(MaterialPageRoute(builder: (context) {
      return SharePostView(
        onClose: () async {
          await ShareExtensionService.clearSharedData();
          setState(() {
            _sharedContent = null;
            _shareStatus = '🧹 Cleared shared content';
          });
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        },
        sharedUrl: sharedUrl,
        sharedText: sharedText,
        sharedImages: _sharedContent?.imagePaths,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: isBaseUrlReady
          ? const SplashScreen()
          : Scaffold(
              body: Center(
                child: CupertinoActivityIndicator(
                  color: ColorsContent.newThemeColor,
                  radius: 15,
                ),
              ),
            ),
    );
  }
}

// ============================================================
// ShareExtensionService - iOS Share Extension Handler
// ============================================================
class ShareExtensionService {
  static const MethodChannel platform = MethodChannel('numuapp.share');

  static Function(Map<String, dynamic>)? onSharedContent;
  static Function()? onNoSharedContent;

  static void initialize() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onSharedContent') {
        final result = await getSharedDataWithStatus();
        if (result.isSuccess && result.data != null) {
          onSharedContent?.call(result.data!);
        } else {
          onNoSharedContent?.call();
        }
      }
      return null;
    });
  }

  static Future<Map<String, dynamic>?> getSharedData() async {
    final r = await getSharedDataWithStatus();
    return r.data;
  }

  static Future<SharedDataResult> getSharedDataWithStatus() async {
    try {
      final result = await platform.invokeMethod('getSharedData');
      if (result == null) {
        return SharedDataResult(
          hasData: false,
          data: null,
          message: 'No shared content found',
        );
      }
      final map = Map<String, dynamic>.from(result as Map);
      return SharedDataResult(
        hasData: true,
        data: map,
        message: 'Shared content loaded successfully',
      );
    } on PlatformException catch (e) {
      return SharedDataResult(
        hasData: false,
        data: null,
        message: 'Platform error: ${e.message}',
        error: e,
      );
    } catch (e) {
      return SharedDataResult(
        hasData: false,
        data: null,
        message: 'Unknown error occurred',
        error: e,
      );
    }
  }

  static Future<bool> clearSharedData() async {
    try {
      final result = await platform.invokeMethod('clearSharedData');
      return result == true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> checkForSharedContent() async {
    try {
      bool? has = await platform.invokeMethod('checkForSharedContent');
      has ??= await platform.invokeMethod('hasSharedData');
      return has ?? false;
    } catch (_) {
      return false;
    }
  }

  static SharedContent parseSharedData(Map<String, dynamic> data) {
    final List<String> images = (() {
      final raw = data['imagePaths'] ?? data['images'];
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return <String>[];
    })();

    final String? text = data['text'] as String?;
    final String? sharedText = (data['sharedText'] as String?) ?? text;
    var url = data['url'] as String?;

    if (url != null && YouTubeUrlHandler.isYouTubeUrl(url)) {
      url = YouTubeUrlHandler.getPlayableYouTubeUrl(url);
      debugPrint("🎥 YouTube URL processed: $url");
    }

    final bool hasContent = ((text ?? '').isNotEmpty) ||
        ((sharedText ?? '').isNotEmpty) ||
        ((url ?? '').isNotEmpty) ||
        images.isNotEmpty;

    return SharedContent(
      text: text,
      sharedText: sharedText,
      url: url,
      imagePaths: images,
      hasContent: hasContent,
    );
  }
}

// ============================================================
// SharedContent Model
// ============================================================
class SharedContent {
  final String? text;
  final String? sharedText;
  final String? url;
  final List<String> imagePaths;
  final bool hasContent;

  SharedContent({
    this.text,
    this.sharedText,
    this.url,
    required this.imagePaths,
    required this.hasContent,
  });

  @override
  String toString() =>
      'SharedContent(text: $text, sharedText: $sharedText, url: $url, images: ${imagePaths.length}, has: $hasContent)';
}

// ============================================================
// SharedDataResult Model
// ============================================================
class SharedDataResult {
  final bool hasData;
  final Map<String, dynamic>? data;
  final String message;
  final Object? error;

  const SharedDataResult({
    required this.hasData,
    required this.data,
    required this.message,
    this.error,
  });

  bool get isSuccess => hasData && error == null;
}

// ============================================================
// Legacy ShareHandler for Android
// ============================================================
class ShareHandler {
  static const _channel = MethodChannel('numuapp.share');

  static Future<Map<String, dynamic>?> getSharedData() async {
    try {
      final jsonString = await _channel.invokeMethod<String>('getSharedData');
      if (jsonString == null) return null;
      return jsonDecode(jsonString);
    } catch (e) {
      debugPrint('❌ Error reading shared data: $e');
      return null;
    }
  }
}
