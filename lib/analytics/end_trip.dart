import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/analytics/create_zip.dart';
import 'package:performarine/analytics/download_trip.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';
import 'package:performarine/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EndTrip {
  FlutterBackgroundService service = FlutterBackgroundService();

  endTrip(
      {BuildContext? context,
      GlobalKey<ScaffoldState>? scaffoldKey,
      VoidCallback? onEnded}) async {
    Utils.customPrint("END TRIP FUNCTIONALITY");

    String downloadedFilePath = '';
    await sharedPreferences!.reload();

    List<String>? tripData = sharedPreferences!.getStringList('trip_data');

    Utils.customPrint(
        'TIMER STOPPED 121212 ${sharedPreferences!.getStringList('trip_data')}');

    String tripId = tripData![0];
    String vesselId = tripData[1];

    String? tripDuration =
        sharedPreferences!.getString("tripDuration") ?? '00:00:00';
    String? tripDistance = sharedPreferences!.getString("tripDistance") ?? '1';
    String? tripSpeed = sharedPreferences!.getString("tripSpeed") ?? '1';
    String? tripAvgSpeed = sharedPreferences!.getString("tripAvgSpeed") ?? '1';

    service.invoke('stopService');

    if (positionStream != null) {
      positionStream!.cancel();
    }

    File file = await CreateZip().createZipFolder(context!, tripId);

    ///Download
    //  downloadTrip(context!, tripId);
    Utils.customPrint('FINAL ZIP FILE PATH: ${file.path}');

    sharedPreferences!.remove('trip_data');
    sharedPreferences!.remove('trip_started');
    Position? currentLocationData =
        await Utils.getLocationPermission(context, scaffoldKey!);

    await DatabaseService().updateTripStatus(
        1,
        file.path,
        DateTime.now().toUtc().toString(),
        [currentLocationData!.latitude, currentLocationData.longitude]
            .join(","),
        tripDuration,
        tripDistance,
        tripSpeed,
        tripAvgSpeed,
        tripId);

    await DatabaseService().updateVesselDataWithDurationSpeedDistance(
        tripDuration, tripDistance, tripSpeed, tripAvgSpeed, vesselId);

    await flutterLocalNotificationsPlugin.cancel(888);

    if (onEnded != null) onEnded.call();
  }
}
