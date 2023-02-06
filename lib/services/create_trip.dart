import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';
import 'package:performarine/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    int? tripDistance = sharedPreferences!.getInt("tripDistance") ?? 1;
    String? tripSpeed = sharedPreferences!.getString("tripSpeed") ?? '1';

    String finalTripDuration =
        Utils.calculateTripDuration((tripDuration / 1000).toInt());
    String finalTripDistance = tripDistance.toStringAsFixed(2);

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
          sourceDir: dataDir, zipFile: zipFile, recurseSubDirs: true);
      print('our path is $dataDir');
    } catch (e) {
      print(e);
    }

    File file = File(zipFile!.path);

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
        json.encode(
            [currentLocationData!.latitude, currentLocationData.longitude]),
        finalTripDuration,
        finalTripDistance,
        tripSpeed.toString(),
        tripId);

    await DatabaseService().updateVesselDataWithDurationSpeedDistance(
        finalTripDuration, finalTripDistance, tripSpeed.toString(), vesselId);

    if (onEnded != null) onEnded.call();
  }
}
