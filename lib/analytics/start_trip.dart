import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:app_settings/app_settings.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sensors/flutter_sensors.dart' as s;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
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

import '../common_widgets/widgets/log_level.dart';

class StartTrip {
  String page = "Start_trip";
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
  Future<void> startBGLocatorTrip(String tripId, DateTime dateTime, [bool isReinitialize = false]) async {

    // checkGPS();

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


    Utils.customPrint("AFTER SESNOR DATA");
    CustomLogger().logWithFile(Level.info, "AFTER SESNOR DATA ->-> $page");

    double latitude = 0.0;
    double longitude = 0.0;
    double finalTripDistance = 0.0;
    double speed = 0.0;

    /// Initialization of file name
    String mobileFileName = 'mobile_$fileIndex.csv';
    String lprFileName = 'lpr_$fileIndex.csv';


    Utils.customPrint("BEFORE PORT LISTEN");
    CustomLogger().logWithFile(Level.info, "BEFORE PORT LISTEN-> $page");

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

      Utils.customPrint("LOCATION DTO $locationDto");
      CustomLogger().logWithFile(Level.info, "LOCATION DTO $locationDto -> $page");

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

        CustomLogger().logWithFile(Level.info, "SPEED SPEED 1111 ${speed} -> $page");
        CustomLogger().logWithFile(Level.info, "SPEED SPEED 2222 ${locationDto.speed} -> $page");

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
            altitude: 0.0,
          altitudeAccuracy: 0.0,
          headingAccuracy: 0.0
            );

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
              altitude: 0.0,
              altitudeAccuracy: 0.0,
              headingAccuracy: 0.0
          );

          /// Calculation of distance between current and previous position
          var _distanceBetweenLastTwoLocations = Geolocator.distanceBetween(
            _previousPosition.latitude,
            _previousPosition.longitude,
            _currentPosition.latitude,
            _currentPosition.longitude,
          );

          Utils.customPrint("PREV LAT ${_previousPosition.latitude}");
          Utils.customPrint("PREV LONG ${_previousPosition.longitude}");
          Utils.customPrint("CURR LAT ${_currentPosition.latitude}");
          Utils.customPrint("CURR LONG ${_currentPosition.longitude}");

          CustomLogger().logWithFile(Level.info, "PREV LAT ${_previousPosition.latitude} -> $page");
          CustomLogger().logWithFile(Level.info, "PREV LONG ${_previousPosition.longitude} -> $page");
          CustomLogger().logWithFile(Level.info, "CURR LAT ${_currentPosition.latitude} -> $page");
          CustomLogger().logWithFile(Level.info, "CURR LONG ${_currentPosition.longitude} -> $page");

          if(isReinitialize)
            {
              String? tempDistInNM = sharedPreferences!.getString('tripDistance');
          Utils.customPrint('@@@@: $tempDistInNM');
              CustomLogger().logWithFile(Level.info, "@@@@: $tempDistInNM -> $page");
              double tempDistInMeter = (double.parse(tempDistInNM ?? '0.00')* 1852);
              finalTripDistance += tempDistInMeter;
            }

          finalTripDistance += _distanceBetweenLastTwoLocations;

      Utils.customPrint('Total Distance: $finalTripDistance');
          CustomLogger().logWithFile(Level.info, "Total Distance: $finalTripDistance -> $page");

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

      Utils.customPrint('FINAL TRIP DUR RRR : $finalTripDuration');
        CustomLogger().logWithFile(Level.info, "FINAL TRIP DUR RRR : $finalTripDuration -> $page");

        /// DURATION 00:00:00
        String tripDurationForStorage =
        Utils.calculateTripDuration((finalTripDuration ~/ 1000).toInt());

        /// SPEED
        ///
        if(isReinitialize)
          {
            String? tempSpeed = sharedPreferences!.getString('tripSpeed');
            speed = double.parse(tempSpeed ?? '0.00');
            isReinitialize = false;
          }

        tripSpeedForStorage =
        Calculation().calculateCurrentSpeed(speed);

      Utils.customPrint('FINAL TRIP SPEED: $tripSpeedForStorage}');
        CustomLogger().logWithFile(Level.info, "FINAL TRIP SPEED: $tripSpeedForStorage -> $page");

        /// AVG. SPEED
        tripAvgSpeedForStorage = Calculation()
            .calculateAvgSpeed(finalTripDistance, finalTripDuration);

        Utils.customPrint('TRIP DURATION: $tripDurationForStorage');
        Utils.customPrint('TRIP SPEED 1212: $tripSpeedForStorage');
        Utils.customPrint('AVG SPEED: $tripAvgSpeedForStorage');

        CustomLogger().logWithFile(Level.info, "TRIP DURATION: $tripDurationForStorage -> $page");
        CustomLogger().logWithFile(Level.info, "TRIP SPEED 1212: $tripSpeedForStorage -> $page");
        CustomLogger().logWithFile(Level.info, "AVG SPEED: $tripAvgSpeedForStorage -> $page");

        var num = double.parse(tripSpeedForStorage) < 0
            ? 0.0
            : double.parse(tripSpeedForStorage);

        Utils.customPrint('SPEED SPEED SPEED 666: $num');


        CustomLogger().logWithFile(Level.info, "SPEED SPEED SPEED 666: $num -> $page");

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

          CustomLogger().logWithFile(Level.info, "STOPPED WRITING -> $page");
          CustomLogger().logWithFile(Level.info, "CREATING NEW FILE -> $page");
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
    }).
    onError((err) {
      Utils.customPrint("PORT LISTEN ON ERROR ");
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
          ///
          if(Platform.isIOS)
            {
              await BackgroundLocator.updateNotificationText(
                  title: '',
                  msg: 'Trip is in progress',
                  bigMsg:
                  'Duration: $tripDuration        Distance: $tripDistanceForStorage $nauticalMile\nCurrent Speed: $tripSpeedForStorage $speedKnot'
                  //'Duration: $tripDuration        Distance: $tripDistanceForStorage $nauticalMile\nCurrent Speed: $tripSpeedForStorage $speedKnot    Avg Speed: $tripAvgSpeedForStorage $knot'
              ).catchError((onError){

                Utils.customPrint('UPDATE NOTI ERROR: $onError');
                CustomLogger().logWithFile(Level.error, "UPDATE NOTI ERROR: $onError -> $page");

              });
            }

          if(Platform.isAndroid)
          {
            flutterLocalNotificationsPlugin
                .show(
              1,
              'Trip is in progress',
              'Duration: $tripDuration        Distance: $tripDistanceForStorage $nauticalMile\nCurrent Speed: $tripSpeedForStorage $speedKnot',
              //'Duration: $tripDuration        Distance: $tripDistanceForStorage $nauticalMile\nCurrent Speed: $tripSpeedForStorage $speedKnot    Avg Speed: $tripAvgSpeedForStorage $knot',
              NotificationDetails(
                android: AndroidNotificationDetails(
                    'performarine_trip_$tripId-3', '$tripId-3',
                    channelDescription: 'Description',
                    importance: Importance.low,
                    playSound: false,
                    enableVibration: false,
                    priority: Priority.low),),
            )
                .catchError((onError) {

              Utils.customPrint('IOS NOTI ERROR: $onError');
              CustomLogger().logWithFile(Level.error, "IOS NOTI ERROR: $onError -> $page");

            });
          }

        });
  }

  checkGPS()
  {
    StreamSubscription<ServiceStatus> serviceStatusStream = Geolocator.getServiceStatusStream().listen(
            (ServiceStatus status) {
          print(status);

          if(status == ServiceStatus.disabled){

            Fluttertoast.showToast(
                msg: "Please enable GPS",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0
            );

            Future.delayed(Duration(seconds: 1), ()async{
              AppSettings.openAppSettings(type: AppSettingsType.location);

              if(!(await Geolocator.isLocationServiceEnabled()))
                {
                  checkGPS();
                }
            });
          }

        });
  }

}
