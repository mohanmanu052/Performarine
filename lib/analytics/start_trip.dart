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
      heading = 0.0,
      speedAccuracy = 0.0;

  bool gyroscopeAvailable = false,
      accelerometerAvailable = false,
      magnetometerAvailable = false,
      userAccelerometerAvailable = false;

  /// In this function we start to listen to the data coming from background locator port
  /// From sensor we are getting values of x,y & z in double format
  Future<void> startBGLocatorTrip(String tripId, DateTime dateTime) async {
    ReceivePort port = ReceivePort();

    /// Connect to the port and listen to location updates coming from background_locator_2 plugin.
    if (IsolateNameServer.lookupPortByName(
            LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }

    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);

    /// Initialization of SharedPreferences
    SharedPreferences pref = await SharedPreferences.getInstance();

    /// Get trips data from database to get start time of the trip
    final currentTrip = await _databaseService.getTrip(tripId);

    /// Conversion of String to DateTime
    DateTime createdAtTime = DateTime.parse(currentTrip.createdAt!);

    int fileIndex = 0;

    /// To Check whether sensor are available in the mobile device
    gyroscopeAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.GYROSCOPE);
    accelerometerAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.ACCELEROMETER);
    magnetometerAvailable =
        await s.SensorManager().isSensorAvailable(s.Sensors.MAGNETIC_FIELD);
    userAccelerometerAvailable = await s.SensorManager()
        .isSensorAvailable(s.Sensors.LINEAR_ACCELERATION);

    /// To get data from sensor only if that sensor is available
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

    double latitude = 0.0;
    double longitude = 0.0;
    double finalTripDistance = 0.0;
    double speed = 0.0;

    /// Initialization of file name
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

    String tripDistanceForStorage = '0.00';
    String tripSpeedForStorage = '0.00';
    String tripAvgSpeedForStorage = '0.00';

    /// Listening to the port to get location updates
    port.listen((dynamic data) async {

      /// Conversion of events coming from port into LocationDto(POJO class)
      LocationDto? locationDto =
          data != null ? LocationDto.fromJson(data) : null;

      print("LOCATION DTO $locationDto");

      if (locationDto != null) {

        latitude = locationDto.latitude;
        longitude = locationDto.longitude;
        speed = locationDto.speed < 0 ? 0 : locationDto.speed;
        accuracy = locationDto.accuracy;
        altitide = locationDto.altitude;
        heading = locationDto.heading;
        speedAccuracy = locationDto.speedAccuracy;

        Utils.customPrint('SPEED SPEED 1111 ${speed}');
        Utils.customPrint('SPEED SPEED 2222 ${locationDto.speed}');

        /// To get each and every location of ongoing trip from shared preferences
        /// this is use to calculate distance by current position and prev position store in the list
        List<String> currentLocList =
            pref.getStringList('current_loc_list') ?? [];

        /// Conversion of current lat long into position
        Position _currentPosition = Position(
            latitude: locationDto.latitude,
            longitude: locationDto.longitude,
            timestamp: null,
            accuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
            heading: 0.0,
            altitude: 0.0);

        /// Adding current position into the list to store in shared preferences
        String currentPosStr =
            [_currentPosition.latitude, _currentPosition.longitude].join(',');

        currentLocList.add(currentPosStr);
        pref.setStringList("current_loc_list", currentLocList);
         tripDistanceForStorage = '';

        if (currentLocList.length > 1) {

          /// Conversion previous lat long into Position
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

          /// Calculation of distance between current and previous position
          var _distanceBetweenLastTwoLocations = Geolocator.distanceBetween(
            _previousPosition.latitude,
            _previousPosition.longitude,
            _currentPosition.latitude,
            _currentPosition.longitude,
          );

          debugPrint("PREV LAT ${_previousPosition.latitude}");
          debugPrint("PREV LONG ${_previousPosition.longitude}");
          debugPrint("CURR LAT ${_currentPosition.latitude}");
          debugPrint("CURR LONG ${_currentPosition.longitude}");

          finalTripDistance += _distanceBetweenLastTwoLocations;
          debugPrint('Total Distance: $finalTripDistance');
          pref.setDouble('temp_trip_dist', finalTripDistance);

          /// Calculate distance with formula
          tripDistanceForStorage =
              Calculation().calculateDistance(finalTripDistance);

          /// Storing trip distance into shared preferences
          pref.setString('tripDistance', tripDistanceForStorage);
        }

        /// Calculating duration by using created time of ongoing trip
        Duration diff = DateTime.now().toUtc().difference(createdAtTime);

        int finalTripDuration = (diff.inMilliseconds);

        /// Here is the actual trip duration
        print('FINAL TRIP DUR RRR : $finalTripDuration');

        /// DURATION 00:00:00
        String tripDurationForStorage =
        Utils.calculateTripDuration((finalTripDuration ~/ 1000).toInt());

        /// SPEED
        tripSpeedForStorage =
        Calculation().calculateCurrentSpeed(speed);
        print('FINAL TRIP SPEED: $tripSpeedForStorage}');

        /// AVG. SPEED
        tripAvgSpeedForStorage = Calculation()
            .calculateAvgSpeed(finalTripDistance, finalTripDuration);

        Utils.customPrint('TRIP DURATION: $tripDurationForStorage');
        Utils.customPrint('TRIP SPEED 1212: $tripSpeedForStorage');
        Utils.customPrint('AVG SPEED: $tripAvgSpeedForStorage');

        var num = double.parse(tripSpeedForStorage) < 0
            ? 0.0
            : double.parse(tripSpeedForStorage);

        Utils.customPrint('SPEED SPEED SPEED 666: $num');

        /// To cancel TripDurationTimer
        // if (tripDurationTimer != null) {
        //   if (tripDurationTimer!.isActive) {
        //     tripDurationTimer!.cancel();
        //   }
        // }

        // await flutterLocalNotificationsPlugin.cancel(889);

        // tripDurationTimer =
        //     Timer.periodic(Duration(seconds: 1), (timer) async {
        //       var durationTime = DateTime.now().toUtc().difference(createdAtTime);
        //
        //       /// To calculate trip duration periodically
        //       String tripDuration = Utils.calculateTripDuration(
        //           ((durationTime.inMilliseconds) ~/ 1000).toInt());
        //
        //       /// To update notification content
        //       await BackgroundLocator.updateNotificationText(
        //           title: '',
        //           msg: 'Trip is in progress',
        //           bigMsg:
        //           'Duration: $tripDuration        Distance: $tripDistanceForStorage $nauticalMile\nCurrent Speed: $tripSpeedForStorage $knot    Avg Speed: $tripAvgSpeedForStorage $knot');
        //     });

        ///
        pref.setString('tripDuration', tripDurationForStorage);
        // To get values in Km/h
        pref.setString('tripSpeed', num.toString());
        pref.setString('tripAvgSpeed', tripAvgSpeedForStorage);

        /// To get files path
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

          /// To convert sensor values into String
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

          /// We are getting accuracy, altitude, heading, speedAccuracy from location updates coming from port.
          String location =
              '${latitude} ${longitude} ${accuracy.toStringAsFixed(3)} ${altitide.toStringAsFixed(3)} $heading $speed $speedAccuracy';

          /// To converting location data into String
          String gps =
          CreateTrip().convertLocationToString('GPS', location, tripId);

          String finalString = '';

          /// Creating csv file Strings by combining all the values
          finalString = '$acc\n$uacc\n$gyro\n$mag\n$gps';

          /// Writing into a csv file
          file.writeAsString('$finalString\n', mode: FileMode.append);

          Utils.customPrint('GPS $gps');
        }
      }
    });

    if (tripDurationTimer != null) {
      if (tripDurationTimer!.isActive) {
        tripDurationTimer!.cancel();
      }
    }

    tripDurationTimer =
        Timer.periodic(Duration(seconds: 1), (timer) async {
          var durationTime = DateTime.now().toUtc().difference(createdAtTime);

          /// To calculate trip duration periodically
          String tripDuration = Utils.calculateTripDuration(
              ((durationTime.inMilliseconds) ~/ 1000).toInt());


          /// To update notification content
          await BackgroundLocator.updateNotificationText(
              title: '',
              msg: 'Trip is in progress',
              bigMsg:
              'Duration: $tripDuration        Distance: $tripDistanceForStorage $nauticalMile\nCurrent Speed: $tripSpeedForStorage $knot    Avg Speed: $tripAvgSpeedForStorage $knot'
          ).catchError((onError){
            print('UPDATE NOTI ERROR: $onError');
          });

          // await flutterLocalNotificationsPlugin.cancel(1).catchError((onError){print('CANCEL NOTI 2: $onError');});
          // await flutterLocalNotificationsPlugin.cancel(776).catchError((onError){print('CANCEL NOTI 3: $onError');});
          //
          // flutterLocalNotificationsPlugin
          //     .show(
          //   777,
          //   '',
          //   // 'Trip is in progress 3',
          //     'Duration: $tripDuration        Distance: $tripDistanceForStorage $nauticalMile\nCurrent Speed: $tripSpeedForStorage $knot    Avg Speed: $tripAvgSpeedForStorage $knot',
          //   NotificationDetails(
          //     android: AndroidNotificationDetails(
          //         'performarine_trip_$tripId-3', '$tripId-3',
          //         channelDescription: 'Description',
          //         importance: Importance.low,
          //         playSound: false,
          //         enableVibration: false,
          //         priority: Priority.low),),
          // )
          //     .catchError((onError) {
          //   print('IOS NOTI ERROR: $onError');
          // });
        });
  }
}
