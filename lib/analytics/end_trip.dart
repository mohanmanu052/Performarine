import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/background_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:performarine/analytics/create_zip.dart';
import 'package:performarine/analytics/location_service_repository.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';
import 'package:performarine/services/database_service.dart';
import 'package:wakelock/wakelock.dart';
import 'package:geolocator/geolocator.dart' as geo;
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

    Utils.customPrint("END TRIP FUNCTIONALITY");
    CustomLogger().logWithFile(Level.info, "END TRIP FUNCTIONALITY -> -> $page");
    WidgetsFlutterBinding.ensureInitialized();
    await sharedPreferences!.reload();
    Utils.customPrint("abhi$duration,$IOSAvgSpeed,$IOSpeed,$IOStripDistance");
    CustomLogger().logWithFile(Level.info, "abhi$duration,$IOSAvgSpeed,$IOSpeed,$IOStripDistance -> $page");
    ReceivePort port = ReceivePort();
    String? latitude, longitude;
    geo.Position currentPosition = await geo.Geolocator.getCurrentPosition();
    var connectedDevicesList = FlutterBluePlus.connectedDevices;
    final FlutterSecureStorage storage = FlutterSecureStorage();
    Utils.customPrint('END TRIP CONNECTED DEVICE LIST: ${connectedDevicesList.length}');
    if(connectedDevicesList.isNotEmpty)
      {
        await storage.write(key: 'lprDeviceId', value: connectedDevicesList.first.remoteId.str);
        await connectedDevicesList.first.disconnect();
      }


    if(currentPosition != null)
    {
      latitude = currentPosition.latitude.toString();
      longitude = currentPosition.longitude.toString();
    }
    /*port.listen((dynamic data) async {
      LocationDto? locationDto =
          data != null ? await LocationDto.fromJson(data) : null;
      if (locationDto != null) {
        latitude = locationDto.latitude.toString();
        longitude = locationDto.longitude.toString();
      }
      ;
    });*/


    Utils.customPrint("endtrip location:$latitude");
    CustomLogger().logWithFile(Level.info, "endtrip location:$latitude -> $page");
    List<String>? tripData = sharedPreferences!.getStringList('trip_data');

    Utils.customPrint('TIMER STOPPED 121212 ${sharedPreferences!.getStringList('trip_data')}');
    CustomLogger().logWithFile(Level.info, "TIMER STOPPED 121212 ${sharedPreferences!.getStringList('trip_data')} -> $page");

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

    Utils.customPrint("END TRIP 1 $latitude");
    Utils.customPrint("END TRIP 2 $longitude");
    Utils.customPrint("END TRIP 3 $tripDistance");

    CustomLogger().logWithFile(Level.info, "END TRIP 1 $latitude -> $page");
    CustomLogger().logWithFile(Level.info, "END TRIP 2 $longitude -> $page");
    CustomLogger().logWithFile(Level.info, "END TRIP 3 $tripDistance -> $page");
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

    await flutterLocalNotificationsPlugin.cancel(889);
    await flutterLocalNotificationsPlugin.cancel(776);
    await flutterLocalNotificationsPlugin.cancel(1);

    if (onEnded != null) onEnded.call();
  }
}
