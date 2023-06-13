class CreateTrip {
  String convertDataToString(
      String type, List<double> sensorData, String tripId) {
    String? input = sensorData.toString();
    final removedBrackets = input.substring(1, input.length - 1);
    var replaceAll = removedBrackets.replaceAll(" ", "");
    var todayDate = DateTime.now().toUtc();
    return '$type,"${[replaceAll].toString()}",$todayDate,$tripId';
  }

  String convertLocationToString(
      String type, String sensorData, String tripId) {
    var todayDate = DateTime.now().toUtc();
    var gps = sensorData.toString().replaceAll(" ", ",");
    return '$type,"${[gps]}",$todayDate,$tripId';
  }
}
