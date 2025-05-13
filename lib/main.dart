import 'dart:async'; // Import this for runZonedGuarded
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // Import for Crashlytics
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mentalhelth/firebase_options.dart';
import 'package:mentalhelth/screens/addactions_screen/model/alaram_info.dart';
import 'package:mentalhelth/screens/auth/signup_screen/provider/signup_provider.dart';
import 'package:mentalhelth/screens/auth/splash/splash.dart';
import 'package:mentalhelth/screens/auth/subscribe_plan_page/provider/subscribe_plan_provider.dart';
import 'package:mentalhelth/screens/dash_borad_screen/provider/dash_board_provider.dart';
import 'package:mentalhelth/screens/edit_add_profile_screen/provider/edit_provider.dart';
import 'package:mentalhelth/screens/goals_dreams_page/provider/goals_dreams_provider.dart';
import 'package:mentalhelth/screens/journal_list_screen/provider/journal_list_provider.dart';
import 'package:mentalhelth/screens/mental_strength_add_edit_screen/provider/mental_strenght_edit_provider.dart';
import 'package:mentalhelth/screens/no_internet/duplicate_screen.dart';
import 'package:mentalhelth/screens/reminder_push_view_screen/reminder_push_view_screen.dart';
import 'package:mentalhelth/utils/core/constants.dart';
import 'package:mentalhelth/utils/core/firebase_api.dart';
import 'package:mentalhelth/utils/core/local_notification.dart';
import 'package:mentalhelth/utils/core/url_constant.dart';
import 'package:mentalhelth/utils/theme/colors.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
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
import 'package:onesignal_flutter/onesignal_flutter.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Some notification Received in background...");
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Set this before initializing bindings
  BindingBase.debugZoneErrorsAreFatal = true;

  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    if(Platform.isAndroid){
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }else if(Platform.isIOS){
      await Firebase.initializeApp(
        name: 'mentalhealth',
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else if (kIsWeb) { // Check for web platform
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    if(Platform.isIOS){
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      OneSignal.initialize("efe6e3e8-86a4-4d67-851b-ce8151850bc1");
      // OneSignal.Notifications.addClickListener((event) {
      //   print("object");
      //   // Handle notification click
      // });

  final oneSignalId = await OneSignal.User.getOnesignalId();
      print("oneSignalId--${oneSignalId}");
  if(oneSignalId!= null){
    oneSignalIdOriginal = oneSignalId;
    print("oneSignalId--${oneSignalId}");
  }
      print("oneSignalId--${oneSignalId}");

// The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
      OneSignal.Notifications.requestPermission(true);

      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        print('Foreground Notification Received: ${event.notification.jsonRepresentation()}');
      });

      OneSignal.Notifications.addClickListener((event) {
        print('Notification Clicked: ${event.notification.jsonRepresentation()}');

        final data = event.notification.additionalData;

        if (data == null) {
          print('No additional data found in notification');
          return;
        }

        final notificationType = data['notification_type'];
        final context = navigatorKey.currentContext;

        if (context == null) {
          print('Navigator context is null');
          return;
        }

        if (notificationType == 'actionreminder') {
          final reminderData = Map<String, dynamic>.from(data);

          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  ReminderPushViewScreen(reminderData: reminderData),
              transitionDuration: const Duration(seconds: 0),
            ),
          );
        } else if (notificationType == 'subscription') {
          final urlString = data['url'];
          if (urlString != null && urlString.isNotEmpty) {
            _launchInAppWithBrowserOptions(Uri.parse(urlString));
          } else {
            print('URL is missing in subscription notification');
          }
        } else {
          print('Unhandled notification type: $notificationType');
        }
      });




      OneSignal.Notifications.addPermissionObserver((event) {
        print('Notification Permission Changed: ${event.toString()}');
      });
    }
    else if(Platform.isAndroid){
      await PushNotifications.init();
      //await PushNotifications().initNotification();
      // initialize local notifications
      // dont use local notifications for web platform
      if (!kIsWeb) {
        await PushNotifications.localNotiInit();
      }
    }

    // Listen to background notifications
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

    // --- Android FCM notification tap handling ---
    if (Platform.isAndroid) {
      // to handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        String payloadData = jsonEncode(message.data);
        print("Got a message in foreground");
        print("payloadData$payloadData");

        String? imageUrl = message.notification?.android?.imageUrl ??
            message.notification?.apple?.imageUrl ??
            message.data['image'];

        print("imageUrl--$imageUrl");

        if (message.notification != null) {
          PushNotifications.showSimpleNotification(
            title: message.notification!.title ?? "",
            body: message.notification!.body ?? "",
            payload: payloadData, // <- used for click handling
            imageUrl: imageUrl,
          );
        }
      });


      // Background or resumed (user taps on the notification)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("Notification tapped (background/resumed): ${message.data}");
        final data = message.data;
        print("dataasdfgb$data");

        if (data['notification_type'] == 'actionreminder') {
          final context = navigatorKey.currentContext;

          if (context != null) {
            final reminderData = Map<String, dynamic>.from(data);

            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) =>
                    ReminderPushViewScreen(reminderData: reminderData),
                transitionDuration: const Duration(seconds: 0),
              ),
            );
          } else {
            print('Navigator context is null');
          }
        }
        else if (data['notification_type'] == 'subscription') {
          final urlString = data['url'];
          if (urlString != null && urlString.isNotEmpty) {
            final context = navigatorKey.currentContext;
            if (context != null) {
              _launchInAppWithBrowserOptions(Uri.parse(urlString));
            } else {
              print('Navigator context is null for subscription');
            }
          } else {
            print('URL is missing in subscription notification');
          }
        }
      });


      // Terminated state
      // Terminated state
      final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        print("Notification tapped (terminated): ${initialMessage.data}");
        final data = initialMessage.data;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = navigatorKey.currentContext;

          if (data['notification_type'] == 'actionreminder') {
            if (context != null) {
              final reminderData = Map<String, dynamic>.from(data);

              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                      ReminderPushViewScreen(reminderData: reminderData),
                  transitionDuration: const Duration(seconds: 0),
                ),
              );
            } else {
              print('Navigator context is null for actionreminder');
            }
          } else if (data['notification_type'] == 'subscription') {
            final urlString = data['url'];
            if (urlString != null && urlString.isNotEmpty) {
              if (context != null) {
                _launchInAppWithBrowserOptions(Uri.parse(urlString));
              } else {
                print('Navigator context is null for subscription');
              }
            } else {
              print('URL is missing in subscription notification');
            }
          }
        });
      }

    }


    // ///for handling in terminated state
    // final RemoteMessage? message =
    // await FirebaseMessaging.instance.getInitialMessage();
    // if (message != null) {
    //   String payloadData = jsonEncode(message.data);
    //   print('Got a Message in Foreground');
    //   if (message.notification != null) {
    //     PushNotifications.showSimpleNotification(
    //         title: message.notification!.title ?? "",
    //         body: message.notification!.body ?? "",
    //         payload: payloadData);
    //   }
    //   print('Launched from terminated state');
    //   Future.delayed(Duration(seconds: 1), () {
    //     ///if to navigate to another screen
    //   });
    // }

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      print("Error during initialization: $error");
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    // Initialize Hive
    await Hive.initFlutter();
    Hive.registerAdapter(AlarmInfoAdapter());
    await Hive.openBox<AlarmInfo>("alarm");

    // // Set up Crashlytics
    FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    debugPrint("Firebase and Crashlytics initialized successfully");

    runApp(
      MultiProvider(
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
      ),
    );
  } catch (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}

Future<void> _launchInAppWithBrowserOptions(Uri url) async {
  // Check if the URL is a deep link
  if (url.scheme == "mental") {
    // Handle the deep link (navigate to a specific screen in your app)
    // For example, navigate to a MentalScreen page
    //Navigator.pushNamed(context, '/mentalScreen', arguments: url);
  } else {
    // If it's a regular URL, open it in an in-app browser
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppBrowserView,
      browserConfiguration: const BrowserConfiguration(showTitle: true),
    )) {
      throw Exception('Could not launch $url');
    }
  }
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PermissionStatus permissionStatus = PermissionStatus.denied;

  late DatabaseReference ref;
  String? baseUrlLive;
  String? baseUrlQA;
  bool isBaseUrlReady = false;


  Future<void> _launchInAppWithBrowserOptions(Uri url) async {
    // Check if the URL is a deep link
    if (url.scheme == "mental") {
      // Handle the deep link (navigate to a specific screen in your app)
      // For example, navigate to a MentalScreen page
      Navigator.pushNamed(context, '/mentalScreen', arguments: url);
    } else {
      // If it's a regular URL, open it in an in-app browser
      if (!await launchUrl(
        url,
        mode: LaunchMode.inAppBrowserView,
        browserConfiguration: const BrowserConfiguration(showTitle: true),
      )) {
        throw Exception('Could not launch $url');
      }
    }
  }

  void setupNotificationTapHandler() {
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );

    flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        print("payload$payload");
        if (payload != null) {
          final data = jsonDecode(payload);

          if (data['notification_type'] == 'actionreminder') {
            final context = navigatorKey.currentContext;

            if (context != null) {
              final reminderData = Map<String, dynamic>.from(data);

              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                      ReminderPushViewScreen(reminderData: reminderData),
                  transitionDuration: const Duration(seconds: 0),
                ),
              );
            }
          } else {
            if (payload != null) {
              try {
                final Map<String, dynamic> data = jsonDecode(payload);
                final String? url = data['url'];
                if (url != null && url.isNotEmpty) {
                  _launchInAppWithBrowserOptions(Uri.parse(url));
                } else {
                  print("URL is missing in payload.");
                }
              } catch (e) {
                print("Error decoding payload: $e");
              }
            }
          }
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
    _requestPermissions();
    setupNotificationTapHandler();
    ref = FirebaseDatabase.instance.ref().child("mentalHealth");
    observeDatabase();
    // Delay the fetchAppRegister call by 2 seconds
    Future.delayed(Duration(seconds: 5), () {
      fetchAppRegister();
    });
  }

  void observeDatabase() {
    ref.onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.value is Map) {
        final value = Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          baseUrlLive = value["base_url_live"] as String?;
          baseUrlQA = value["base_url_qa"] as String?;
        });

        setupRemoteConfig();
      } else {
        print("Error: Snapshot does not contain valid data");
      }
    }, onError: (error) {
      hideLoader();
      print("${error.toString()} ====> remote config feature me database observing error");
    });
  }


  void setupRemoteConfig() {

    if (kDebugMode) {
      if(baseUrlQA!.isNotEmpty){
        UrlConstant.baseUrl = baseUrlQA ?? "";
        isBaseUrlReady = true;
        print("QA Base URL set to1: $baseUrlQA");
      }
      print("App is running in Debug mode.");
      // Debug-specific code here
    } else if (kReleaseMode) {
      if(baseUrlLive!.isNotEmpty){
        UrlConstant.baseUrl = baseUrlLive ?? "";
        isBaseUrlReady = true;
        print("Live Base URL set to1: $baseUrlLive");
      }

      print("App is running in Release mode.");
      // Production-specific code here
    } else {
      print("App is running in Profile mode.");
      // Profile-specific code here
    }
    // Your remote config setup logic here
    print("Live Base URL set to: $baseUrlLive");
    print("QA Base URL set to: $baseUrlQA");
  }

  void hideLoader() {
    // Logic to hide loader
    print("Loader hidden");
  }
  Future<void> _checkPermissionStatus() async {
    // Check location permission status
    final status = await Permission.locationWhenInUse.status;
    setState(() {
      permissionStatus = status;
    });
  }
  Future<void> fetchAppRegister() async {
    String deviceType = Platform.isAndroid ? 'android' : 'ios';
    //isLoading = true;
    final signInProvider = Provider.of<SignInProvider>(context, listen: false);

    await signInProvider.fetchAppRegister(context, deviceType: deviceType);

  }

  Future<void> _requestPermissions() async {
    // Request location permission (Platform specific)
    if (Platform.isIOS) {

    } else if (Platform.isAndroid) {

      await Permission.notification.request();

    }

    // Check updated location permission status
    final locationStatus = await Permission.locationWhenInUse.status;
    setState(() {
      permissionStatus = locationStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      navigatorKey: navigatorKey, // <-- Add this line
      debugShowCheckedModeBanner: false,
      home: isBaseUrlReady
          ? const SplashScreen() // Navigate to SplashScreen if baseUrl is ready
          :  Scaffold(
                  body: Center(
          child: CupertinoActivityIndicator(
            color: ColorsContent.newThemeColor,
            radius: 15,
          )// Show a loader while waiting
                  ),
                ),
    );
  }
}
