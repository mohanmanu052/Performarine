import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/analytics/start_trip.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/intro_screen.dart';
import 'package:performarine/pages/trip_analytics.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;

SharedPreferences? sharedPreferences;
bool? isStart;
Timer? timer;
Timer? tripDurationTimer;
Directory? ourDirectory;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();
StreamSubscription<Position>? positionStream;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeService();

  tz.initializeTimeZones();

  SharedPreferences.getInstance().then((value) {
    sharedPreferences = value;
    runApp(Phoenix(child: MyApp()));
  });
}

const notificationChannelId = 'my_foreground';

@pragma('vm:entry-point')
onDidReceiveBackgroundNotificationResponse(
    NotificationResponse response) async {
  DartPluginRegistrant.ensureInitialized();
  var pref = await SharedPreferences.getInstance();
  pref.setBool('sp_key_called_from_noti', true);
  Utils.customPrint('APP RESTART 2');

  /// APP RESTART
}

@pragma('vm:entry-point')
Future<bool> onStart(ServiceInstance serviceInstance) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  StartTrip().startTrip(serviceInstance);

  return true;
}

onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) {
  Utils.customPrint('APP RESTART 3');

  /// APP RESTART
}

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;
Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  isStart = false;

  final appDirectory = await getApplicationDocumentsDirectory();
  ourDirectory = Directory('${appDirectory.path}');

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'MY FOREGROUND SERVICE',
    description: 'This channel is used for important notifications.',
    importance: Importance.low, // importance must be at low or higher level
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(sound: true, alert: true, badge: true);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('noti_logo');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin);

  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (value) async {
    Utils.customPrint('APP RESTART 1');

    if (value.id == 888) {
      Utils.customPrint('NOTIFICATION ID: ${value.id}');
      var pref = await SharedPreferences.getInstance();
      pref.setBool('sp_key_called_from_noti', true);
      List<String>? tripData = pref.getStringList('trip_data');
      bool? isTripStarted = pref.getBool('trip_started');

      Get.to(TripAnalyticsScreen(
          tripId: tripData![0],
          vesselId: tripData[1],
          tripIsRunningOrNot: isTripStarted));
    }
    return;

    await Get.deleteAll(force: true);
    Phoenix.rebirth(Get.context!);
    Get.reset();

    /// APP RESTART
  },
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      initialNotificationTitle: 'PerforMarine',
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationContent: 'PerforMarine consuming background services.',
      /*'Trip Data Collection in progress...',*/
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(
        autoStart: true, onForeground: onStart, onBackground: onStart),
  );
  service.startService();
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Utils.customPrint('APP IN BG INIT');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // positionStream!.cancle
    super.dispose();
    Utils.customPrint('APP IN BG DISPOSE');
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CommonProvider()),
      ],
      child: GetMaterialApp(
        title: 'PerforMarine',
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        getPages: [
          GetPage(name: '/', page: () => IntroScreen()),
          GetPage(name: '/HomePage', page: () => HomePage()),
        ],
      ),
    );
  }
}
