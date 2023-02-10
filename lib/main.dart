import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_sensors/flutter_sensors.dart' as s;
import 'package:geolocator/geolocator.dart';
// import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/colors.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/pages/authentication/sign_in_screen.dart';
import 'package:performarine/pages/home_page.dart';
import 'package:performarine/pages/intro_screen.dart';
import 'package:get/get.dart';
import 'package:performarine/pages/lets_get_started_screen.dart';
import 'package:performarine/pages/trip_analytics.dart';
import 'package:performarine/provider/common_provider.dart';
import 'package:performarine/services/create_trip.dart';
import 'package:performarine/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:timezone/data/latest.dart' as tz;

import 'models/vessel.dart';

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
  print('APP RESTART 2');

  /// APP RESTART
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance serviceInstance) async {
  DartPluginRegistrant.ensureInitialized();
  /*Get.put<ServiceInstance>(serviceInstance,
      permanent: true, tag: 'serviceInstance');*/

  CreateTrip().startTrip(serviceInstance);

  return;

  print('Background task is running');

  var pref = await SharedPreferences.getInstance();

  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  double latitude = 0.0, longitude = 0.0, speed = 0.0;
  var tripId = '', vesselName = '';
  //  bool stopSending = false;

  // Timer? timer;
  String fileName = '', firstLat, firstLong;
  int fileIndex = 1;

  // Only available for flutter 3.0.0 and later

  fileName = '$fileIndex.csv';

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    // distanceFilter: 0,
  );
  await Geolocator.checkPermission().then((value) {
    if (value == LocationPermission.always) {
      Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position event) {
        print(event == null
            ? 'Unknown'
            : '${event.latitude.toString()}, ${event.longitude.toString()}');

        debugPrint('SPEED SPEED ${event.speed}');
        latitude = event.latitude;
        longitude = event.longitude;
        speed = event.speed;
      });
    }
  });

  bool gyroscopeAvailable =
      await s.SensorManager().isSensorAvailable(s.Sensors.GYROSCOPE);
  bool accelerometerAvailable =
      await s.SensorManager().isSensorAvailable(s.Sensors.ACCELEROMETER);
  bool magnetometerAvailable =
      await s.SensorManager().isSensorAvailable(s.Sensors.MAGNETIC_FIELD);
  bool userAccelerometerAvailable =
      await s.SensorManager().isSensorAvailable(s.Sensors.LINEAR_ACCELERATION);

  debugPrint('GYROSCOPE SENSOR $gyroscopeAvailable');

  if (accelerometerAvailable) {
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          _accelerometerValues = <double>[event.x, event.y, event.z];
        },
      ),
    );
  }

  if (gyroscopeAvailable) {
    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          _gyroscopeValues = <double>[event.x, event.y, event.z];
        },
      ),
    );
  }

  if (userAccelerometerAvailable) {
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          _userAccelerometerValues = <double>[event.x, event.y, event.z];
        },
      ),
    );
  }

  if (magnetometerAvailable) {
    _streamSubscriptions.add(
      magnetometerEvents.listen(
        (MagnetometerEvent event) {
          _magnetometerValues = <double>[event.x, event.y, event.z];
        },
      ),
    );
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
    /*sharedPreferences!.setString('lastLat', latitude.toString()) as String;
    sharedPreferences!.setString('lastLong', longitude.toString()) as String;*/
    print('service stopped'.toUpperCase());
    if (positionStream != null) {
      positionStream!.cancel();
    }
  });

  /*Geolocator.getPositionStream(locationSettings: locationSettings)
      .listen((Position event) {
    latitude = event.latitude;
    longitude = event.longitude;
  });*/

  serviceInstance.on('tripId').listen((event) {
    tripId = event!['tripId'];
    vesselName = event['vesselName'];
  });

  /* serviceInstance.on("stopSending").listen((event) {
    print('STOP SENDING: ${event!['stopSending']}');
    stopSending = event['stopSending'];
  });*/

  serviceInstance.on('onStartTrip').listen((event) async {
    // bring to foreground
    print('ON START TRIP');

    Position startTripPosition = await Geolocator.getCurrentPosition();
    int finalTripDistance = 0;
    int finalTripDuration = 0;
    double finalTripSpeed = 0;
    double finalTripAvgSpeed = 0;

    /*Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position event) {
      double endTripLat = event.latitude;
      double endTripLong = event.longitude;

      double tripDistance = Geolocator.distanceBetween(
          startTripPosition.latitude,
          startTripPosition.longitude,
          endTripLat,
          endTripLong);

      print('TRIP DISTANCE: $tripDistance');
    });*/
    // var pref = await SharedPreferences.getInstance();

    timer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      // to get values in seconds (we are executing value every miliseconds)
      finalTripDuration =
          timer.tick % 5 == 0 ? (timer.tick * 200) : finalTripDuration;
      Position endTripPosition = await Geolocator.getCurrentPosition();
      double tripDistance = Geolocator.distanceBetween(
          startTripPosition.latitude,
          startTripPosition.longitude,
          endTripPosition.latitude,
          endTripPosition.longitude);

      finalTripDistance = finalTripDistance < tripDistance.toInt()
          ? tripDistance.toInt()
          : finalTripDistance;

      finalTripSpeed = (speed * 1.944);

      finalTripAvgSpeed = finalTripDistance / finalTripDuration;

      print('TRIP DISTANCE: $finalTripDistance');
      print('TRIP DURATION: $finalTripDuration');
      print('TRIP SPEED 1212: $finalTripSpeed');
      print('AVG SPEED: ${finalTripDistance}/${finalTripDuration}');

      if (serviceInstance is AndroidServiceInstance) {
        if (await serviceInstance.isForegroundService()) {
          flutterLocalNotificationsPlugin.show(
            888,
            '',
            // '$vesselName',
            'Dist: ${finalTripDistance}m, Duration: ${Utils.calculateTripDuration((finalTripDuration / 1000).toInt())}sec, Speed: ${(speed * 1.944).toStringAsFixed(2)}nm',
            /*'Trip data collection is in progress...',*/
            NotificationDetails(
              android: AndroidNotificationDetails(
                  notificationChannelId, 'MY FOREGROUND SERVICE',
                  icon: '@drawable/logo',
                  ongoing: true,
                  styleInformation:
                      BigTextStyleInformation('', summaryText: '$tripId')
                  /*styleInformation: BigTextStyleInformation(
                      'Duration: ${Utils.calculateTripDuration((finalTripDuration / 1000).toInt())}hr, Distance: ${finalTripDistance}m, Speed: ${(speed * 1.944).toStringAsFixed(2)}nm',
                      contentTitle:
                          '<font size="10" color="blue">$vesselName</font>',
                      htmlFormatContentTitle: true,
                      summaryText: '$tripId')*/
                  /*styleInformation: BigTextStyleInformation('''
                  <table width=100%>
                    <tr>
                      <th align="center">${Utils.calculateTripDuration((finalTripDuration / 1000).toInt())}</th>
                      <th align="center">${finalTripDistance.toStringAsFixed(2)}</th>
                      <th align="center">${finalTripSpeed.toStringAsFixed(2)}</th>
                      <th align="center">${finalTripAvgSpeed.toStringAsFixed(2)}</th>
                    </tr>
                    <br>
                    <tr>
                      <td align="center">Trip Duration&nbsp&nbsp</td>
                      <td align="center">Distance&nbsp&nbsp</td>
                      <td align="center">Current Speed&nbsp&nbsp</td>
                      <td align="center">Avg. Speed&nbsp&nbsp</td>
                    </tr>
                  </table>
                  ''',
                      htmlFormatBigText: true,
                      contentTitle: '<font size="6" color="blue">Name</font>',
                      htmlFormatContentTitle: true,
                      summaryText: '$tripId')*/
                  ),
            ),
          );

          debugPrint('AVG SPEED 12 ${finalTripAvgSpeed.toStringAsFixed(2)}');

          if (finalTripAvgSpeed.isNaN) {
            finalTripAvgSpeed = 0.0;
          }

          serviceInstance.invoke('tripAnalyticsData', {
            "tripDistance": finalTripDistance,
            "tripDuration": finalTripDuration,
            "tripSpeed": finalTripSpeed.toStringAsFixed(2),
            "tripAvgSpeed": finalTripAvgSpeed.toStringAsFixed(2)
          });

          pref.setInt('tripDistance', finalTripDistance);
          pref.setInt('tripDuration', finalTripDuration);
          // To get values in Km/h
          pref.setString('tripSpeed', (speed * 1.944).toStringAsFixed(2));
          pref.setString('tripAvgSpeed', finalTripAvgSpeed.toStringAsFixed(2));

          String filePath = await CreateTrip().getFile(tripId, fileName);
          File file = File(filePath);
          int fileSize = await CreateTrip().checkFileSize(file);

          /// CHECK FOR ONLY 10 KB FOR Testing PURPOSE
          /// Now File Size is 200000
          if (fileSize >= 200000) {
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
            String gyro = '', acc = '', mag = '', uacc = '';
            //print('LAT1 LONG1 $latitude $longitude');

            if (gyroscopeAvailable) {
              gyro = CreateTrip()
                  .convertDataToString('GYRO', _gyroscopeValues!, tripId);
            }
            if (accelerometerAvailable) {
              acc = CreateTrip()
                  .convertDataToString('AAC', _accelerometerValues!, tripId);
            }
            if (magnetometerAvailable) {
              mag = CreateTrip()
                  .convertDataToString('MAG', _magnetometerValues!, tripId);
            }
            if (userAccelerometerAvailable) {
              uacc = CreateTrip().convertDataToString(
                  'UACC', _userAccelerometerValues!, tripId);
            }

            String location = '$latitude $longitude';
            String gps =
                CreateTrip().convertLocationToString('GPS', location, tripId);

            String finalString = '';

            if (gyroscopeAvailable &&
                accelerometerAvailable &&
                userAccelerometerAvailable &&
                magnetometerAvailable) {
              finalString = '$acc\n$uacc\n$gyro\n$mag\n$gps';
            } else if (!gyroscopeAvailable &&
                accelerometerAvailable &&
                userAccelerometerAvailable &&
                magnetometerAvailable) {
              finalString = '$acc\n$uacc\n$mag\n$gps';
            } else if (gyroscopeAvailable &&
                !accelerometerAvailable &&
                userAccelerometerAvailable &&
                magnetometerAvailable) {
              finalString = '$uacc\n$gyro\n$mag\n$gps';
            } else if (gyroscopeAvailable &&
                accelerometerAvailable &&
                !userAccelerometerAvailable &&
                magnetometerAvailable) {
              finalString = '$acc\n$gyro\n$mag\n$gps';
            } else if (gyroscopeAvailable &&
                accelerometerAvailable &&
                userAccelerometerAvailable &&
                !magnetometerAvailable) {
              finalString = '$acc\n$uacc\n$gyro\n$gps';
            } else if (!gyroscopeAvailable &&
                !accelerometerAvailable &&
                !userAccelerometerAvailable &&
                !magnetometerAvailable) {
              finalString = '$gps';
            }

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

    var pref = await SharedPreferences.getInstance();
    pref.setBool('sp_key_called_from_noti', true);
    List<String>? tripData = pref.getStringList('trip_data');
    bool? isTripStarted = pref.getBool('trip_started');

    Get.to(TripAnalyticsScreen(
        tripId: tripData![0],
        vesselId: tripData[1],
        tripIsRunningOrNot: isTripStarted));

    return;

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
      initialNotificationTitle: 'PerforMarine',
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: notificationChannelId,
      initialNotificationContent: 'PerforMarine consuming background services.',
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
        title: 'PerforMarine',
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
