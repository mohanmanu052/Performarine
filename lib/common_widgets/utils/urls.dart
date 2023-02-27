class Urls {
  static const String baseUrl = 'goeapidev.azurewebsites.net';

  // Auth
  static const String registrationUrl = '/api/auth/signup';
  static const String loginUrl = '/api/auth/login';

  // Vessel
  static const String vesselList = '/api/listVessels';
  static const String createVessel = '/api/createVessel';
  static const String getVesselById = '/api/getVesselById';
  static const String removeVessel = '/api/removeVessel';
  static const String editVessel = '/api/editVessel';

// Trip
  static const String createTrip = '/api/createTrip';
  static const String getTripById = '/api/getTripById';
  static const String GetTripList = '/api/listTrips';
  static const String SendSensorData = '/api/sendSensorInfo';

  // Sync Data
  static const String getUserConfig = '/api/auth/getUserConfigbyId';
}
