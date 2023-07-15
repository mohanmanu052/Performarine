import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:performarine/analytics/create_zip.dart';
import 'package:performarine/analytics/location_service_repository.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';
import 'package:performarine/services/database_service.dart';
import 'package:wakelock/wakelock.dart';

import '../common_widgets/widgets/log_level.dart';

class EndTrip {
  String page = "End_trip";
  endTrip({
    BuildContext? context,
    GlobalKey<ScaffoldState>? scaffoldKey,
    VoidCallback? onEnded,
    String duration = "",
    IOStripDistance = "",
    IOSpeed = "",
    IOSAvgSpeed = "",
  }) async {

    getDirectoryForDebugLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileD!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggD = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );

    getDirectoryForErrorLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileE!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggE = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );

    getDirectoryForInfoLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileI!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggI = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );

    getDirectoryForVerboseLogRecord().whenComplete(
          () {
        FileOutput fileOutPut = FileOutput(file: fileV!);
        // ConsoleOutput consoleOutput = ConsoleOutput();
        LogOutput multiOutput = fileOutPut;
        loggV = Logger(
            filter: DevelopmentFilter(),
            printer: PrettyPrinter(
              methodCount: 0,
              errorMethodCount: 3,
              lineLength: 70,
              colors: true,
              printEmojis: false,
              //printTime: true
            ),
            output: multiOutput // Use the default LogOutput (-> send everything to console)
        );
      },
    );

    Utils.customPrint("END TRIP FUNCTIONALITY");
    loggD.d("END TRIP FUNCTIONALITY -> $page ${DateTime.now()}");
    loggV.v("END TRIP FUNCTIONALITY -> $page ${DateTime.now()}");
    WidgetsFlutterBinding.ensureInitialized();
    await sharedPreferences!.reload();
    debugPrint("abhi$duration,$IOSAvgSpeed,$IOSpeed,$IOStripDistance");
    loggD.d("abhi$duration,$IOSAvgSpeed,$IOSpeed,$IOStripDistance -> $page ${DateTime.now()}");
    loggV.v("abhi$duration,$IOSAvgSpeed,$IOSpeed,$IOStripDistance -> $page ${DateTime.now()}");
    loggI.i("abhi$duration,$IOSAvgSpeed,$IOSpeed,$IOStripDistance -> $page ${DateTime.now()}");
    ReceivePort port = ReceivePort();
    String? latitude, longitude;
    port.listen((dynamic data) async {
      LocationDto? locationDto =
          data != null ? await LocationDto.fromJson(data) : null;
      if (locationDto != null) {
        latitude = locationDto.latitude.toString();
        longitude = locationDto.longitude.toString();
      }
      ;
    });

    debugPrint("endtrip location:$latitude");
    loggD.d("endtrip location:$latitude -> $page ${DateTime.now()}");
    loggV.v("endtrip location:$latitude -> $page ${DateTime.now()}");
    List<String>? tripData = sharedPreferences!.getStringList('trip_data');

    Utils.customPrint('TIMER STOPPED 121212 ${sharedPreferences!.getStringList('trip_data')}');
    loggD.d('TIMER STOPPED 121212 ${sharedPreferences!.getStringList('trip_data')} -> $page ${DateTime.now()}');
    loggV.v('TIMER STOPPED 121212 ${sharedPreferences!.getStringList('trip_data')} -> $page ${DateTime.now()}');

    String tripId = tripData![0];
    String vesselId = tripData[1];
    String? tripDuration;
    String tripDistance;
    String tripSpeed;
    String tripAvgSpeed;

    if (Platform.isAndroid) {
      tripDuration = duration;
      tripDistance = sharedPreferences!.getString("tripDistance") ?? '1';
      tripSpeed = sharedPreferences!.getString("tripSpeed") ?? '0.1';
      tripAvgSpeed = sharedPreferences!.getString("tripAvgSpeed") ?? '0.1';
    } else {
      tripDuration = duration;
      tripDistance = sharedPreferences!.getString("tripDistance") ?? '0';
      tripSpeed = sharedPreferences!.getString("tripSpeed") ?? '0.1';
      tripAvgSpeed = sharedPreferences!.getString("tripAvgSpeed") ?? '0.1';
    }

    await BackgroundLocator.unRegisterLocationUpdate();
    IsolateNameServer.removePortNameMapping(
        LocationServiceRepository.isolateName);

    if (tripDurationTimer != null) {
      tripDurationTimer!.cancel();
    }

    File file = await CreateZip().createZipFolder(context!, tripId);

    sharedPreferences!.remove('trip_data');
    sharedPreferences!.remove('trip_started');
    sharedPreferences!.remove('tripDuration');
    sharedPreferences!.remove('tripDistance');
    sharedPreferences!.remove('tripSpeed');
    sharedPreferences!.remove('tripAvgSpeed');
    sharedPreferences!.remove('current_loc_list');
    sharedPreferences!.remove('temp_trip_dist');

    debugPrint("END TRIP 1 $latitude");
    debugPrint("END TRIP 2 $longitude");
    debugPrint("END TRIP 3 $tripDistance");

    loggD.d("END TRIP 1 $latitude -> $page ${DateTime.now()}");
    loggD.d("END TRIP 2 $longitude -> $page ${DateTime.now()}");
    loggD.d("END TRIP 3 $tripDistance -> $page ${DateTime.now()}");
    loggV.v("END TRIP 1 $latitude -> $page ${DateTime.now()}");
    loggV.v("END TRIP 2 $longitude -> $page ${DateTime.now()}");
    loggV.v("END TRIP 3 $tripDistance -> $page ${DateTime.now()}");
    await DatabaseService().updateTripStatus(
        1,
        file.path,
        DateTime.now().toUtc().toString(),
        [latitude, longitude].join(","),
        tripDuration,
        tripDistance,
        tripSpeed,
        tripAvgSpeed,
        tripId);

    await DatabaseService().updateVesselDataWithDurationSpeedDistance(
        tripDuration, tripDistance, tripSpeed, tripAvgSpeed, vesselId);

    Wakelock.disable();

    //await flutterLocalNotificationsPlugin.cancel(888);
    await flutterLocalNotificationsPlugin.cancel(889);
    await flutterLocalNotificationsPlugin.cancel(776);
    await flutterLocalNotificationsPlugin.cancel(1);

    if (onEnded != null) onEnded.call();
  }
}
