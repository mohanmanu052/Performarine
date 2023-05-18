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
import 'package:performarine/provider/get_user_config_api_provider.dart';
import 'package:performarine/provider/login_api_provider.dart';
import 'package:performarine/provider/registration_api_provider.dart';
import 'package:performarine/provider/report_module_provider.dart';
import 'package:performarine/provider/send_sensor_info_api_provider.dart';
import 'package:performarine/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

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

  init() {
    String? loginData = sharedPreferences!.getString('loginData');
    Utils.customPrint('LOGIN DATA: $loginData');
    if (loginData != null) {
      loginModel = LoginModel.fromJson(json.decode(loginData));
      // notifyListeners();
    }
  }

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

  getTripsCount() async {
    final DatabaseService _databaseService = DatabaseService();
    List<Trip> trips = await _databaseService.trips();

    tripsCount = trips.length;
    notifyListeners();
    // return tripsCount.toString();
  }

  updateTripStatus(bool value) async {
    tripStatus = value;
    notifyListeners();
  }

  Future<List<Trip>>? getTripsByVesselId(String? vesselId) {
    if (vesselId == null || vesselId == "") {
      getTripsByIdFuture = DatabaseService().trips();
    } else {
      getTripsByIdFuture =
          DatabaseService().getAllTripsByVesselId(vesselId.toString());
    }
    return getTripsByIdFuture!;
  }

  updateTripUploadingStatus(bool value) {
    isTripUploading = value;
    notifyListeners();
  }

  updateConnectionCloseStatus(bool value) {
    internetError = value;
    notifyListeners();
  }

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

  updateExceptionOccurredValue(bool value) {
    exceptionOccurred = value;
    notifyListeners();
  }

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
}
