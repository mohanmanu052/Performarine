import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/pages/authentication/reset_password.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/intro_screen.dart';
import 'package:performarine/pages/trip_analytics.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:uni_links/uni_links.dart';

SharedPreferences? sharedPreferences;
bool? isStart;
Timer? timer;
Timer? tripDurationTimer;
Directory? ourDirectory;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configEasyLoading();

  initializeService();

  tz.initializeTimeZones();

  SharedPreferences.getInstance().then((value) {
    sharedPreferences = value;
    runApp(Phoenix(child: MyApp()));
  });
}

configEasyLoading() {
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.threeBounce
    ..indicatorSize = 20.0
    ..loadingStyle = EasyLoadingStyle.custom
    ..backgroundColor = Colors.white
    ..indicatorColor = Colors.black
    ..textColor = Colors.black
    ..maskColor = Colors.blue.withOpacity(1)
    ..radius = 12.0
    ..textStyle = TextStyle(fontWeight: FontWeight.bold);
}

const notificationChannelId = 'my_foreground';

@pragma('vm:entry-point')
onDidReceiveBackgroundNotificationResponse(
    NotificationResponse response) async {
  DartPluginRegistrant.ensureInitialized();
  var pref = await SharedPreferences.getInstance();
  pref.setBool('sp_key_called_from_noti', true);
  Utils.customPrint('APP RESTART 24');

  /// APP RESTART
}

@pragma('vm:entry-point')
void bgLocationCallBack() async {
  DartPluginRegistrant.ensureInitialized();
  var pref = await SharedPreferences.getInstance();
  pref.setBool('sp_key_called_from_noti', true);
  Utils.customPrint('APP RESTART 23');

  /// APP RESTART
}

onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) {
  Utils.customPrint('APP RESTART 3');

  /// APP RESTART
}

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;
Future<void> initializeService() async {
  //final service = FlutterBackgroundService();
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

    if (value.id == 889) {
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

    /// APP RESTART
  },
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool isLoading = false, isComingFromUnilink = false;
  StreamSubscription? _sub;

  Future<void> initDeepLinkListener() async {


    try {
      _sub = uriLinkStream.listen((Uri? uri) async{

       setState(() {
         isComingFromUnilink = true;
       });

        print("URI: ${uri}");
        if (uri != null) {
          print('Deep link received: $uri');
          if(uri.queryParameters['verify'] != null){
            print("reset: ${uri.queryParameters['verify'].toString()}");
            bool? isUserLoggedIn = await sharedPreferences!.getBool('isUserLoggedIn');
            print("isUserLoggedIn: $isUserLoggedIn");
            if(isUserLoggedIn != null && isUserLoggedIn)
              {
                Get.to(HomePage(isComingFromReset: true,token: uri.queryParameters['verify'].toString(),));
              }
            else
              {
                Get.to(ResetPassword(token: uri.queryParameters['verify'].toString(),));
              }

          }
        }
      }, onError: (err) {
        print('Error handling deep link: $err');
      });
    } on PlatformException {
      print("Exception while handling with uni links : ${PlatformException}");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initDeepLinkListener();
    Utils.customPrint('APP IN BG INIT');
  }

  getTripData()async
  {
    bool? isTripStarted =
    sharedPreferences!.getBool('trip_started');

    print("TRIP IN PROGRESS MAIN $isTripStarted");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // positionStream!.cancle
    _sub?.cancel();
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
        builder: EasyLoading.init(),
        getPages: [
          GetPage(name: '/', page: () => IntroScreen()),
          GetPage(name: '/HomePage', page: () => HomePage()),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        print('\n\n**********resumed');
        // var pref = await SharedPreferences.getInstance();

        WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
          await Future.delayed(Duration(seconds: 1), () async {
            sharedPreferences = await SharedPreferences.getInstance();
          });

          sharedPreferences!.reload().then((value) {
            bool? isTripStarted = sharedPreferences!.getBool('trip_started');

            if (isTripStarted != null) {
              if (isTripStarted) {

                if(isComingFromUnilink)
                  {

                  }
                else
                  {
                    EasyLoading.show(
                        status: 'Loading your current trip',
                        maskType: EasyLoadingMaskType.black);
                  }
              }
            }

            Future.delayed(Duration(seconds: 3), () async {
              bool? result =
                  sharedPreferences!.getBool('sp_key_called_from_noti');

              print('********$result');

              if (result != null) {
                if (result) {
                  List<String>? tripData =
                      sharedPreferences!.getStringList('trip_data');
                  bool? isTripStarted =
                      sharedPreferences!.getBool('trip_started');

                  EasyLoading.dismiss();

                  Get.to(TripAnalyticsScreen(
                      tripId: tripData![0],
                      vesselId: tripData[1],
                      tripIsRunningOrNot: isTripStarted));

                  // Navigator.pushAndRemoveUntil(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => TripAnalyticsScreen(
                  //             tripId: tripData![0],
                  //             vesselId: tripData[1],
                  //             tripIsRunningOrNot: isTripStarted)),
                  //     ModalRoute.withName(""));
                } else {
                  EasyLoading.dismiss();
                }
              } else {
                EasyLoading.dismiss();
                sharedPreferences!.reload();
                bool? result =
                    sharedPreferences!.getBool('sp_key_called_from_noti');

                print('********$result');
              }
            });
          });
        });
        break;
      case AppLifecycleState.inactive:
        print('\n\ninactive');
        break;
      case AppLifecycleState.paused:
        print('\n\npaused');
        sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences!.reload();
        break;
      case AppLifecycleState.detached:
        print('\n\ndetached');
        break;
    }
  }
}
