import 'package:flutter/services.dart';

class LocationMethodChannelPermission {
  static const _channel = MethodChannel('com.performarine/location_permission');

  static Future<String> requestLocationPermission() async {
    try {
      final String result = await _channel.invokeMethod('requestLocationPermission');
      return result;
    } on PlatformException catch (e) {
      print("Failed to request location permission: '${e.message}'.");
      return 'error';
    }
  }
}
