import 'dart:async';
import 'package:background_locator_2/location_dto.dart';
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'location_service_repository.dart';

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
    Utils.customPrint('***notificationCallback');
    WidgetsFlutterBinding.ensureInitialized();
    var pref = await SharedPreferences.getInstance();
    pref.setBool('sp_key_called_from_noti', true);
    Utils.customPrint('APP RESTART 2');
  }
}
