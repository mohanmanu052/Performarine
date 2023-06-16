import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'location_service_repository.dart';
import 'package:background_locator_2/location_dto.dart';

@pragma('vm:entry-point')
class LocationCallbackHandler {
  @pragma('vm:entry-point')
  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.init(params);
  }

  @pragma('vm:entry-point')
  static Future<void> disposeCallback() async {
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.dispose();
  }

  @pragma('vm:entry-point')
  static Future<void> callback(LocationDto locationDto) async {
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.callback(locationDto);
  }

  @pragma('vm:entry-point')
  static Future<void> notificationCallback() async {
    print('***notificationCallback');

    WidgetsFlutterBinding.ensureInitialized();
    var pref = await SharedPreferences.getInstance();
    pref.setBool('sp_key_called_from_noti', true);
    // bool? isTripStarted = pref.getBool('trip_started');
    // List<String>? tripData = pref.getStringList('trip_data');
    //
    // Get.to(TripAnalyticsScreen(
    //     tripId: tripData![0],
    //     vesselId: tripData[1],
    //     tripIsRunningOrNot: isTripStarted));

    debugPrint('APP RESTART 2');
  }
}
