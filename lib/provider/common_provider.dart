import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:performarine/main.dart';
import 'package:performarine/models/login_model.dart';
import 'package:performarine/models/registration_model.dart';
import 'package:performarine/provider/login_api_provider.dart';
import 'package:performarine/provider/registration_api_provider.dart';

class CommonProvider with ChangeNotifier {
  LoginModel? loginModel;
  RegistrationModel? registrationModel;

  init() {
    String? loginData = sharedPreferences!.getString('loginData');
    print('LOGIN DATA: $loginData');
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
}
