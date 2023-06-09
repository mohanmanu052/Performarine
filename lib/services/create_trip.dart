//import 'package:flutter_background_service/flutter_background_service.dart';

class CreateTrip {
  //FlutterBackgroundService service = FlutterBackgroundService();

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
}
