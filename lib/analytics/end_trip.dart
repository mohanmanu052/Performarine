import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:flutter/material.dart';
import 'package:performarine/analytics/create_zip.dart';
import 'package:performarine/analytics/location_service_repository.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';
import 'package:performarine/services/database_service.dart';

class EndTrip {
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
    WidgetsFlutterBinding.ensureInitialized();
    await sharedPreferences!.reload();
    debugPrint("abhi$duration,$IOSAvgSpeed,$IOSpeed,$IOStripDistance");
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
    List<String>? tripData = sharedPreferences!.getStringList('trip_data');

    Utils.customPrint(
        'TIMER STOPPED 121212 ${sharedPreferences!.getStringList('trip_data')}');

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

    //await flutterLocalNotificationsPlugin.cancel(888);
    await flutterLocalNotificationsPlugin.cancel(889);

    if (onEnded != null) onEnded.call();
  }
}
