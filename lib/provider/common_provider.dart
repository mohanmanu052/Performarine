import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/add_vessel_model.dart';
import 'package:performarine/models/common_model.dart';
import 'package:performarine/models/get_user_config_model.dart';
import 'package:performarine/models/login_model.dart';
import 'package:performarine/models/registration_model.dart';
import 'package:performarine/models/send_sensor_model.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/upload_trip_model.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/provider/add_vessel_api_provider.dart';
import 'package:performarine/provider/change_password_provider.dart';
import 'package:performarine/provider/get_user_config_api_provider.dart';
import 'package:performarine/provider/login_api_provider.dart';
import 'package:performarine/provider/registration_api_provider.dart';
import 'package:performarine/provider/report_module_provider.dart';
import 'package:performarine/provider/reset_password_provider.dart';
import 'package:performarine/provider/send_sensor_info_api_provider.dart';
import 'package:performarine/services/database_service.dart';

import '../models/forgot_password_model.dart';
import '../models/reports_model.dart';
import '../models/trip_list_model.dart';
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
      internetError = false;
  Future<List<Trip>>? getTripsByIdFuture;
  GetUserConfigModel? getUserConfigModel;
  ReportModel? reportModel;
  TripList? tripListModel;
  ForgotPasswordModel? forgotPasswordModel;

  init() {
    String? loginData = sharedPreferences!.getString('loginData');
    Utils.customPrint('LOGIN DATA: $loginData');
    if (loginData != null) {
      loginModel = LoginModel.fromJson(json.decode(loginData));
      // notifyListeners();
    }
  }

  /// Login
  Future<LoginModel> login(
    BuildContext context,
    String email,
    String password,
    bool isLoginWithGoogle,
    String socialLoginId,
    GlobalKey<ScaffoldState> scaffoldKey,
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
        scaffoldKey);
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
  Future<ForgotPasswordModel> resetPassword(
      BuildContext context,
      String email,
      GlobalKey<ScaffoldState> scaffoldKey,
      ) async {
    forgotPasswordModel = ForgotPasswordModel();

    forgotPasswordModel = await ResetPasswordProvider().resetPassword(context, email,scaffoldKey);
    notifyListeners();

    return forgotPasswordModel!;
  }


  ///Change password
  Future<LoginModel> changePassword(
      BuildContext context,
      String password,
      GlobalKey<ScaffoldState> scaffoldKey,
      ) async {
    loginModel = LoginModel();

    loginModel = await ChangePasswordProvider().changePassword(context, password,scaffoldKey);
    notifyListeners();

    return loginModel!;
  }
}
