import 'dart:async';
import 'dart:io';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sensors/flutter_sensors.dart' as s;
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:performarine/analytics/calculation.dart';
import 'package:performarine/analytics/get_file.dart';
import 'package:performarine/common_widgets/utils/constants.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';
import 'package:performarine/services/create_trip.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartTrip {
  startTrip(ServiceInstance serviceInstance) async {
    Utils.customPrint('Background task is running');

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
          Utils.customPrint(event == null
              ? 'Unknown'
              : '${event.latitude.toString()}, ${event.longitude.toString()}');

          Utils.customPrint('SPEED SPEED ${event.speed}');
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

        /// DURATION 00:00:00
        String tripDurationForStorage =
            Utils.calculateTripDuration((finalTripDuration / 1000).toInt());

        /// DISTANCE
        finalTripDistance =
            finalTripDistance < tripDistance ? tripDistance : finalTripDistance;
        String tripDistanceForStorage =
            Calculation().calculateDistance(finalTripDistance);

        /// SPEED
        String tripSpeedForStorage = Calculation().calculateCurrentSpeed(speed);

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
          if (await serviceInstance.isForegroundService()) {
            flutterLocalNotificationsPlugin.show(
              888,
              '',
              'Trip is in progress',
              NotificationDetails(
                android: AndroidNotificationDetails(
                    notificationChannelId, 'MY FOREGROUND SERVICE',
                    icon: '@drawable/noti_logo',
                    ongoing: true,
                    /*styleInformation:
                        BigTextStyleInformation('', summaryText: '$tripId')*/
                    styleInformation: BigTextStyleInformation(
                        'Duration: $tripDurationForStorage        Distance: $tripDistanceForStorage $nauticalMile\nCurrent Speed: $tripSpeedForStorage $knot    Avg Speed: $tripAvgSpeedForStorage $knot',
                        htmlFormatContentTitle: true,
                        summaryText: '')),
              ),
            );

            pref.setString('tripDistance', tripDistanceForStorage);
            pref.setString('tripDuration', tripDurationForStorage);
            // To get values in Km/h
            pref.setString('tripSpeed', tripSpeedForStorage);
            pref.setString('tripAvgSpeed', tripAvgSpeedForStorage);

            String filePath = await GetFile().getFile(tripId, fileName);
            File file = File(filePath);
            int fileSize = await GetFile().checkFileSize(file);

            /// CHECK FOR ONLY 10 KB FOR Testing PURPOSE
            /// Now File Size is 200000
            if (fileSize >= 200000) {
              Utils.customPrint('STOPPED WRITING');
              Utils.customPrint('CREATING NEW FILE');
              // if (timer != null) timer.cancel();
              // Utils.customPrint('TIMER STOPPED');
              fileIndex = fileIndex + 1;
              fileName = '$fileIndex.csv';

              /// STOP WRITING & CREATE NEW FILE
            } else {
              Utils.customPrint('WRITING');
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

              String location = '$latitude $longitude';
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
    });
  }
}
