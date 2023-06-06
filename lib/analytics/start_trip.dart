import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/location_dto.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_background_service_ios/flutter_background_service_ios.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sensors/flutter_sensors.dart' as s;
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:performarine/analytics/calculation.dart';
import 'package:performarine/analytics/get_file.dart';
import 'package:performarine/analytics/location_service_repository.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';
import 'package:performarine/services/create_trip.dart';
import 'package:performarine/services/database_service.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartTrip {
  //bool presentNoti = true;

  final DatabaseService _databaseService = DatabaseService();

  startTrip(ServiceInstance serviceInstance) async {
    bool presentNoti = true;
    Utils.customPrint('Background task is running');

    var pref = await SharedPreferences.getInstance();

    List<double>? _accelerometerValues;
    List<double>? _userAccelerometerValues;
    List<double>? _gyroscopeValues;
    List<double>? _magnetometerValues;
    final _streamSubscriptions = <StreamSubscription<dynamic>>[];
    double latitude = 0.0,
        longitude = 0.0,
        speed = 0.0,
        accuracy = 0.0,
        altitide = 0.0,
        gpsSpeed = 0.0,
        heading = 0.0,
        speedAccuracy = 0.0;
    var tripId = '', vesselName = '';
    //  bool stopSending = false;

    // Timer? timer;
    String mobileFileName = '',
        firstLat,
        firstLong,
        // lprFileName = '',
        timestamp = '';
    int fileIndex = 1;

    // Only available for flutter 3.0.0 and later

    mobileFileName = 'mobile_$fileIndex.csv';
    // lprFileName = 'lpr_$fileIndex.csv';

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      // distanceFilter: 0,
    );
    await Geolocator.checkPermission().then((value) {
      if (value == LocationPermission.always) {
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position event) {
          Utils.customPrint(event == null
              ? 'Unknown'
              : '${event.latitude.toString()}, ${event.longitude.toString()}');

          Utils.customPrint('SPEED SPEED ${event.speed}');
          latitude = event.latitude;
          longitude = event.longitude;
          speed = event.speed;
          accuracy = event.accuracy;
          altitide = event.altitude;
          speedAccuracy = event.speedAccuracy;
          gpsSpeed = event.speed;
          heading = event.heading;
          timestamp = event.timestamp!.toUtc().toIso8601String();
        });
      }
    });

    bool gyroscopeAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.GYROSCOPE);
    bool accelerometerAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.ACCELEROMETER);
    bool magnetometerAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.MAGNETIC_FIELD);
    bool userAccelerometerAvailable = await s.SensorManager()
        .isSensorAvailable(s.Sensors.LINEAR_ACCELERATION);

    Utils.customPrint('GYROSCOPE SENSOR $gyroscopeAvailable');

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
      serviceInstance.on('setAsForeground').listen((event) async {
        serviceInstance.setAsForegroundService();
      });

      serviceInstance.on('setAsBackground').listen((event) {
        serviceInstance.setAsBackgroundService();
      });
    }

    serviceInstance.on('stopService').listen((event) {
      serviceInstance.stopSelf();

      Utils.customPrint('service stopped'.toUpperCase());
      if (positionStream != null) {
        positionStream!.cancel();
      }
    });

    serviceInstance.on('tripId').listen((event) {
      tripId = event!['tripId'];
      vesselName = event['vesselName'];
    });

    serviceInstance.on('onStartTrip').listen((event) async {
      // bring to foreground
      Utils.customPrint('ON START TRIP');

      Position startTripPosition = await Geolocator.getCurrentPosition();
      double finalTripDistance = 0;
      int finalTripDuration = 0;

      Duration duration = Platform.isAndroid
          ? const Duration(milliseconds: 300)
          : const Duration(seconds: 1);

      timer = Timer.periodic(duration, (timer) async {
        // to get values in seconds (we are executing value every miliseconds)
        if (Platform.isAndroid) {
          finalTripDuration =
              timer.tick % 5 == 0 ? (timer.tick * 300) : finalTripDuration;
        } else {
          print('1 SEC DUR');
          finalTripDuration = finalTripDuration + 1000;
          print('FINAL TRIP DUR: $finalTripDuration');
        }

        Position endTripPosition = await Geolocator.getCurrentPosition(
            timeLimit: Duration(seconds: 1));
        double tripDistance = Geolocator.distanceBetween(
            startTripPosition.latitude,
            startTripPosition.longitude,
            endTripPosition.latitude,
            endTripPosition.longitude);
        print('FINAL TRIP DIST: $tripDistance');

        /// DURATION 00:00:00
        String tripDurationForStorage =
            Utils.calculateTripDuration((finalTripDuration / 1000).toInt());

        /// DISTANCE
        finalTripDistance =
            finalTripDistance < tripDistance ? tripDistance : finalTripDistance;
        String tripDistanceForStorage =
            Calculation().calculateDistance(finalTripDistance);

        print('FINAL TRIP DIST: $tripDistanceForStorage');

        /// SPEED
        String tripSpeedForStorage = Calculation().calculateCurrentSpeed(speed);

        print('FINAL TRIP SPEED: $tripSpeedForStorage');

        /// AVG. SPEED
        String tripAvgSpeedForStorage = Calculation()
            .calculateAvgSpeed(finalTripDistance, finalTripDuration);
        // finalTripAvgSpeed = (((finalTripDistance / 1852) / (finalTripDuration / 1000)) * 1.944);

        Utils.customPrint('TRIP DISTANCE: $tripDistanceForStorage');
        Utils.customPrint('TRIP DURATION: $tripDurationForStorage');
        Utils.customPrint('TRIP SPEED 1212: $tripSpeedForStorage');
        Utils.customPrint('AVG SPEED: $tripAvgSpeedForStorage');

        serviceInstance.invoke('tripAnalyticsData', {
          "tripDistance": tripDistanceForStorage,
          "tripDuration": tripDurationForStorage,
          "tripSpeed": tripSpeedForStorage,
          "tripAvgSpeed": tripAvgSpeedForStorage
        });

        if (serviceInstance is AndroidServiceInstance) {
          print('INSIDE IOS SER INS ANDROID 1');
          if (await serviceInstance.isForegroundService()) {
            print('INSIDE IOS SER INS 2');
            flutterLocalNotificationsPlugin.show(
              888,
              '',
              'Trip is in progress',
              NotificationDetails(
                  android: AndroidNotificationDetails(
                      notificationChannelId, 'MY FOREGROUND SERVICE',
                      icon: '@drawable/noti_logo',
                      ongoing: true,
                      // styleInformation:
                      //     BigTextStyleInformation('', summaryText: '$tripId')
                      styleInformation: BigTextStyleInformation(
                          'Duration: $tripDurationForStorage        Distance: $tripDistanceForStorage $nauticalMile\nCurrent Speed: $tripSpeedForStorage $knot    Avg Speed: $tripAvgSpeedForStorage $knot',
                          htmlFormatContentTitle: true,
                          summaryText: '')),
                  iOS: DarwinNotificationDetails(
                    presentSound: presentNoti,
                    presentAlert: presentNoti,
                    /*subtitle:
                        'Duration: $tripDurationForStorage        Distance: $tripDistanceForStorage $nauticalMile\nCurrent Speed: $tripSpeedForStorage $knot    Avg Speed: $tripAvgSpeedForStorage $knot',
                  */
                  )),
            );

            presentNoti = false;

            pref.setString('tripDistance', tripDistanceForStorage);
            pref.setString('tripDuration', tripDurationForStorage);
            // To get values in Km/h
            pref.setString('tripSpeed', tripSpeedForStorage);
            pref.setString('tripAvgSpeed', tripAvgSpeedForStorage);

            String filePath = await GetFile().getFile(tripId, mobileFileName);
            // String lprFilePath = await GetFile().getFile(tripId, lprFileName);
            // File mobileFile = File(filePath[0]);
            // File lprFile = File(filePath[1]);
            File file = File(filePath);
            // File lprFile = File(lprFilePath);
            int fileSize = await GetFile().checkFileSize(file);
            // int lprFileSize = await GetFile().checkFileSize(lprFile);
            //int mobileFileSize = await GetFile().checkFileSize(mobileFile);
            //int lprFileSize = await GetFile().checkFileSize(mobileFile);

            /// CHECK FOR ONLY 10 KB FOR Testing PURPOSE
            /// Now File Size is 200000
            if (fileSize >= 200000 /*&& lprFileSize >= 200000*/) {
              Utils.customPrint('STOPPED WRITING');
              Utils.customPrint('CREATING NEW FILE');
              // if (timer != null) timer.cancel();
              // Utils.customPrint('TIMER STOPPED');
              fileIndex = fileIndex + 1;
              mobileFileName = 'mobile_$fileIndex.csv';
              // lprFileName = 'lpr_$fileIndex.csv';

              /// STOP WRITING & CREATE NEW FILE
            } else {
              Utils.customPrint('WRITING');
              //Utils.customPrint('LOCATION DATA $latitude\n$longitude');
              String gyro = '', acc = '', mag = '', uacc = '';
              //Utils.customPrint('LAT1 LONG1 $latitude $longitude');

              gyro = CreateTrip().convertDataToString('GYRO',
                  gyroscopeAvailable ? _gyroscopeValues! : [0.0], tripId);

              acc = CreateTrip().convertDataToString(
                  'AAC',
                  accelerometerAvailable ? _accelerometerValues! : [0.0],
                  tripId);

              mag = CreateTrip().convertDataToString('MAG',
                  magnetometerAvailable ? _magnetometerValues! : [0.0], tripId);

              uacc = CreateTrip().convertDataToString(
                  'UACC',
                  userAccelerometerAvailable
                      ? _userAccelerometerValues!
                      : [0.0],
                  tripId);

              String location =
                  '$latitude $longitude ${accuracy.toStringAsFixed(3)} ${altitide.toStringAsFixed(3)} $heading $speed $speedAccuracy';
              String gps =
                  CreateTrip().convertLocationToString('GPS', location, tripId);

              String finalString = '';

              finalString = '$acc\n$uacc\n$gyro\n$mag\n$gps';

              await file.writeAsString('$finalString\n', mode: FileMode.append);
              // lprFile.writeAsString('$finalString\n', mode: FileMode.append);
              //lprFile.writeAsString('$finalString\n', mode: FileMode.append);

              Utils.customPrint('GPS $gps');
            }
          }
        } else {
          print('INSIDE IOS SER INS ${serviceInstance}');
          flutterLocalNotificationsPlugin
              .show(
            889,
            'PerforMarine',
            'Trip is in progress',
            /*'Duration: $tripDurationForStorage        Distance: $tripDistanceForStorage $nauticalMile\nCurrent Speed: $tripSpeedForStorage $knot    Avg Speed: $tripAvgSpeedForStorage $knot',*/
            NotificationDetails(
                iOS: DarwinNotificationDetails(
              presentSound: presentNoti,
              presentAlert: presentNoti,
              subtitle: '',
            )),
          )
              .catchError((onError) {
            print('IOS NOTI ERROR: $onError');
          });

          presentNoti = false;

          pref.setString('tripDistance', tripDistanceForStorage);
          pref.setString('tripDuration', tripDurationForStorage);
          // To get values in Km/h
          pref.setString('tripSpeed', tripSpeedForStorage);
          pref.setString('tripAvgSpeed', tripAvgSpeedForStorage);

          String filePath = await GetFile().getFile(tripId, mobileFileName);
          // String lprFilePath = await GetFile().getFile(tripId, lprFileName);
          // File mobileFile = File(filePath[0]);
          // File lprFile = File(filePath[1]);
          File file = File(filePath);
          // File lprFile = File(lprFilePath);
          int fileSize = await GetFile().checkFileSize(file);
          // int lprFileSize = await GetFile().checkFileSize(lprFile);
          //int mobileFileSize = await GetFile().checkFileSize(mobileFile);
          //int lprFileSize = await GetFile().checkFileSize(mobileFile);

          /// CHECK FOR ONLY 10 KB FOR Testing PURPOSE
          /// Now File Size is 200000
          if (fileSize >= 200000 /* && lprFileSize >= 200000*/) {
            Utils.customPrint('STOPPED WRITING');
            Utils.customPrint('CREATING NEW FILE');
            // if (timer != null) timer.cancel();
            // Utils.customPrint('TIMER STOPPED');
            fileIndex = fileIndex + 1;
            mobileFileName = 'mobile_$fileIndex.csv';
            // lprFileName = 'lpr_$fileIndex.csv';

            /// STOP WRITING & CREATE NEW FILE
          } else {
            Utils.customPrint('WRITING');
            String gyro = '', acc = '', mag = '', uacc = '';
            //Utils.customPrint('LAT1 LONG1 $latitude $longitude');

            gyro = CreateTrip().convertDataToString(
                'GYRO', gyroscopeAvailable ? _gyroscopeValues! : [0.0], tripId);

            acc = CreateTrip().convertDataToString('AAC',
                accelerometerAvailable ? _accelerometerValues! : [0.0], tripId);

            mag = CreateTrip().convertDataToString('MAG',
                magnetometerAvailable ? _magnetometerValues! : [0.0], tripId);

            uacc = CreateTrip().convertDataToString(
                'UACC',
                userAccelerometerAvailable
                    ? _userAccelerometerValues ?? [0.0]
                    : [0.0],
                tripId);

            String location = '$latitude $longitude';
            String gps =
                CreateTrip().convertLocationToString('GPS', location, tripId);

            String finalString = '';

            finalString = '$acc\n$uacc\n$gyro\n$mag\n$gps';

            file.writeAsString('$finalString\n', mode: FileMode.append);
            //lprFile.writeAsString('$finalString\n', mode: FileMode.append);
            //lprFile.writeAsString('$finalString\n', mode: FileMode.append);

            Utils.customPrint('GPS $gps');
          }
        }
      });
    });
  }

  bool presentNoti = true;

  SharedPreferences? pref;

  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  double latitude = 0.0,
      longitude = 0.0,
      speed = 0.0,
      accuracy = 0.0,
      altitide = 0.0,
      gpsSpeed = 0.0,
      heading = 0.0,
      speedAccuracy = 0.0;
  var tripId = '', vesselName = '';
  //  bool stopSending = false;

  // Timer? timer;
  String mobileFileName = '',
      firstLat = '',
      firstLong = '',
      lprFileName = '',
      timestamp = '';
  int fileIndex = 1;

  double finalTripDistance = 0;
  int finalTripDuration = 0;

  Position? startTripPosition;

  bool gyroscopeAvailable = false,
      accelerometerAvailable = false,
      magnetometerAvailable = false,
      userAccelerometerAvailable = false;

  Future initIOSTrip() async {
    pref = await SharedPreferences.getInstance();

    mobileFileName = 'mobile_$fileIndex.csv';
    lprFileName = 'lpr_$fileIndex.csv';

    try {
      List<String>? tripData = pref!.getStringList('trip_data');
      tripId = tripData![0];
      vesselName = tripData[2];
    } on Exception catch (e) {
      log('SP EXE: $e');
    }

    // startTripPosition = await Geolocator.getCurrentPosition();

    // print('LAT: ${startTripPosition!.latitude} - ${startTripPosition!.longitude}');

    finalTripDistance = 0;
    // finalTripDuration = 0;

    flutterLocalNotificationsPlugin
        .show(
      889,
      'PerforMarine',
      'Trip is in progress',
      /*'Duration: $tripDurationForStorage        Distance: $tripDistanceForStorage $nauticalMile\nCurrent Speed: $tripSpeedForStorage $knot    Avg Speed: $tripAvgSpeedForStorage $knot',*/
      NotificationDetails(
          iOS: DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
        subtitle: '',
      )),
    )
        .catchError((onError) {
      print('IOS NOTI ERROR: $onError');
    });

    return;
  }

  Future startIOSTrip2(
    DateTime startDateTime,
    double finalTripDistance,
    Position startTripPosition,
    double endTripLatitude,
    double endTripLongitude,
    String tripId,
    String vesselName,
    double speed,
    SharedPreferences pref,
    int fileIndex,
    bool gyroscopeAvailable,
    bool accelerometerAvailable,
    bool magnetometerAvailable,
    bool userAccelerometerAvailable,
    /*List<double>? _accelerometerValues,
      List<double>? _gyroscopeValues,
      List<double>? _userAccelerometerValues,
      List<double>? _magnetometerValues*/
  ) async {
    DateTime currentDateTime = DateTime.now();

    Duration diff = currentDateTime.difference(startDateTime);

    pref = await SharedPreferences.getInstance();

    if (accelerometerAvailable) {
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          _accelerometerValues = <double>[event.x, event.y, event.z];
        },
      );
    }

    if (gyroscopeAvailable) {
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          _gyroscopeValues = <double>[event.x, event.y, event.z];
        },
      );
    }

    if (userAccelerometerAvailable) {
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          _userAccelerometerValues = <double>[event.x, event.y, event.z];
        },
      );
    }

    if (magnetometerAvailable) {
      magnetometerEvents.listen(
        (MagnetometerEvent event) {
          _magnetometerValues = <double>[event.x, event.y, event.z];
        },
      );
    }

    finalTripDistance = pref.getDouble('temp_trip_dist') ?? 0.0;

    Geolocator.getPositionStream(
        locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
    )).listen((Position event) async {
      // Utils.customPrint(event == null
      //     ? 'Unknown'
      //     : '${event.latitude.toString()}, ${event.longitude.toString()}');

      // latitude = event.latitude;
      // longitude = event.longitude;
      endTripLatitude = event.latitude;
      endTripLongitude = event.longitude;
      speed = event.speed < 0 ? 0 : event.speed;
      Utils.customPrint('SPEED SPEED 1212 ${speed}');
      // accuracy = event.accuracy;
      // altitide = event.altitude;
      // speedAccuracy = event.speedAccuracy;
      // gpsSpeed = event.speed;
      // heading = event.heading;
      // timestamp = event.timestamp!.toUtc().toIso8601String();

      List<String> currentLocList =
          pref.getStringList('current_loc_list') ?? [];

      Position _currentPosition = Position(
          latitude: event.latitude,
          longitude: event.longitude,
          timestamp: null,
          accuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
          heading: 0.0,
          altitude: 0.0);

      String currentPosStr =
          [_currentPosition.latitude, _currentPosition.longitude].join(',');

      currentLocList.add(currentPosStr);
      pref.setStringList("current_loc_list", currentLocList);

      if (currentLocList.length > 1) {
        String previousPosStr =
            currentLocList.elementAt(currentLocList.length - 2);
        Position _previousPosition = Position(
            latitude: double.parse(previousPosStr.split(',').first.trim()),
            longitude: double.parse(previousPosStr.split(',').last.trim()),
            timestamp: null,
            accuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            heading: 0.0,
            altitude: 0.0);

        var _distanceBetweenLastTwoLocations = Geolocator.distanceBetween(
          _previousPosition.latitude,
          _previousPosition.longitude,
          _currentPosition.latitude,
          _currentPosition.longitude,
        );

        finalTripDistance += _distanceBetweenLastTwoLocations;
        print('Total Distance: $finalTripDistance');
        pref.setDouble('temp_trip_dist', finalTripDistance);
        String tripDistanceForStorage =
            Calculation().calculateDistance(finalTripDistance);

        print('FINAL TRIP DIST: $tripDistanceForStorage');
        print('FINAL TRIP DIST 2: $finalTripDistance');

        pref.setString('tripDistance', tripDistanceForStorage);
      }
    });

    // List<String>? tripData = pref.getStringList('trip_data');
    // tripId = tripData![0];
    // vesselName = tripData[2];

    String mobileFileName = 'mobile_$fileIndex.csv';
    String lprFileName = 'lpr_$fileIndex.csv';

    print('1 SEC DUR');
    int finalTripDuration = (diff.inMilliseconds);
    print('FINAL TRIP DUR: $finalTripDuration');
    debugPrint("USER ACC 1 $_userAccelerometerValues");

    // Position endTripPosition =
    //     await Geolocator.getCurrentPosition(timeLimit: Duration(seconds: 1));
    /*double tripDistance = Geolocator.distanceBetween(startTripPosition.latitude,
        startTripPosition.longitude, endTripLatitude, endTripLongitude);
    print('FINAL TRIP DIST: $tripDistance');*/

    /// DURATION 00:00:00
    String tripDurationForStorage =
        Utils.calculateTripDuration((finalTripDuration ~/ 1000).toInt());

    /// DISTANCE
    /*finalTripDistance =
        finalTripDistance < tripDistance ? tripDistance : finalTripDistance;*/
    // String tripDistanceForStorage =
    //     Calculation().calculateDistance(finalTripDistance);

    /// SPEED
    String tripSpeedForStorage = Calculation().calculateCurrentSpeed(speed);

    print('FINAL TRIP SPEED: $tripSpeedForStorage}');

    /// AVG. SPEED
    String tripAvgSpeedForStorage =
        Calculation().calculateAvgSpeed(finalTripDistance, finalTripDuration);
    // finalTripAvgSpeed = (((finalTripDistance / 1852) / (finalTripDuration / 1000)) * 1.944);

    // Utils.customPrint('TRIP DISTANCE: $tripDistanceForStorage');
    Utils.customPrint('TRIP DURATION: $tripDurationForStorage');
    Utils.customPrint('TRIP SPEED 1212: $tripSpeedForStorage');
    Utils.customPrint('AVG SPEED: $tripAvgSpeedForStorage');

    presentNoti = false;

    var num = double.parse(tripSpeedForStorage) < 0
        ? 0.0
        : double.parse(tripSpeedForStorage);

    Utils.customPrint('SPEED SPEED SPEED 666: $num');

    //pref.setString('tripDistance', tripDistanceForStorage);
    pref.setString('tripDuration', tripDurationForStorage);
    // To get values in Km/h
    pref.setString('tripSpeed', num.toString());
    pref.setString('tripAvgSpeed', tripAvgSpeedForStorage);

    String filePath = await GetFile().getFile(tripId, mobileFileName);
    String lprFilePath = await GetFile().getFile(tripId, lprFileName);
    // File mobileFile = File(filePath[0]);
    // File lprFile = File(filePath[1]);
    File file = File(filePath);
    File lprFile = File(lprFilePath);
    int fileSize = await GetFile().checkFileSize(file);
    int lprFileSize = await GetFile().checkFileSize(lprFile);
    //int mobileFileSize = await GetFile().checkFileSize(mobileFile);
    //int lprFileSize = await GetFile().checkFileSize(mobileFile);

    /// CHECK FOR ONLY 10 KB FOR Testing PURPOSE
    /// Now File Size is 200000
    if (fileSize >= 200000 && lprFileSize >= 200000) {
      Utils.customPrint('STOPPED WRITING');
      Utils.customPrint('CREATING NEW FILE');
      // if (timer != null) timer.cancel();
      // Utils.customPrint('TIMER STOPPED');
      fileIndex = fileIndex + 1;
      mobileFileName = 'mobile_$fileIndex.csv';
      lprFileName = 'lpr_$fileIndex.csv';

      /// STOP WRITING & CREATE NEW FILE
    } else {
      Utils.customPrint('WRITING');
      String gyro = '', acc = '', mag = '', uacc = '';
      //Utils.customPrint('LAT1 LONG1 $latitude $longitude');

      gyro = CreateTrip().convertDataToString('GYRO',
          gyroscopeAvailable ? _gyroscopeValues ?? [0.0] : [0.0], tripId);

      acc = CreateTrip().convertDataToString(
          'AAC',
          accelerometerAvailable ? _accelerometerValues ?? [0.0] : [0.0],
          tripId);

      mag = CreateTrip().convertDataToString('MAG',
          magnetometerAvailable ? _magnetometerValues ?? [0.0] : [0.0], tripId);

      uacc = CreateTrip().convertDataToString(
          'UACC',
          userAccelerometerAvailable
              ? _userAccelerometerValues ?? [0.0]
              : [0.0],
          tripId);

      String location = '${endTripLatitude} ${endTripLongitude}';
      String gps =
          CreateTrip().convertLocationToString('GPS', location, tripId);

      String finalString = '';

      finalString = '$acc\n$uacc\n$gyro\n$mag\n$gps';

      debugPrint('FILE WRITING CURRENT TIME ${Utils.getCurrentTZDateTime()}');
      file.writeAsString('$finalString\n', mode: FileMode.append);
      // file.writeAsString('$finalString\n -> $data', mode: FileMode.append);
      //lprFile.writeAsString('$finalString\n', mode: FileMode.append);
      //lprFile.writeAsString('$finalString\n', mode: FileMode.append);

      Utils.customPrint('GPS $gps');
    }

    return;
  }

  Future<void> startBGLocatorTrip(String tripId, DateTime dateTime) async {
    if (Platform.isAndroid) {
      flutterLocalNotificationsPlugin.show(
        888,
        '',
        'Android Trip is in progress',
        NotificationDetails(
            android: AndroidNotificationDetails(
                notificationChannelId, 'MY FOREGROUND SERVICE',
                icon: '@drawable/noti_logo',
                ongoing: true,
                // styleInformation:
                //     BigTextStyleInformation('', summaryText: '$tripId')
                styleInformation: BigTextStyleInformation('',
                    //'Duration: $tripDurationForStorage        Distance: $tripDistanceForStorage $nauticalMile\nCurrent Speed: $tripSpeedForStorage $knot    Avg Speed: $tripAvgSpeedForStorage $knot',
                    htmlFormatContentTitle: true,
                    summaryText: '')),
            iOS: DarwinNotificationDetails(
              presentSound: presentNoti,
              presentAlert: presentNoti,
              /*subtitle:
                        'Duration: $tripDurationForStorage        Distance: $tripDistanceForStorage $nauticalMile\nCurrent Speed: $tripSpeedForStorage $knot    Avg Speed: $tripAvgSpeedForStorage $knot',
                  */
            )),
      );
    } else {
      flutterLocalNotificationsPlugin
          .show(
        889,
        'PerforMarine',
        'Trip is in progress',
        /*'Duration: $tripDurationForStorage        Distance: $tripDistanceForStorage $nauticalMile\nCurrent Speed: $tripSpeedForStorage $knot    Avg Speed: $tripAvgSpeedForStorage $knot',*/
        NotificationDetails(
            iOS: DarwinNotificationDetails(
          presentSound: true,
          presentAlert: true,
          subtitle: '',
        )),
      )
          .catchError((onError) {
        print('IOS NOTI ERROR: $onError');
      });
    }

    ReceivePort port = ReceivePort();

    if (IsolateNameServer.lookupPortByName(
            LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }

    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);

    SharedPreferences pref = await SharedPreferences.getInstance();

    DateTime currentDateTime = DateTime.now().toUtc();

    final currentTrip = await _databaseService.getTrip(tripId);

    DateTime createdAtTime = DateTime.parse(currentTrip.createdAt!);

    //Duration diff = currentDateTime.difference(createdAtTime);

    int fileIndex = 0;

    gyroscopeAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.GYROSCOPE);
    accelerometerAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.ACCELEROMETER);
    magnetometerAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.MAGNETIC_FIELD);
    userAccelerometerAvailable = await s.SensorManager()
        .isSensorAvailable(s.Sensors.LINEAR_ACCELERATION);

    print("INSIDE BG LOCATOR 2");
    print("INSIDE BG LOCATOR 2: $gyroscopeAvailable");
    print("INSIDE BG LOCATOR 2: $accelerometerAvailable");
    print("INSIDE BG LOCATOR 2: $magnetometerAvailable");
    print("INSIDE BG LOCATOR 2: $userAccelerometerAvailable");

    if (accelerometerAvailable) {
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          _accelerometerValues = <double>[event.x, event.y, event.z];
        },
      );
    }

    if (gyroscopeAvailable) {
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          _gyroscopeValues = <double>[event.x, event.y, event.z];
        },
      );
    }

    if (userAccelerometerAvailable) {
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          _userAccelerometerValues = <double>[event.x, event.y, event.z];
        },
      );
    }

    if (magnetometerAvailable) {
      magnetometerEvents.listen(
        (MagnetometerEvent event) {
          _magnetometerValues = <double>[event.x, event.y, event.z];
        },
      );
    }

    print("AFTER SESNOR DATA");

    double endTripLatitude = 0.0;
    double endTripLongitude = 0.0;
    double finalTripDistance = 0.0;
    double speed = 0.0;

    String mobileFileName = 'mobile_$fileIndex.csv';
    String lprFileName = 'lpr_$fileIndex.csv';

    print("BEFORE PORT LISTEN");

    port.listen((dynamic data) async {
      print("INSIDE PORT LISTEN");

      if (Platform.isIOS) {
        flutterLocalNotificationsPlugin
            .show(
          889,
          'PerforMarine',
          'Trip is in progress',
          /*'Duration: $tripDurationForStorage        Distance: $tripDistanceForStorage $nauticalMile\nCurrent Speed: $tripSpeedForStorage $knot    Avg Speed: $tripAvgSpeedForStorage $knot',*/
          NotificationDetails(
              iOS: DarwinNotificationDetails(
            presentSound: false,
            presentAlert: false,
            subtitle: '',
          )),
        )
            .catchError((onError) {
          print('IOS NOTI ERROR: $onError');
        });
      }

      print("AFTER NOTIFICATION IN PORT LISTEN");

      LocationDto? locationDto =
          data != null ? LocationDto.fromJson(data) : null;
      if (locationDto != null) {
        endTripLatitude = locationDto.latitude;
        endTripLongitude = locationDto.longitude;
        speed = locationDto.speed < 0 ? 0 : locationDto.speed;
        accuracy = locationDto.accuracy;
        altitide = locationDto.altitude;
        heading = locationDto.heading;
        speedAccuracy = locationDto.speedAccuracy;

        Utils.customPrint('SPEED SPEED 1111 ${speed}');
        Utils.customPrint('SPEED SPEED 2222 ${locationDto.speed}');

        List<String> currentLocList =
            pref.getStringList('current_loc_list') ?? [];

        Position _currentPosition = Position(
            latitude: locationDto.latitude,
            longitude: locationDto.longitude,
            timestamp: null,
            accuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            heading: 0.0,
            altitude: 0.0);

        String currentPosStr =
            [_currentPosition.latitude, _currentPosition.longitude].join(',');

        currentLocList.add(currentPosStr);
        pref.setStringList("current_loc_list", currentLocList);

        if (currentLocList.length > 1) {
          String previousPosStr =
              currentLocList.elementAt(currentLocList.length - 2);
          Position _previousPosition = Position(
              latitude: double.parse(previousPosStr.split(',').first.trim()),
              longitude: double.parse(previousPosStr.split(',').last.trim()),
              timestamp: null,
              accuracy: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
              heading: 0.0,
              altitude: 0.0);

          var _distanceBetweenLastTwoLocations = Geolocator.distanceBetween(
            _previousPosition.latitude,
            _previousPosition.longitude,
            _currentPosition.latitude,
            _currentPosition.longitude,
          );

          finalTripDistance += _distanceBetweenLastTwoLocations;
          print('Total Distance: $finalTripDistance');
          pref.setDouble('temp_trip_dist', finalTripDistance);
          String tripDistanceForStorage =
              Calculation().calculateDistance(finalTripDistance);

          Duration diff = DateTime.now().toUtc().difference(createdAtTime);

          print('FINAL TRIP DIST: ${DateTime.now().toUtc()}');
          print('FINAL TRIP DIST: $createdAtTime');
          print('FINAL TRIP DIST: $tripDistanceForStorage');
          print('FINAL TRIP DIST 2: $finalTripDistance');
          print('FINAL TRIP DIST 3: ${diff.inMilliseconds}');

          pref.setString('tripDistance', tripDistanceForStorage);

          int finalTripDuration = (diff.inMilliseconds);

          //TODO Here is the actual trip duration
          print('FINAL TRIP DUR RRR : $finalTripDuration');

          /// DURATION 00:00:00
          String tripDurationForStorage =
              Utils.calculateTripDuration((finalTripDuration ~/ 1000).toInt());

          /// DISTANCE
          /*finalTripDistance =
        finalTripDistance < tripDistance ? tripDistance : finalTripDistance;*/
          // String tripDistanceForStorage =
          //     Calculation().calculateDistance(finalTripDistance);

          /// SPEED
          String tripSpeedForStorage =
              Calculation().calculateCurrentSpeed(speed);
          print('FINAL TRIP SPEED: $tripSpeedForStorage}');

          /// AVG. SPEED

          String tripAvgSpeedForStorage = Calculation()
              .calculateAvgSpeed(finalTripDistance, finalTripDuration);
          // finalTripAvgSpeed = (((finalTripDistance / 1852) / (finalTripDuration / 1000)) * 1.944);

          // Utils.customPrint('TRIP DISTANCE: $tripDistanceForStorage');
          Utils.customPrint('TRIP DURATION: $tripDurationForStorage');
          Utils.customPrint('TRIP SPEED 1212: $tripSpeedForStorage');
          Utils.customPrint('AVG SPEED: $tripAvgSpeedForStorage');

          var num = double.parse(tripSpeedForStorage) < 0
              ? 0.0
              : double.parse(tripSpeedForStorage);

          Utils.customPrint('SPEED SPEED SPEED 666: $num');

          //pref.setString('tripDistance', tripDistanceForStorage);
          pref.setString('tripDuration', tripDurationForStorage);
          // To get values in Km/h
          pref.setString('tripSpeed', num.toString());
          pref.setString('tripAvgSpeed', tripAvgSpeedForStorage);

          String filePath = await GetFile().getFile(tripId, mobileFileName);
          String lprFilePath = await GetFile().getFile(tripId, lprFileName);
          // File mobileFile = File(filePath[0]);
          // File lprFile = File(filePath[1]);
          File file = File(filePath);
          File lprFile = File(lprFilePath);
          int fileSize = await GetFile().checkFileSize(file);
          int lprFileSize = await GetFile().checkFileSize(lprFile);
          //int mobileFileSize = await GetFile().checkFileSize(mobileFile);
          //int lprFileSize = await GetFile().checkFileSize(mobileFile);

          /// CHECK FOR ONLY 10 KB FOR Testing PURPOSE
          /// Now File Size is 200000
          if (fileSize >= 200000 && lprFileSize >= 200000) {
            Utils.customPrint('STOPPED WRITING');
            Utils.customPrint('CREATING NEW FILE');
            // if (timer != null) timer.cancel();
            // Utils.customPrint('TIMER STOPPED');
            fileIndex = fileIndex + 1;
            mobileFileName = 'mobile_$fileIndex.csv';
            lprFileName = 'lpr_$fileIndex.csv';

            /// STOP WRITING & CREATE NEW FILE
          } else {
            Utils.customPrint('WRITING');
            String gyro = '', acc = '', mag = '', uacc = '';
            //Utils.customPrint('LAT1 LONG1 $latitude $longitude');

            gyro = CreateTrip().convertDataToString('GYRO',
                gyroscopeAvailable ? _gyroscopeValues ?? [0.0] : [0.0], tripId);

            acc = CreateTrip().convertDataToString(
                'AAC',
                accelerometerAvailable ? _accelerometerValues ?? [0.0] : [0.0],
                tripId);

            mag = CreateTrip().convertDataToString(
                'MAG',
                magnetometerAvailable ? _magnetometerValues ?? [0.0] : [0.0],
                tripId);

            uacc = CreateTrip().convertDataToString(
                'UACC',
                userAccelerometerAvailable
                    ? _userAccelerometerValues ?? [0.0]
                    : [0.0],
                tripId);

            String location =
                '${endTripLatitude} ${endTripLongitude} ${accuracy.toStringAsFixed(3)} ${altitide.toStringAsFixed(3)} $heading $speed $speedAccuracy';
            String gps =
                CreateTrip().convertLocationToString('GPS', location, tripId);

            String finalString = '';

            finalString = '$acc\n$uacc\n$gyro\n$mag\n$gps';

            debugPrint(
                'FILE WRITING CURRENT TIME ${Utils.getCurrentTZDateTime()}');
            file.writeAsString('$finalString\n', mode: FileMode.append);
            // file.writeAsString('$finalString\n -> $data', mode: FileMode.append);
            //lprFile.writeAsString('$finalString\n', mode: FileMode.append);
            //lprFile.writeAsString('$finalString\n', mode: FileMode.append);

            Utils.customPrint('GPS $gps');
          }
        }
      }
    });
  }
}
