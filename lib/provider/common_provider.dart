import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:performarine/common_widgets/utils/utils.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/add_vessel_model.dart';
import 'package:performarine/models/common_model.dart';
import 'package:performarine/models/login_model.dart';
import 'package:performarine/models/registration_model.dart';
import 'package:performarine/models/send_sensor_model.dart';
import 'package:performarine/models/trip.dart';
import 'package:performarine/models/upload_trip_model.dart';
import 'package:performarine/models/vessel.dart';
import 'package:performarine/provider/add_vessel_api_provider.dart';
import 'package:performarine/provider/login_api_provider.dart';
import 'package:performarine/provider/registration_api_provider.dart';
import 'package:performarine/provider/send_sensor_info_api_provider.dart';
import 'package:performarine/services/database_service.dart';

class CommonProvider with ChangeNotifier {
  LoginModel? loginModel;
  RegistrationModel? registrationModel;
  CreateVessel? addVesselRequestModel;
  SendSensorDataModel? sendSensorDataModel;
  AddVesselModel? addVesselModel;
  CommonModel? commonModel;
  UploadTripModel? uploadTripModel;
  int tripsCount = 0;
  bool tripStatus = false;

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
      GlobalKey<ScaffoldState> scaffoldKey) async {
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
      GlobalKey<ScaffoldState> scaffoldKey) async {
    uploadTripModel = UploadTripModel();

    uploadTripModel = await SendSensorInfoApiProvider().sendSensorDataInfoDio(
        context,
        accessToken,
        sensorZipFiles,
        queryParameters,
        tripId,
        scaffoldKey);
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
}
