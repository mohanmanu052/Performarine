import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as perm;

abstract class IUserCurrentLocation {
  Future<dynamic> startTracking(BuildContext context);
  Future<dynamic> stopTracking();
}

class LocationServices implements IUserCurrentLocation {
  late LocationSettings locationSettings;

  final List<List<dynamic>> csvData = [];
  //Location location = Location();
  Timer? timer;

  checkGPS(BuildContext context) {
    StreamSubscription<ServiceStatus> serviceStatusStream =
    Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      print(status);

      if (status == ServiceStatus.disabled) {
        Fluttertoast.showToast(
            msg: "Please enable GPS",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);

        Future.delayed(Duration(seconds: 1), () async {
          AppSettings.openAppSettings(type: AppSettingsType.location);

          if (!(await Geolocator.isLocationServiceEnabled())) {
            checkGPS(context);
          } else {
            getUserCurrentLocation(context);
          }
        });
      }
      else{
        Future.delayed(Duration(seconds: 2), () {
          getUserCurrentLocation(context);
        });

      }
    });
  }

  Future<Position> getUserCurrentLocation(BuildContext context) async {
    // TODO: implement getUserCurrentLocation
    bool serviceEnabled;
    LocationPermission permission;
    //Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.

      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      // if(Platform.isIOS){
      if (permission != LocationPermission.always) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Please allow always location tracking permission')));
        //  Geolocator.openLocationSettings();
        perm.openAppSettings();

        // }
      }

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    var postion = await Geolocator.getCurrentPosition();

    return postion;
  }

  Future<dynamic>? getUserLocationOnTimeInterVal() async {
    // await initBackgroundLocator();
    // await _startLocator();
    // final _isRunning = await BackgroundLocator.isServiceRunning();

    timer = Timer.periodic(Duration(seconds: 1), (Timer timer) async {
      var postion = await Geolocator.getCurrentPosition();
      csvData.add([postion.latitude, postion.longitude]);
      writeToCsv();
    });
  }

  Future<void> writeToCsv() async {
    final List<List<dynamic>> rows = [];
    for (final row in csvData) {
      rows.add(row);
    }
  }

  @override
  Future startTracking(BuildContext context) async {
    // await getUserCurrentLocation();
    getUserLocationOnTimeInterVal();
    // TODO: implement startTracking
  }

  @override
  Future stopTracking() async {
    print('coming to cancel----');
    timer?.cancel();
    // TODO: implement stopTracking
  }
}
