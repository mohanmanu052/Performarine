import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sensors/flutter_sensors.dart' as s;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  final DatabaseService _databaseService = DatabaseService();

  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  List<double>? _magnetometerValues;
  double accuracy = 0.0,
      altitide = 0.0,
      gpsSpeed = 0.0,
      heading = 0.0,
      speedAccuracy = 0.0;

  bool gyroscopeAvailable = false,
      accelerometerAvailable = false,
      magnetometerAvailable = false,
      userAccelerometerAvailable = false;

  /// In this function we start to listen to the data coming from background locator port
  Future<void> startBGLocatorTrip(String tripId, DateTime dateTime) async {
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

    final currentTrip = await _databaseService.getTrip(tripId);

    DateTime createdAtTime = DateTime.parse(currentTrip.createdAt!);

    int fileIndex = 0;

    gyroscopeAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.GYROSCOPE);
    accelerometerAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.ACCELEROMETER);
    magnetometerAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.MAGNETIC_FIELD);
    userAccelerometerAvailable = await s.SensorManager()
        .isSensorAvailable(s.Sensors.LINEAR_ACCELERATION);

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
    // Future<bool> hasActiveNotifications() async {
    //   var activeNotifications = await flutterLocalNotificationsPlugin
    //       .resolvePlatformSpecificImplementation<
    //           AndroidFlutterLocalNotificationsPlugin>()
    //       ?.getActiveNotifications();
    //
    //   return activeNotifications?.isEmpty ?? true;
    // }

    var activeNotifications = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.getActiveNotifications();

//Todo: Notification spanning on port listen it will generate the notification continuously
    port.listen((dynamic data) async {
      LocationDto? locationDto =
          data != null ? LocationDto.fromJson(data) : null;

      print("LOCATION DTO $locationDto");

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
          debugPrint('Total Distance: $finalTripDistance');
          pref.setDouble('temp_trip_dist', finalTripDistance);
          String tripDistanceForStorage =
              Calculation().calculateDistance(finalTripDistance);

          Duration diff = DateTime.now().toUtc().difference(createdAtTime);

          pref.setString('tripDistance', tripDistanceForStorage);

          int finalTripDuration = (diff.inMilliseconds);

          /// Here is the actual trip duration
          print('FINAL TRIP DUR RRR : $finalTripDuration');

          /// DURATION 00:00:00
          String tripDurationForStorage =
              Utils.calculateTripDuration((finalTripDuration ~/ 1000).toInt());

          /// SPEED
          String tripSpeedForStorage =
              Calculation().calculateCurrentSpeed(speed);
          print('FINAL TRIP SPEED: $tripSpeedForStorage}');

          /// AVG. SPEED

          String tripAvgSpeedForStorage = Calculation()
              .calculateAvgSpeed(finalTripDistance, finalTripDuration);

          Utils.customPrint('TRIP DURATION: $tripDurationForStorage');
          Utils.customPrint('TRIP SPEED 1212: $tripSpeedForStorage');
          Utils.customPrint('AVG SPEED: $tripAvgSpeedForStorage');

          var num = double.parse(tripSpeedForStorage) < 0
              ? 0.0
              : double.parse(tripSpeedForStorage);

          Utils.customPrint('SPEED SPEED SPEED 666: $num');

          if (tripDurationTimer != null) {
            if (tripDurationTimer!.isActive) {
              tripDurationTimer!.cancel();
            }
          }

          await flutterLocalNotificationsPlugin.cancel(889);
          tripDurationTimer =
              Timer.periodic(Duration(seconds: 1), (timer) async {
            var durationTime = DateTime.now().toUtc().difference(createdAtTime);
            String tripDuration = Utils.calculateTripDuration(
                ((durationTime.inMilliseconds) ~/ 1000).toInt());

            await BackgroundLocator.updateNotificationText(
                title: '',
                msg: 'Trip is in progress',
                bigMsg:
                    'Duration: $tripDuration        Distance: $tripDistanceForStorage $nauticalMile\nCurrent Speed: $tripSpeedForStorage $knot    Avg Speed: $tripAvgSpeedForStorage $knot');
          });

          pref.setString('tripDuration', tripDurationForStorage);
          // To get values in Km/h
          pref.setString('tripSpeed', num.toString());
          pref.setString('tripAvgSpeed', tripAvgSpeedForStorage);

          String filePath = await GetFile().getFile(tripId, mobileFileName);
          String lprFilePath = await GetFile().getFile(tripId, lprFileName);
          File file = File(filePath);
          File lprFile = File(lprFilePath);
          int fileSize = await GetFile().checkFileSize(file);
          int lprFileSize = await GetFile().checkFileSize(lprFile);

          /// CHECK FOR ONLY 10 KB FOR Testing PURPOSE
          /// Now File Size is 200000
          if (fileSize >= 200000 && lprFileSize >= 200000) {
            Utils.customPrint('STOPPED WRITING');
            Utils.customPrint('CREATING NEW FILE');
            fileIndex = fileIndex + 1;
            mobileFileName = 'mobile_$fileIndex.csv';
            lprFileName = 'lpr_$fileIndex.csv';

            /// STOP WRITING & CREATE NEW FILE
          } else {
            Utils.customPrint('WRITING');
            String gyro = '', acc = '', mag = '', uacc = '';

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

            file.writeAsString('$finalString\n', mode: FileMode.append);

            Utils.customPrint('GPS $gps');
          }
        }
      }
    });
  }
}
