class Urls {
  //dev
  static const String baseUrl = 'goeapidev.azurewebsites.net';
  //UAT
  //static const String baseUrl = 'goeapiuat.azurewebsites.net';

  // Auth
  static const String registrationUrl = '/api/auth/signup';
  static const String loginUrl = '/api/auth/login';

  // Vessel
  static const String createVessel = '/api/createVessel';
  static const String editVessel = '/api/editVessel';

// Trip
  static const String GetTripList = '/api/listTrips';
  static const String SendSensorData = '/api/sendSensorInfo';

  // Sync Data
  static const String getUserConfig = '/api/auth/getUserConfigbyId';

  // Reports module
  static const String reportModule = '/api/reports';
}
