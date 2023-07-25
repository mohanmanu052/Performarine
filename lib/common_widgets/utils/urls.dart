class Urls {


  static String baseUrl =  baseUrlVersion;

  //dev
   //static const String baseUrl = 'goeapidev.azurewebsites.net';

  //UAT
  //static const String baseUrl = 'goeapiuat.azurewebsites.net';
  //Client Environment
    //static const String baseUrl = 'performarineuat.azurewebsites.net';

  // Auth
  static const String registrationUrl = '/api/auth/signup';
  static const String loginUrl = '/api/auth/login';
  static const String forgotPassword = '/api/auth/forgot';
  static const String resetPassword = '/api/auth/reset';
  static const String changePassword = '/api/auth/change';

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
//  Privacy & terms
  static  String privacy="$baseUrl/privacy";
  static  String terms="$baseUrl/terms";

  //User feedback
  static const userFeedback = '/api/userFeedback';


  static String baseUrlVersion = '';



}
