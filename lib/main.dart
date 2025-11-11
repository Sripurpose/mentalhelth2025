// ==============================
// main.dart (CLEAN + FIXED)
// ==============================
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
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
import 'package:mentalhelth/screens/addgoals_dreams_screen/add_goals_link_screen.dart';
import 'package:mentalhelth/screens/addgoals_dreams_screen/addgoals_dreams_screen.dart';
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
import 'package:mentalhelth/utils/core/constants.dart';
import 'package:mentalhelth/utils/core/firebase_api.dart';
import 'package:mentalhelth/utils/core/local_notification.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

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
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
const platform = MethodChannel('com.numuapp.numuapp/native');
String? oneSignalIdOriginal;

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

// ===== main() =====
void main() async {
  BindingBase.debugZoneErrorsAreFatal = true;
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Share extension callbacks MUST be set early on iOS
    ShareExtensionService.initialize(); // set up callback



    await initializeReferralTracking();

    if (kIsWeb) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } else if (Platform.isAndroid) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } else if (Platform.isIOS) {
      await Firebase.initializeApp(name: 'numuapp', options: DefaultFirebaseOptions.currentPlatform);
    }

    // OneSignal setup (iOS)
    if (!kIsWeb && Platform.isIOS) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize("2c9a2265-f0a5-45a8-8f88-9faa90a04040");
      OneSignal.Notifications.requestPermission(true);

      oneSignalIdOriginal = await OneSignal.User.getOnesignalId();
      debugPrint("OneSignal ID: $oneSignalIdOriginal");

      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        debugPrint('Foreground Notification: ${event.notification.jsonRepresentation()}');
      });

      OneSignal.Notifications.addClickListener((event) {
        final data = event.notification.additionalData;
        if (data == null) return;
        final type = data['notification_type'];
        final ctx = navigatorKey.currentContext;
        if (ctx == null) return;
        if (type == 'actionreminder') {
          Navigator.push(ctx, PageRouteBuilder(pageBuilder: (_, __, ___) =>
              ReminderPushViewScreen(reminderData: Map<String, dynamic>.from(data)), transitionDuration: Duration.zero));
        } else if (type == 'subscription') {
          final url = data['url'] as String?;
          if (url != null && url.isNotEmpty) _launchInAppWithBrowserOptions(Uri.parse(url));
        }
      });
    }

    // Push (Android)
    if (!kIsWeb && Platform.isAndroid) {
      await PushNotifications.init();
      await PushNotifications.localNotiInit();
    }

    // FCM listeners
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

    if (!kIsWeb && Platform.isAndroid) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final payloadData = jsonEncode(message.data);
        final imageUrl = message.notification?.android?.imageUrl ??
            message.notification?.apple?.imageUrl ?? message.data['image'];
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
          Navigator.push(ctx, PageRouteBuilder(pageBuilder: (_, __, ___) =>
              ReminderPushViewScreen(reminderData: Map<String, dynamic>.from(data)), transitionDuration: Duration.zero));
        } else if (data['notification_type'] == 'subscription') {
          final url = data['url'];
          if (url != null && (url as String).isNotEmpty) {
            _launchInAppWithBrowserOptions(Uri.parse(url));
          }
        }
      });

      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = navigatorKey.currentContext;
          if (ctx == null) return;
          final data = initialMessage.data;
          if (data['notification_type'] == 'actionreminder') {
            Navigator.push(ctx, PageRouteBuilder(pageBuilder: (_, __, ___) =>
                ReminderPushViewScreen(reminderData: Map<String, dynamic>.from(data)), transitionDuration: Duration.zero));
          } else if (data['notification_type'] == 'subscription') {
            final url = data['url'];
            if (url != null && (url as String).isNotEmpty) {
              _launchInAppWithBrowserOptions(Uri.parse(url));
            }
          }
        });
      }
    }

    // Crashlytics
    FlutterError.onError = (details) => FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Hive
    await Hive.initFlutter();
    Hive.registerAdapter(AlarmInfoAdapter());
    await Hive.openBox<AlarmInfo>('alarm');
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);

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
    debugPrint("Uncaught error during main initialization: $e");
    FirebaseCrashlytics.instance.recordError(e, st);
  }
}

Future<void> _launchInAppWithBrowserOptions(Uri url) async {
  if (url.scheme == 'mental') {
    // TODO: handle custom deep link
    return;
  }
  final ok = await launchUrl(
    url,
    mode: LaunchMode.inAppBrowserView,
    browserConfiguration: const BrowserConfiguration(showTitle: true),
  );
  if (!ok) throw Exception('Could not launch $url');
}

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

  // iOS share state
  SharedContent? _sharedContent;
  String _shareStatus = 'Waiting for shared content...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _checkPermissionStatus();
    _requestPermissions();
    _setupNotificationTapHandler();
    _setupMethodChannelHandler();

    if (!kIsWeb && Platform.isIOS) {
      _setupShareExtensionHandler();
      Future.delayed(const Duration(milliseconds: 500), _checkForSharedContent);
    }

    ref = FirebaseDatabase.instance.ref().child('mentalHealth');
    _observeDatabase();
    Future.delayed(const Duration(seconds: 5), _fetchAppRegister);


    // When native tells us about new content:
    ShareExtensionService.onSharedContent = (data) {
      _openShareScreen(data);
    };

    // Also poll on resume:
    _checkOnResume();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkOnResume();
    }
  }

  Future<void> _checkOnResume() async {
    if (await ShareExtensionService.checkForSharedContent()) {
      final data = await ShareExtensionService.getSharedData();
      if (data != null) _openShareScreen(data);
      await ShareExtensionService.clearSharedData();
    }
  }
  void _openShareScreen(Map<String, dynamic> data) {
    final images = (data['imagePaths'] as List?)?.map((e) => e.toString()).toList();
    Navigator.of(navigatorKey.currentContext!).push(
      // MaterialPageRoute(
      //   builder: (_) => SharePostView(
      //     sharedUrl: data['url'] as String?,
      //     sharedText: data['text'] as String?, // or data['sharedText']
      //     sharedImages: images,
      //     onClose: () => Navigator.of(navigatorKey.currentContext!).pop(),
      //   ),
      // ),

      MaterialPageRoute(
        builder: (_) => AddGoalsLinkScreen(
          sharedUrl: data['url'] as String?,
          sharedText: data['text'] as String?, // or data['sharedText']
          sharedImages: images,
          onClose: () => Navigator.of(navigatorKey.currentContext!).pop(),
        ),
      ),
    );
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
        debugPrint('Remote config snapshot invalid');
      }
    }, onError: (error) {
      _hideLoader();
      debugPrint('Remote config observing error: $error');
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
        debugPrint('QA Base URL: $baseUrlQA');
      }
    } else if (kReleaseMode) {
      if ((baseUrlLive ?? '').isNotEmpty) {
        UrlConstant.baseUrl = baseUrlLive ?? '';
        UrlConstant.oneSignalRemote = oneSignalLive ?? '';
        UrlConstant.appShareDownloads = baseUrlAppShareDownloads ?? '';
        isBaseUrlReady = true;
        debugPrint('Live Base URL (${deviceType == 'ios' ? 'iOS' : 'Android'}): $baseUrlLive');
      }
    } else {
      debugPrint('Profile mode');
    }
  }

  void _hideLoader() => debugPrint('Loader hidden');

  Future<void> _checkPermissionStatus() async {
    final status = await Permission.locationWhenInUse.status;
    setState(() => permissionStatus = status);
  }

  Future<void> _fetchAppRegister() async {
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
      const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
                  pageBuilder: (_, __, ___) => ReminderPushViewScreen(reminderData: Map<String, dynamic>.from(data)),
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
            debugPrint('Error decoding payload: $e');
          }
        },
      );
    } else {
      debugPrint('Skipping flutter_local_notifications on non-Android');
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

  // ===== Share Extension (iOS) =====
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
      debugPrint('[ShareNav] Context is null');
      return;
    }
    Navigator.of(ctx).push(MaterialPageRoute(builder: (context) {
      return SharePostView(onClose: () => Navigator.of(context).pop());
    }));
  }

  void _navigateToSharePostPageWithData() {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) {
      debugPrint('[ShareNav] Context is null');
      return;
    }
    Navigator.of(ctx).push(MaterialPageRoute(builder: (context) {
      return SharePostView(
        onClose: () async {
          await ShareExtensionService.clearSharedData();
          setState(() {
            _sharedContent = null;
            _shareStatus = 'Cleared shared content';
          });
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        },
        sharedUrl: _sharedContent?.url,
        sharedText: _sharedContent?.sharedText ?? _sharedContent?.text,
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

// ==============================
// Legacy ShareHandler – kept for Android native shares
// ==============================
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

// ShareExtensionService.dart — drop-in replacement
// Channel name matches your AppDelegate: "numuapp.share"



class ShareExtensionService {
  static const MethodChannel platform = MethodChannel('numuapp.share');

  /// Called when native iOS notifies that new shared content is available.
  static Function(Map<String, dynamic>)? onSharedContent;

  /// Optional: called when native notifies but no content is available.
  static Function()? onNoSharedContent;

  /// Wire up native -> Dart callbacks. Call this early in main() before runApp().
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

  /// Old helper kept for compatibility.
  static Future<Map<String, dynamic>?> getSharedData() async {
    final r = await getSharedDataWithStatus();
    return r.data;
  }

  /// NEW: returns structured status + payload, with friendly messages.
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

  /// Clears the stored shared payload in the App Group.
  static Future<bool> clearSharedData() async {
    try {
      final result = await platform.invokeMethod('clearSharedData');
      return result == true;
    } catch (_) {
      return false;
    }
  }

  /// Ask native if there is new content (alias to hasSharedData/checkForSharedContent).
  static Future<bool> checkForSharedContent() async {
    try {
      // Prefer explicit method; fallback to hasSharedData if not implemented
      bool? has = await platform.invokeMethod('checkForSharedContent');
      has ??= await platform.invokeMethod('hasSharedData');
      return has ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Parse the native payload into a typed model convenient for UI.
  static SharedContent parseSharedData(Map<String, dynamic> data) {
    // Accept either 'imagePaths' (preferred) or 'images'
    final List<String> images = (() {
      final raw = data['imagePaths'] ?? data['images'];
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return <String>[];
    })();

    final String? text = data['text'] as String?;
    final String? sharedText = (data['sharedText'] as String?) ?? text;
    final String? url = data['url'] as String?;

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

/// Lightweight model used by UI widgets (e.g., SharePostView)
class SharedContent {
  final String? text;        // comment/caption
  final String? sharedText;  // additional text from host app
  final String? url;         // shared URL
  final List<String> imagePaths; // local image file paths
  final bool hasContent;

  SharedContent({
    this.text,
    this.sharedText,
    this.url,
    required this.imagePaths,
    required this.hasContent,
  });

  @override
  String toString() => 'SharedContent(text: $text, sharedText: $sharedText, url: $url, images: ${imagePaths.length}, has: $hasContent)';
}

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



