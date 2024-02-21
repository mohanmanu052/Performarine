class Urls {
  //Client Environment
  static const String baseUrl = 'goeapidev.azurewebsites.net';

 // static String baseUrl =  baseUrlVersion;


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

  // Delete Trip
  static const deleteTrip = '/api/getTripById';

  // Update User Info
  static const updateUserInfo = '/api/auth/updateUserInfo';
  //Create Fleet
static const creteNewFleet='/api/createfleet';
static const inViteFleetMembers='/api/addfleetmembers';
static const fleetList='/api/fleetLists';
static const addFleetVessels='/api/addfleetVessels';
static const fleetDashboardApi ='/api/fleetdashboard';
static const fleetMember ='/fleetmember';


  static String baseUrlVersion = '';

}
