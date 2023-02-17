import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';
import 'package:performarine/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sensors/flutter_sensors.dart' as s;

class CreateTrip {
  FlutterBackgroundService service = FlutterBackgroundService();

  Future<String> getOrCreateFolderForAddVessel() async {
    final appDirectory = await getApplicationDocumentsDirectory();
    Directory directory = Directory('${appDirectory.path}/vesselImages');
    debugPrint('FOLDER PATH $directory');
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if ((await directory.exists())) {
      return directory.path;
    } else {
      directory.create();
      return directory.path;
    }
  }

  String convertDataToString(
      String type, List<double> sensorData, String tripId) {
    String? input = sensorData.toString();
    final removedBrackets = input.substring(1, input.length - 1);
    var replaceAll = removedBrackets.replaceAll(" ", "");
    // var date = DateTime.now().toUtc();
    var todayDate = DateTime.now().toUtc();
    // return '$type,$replaceAll,$todayDate';
    return '$type,"${[replaceAll].toString()}",$todayDate,$tripId';
  }

  String convertLocationToString(
      String type, String sensorData, String tripId) {
    // var date = DateTime.now().toUtc();
    var todayDate = DateTime.now().toUtc();
    var gps = sensorData.toString().replaceAll(" ", ",");
    // return '$type,$gps,$todayDate';
    return '$type,"${[gps]}",$todayDate,$tripId';
  }

  Future<String> getOrCreateFolder(String tripId) async {
    Directory? ourDirectory;
    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}/$tripId');

    debugPrint('FOLDER PATH $ourDirectory');
    if ((await ourDirectory.exists())) {
      return ourDirectory.path;
    } else {
      ourDirectory.create();
      return ourDirectory.path;
    }
  }

  Future<String> getFile(String tripId, String fileName) async {
    String folderPath = await getOrCreateFolder(tripId);

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

  endTrip(
      {BuildContext? context,
      GlobalKey<ScaffoldState>? scaffoldKey,
      VoidCallback? onEnded}) async {
    await sharedPreferences!.reload();

    List<String>? tripData = sharedPreferences!.getStringList('trip_data');

    print(
        'TIMER STOPPED 121212 ${sharedPreferences!.getStringList('trip_data')}');

    String tripId = tripData![0];
    String vesselId = tripData[1];

    int? tripDuration = sharedPreferences!.getInt("tripDuration") ?? 1;
    String? tripDistance = sharedPreferences!.getString("tripDistance") ?? '1';
    String? tripSpeed = sharedPreferences!.getString("tripSpeed") ?? '1';
    String? tripAvgSpeed = sharedPreferences!.getString("tripAvgSpeed") ?? '1';

    String finalTripDuration =
        Utils.calculateTripDuration((tripDuration / 1000).toInt());
    String finalTripDistance = tripDistance;

    service.invoke('stopService');

    if (positionStream != null) {
      positionStream!.cancel();
    }

    final appDirectory = await getApplicationDocumentsDirectory();
    ourDirectory = Directory('${appDirectory.path}');

    File? zipFile;
    if (timer != null) timer!.cancel();
    print('TIMER STOPPED ${ourDirectory!.path}/$tripId');
    final dataDir = Directory('${ourDirectory!.path}/$tripId');

    try {
      zipFile = File('${ourDirectory!.path}/$tripId.zip');

      ZipFile.createFromDirectory(
              sourceDir: dataDir, zipFile: zipFile, recurseSubDirs: true)
          .then((value) {
        downloadTrip(context!, tripId);
      });
      print('our path is $dataDir');
    } catch (e) {
      print(e);
    }

    File file = File(zipFile!.path);

    ///Download
    //  downloadTrip(context!, tripId);
    var pref = await SharedPreferences.getInstance();
    print('FINAL PATH: ${file.path}');
    print('FINAL PATH: ${pref.getInt("tripDuration")}');

    sharedPreferences!.remove('trip_data');
    sharedPreferences!.remove('trip_started');
    Position? currentLocationData =
        await Utils.getLocationPermission(context!, scaffoldKey!);
    await DatabaseService().updateTripStatus(
        1,
        file.path,
        DateTime.now().toUtc().toString(),
        [currentLocationData!.latitude, currentLocationData.longitude]
            .join(","),
        finalTripDuration,
        finalTripDistance,
        tripSpeed.toString(),
        tripAvgSpeed,
        tripId);

    await DatabaseService().updateVesselDataWithDurationSpeedDistance(
        finalTripDuration,
        finalTripDistance,
        tripSpeed.toString(),
        tripAvgSpeed,
        vesselId);

    await flutterLocalNotificationsPlugin.cancel(888);

    if (onEnded != null) onEnded.call();
  }

  startTrip(ServiceInstance serviceInstance) async {
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
    bool userAccelerometerAvailable = await s.SensorManager()
        .isSensorAvailable(s.Sensors.LINEAR_ACCELERATION);

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
      serviceInstance.on('setAsForeground').listen((event) async {
        serviceInstance.setAsForegroundService();
        // bool vaslue = await serviceInstance.isForegroundService();
        // print('IS FOREGROUND SERVICE: $vaslue');
        // serviceInstance.setForegroundNotificationInfo(
        //     title: 'PerforMarine',
        //     content: 'PerforMarine consuming background services.');
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
      double finalTripDistance = 0;
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

        finalTripDistance =
            finalTripDistance < tripDistance ? tripDistance : finalTripDistance;

        finalTripSpeed = (speed * 2.237);

        finalTripAvgSpeed =
            (((finalTripDistance / 1852) / (finalTripDuration / 1000)) * 1.944);

        print(
            'TRIP DISTANCE: ${(finalTripDistance / 1852).toStringAsFixed(2)}');
        print('TRIP DURATION: $finalTripDuration');
        print('TRIP SPEED 1212: $finalTripSpeed');
        print('AVG SPEED: ${finalTripAvgSpeed.toStringAsFixed(2)}');

        debugPrint('AVG SPEED 12 ${finalTripAvgSpeed.toStringAsFixed(2)}');

        if (finalTripAvgSpeed.isNaN) {
          finalTripAvgSpeed = 0.0;
        }

        serviceInstance.invoke('tripAnalyticsData', {
          "tripDistance":
              (finalTripDistance / 1852).toDouble().toStringAsFixed(2),
          "tripDuration": finalTripDuration,
          "tripSpeed": finalTripSpeed.toStringAsFixed(1),
          "tripAvgSpeed": finalTripAvgSpeed.toStringAsFixed(1)
        });

        if (serviceInstance is AndroidServiceInstance) {
          if (await serviceInstance.isForegroundService()) {
            flutterLocalNotificationsPlugin.show(
              888,
              '',
              'Trip is in progress',
              // '$vesselName',
              // 'Dist: ${(finalTripDistance / 1852).toStringAsFixed(2)}nm, Duration: ${Utils.calculateTripDuration((finalTripDuration / 1000).toInt())}hr, Speed: ${finalTripSpeed.toStringAsFixed(2)}m/h',
              /*'Trip data collection is in progress...',*/
              NotificationDetails(
                android: AndroidNotificationDetails(
                    notificationChannelId, 'MY FOREGROUND SERVICE',
                    icon: '@drawable/logo',
                    ongoing: true,
                    /*styleInformation:
                        BigTextStyleInformation('', summaryText: '$tripId')*/
                    styleInformation: BigTextStyleInformation(
                        'Duration: ${Utils.calculateTripDuration((finalTripDuration / 1000).toInt())}    Distance: ${(finalTripDistance / 1852).toStringAsFixed(2)} nm\nSpeed: ${finalTripSpeed.toStringAsFixed(1)} m/h        Avg Speed: ${(finalTripAvgSpeed).toStringAsFixed(1)} nm',
                        htmlFormatContentTitle: true,
                        summaryText: '$tripId')),
              ),
            );

            pref.setString(
                'tripDistance', (finalTripDistance / 1852).toStringAsFixed(2));
            pref.setInt('tripDuration', finalTripDuration);
            // To get values in Km/h
            pref.setString('tripSpeed', finalTripSpeed.toStringAsFixed(1));
            pref.setString(
                'tripAvgSpeed', finalTripAvgSpeed.toStringAsFixed(1));

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

  downloadTrip(BuildContext context, String tripId) async {
    debugPrint('DOWLOAD Started!!!');

    final androidInfo = await DeviceInfoPlugin().androidInfo;

    var isStoragePermitted;
    if (androidInfo.version.sdkInt < 29) {
      isStoragePermitted = await Permission.storage.status;

      if (isStoragePermitted.isGranted) {
        //File copiedFile = File('${ourDirectory!.path}.zip');
        File copiedFile = File('${ourDirectory!.path}/${tripId}.zip');

        print('DIR PATH R ${ourDirectory!.path}');

        Directory directory;

        if (Platform.isAndroid) {
          directory = Directory("storage/emulated/0/Download/${tripId}.zip");
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        copiedFile.copy(directory.path);

        print('DOES FILE EXIST: ${copiedFile.existsSync()}');

        if (copiedFile.existsSync()) {
          print('DOES FILE EXIST: ${copiedFile.existsSync()}');
        }
      } else {
        await Utils.getStoragePermission(context);
        var isStoragePermitted = await Permission.storage.status;

        if (isStoragePermitted.isGranted) {
          File copiedFile = File('${ourDirectory!.path}.zip');

          Directory directory;

          if (Platform.isAndroid) {
            directory = Directory("storage/emulated/0/Download/${tripId}.zip");
          } else {
            directory = await getApplicationDocumentsDirectory();
          }

          copiedFile.copy(directory.path);

          print('DOES FILE EXIST: ${copiedFile.existsSync()}');

          if (copiedFile.existsSync()) {
            print('DOES FILE EXIST: ${copiedFile.existsSync()}');
          }
        }
      }
    } else {
      //File copiedFile = File('${ourDirectory!.path}.zip');
      File copiedFile = File('${ourDirectory!.path}/${tripId}.zip');

      print('DIR PATH RT ${copiedFile.path}');
      print('DIR PATH RT ${copiedFile.existsSync()}');

      Directory directory;

      if (Platform.isAndroid) {
        directory = Directory("storage/emulated/0/Download/${tripId}.zip");
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      copiedFile.copy(directory.path);

      print('DOES FILE EXIST: ${copiedFile.existsSync()}');

      if (copiedFile.existsSync()) {
        print('DOES FILE EXIST: ${copiedFile.existsSync()}');
      }
    }
  }
}
