import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/pages/authentication/sign_in_screen.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/intro_screen.dart';
import 'package:get/get.dart';
import 'package:performarine/pages/lets_get_started_screen.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

SharedPreferences? sharedPreferences;
bool? isStart;
Timer? timer;
Directory? ourDirectory;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeService();

  SharedPreferences.getInstance().then((value) {
    sharedPreferences = value;
    runApp(Phoenix(child: MyApp()));
  });
}

const notificationChannelId = 'my_foreground';

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance serviceInstance) async {
  DartPluginRegistrant.ensureInitialized();
  /*Get.put<ServiceInstance>(serviceInstance,
      permanent: true, tag: 'serviceInstance');*/
  print('Background task is running');

  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  double latitude = 0.0, longitude = 0.0;
  var tripId = '';

  // Timer? timer;
  String fileName = '';
  int fileIndex = 1;
  StreamSubscription<Position> positionStream;
  // Only available for flutter 3.0.0 and later

  fileName = '$fileIndex.csv';

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    // distanceFilter: 0,
  );
  await Geolocator.checkPermission().then((value) {
    if (value == LocationPermission.always) {
      Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position event) {
        print(event == null ? 'Unknown' : '${event.latitude.toString()}, ${event.longitude.toString()}');
        latitude=event.latitude;
        longitude=event.longitude;
      });
    }
  });




  _streamSubscriptions.add(
    accelerometerEvents.listen(
      (AccelerometerEvent event) {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      },
    ),
  );
  _streamSubscriptions.add(
    gyroscopeEvents.listen(
      (GyroscopeEvent event) {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      },
    ),
  );
  _streamSubscriptions.add(
    userAccelerometerEvents.listen(
      (UserAccelerometerEvent event) {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      },
    ),
  );
  _streamSubscriptions.add(
    magnetometerEvents.listen(
      (MagnetometerEvent event) {
        _magnetometerValues = <double>[event.x, event.y, event.z];
      },
    ),
  );
  String convertDataToString(String type, List<double> sensorData) {
    String? input = sensorData.toString();
    final removedBrackets = input.substring(1, input.length - 1);
    var replaceAll = removedBrackets.replaceAll(" ", "");
    var date = DateTime.now().toUtc();
    var todayDate = date.toString().replaceAll(" ", "");
    return '$type,$replaceAll,$todayDate';
  }

  String convertLocationToString(String type, String sensorData) {
    var date = DateTime.now().toUtc();
    var todayDate = date.toString().replaceAll(" ", "");
    var gps = sensorData.toString().replaceAll(" ", ",");
    return '$type,$gps,$todayDate';
  }

  Future<String> getOrCreateFolder() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}/$tripId');

    debugPrint('FOLDER PATH $ourDirectory');

    // Location location = Location();
    //
    // location.onLocationChanged.listen((LocationData currentLocation) {
    //   print("${currentLocation.latitude} : ${currentLocation.longitude}");
    //
    //   latitude = currentLocation.latitude!;
    //   longitude = currentLocation.longitude!;
    // });

    debugPrint('MAIN LAT LONGS $latitude $longitude');
    // var status = await Permission.storage.status;
    // if (!status.isGranted) {
    //   await Permission.storage.request();
    // }
    if ((await ourDirectory!.exists())) {
      return ourDirectory!.path;
    } else {
      ourDirectory!.create();
      return ourDirectory!.path;
    }
  }

  Future<String> getFile() async {
    String folderPath = await getOrCreateFolder();

    File sensorDataFile = File('$folderPath/$fileName');
    return sensorDataFile.path;
  }

  int checkFileSize(File file) {
    if (file.existsSync()) {
      var bytes = file.lengthSync();
      double sizeInKB = bytes / 1024;
      double sizeInMB = sizeInKB / 1024;

      int finalSizeInMB = sizeInMB.toInt();
      // print('FILE SIZE: $sizeInMB');
      //print('FILE SIZE KB: $sizeInKB');
      // print('FINAL FILE SIZE: $finalSizeInMB');
      return sizeInKB.toInt();
    } else {
      return -1;
    }
  }

  if (serviceInstance is AndroidServiceInstance) {
    serviceInstance.on('setAsForeground').listen((event) {
      serviceInstance.setAsForegroundService();
    });

    serviceInstance.on('setAsBackground').listen((event) {
      serviceInstance.setAsBackgroundService();
    });
  }

  serviceInstance.on('stopService').listen((event) {
    serviceInstance.stopSelf();
    print('service stopped'.toUpperCase());
  });

  Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position event)  {
    latitude = event.latitude;
    longitude = event.longitude;
  });

  serviceInstance.on('tripId').listen((event) {
    tripId = event!['tripId'];
  });

  serviceInstance.on('onStartTrip').listen((event) {
    // bring to foreground
    print('ON START TRIP');
    //print('LAT LONG $latitude $longitude');

    timer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      print('LAT LONG main file:  $latitude $longitude');

      if (serviceInstance is AndroidServiceInstance) {
        if (await serviceInstance.isForegroundService()) {
          flutterLocalNotificationsPlugin.show(
            888,
            'Performarine',
            'Trip Data Collection in progress....',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                notificationChannelId,
                'MY FOREGROUND SERVICE',
                icon: '@drawable/logo',
                ongoing: true,
              ),
            ),
          );

          String filePath = await getFile();
          File file = File(filePath);
          int fileSize = await checkFileSize(file);

          /// CHECK FOR ONLY 10 KB FOR Testing PURPOSE
          /// Now File Size is 10,00,000
          if (fileSize >= 1000000) {
            print('STOPPED WRITING');
            print('CREATING NEW FILE');
            // if (timer != null) timer.cancel();
            // print('TIMER STOPPED');
            fileIndex = fileIndex + 1;
            fileName = '$fileIndex.csv';
            // print('FILE NAME: $fileName');
            //print('NEW FILE CREATED');

            /// STOP WRITING & CREATE NEW FILE
          } else {
            print('WRITING');
            //print('LAT1 LONG1 $latitude $longitude');
            String acc = convertDataToString('AAC', _accelerometerValues!);
            String uacc =
                convertDataToString('UACC', _userAccelerometerValues!);
            String gyro = convertDataToString('GYRO', _gyroscopeValues!);
            String mag = convertDataToString('MAG', _magnetometerValues!);
            String location = '$latitude $longitude';
            String gps = convertLocationToString('GPS', location);
            String finalString = '$acc\n$uacc\n$gyro\n$mag\n$gps';
            file.writeAsString('$finalString\n', mode: FileMode.append);

            print('GPS $gps');
          }
        }
      }
    });
  });
}

onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) {
  print('APP RESTART 3');

  /// APP RESTART
}

@pragma('vm:entry-point')
onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  print('APP RESTART 2');

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

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('logo');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin);

  flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (value) async {
    print('APP RESTART 1');
    await Get.deleteAll(force: true);
    Phoenix.rebirth(Get.context!);
    Get.reset();

    /// APP RESTART
  },
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse);

  /*flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
      .requestPermission();*/
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      initialNotificationTitle: 'Performarine',
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationContent: 'Performarine consuming background services.',
      /*'Trip Data Collection in progress...',*/
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: (service) {},
    ),
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
    print('APP IN BG INIT');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // positionStream!.cancle
    super.dispose();
    print('APP IN BG DISPOSE');
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CommonProvider()),
      ],
      child: GetMaterialApp(
        title: 'Performarine',
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        /*routes: {
          '/': (context) => IntroScreen(),
          '/HomePage': (context) => HomePage(),
        },*/
        getPages: [
          GetPage(name: '/', page: () => IntroScreen()),
          GetPage(name: '/HomePage', page: () => HomePage()),
        ],
        // theme: ThemeData(
        //   // primarySwatch: Color(0xFF42B5BF),
        //   // accentColor: Colors.tealAccent,
        // ),
        //home: IntroScreen(),
      ),
    );
  }
}
