import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/lpr_device_handler.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/add_vessel_model.dart';
import 'package:performarine/models/common_model.dart';
import 'package:performarine/models/create_fleet_response.dart';
import 'package:performarine/models/delete_trip_model.dart';
import 'package:performarine/models/export_report_model.dart';
import 'package:performarine/models/fleet_details_model.dart';
import 'package:performarine/models/fleet_list_model.dart';
import 'package:performarine/models/fleet_dashboard_model.dart';
import 'package:performarine/models/get_user_config_model.dart';
import 'package:performarine/models/login_model.dart';
import 'package:performarine/models/my_delegate_invite_model.dart';
import 'package:performarine/models/registration_model.dart';
import 'package:performarine/models/send_sensor_model.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/upload_trip_model.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/models/vessel_delegate_model.dart';
import 'package:performarine/provider/add_vessel_api_provider.dart';
import 'package:performarine/provider/change_password_provider.dart';
import 'package:performarine/provider/create_delegate_api_provider.dart';
import 'package:performarine/provider/create_newfleet_provider.dart';
import 'package:performarine/provider/delegate_provider.dart';
import 'package:performarine/provider/delete_fleet_api_provider.dart';
import 'package:performarine/provider/delete_trip_api_provider.dart';
import 'package:performarine/provider/edit_fleet_api_provider.dart';
import 'package:performarine/provider/fleet_assign_vessels_provider.dart';
import 'package:performarine/provider/fleet_details_api_provider.dart';
import 'package:performarine/provider/fleet_list_provider.dart';
import 'package:performarine/provider/fleet_dashboard_api_provider.dart';
import 'package:performarine/provider/fleet_member_invitation_api_provider.dart';
import 'package:performarine/provider/fleet_sendinvite_provider.dart';
import 'package:performarine/provider/get_user_config_api_provider.dart';
import 'package:performarine/provider/leave_fleet_api_provider.dart';
import 'package:performarine/provider/login_api_provider.dart';
import 'package:performarine/provider/manage_delegate_api_provider.dart';
import 'package:performarine/provider/my_delegate_invite_provider.dart';
import 'package:performarine/provider/registration_api_provider.dart';
import 'package:performarine/provider/remove_delegate_api_provider.dart';
import 'package:performarine/provider/remove_fleet_member.dart';
import 'package:performarine/provider/report_module_provider.dart';
import 'package:performarine/provider/reset_password_provider.dart';
import 'package:performarine/provider/send_sensor_info_api_provider.dart';
import 'package:performarine/provider/update_userinfo_api_provider.dart';
import 'package:performarine/provider/user_feedback_provider.dart';
import 'package:performarine/provider/vessel_delegate_api_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/change_password_model.dart';
import '../models/forgot_password_model.dart';
import '../models/reports_model.dart';
import '../models/reset_password_model.dart';
import '../models/trip_list_model.dart';
import '../models/user_feedback_model.dart';
import 'forgot_password_provider.dart';
import 'list_vessels_provider.dart';

class CommonProvider with ChangeNotifier {
  LoginModel? loginModel;
  RegistrationModel? registrationModel;
  CreateVessel? addVesselRequestModel;
  SendSensorDataModel? sendSensorDataModel;
  AddVesselModel? addVesselModel;
  CommonModel? commonModel;
  UploadTripModel? uploadTripModel;
  int tripsCount = 0;
  bool tripStatus = false,
      isTripUploading = false,
      exceptionOccurred = false,
      internetError = false, downloadTripData = false, onTripEndClicked = false;
  Future<List<Trip>>? getTripsByIdFuture;
  GetUserConfigModel? getUserConfigModel;
  ReportModel? reportModel;
  TripList? tripListModel;
  ForgotPasswordModel? forgotPasswordModel;
  ResetPasswordModel? resetPasswordModel;
  ChangePasswordModel? changePasswordModel;
  bool isBluetoothEnabled = false, isMyFleetNotEmpty = false;
  UserFeedbackModel? userFeedbackModel;
  DeleteTripModel? deleteTripModel;
  int bottomNavIndex = 0;
  List<File?> selectedImageFiles = [];
  CommonModel? userInfoCommonModel;
  FleetDashboardModel? fleetDashboardModel;
  CommonModel? fleetMemberModel;
  CommonModel? deleteFleetModel;
  CommonModel? editFleetDetailsModel;
  CommonModel? createDelegateModel;
  CommonModel? manageDelegateModel;
  CommonModel? removeFleetMemberModel;
  CommonModel? myDelegateInviteModel;
  FleetDetailsModel? fleetDetailsModel;
  VesselDelegateModel? vesselDelegateModel;
  CommonModel? removeDelegateModel;


  init()async {
    final storage = new FlutterSecureStorage();
    String? loginData = await storage.read(key: 'loginData');
    //String? loginData = sharedPreferences!.getString('loginData');
    //Utils.customPrint('LOGIN DATA: $loginData');
    if (loginData != null) {
      loginModel = LoginModel.fromJson(json.decode(loginData));
      // notifyListeners();
    }
  }


  Future<void>getToken()async{
    final storage = new FlutterSecureStorage();
    String? loginData = await storage.read(key: 'loginData');
    //String? loginData = sharedPreferences!.getString('loginData');
    //Utils.customPrint('LOGIN DATA: $loginData');
    if (loginData != null) {
      loginModel = LoginModel.fromJson(json.decode(loginData));
       notifyListeners();
    }
  }

  /// to check if bluetooth is enabled or not
  Future<dynamic> checkIfBluetoothIsEnabled(GlobalKey<ScaffoldState> scaffoldKey, VoidCallback showBluetoothDialog) async{

    BluetoothAdapterState adapterState = await FlutterBluePlus.adapterState.first;
    bool isBLEEnabled = adapterState == BluetoothAdapterState.on;
    // bool isBLEEnabled = await flutterBluePlus!.isOn;
    Utils.customPrint('isBLEEnabled: $isBLEEnabled');

    if(isBLEEnabled){
      bool isGranted = await Permission.bluetooth.isGranted;
      Utils.customPrint('isGranted: $isGranted');
      if(!isGranted){
        await Permission.bluetooth.request();
        bool isPermGranted = await Permission.bluetooth.isGranted;

        if(isPermGranted){

          // FlutterBluePlus _flutterBlue = FlutterBluePlus();
          BluetoothAdapterState adapterState = await FlutterBluePlus.adapterState.first;
          final isOn = adapterState == BluetoothAdapterState.on;
          if(isOn) isBluetoothEnabled =  true;

          await Future.delayed(const Duration(seconds: 1));
          BluetoothAdapterState tempAdapterState = await FlutterBluePlus.adapterState.first;
          isBluetoothEnabled = adapterState == BluetoothAdapterState.on;
          // isBluetoothEnabled = await FlutterBluePlus.isOn;
          notifyListeners();
          return isBluetoothEnabled;
        }
        else{
          Utils.showSnackBar(scaffoldKey.currentContext!,
              scaffoldKey: scaffoldKey,
              message:
              'Bluetooth permission is needed. Please enable bluetooth permission from app\'s settings.');

          Future.delayed(Duration(seconds: 3),
                  () async {
                await openAppSettings();
              });
          return null;
        }
      }
      else{

        // FlutterBluePlus _flutterBlue = FlutterBluePlus();
        BluetoothAdapterState adapterState = await FlutterBluePlus.adapterState.first;
        final isOn = adapterState == BluetoothAdapterState.on;
        // final isOn = await _flutterBlue.isOn;
        if(isOn) isBluetoothEnabled =  true;

        await Future.delayed(const Duration(seconds: 1));
        BluetoothAdapterState tempAdapterState = await FlutterBluePlus.adapterState.first;
        isBluetoothEnabled = tempAdapterState == BluetoothAdapterState.on;
        // isBluetoothEnabled = await FlutterBluePlus.instance.isOn;
        notifyListeners();
        return isBluetoothEnabled;
      }
    }
    else{
      bool isGranted = await Permission.bluetooth.isGranted;
      Utils.customPrint('isGranted: $isGranted');
      if(!isGranted){
        if(await Permission.bluetooth.isPermanentlyDenied){
          Utils.showSnackBar(scaffoldKey.currentContext!,
              scaffoldKey: scaffoldKey,
              message:
              'Bluetooth permission is needed. Please enable bluetooth permission from app\'s settings.');

          Future.delayed(Duration(seconds: 3),
                  () async {
                await openAppSettings();
              });
          return null;
        }
        else{
          await Permission.bluetooth.request();
        }
      }
      else{
        // FlutterBluePlus _flutterBlue = FlutterBluePlus();
        BluetoothAdapterState adapterState = await FlutterBluePlus.adapterState.first;
        final isOn = adapterState == BluetoothAdapterState.on;
        // final isOn = await _flutterBlue.isOn;
        if(isOn) isBluetoothEnabled =  true;

        await Future.delayed(const Duration(seconds: 1));
        BluetoothAdapterState tempAdapterState = await FlutterBluePlus.adapterState.first;
        isBluetoothEnabled = tempAdapterState == BluetoothAdapterState.on;
        // isBluetoothEnabled = await FlutterBluePlus.instance.isOn;
        notifyListeners();
        return isBluetoothEnabled;
      }
    }
  }

  /// Login
  Future<LoginModel> login(
    BuildContext context,
    String email,
    String password,
    bool isLoginWithGoogle,
    String socialLoginId,
    GlobalKey<ScaffoldState> scaffoldKey
  ) async {
    loginModel = LoginModel();

    loginModel = await LoginApiProvider().login(context, email, password,
        isLoginWithGoogle, socialLoginId, scaffoldKey);
    notifyListeners();

    return loginModel!;
  }

  /// Sign Up
  Future<RegistrationModel> registerUser(
    BuildContext context,
    String email,
    String password,
    String countryCode,
    String phoneNumber,
    String country,
    String zipcode,
    dynamic lat,
    dynamic long,
    bool isRegisterWithGoogle,
    String socialLoginId,
    String profileImage,
    GlobalKey<ScaffoldState> scaffoldKey,
    String? firstName,
      String? lastName
  ) async {
    registrationModel = RegistrationModel();

    registrationModel = await RegistrationApiProvider().registerUser(
        context,
        email,
        password,
        countryCode,
        phoneNumber,
        country,
        zipcode,
        lat,
        long,
        isRegisterWithGoogle,
        socialLoginId,
        profileImage,
        scaffoldKey,
    firstName, lastName);
    notifyListeners();

    return registrationModel!;
  }

  /// Add Vessel
  Future<AddVesselModel?> addVessel(
      BuildContext context,
      CreateVessel? addVesselRequestModel,
      String userId,
      String accessToken,
      GlobalKey<ScaffoldState> scaffoldKey,
      {bool calledFromSignOut = false}) async {
    addVesselModel = AddVesselModel();

    addVesselModel = await AddVesselApiProvider().addVesselData(
        context, addVesselRequestModel, userId, accessToken, scaffoldKey);
    notifyListeners();

    return addVesselModel;
  }

  /// Send Sensor data
  Future<UploadTripModel?> sendSensorInfo(
      BuildContext context,
      accessToken,
      File sensorZipFiles,
      Map<String, dynamic> queryParameters,
      String tripId,
      GlobalKey<ScaffoldState> scaffoldKey,
      {bool calledFromSignOut = false}) async {
    uploadTripModel = UploadTripModel();

    uploadTripModel = await SendSensorInfoApiProvider().sendSensorDataInfoDio(
        context,
        accessToken,
        sensorZipFiles,
        queryParameters,
        tripId,
        scaffoldKey,
        calledFromSignOut: calledFromSignOut);
    final DatabaseService _databaseService = DatabaseService();
    Utils.customPrint(
        'queryParameters["id"].toString(): ${queryParameters["id"].toString()}');
    if (uploadTripModel!.status!) {
      _databaseService.updateTripIsSyncStatus(1, queryParameters["id"]);
    }
    notifyListeners();

    return uploadTripModel;
  }

  /// To get trip count from local database
  getTripsCount() async {
    final DatabaseService _databaseService = DatabaseService();
    List<Trip> trips = await _databaseService.trips();

    tripsCount = trips.length;
    notifyListeners();
  }

  /// It will update trip status
  updateTripStatus(bool value) async {
    tripStatus = value;
    notifyListeners();
  }

  /// Get trips by vessel id
  Future<List<Trip>>? getTripsByVesselId(String? vesselId) {
    if (vesselId == null || vesselId == "") {
      getTripsByIdFuture = DatabaseService().trips();
    } else {
      getTripsByIdFuture =
          DatabaseService().getAllTripsByVesselId(vesselId.toString());
    }
    return getTripsByIdFuture!;
  }

  /// It will update trip uploading status
  updateTripUploadingStatus(bool value) {
    isTripUploading = value;
    notifyListeners();
  }

  /// It will update if there is any internet issue
  updateConnectionCloseStatus(bool value) {
    internetError = value;
    notifyListeners();
  }

  /// Get User data
  Future<GetUserConfigModel?> getUserConfigData(
      BuildContext context,
      String userId,
      String accessToken,
      GlobalKey<ScaffoldState> scaffoldKey) async {

    getUserConfigModel = GetUserConfigModel();

    getUserConfigModel = await GetUserConfigApiProvider()
        .getUserConfigData(context, userId, accessToken, scaffoldKey);
    notifyListeners();

    return getUserConfigModel;
  }

  /// If any exception occured it will update the status
  updateExceptionOccurredValue(bool value) {
    exceptionOccurred = value;
    notifyListeners();
  }

  /// Report
  Future<ReportModel?> getReportData(
      String startDate,
      String endDate,
      int? caseType,
      String? vesselID,
      String? token,
      List<String> selectedTripId,
      BuildContext context,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    reportModel = ReportModel();
    reportModel = await ReportModuleProvider().reportData(startDate, endDate,
        caseType, vesselID, token, selectedTripId, context, scaffoldKey);
    notifyListeners();
    return reportModel;
  }

Future<ExportDataModel> exportReportData(Map<String,dynamic>body,String token,BuildContext context,GlobalKey<ScaffoldState> scaffoldKey ) async{
  var data= await ReportModuleProvider().exportReportData(body, token, context, scaffoldKey);
  notifyListeners();
  return data;
}
  /// All Trip list
  Future<TripList> tripListData(
    String vesselID,
    BuildContext context,
    String accessToken,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) async {
    tripListModel = TripList();
    tripListModel = await TripListApiProvider()
        .tripListData(vesselID, context, accessToken, scaffoldKey);
    notifyListeners();
    return tripListModel!;
  }

  ///Reset password
  Future<ForgotPasswordModel> forgotPassword(
      BuildContext context,
      String email,
      GlobalKey<ScaffoldState> scaffoldKey,
      ) async {
    forgotPasswordModel = ForgotPasswordModel();

    forgotPasswordModel = await ForgotPasswordProvider().forgotPassword(context, email,scaffoldKey);
    notifyListeners();

    return forgotPasswordModel!;
  }


  ///Reset password
  Future<ResetPasswordModel> resetPassword(
      BuildContext context,
      String token,
      String password,
      GlobalKey<ScaffoldState> scaffoldKey,
      ) async {
    resetPasswordModel = ResetPasswordModel();

    resetPasswordModel = await ResetPasswordProvider().resetPassword(context,token, password, scaffoldKey);
    notifyListeners();

    return resetPasswordModel!;
  }

  ///change password
  Future<ChangePasswordModel> changePassword(
      BuildContext context,
      String token,
      String currentPassword,
      String newPassword,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    changePasswordModel = ChangePasswordModel();

    changePasswordModel = await ChangePasswordProvider().changePassword(context,token,currentPassword, newPassword,scaffoldKey);
    notifyListeners();

    return changePasswordModel!;
  }

  Future<UserFeedbackModel> sendUserFeedbackDio(
      BuildContext context,
      String token,
      String subject,
      String description,
      Map<String, dynamic> deviceInfo,
      List<File?> fileList,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    userFeedbackModel = UserFeedbackModel();
    userFeedbackModel = await UserFeedbackProvider().sendUserFeedbackDio(context,token, subject, description, deviceInfo, fileList, scaffoldKey);
    notifyListeners();

    return userFeedbackModel!;
  }

  Future<DeleteTripModel> deleteTrip(
      BuildContext context,
      String token,
      String tripId,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    deleteTripModel = DeleteTripModel();
    deleteTripModel = await DeleteTripApiProvider().deleteTrip(context, token, tripId, scaffoldKey);
    notifyListeners();

    return deleteTripModel!;
  }

  /// It will update trip uploading status
  downloadTripProgressBar(bool value) {
    downloadTripData = value;
    notifyListeners();
  }

  updateStateOfOnTripEndClick(bool value)
  {
    onTripEndClicked = value;
    notifyListeners();
  }

  Future<CommonModel> updateUserInfo(
      BuildContext context,
      String token,
      String firstName,
      String lastName,
      String userId,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    userInfoCommonModel = CommonModel();
    userInfoCommonModel = await UpdateUserInfoApiProvider().updateUserInfo(context, token, firstName, lastName, userId, scaffoldKey);
    notifyListeners();

    return userInfoCommonModel!;
  }

Future<CreateFleetResponse> createNewFleet(String token, BuildContext context,GlobalKey<ScaffoldState> scaffoldKey, Map<String,dynamic>? data, )async{
  var response =CreateNewFleetProvider().createFleet(token, scaffoldKey,context,  data!);
return response;
}

Future<CreateFleetResponse> sendFleetInvite(String token, BuildContext context,GlobalKey<ScaffoldState> scaffoldKey, Map<String,dynamic>? data)async{
  var response =SendInviteProvider ().sendFleetInvite(token: token,context: context,scaffoldKey: scaffoldKey,data: data);
return response;
}

Future<FleetListModel> getFleetListdata(
  {BuildContext? context,String? token,GlobalKey<ScaffoldState>? scaffoldKey}
)async{
  var response=await FleetListProvider().getFleetDetails(context: context,token: token,scaffoldKey: scaffoldKey);
return response;
}
Future<CommonModel> addFleetVessels( {BuildContext? context,String? token,GlobalKey<ScaffoldState>? scaffoldKey,Map<String,dynamic>? data})async{
var res=await FleetAssignVesselsProvider().addVesselAndGrantAccess(context: context,token: token,scaffoldKey: scaffoldKey,data: data);
return res;
}
  Future<FleetDashboardModel> fleetDashboardDetails(
      BuildContext context,
      String token,
      GlobalKey<ScaffoldState> scaffoldKey) async {

    isMyFleetNotEmpty = false;
    //notifyListeners();
    fleetDashboardModel = FleetDashboardModel();
    fleetDashboardModel = await FleetDashboardApiProvider().fleetDashboardData(context, token, scaffoldKey);

    if(fleetDashboardModel!.myFleets!.isNotEmpty)
      {
        debugPrint("IS LIST EMPTY ${fleetDashboardModel!.myFleets!.isNotEmpty}");
        isMyFleetNotEmpty = true;
        notifyListeners();
      }
    else
      {
        isMyFleetNotEmpty = false;
        notifyListeners();
      }


    return fleetDashboardModel!;
  }

  Future<CommonModel> fleetMemberInvitation(
      BuildContext context,
      String token,
      String invitationToken,
      String invitationFlag,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    commonModel = CommonModel();
    commonModel = await FleetMemberInvitationApiProvider().fleetMemberInvitation(context, token, invitationToken, invitationFlag, scaffoldKey);
    notifyListeners();

    return commonModel!;
  }

  Future<FleetDetailsModel> getFleetDetailsData(
      BuildContext context,
      String token,
      String fleetId,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    fleetDetailsModel = FleetDetailsModel();
    fleetDetailsModel = await FleetDetailsApiProvider().getFleetDetails(context, token, fleetId, scaffoldKey);
    notifyListeners();

    return fleetDetailsModel!;
  }

  Future<CommonModel> deleteFleet(
      BuildContext context,
      String token,
      String fleetId,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    deleteFleetModel = CommonModel();
    deleteFleetModel = await DeleteFleetApiProvider().deleteFleet(context, token, fleetId, scaffoldKey);
    notifyListeners();

    return deleteFleetModel!;
  }

  Future<CommonModel> leaveFleet(
      BuildContext context,
      String token,
      String fleetId,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    deleteFleetModel = CommonModel();
    deleteFleetModel = await LeaveFleetApiProvider().leaveFleet(context, token, fleetId, scaffoldKey);
    notifyListeners();

    return deleteFleetModel!;
  }

  Future<CommonModel> editFleetDetails(
      BuildContext context,
      String token,
      String fleetId,
      String fleetName,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    editFleetDetailsModel = CommonModel();
    editFleetDetailsModel = await EditFleetApiProvider().editFleetDetails(context, token, fleetId, fleetName, scaffoldKey);
    notifyListeners();

    return editFleetDetailsModel!;
  }


  Future<Response> acceptFleetInvitation(Uri url)async{
    var res=await FleetDashboardApiProvider().acceptfleetInvite(url);
    return res;
  }


  Future<CommonModel> createDelegate(
      BuildContext context,
      String token,
Map<String,dynamic> body,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    createDelegateModel = CommonModel();
    createDelegateModel = await CreateDelegateApiProvider().createDelegate(context, token, body, scaffoldKey);
    notifyListeners();

    return createDelegateModel!;
  }


Future<MyDelegateInviteModel> getDelegateInvites(BuildContext context,String accessToken,GlobalKey<ScaffoldState> scaffoldKey)async{
  var res=await MyDelegateInviteProvider().getDelegateInvites(context, accessToken, scaffoldKey);
  List<MyDelegateInvite> tempList = res.myDelegateInvities!.where((element) => element.status == 0 || element.status == 3).toList();
  res.myDelegateInvities!.clear();
  res.myDelegateInvities!.addAll(tempList);
  return res;
  
}

  Future<CommonModel> delegateAcceptReject(
      BuildContext context,String accessToken,GlobalKey<ScaffoldState> scaffoldKey,String flag,String verifyToken) async {
    myDelegateInviteModel = CommonModel();
    myDelegateInviteModel = await MyDelegateInviteProvider().delegateAcceptReject(context, accessToken, scaffoldKey, flag, verifyToken);
    notifyListeners();

    return myDelegateInviteModel!;
  }

Future<Response> acceptDelegateInvite(Uri uri)async{
  var res=DelegateProvider().acceptDelegateInvitation(uri);
  return res;

}

  Future<VesselDelegateModel> vesselDelegateData(
      BuildContext context, String accessToken, String vesselId, GlobalKey<ScaffoldState> scaffoldKey) async {
    vesselDelegateModel = VesselDelegateModel();
    vesselDelegateModel = await VesselDelegateApiProvider().vesselDelegateData(context, accessToken, vesselId, scaffoldKey);
    notifyListeners();

    return vesselDelegateModel!;
  }

  Future<CommonModel> removeDelegate(
      BuildContext context, String accessToken, String vesselId, delegateID, GlobalKey<ScaffoldState> scaffoldKey) async {
    removeDelegateModel = CommonModel();
    removeDelegateModel = await RemoveDelegateApiProvider().removeDelegate(context, accessToken, vesselId, delegateID, scaffoldKey);
    notifyListeners();

    return removeDelegateModel!;
  }

  Future<CommonModel> manageDelegate(
      BuildContext context,
      String token,
      Map<String,dynamic> body,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    manageDelegateModel = CommonModel();
    manageDelegateModel = await ManageDelegateApiProvider().manageDelegate(context, token, body, scaffoldKey);
    notifyListeners();

    return manageDelegateModel!;
  }

  Future<CommonModel> removeFleetMember(
      BuildContext context,
      String token,
      Map<String,dynamic> body,
      GlobalKey<ScaffoldState> scaffoldKey) async {
    removeFleetMemberModel = CommonModel();
    removeFleetMemberModel = await RemoveFleetMember().removeFleetMember(context, token, body, scaffoldKey);
    notifyListeners();

    return removeFleetMemberModel!;
  }

}
